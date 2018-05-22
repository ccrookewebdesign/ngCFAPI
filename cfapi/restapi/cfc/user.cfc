component hint = 'user rest functions' displayname = 'user' {

	public struct function getUser(required numeric userid) 
		hint = 'Get user details' {
	  
		var resObj = {};
    returnArray = ArrayNew(1);

		qryGetUser = new Query(datasource = request.dsn);    
    
    qryGetUser.setSQL('
      SELECT *
      FROM users u
      WHERE u.userid = :userid
    ');
    
    qryGetUser.addParam(
			name = 'userid', value = trim(arguments.userid), cfsqltype = 'cf_sql_integer');

    qryGetUser = qryGetUser.execute().getResult();
    		
		if (!qryGetUser.recordcount) {
          
			resObj['success'] = false;
      resObj['message'] = 'Incorrect user id provided.';
				
		} else {
			
			userStruct = StructNew();
			userStruct['userid'] = userid;
			userStruct['firstname'] = qryGetUser.firstname;
			userStruct['lastname'] = qryGetUser.lastname;
			userStruct['username'] = qryGetUser.username;
			userStruct['email'] = qryGetUser.email;
			userStruct['password'] = qryGetUser.password_nohash;
			userStruct['lastlogin'] = qryGetUser.lastlogin;
    				
			resObj['success'] = true;
			resObj['message'] = Hash(qryGetUser.salt & qryGetUser.password_nohash);
			resObj['data'] = SerializeJSON(userStruct);

		}

		return resObj;

	}

	public struct function getUsers() 
		hint = 'Get user details' {
	  
		var resObj = {};
    returnArray = ArrayNew(1);

		qryGetUser = new Query(datasource = request.dsn);    
    
    qryGetUser.setSQL('
      SELECT *
      FROM users u
      ORDER BY u.lastname desc
    ');
    
    qryGetUser = qryGetUser.execute().getResult();
    		
		if (!qryGetUser.recordcount) {
          
			resObj['success'] = false;
      resObj['message'] = 'No users found.';
				
		} else {
			
			for (user in qryGetUser) {
			
				userStruct = StructNew();
				userStruct['userid'] = user.userid;
				userStruct['firstname'] = user.firstname;
				userStruct['lastname'] = user.lastname;
				userStruct['username'] = user.username;
				userStruct['email'] = user.email;
				userStruct['password'] = user.password_nohash;
				userStruct['lastlogin'] = user.lastlogin;
    		
				ArrayAppend(returnArray, userStruct);
			
			}			

			resObj['success'] = true;
			resObj['message'] = Hash(qryGetUser.salt & qryGetUser.password_nohash);
			resObj['data'] = SerializeJSON(returnArray);

		}

		return resObj;

	}

	public struct function loginUser(required any structform)  
		hint = 'Login User' {

		var resObj = {};

		qryLoginUser = new Query(datasource = request.dsn);    

		qryLoginUser.setSQL('
			SELECT *
			FROM users u
			WHERE u.username = :username
				AND u.password_nohash = :password_nohash
		');
		
		qryLoginUser.addParam(
			name = 'username', value = trim(structform.username), cfsqltype = 'cf_sql_varchar');
		qryLoginUser.addParam(
			name = 'password_nohash', value = trim(structform.password), cfsqltype = 'cf_sql_varchar');

		qryLoginUser = qryLoginUser.execute().getResult();	
	
		if (qryLoginUser.recordcount and (Hash(qryLoginUser.salt & structform.password) eq qryLoginUser.password)) {
		
			qryUpdateLoginDate = new Query(datasource = request.dsn);    

			qryUpdateLoginDate.setSQL('
				UPDATE users
				SET lastlogin = :lastlogin 
				WHERE username = :username
			');
									
			qryUpdateLoginDate.addParam(
				name = 'lastlogin', value = trim(now()), cfsqltype = 'cf_sql_timestamp');
			qryUpdateLoginDate.addParam(
				name = 'username', value = trim(structform.username), cfsqltype = 'cf_sql_varchar');

			qryUpdateLoginDate.execute();
			
			expdt =  dateAdd('n', 30, now());
			utcDate = dateDiff('s', dateConvert('utc2Local', createDateTime(1970, 1, 1, 0, 0, 0)), expdt);

			jwt = new jwt(Application.jwtkey);
			payload = {
				'ts' = now(),
				'userid' = qryLoginUser.userid,
				'Exp' = utcDate
			};
			token = jwt.encode(payload);
			
			resObj['success'] = true;
			resObj['message'] = Hash(qryLoginUser.salt & structform.password);
			resObj['data'] = {
				'userid': qryLoginUser.userid, 
				'username': qryLoginUser.username, 
				'firstName': qryLoginUser.firstname, 
				'lastName': qryLoginUser.lastname,
				'password': qryLoginUser.password_nohash,
				'email': qryLoginUser.email, 
				'lastlogin': dateTimeFormat(qryLoginUser.lastlogin, 'dd-MMM-yyyy hh:nn:ss tt')
			};
			resObj['token'] = token;
		
		} else {

			resObj['success'] = false;
			//resObj['message'] = 'Incorrect login credentials.';
			resObj['message'] = Hash(qryLoginUser.salt & structform.password) & ' hereh: ' & trim(qryLoginUser.password);
		}
        
 		return resObj;

	}

	public struct function insertUser(required any structform) 
		hint = 'Register User' {
	
		var resObj = {};
    qryCheckUser = new Query(datasource = request.dsn);    

		qryCheckUser.setSQL('
			SELECT *
			FROM users u
			WHERE u.username = :username
		');
				
		qryCheckUser.addParam(
			name = 'username', value = trim(structform.username), cfsqltype = 'cf_sql_varchar');

		qryCheckUser = qryCheckUser.execute().getResult();	

		if (qryCheckUser.recordcount) {
    
		  resObj['success'] = false;
			resObj['message'] = 'Username already exists.';
    
		} else {
            
			Salt="";

			for (i = 1; i <= 12; i = i + 1) {
				Salt = Salt & chr(RandRange(65,90));
			}
            
      hashpwd = Hash(Salt & structform.password);	

			qryInsertUser = new Query(datasource = request.dsn);    

			qryInsertUser.setSQL('
				INSERT INTO users (
					userid,
					firstname,
					lastname,
					email,
					username,
					lastlogin,
					password,
					password_nohash,
					salt
				) VALUES (
					:userid,
					:firstname,
					:lastname,
					:email,
					:username,
					:lastlogin,
					:password,
					:password_nohash,
					:salt
				)
			');

			newID = '#randrange(10,99)##randrange(40,70)##randrange(10,20)#';

			qryInsertUser.addParam(
				name = 'userid', value = newID, cfsqltype = 'cf_sql_integer');
			qryInsertUser.addParam(
				name = 'firstname', value = trim(structform.firstname), cfsqltype = 'cf_sql_varchar');
			qryInsertUser.addParam(
				name = 'lastname', value = trim(structform.lastname), cfsqltype = 'cf_sql_varchar');
			qryInsertUser.addParam(
				name = 'email', value = trim(structform.email), cfsqltype = 'cf_sql_varchar');
			qryInsertUser.addParam(
				name = 'username', value = trim(structform.username), cfsqltype = 'cf_sql_varchar');
			qryInsertUser.addParam(
				name = 'lastlogin', value = trim(now()), cfsqltype = 'cf_sql_timestamp');
			qryInsertUser.addParam(
				name = 'password', value = trim(hashpwd), cfsqltype = 'cf_sql_varchar');
			qryInsertUser.addParam(
				name = 'password_nohash', value = trim(structform.password), cfsqltype = 'cf_sql_varchar');
			qryInsertUser.addParam(
				name = 'salt', value = trim(salt), cfsqltype = 'cf_sql_varchar');

			qryInsertUser.execute();

			//loginUser({username: structform.username, password: hashpwd});

			expdt =  dateAdd('n', 30, now());
			utcDate = dateDiff('s', dateConvert('utc2Local', createDateTime(1970, 1, 1, 0, 0, 0)), expdt);

			jwt = new jwt(Application.jwtkey);
			payload = {
				'ts' = now(),
				'userid' = newID,
				'Exp' = utcDate
			};
			token = jwt.encode(payload);
			
			resObj['success'] = true;
			//resObj['message'] = 'User created successfully';
			resObj['message'] = Hash(salt & structform.password);
			resObj['data'] = {
				'userid': newID, 
				'username': structform.username, 
				'firstname': structform.firstname, 
				'lastname': structform.lastname, 
				'email': structform.email, 
				'password':structform.password,
				'lastlogin': dateTimeFormat(now(), 'dd-MMM-yyyy hh:nn:ss tt')
			};
			resObj['token'] = token;
		}

		return resObj;
  }

  public struct function updateUser(
		required numeric userid, 
		required any structform) 
		hint = 'Update user details'
	{
        
    var resObj = {};

		qryCheckUser = new Query(datasource = request.dsn);    

		qryCheckUser.setSQL('
			SELECT *
			FROM users u
			WHERE u.userid = :userid
		');
				
		qryCheckUser.addParam(
			name = 'userid', value = trim(arguments.userid), cfsqltype = 'cf_sql_integer');

		qryCheckUser = qryCheckUser.execute().getResult();	


    if (qryCheckUser.recordcount) {
  
			try {
				qryUpdateUser = new Query(datasource = request.dsn);    

				qryUpdateUser.setSQL('
					UPDATE users
					SET firstname = :firstname,
						lastname = :lastname,
						email = :email,
						username = :username,
						password = :password,
						password_nohash = :password_nohash,
						salt = :salt
					WHERE userid = :userid
				');

				Salt="";

				for (i = 1; i <= 12; i = i + 1) {
					Salt = Salt & chr(RandRange(65,90));
				}
							
				hashpwd = Hash(Salt & structform.password);	

				qryUpdateUser.addParam(
					name = 'firstname', value = trim(structform.firstname), cfsqltype = 'cf_sql_varchar');
				qryUpdateUser.addParam(
					name = 'lastname', value = trim(structform.lastname), cfsqltype = 'cf_sql_varchar');
				qryUpdateUser.addParam(
					name = 'email', value = trim(structform.email), cfsqltype = 'cf_sql_varchar');
				qryUpdateUser.addParam(
				name = 'username', value = trim(structform.username), cfsqltype = 'cf_sql_varchar');
				qryUpdateUser.addParam(
					name = 'password', value = trim(hashpwd), cfsqltype = 'cf_sql_varchar');
				qryUpdateUser.addParam(
					name = 'password_nohash', value = trim(structform.password), cfsqltype = 'cf_sql_varchar');
				qryUpdateUser.addParam(
					name = 'salt', value = salt, cfsqltype = 'cf_sql_varchar');
				qryUpdateUser.addParam(
					name = 'userid', value = arguments.userid, cfsqltype = 'cf_sql_varchar');

				qryUpdateUser.execute();
  
  			resObj['success'] = true;
        resObj['message'] = 'User details updated successfully.';
				resObj['data'] = {
					'userid': arguments.userid, 
					'username': structform.username, 
					'firstName': structform.firstname, 
					'lastName': structform.lastname, 
					'email': structform.email, 
					'password':structform.password/* ,
					'lastlogin': dateTimeFormat(now(), 'dd-MMM-yyyy hh:nn:ss tt') */
				};
						
			} catch (any e) {
      
			  resObj['success'] = false;
        resObj['message'] = 'Problem executing database query ' & e['message'];
                
      }
		
		} else {
    
		  resObj['success'] = false;
      resObj['message'] = 'Incorrect user id provided.';
    
		}

    return resObj;

  }

	public struct function deleteUser(required numeric userid) 
		hint = 'Update user details'
	{
        
    var resObj = {};

		qryCheckUser = new Query(datasource = request.dsn);    

		qryCheckUser.setSQL('
			SELECT *
			FROM users u
			WHERE u.userid = :userid
		');
				
		qryCheckUser.addParam(
			name = 'userid', value = trim(arguments.userid), cfsqltype = 'cf_sql_integer');

		qryCheckUser = qryCheckUser.execute().getResult();	

    if (qryCheckUser.recordcount) {
  
			try {
				qryDeleteUser = new Query(datasource = request.dsn);    

				qryDeleteUser.setSQL('
					DELETE FROM users
					WHERE userid = :userid
				');
									
				qryDeleteUser.addParam(
					name = 'userid', value = arguments.userid, cfsqltype = 'cf_sql_varchar');

				qryDeleteUser.execute();
  
  			resObj['success'] = true;
        resObj['message'] = 'User deleted successfully.';
						
			} catch (any e) {
      
			  resObj['success'] = false;
        resObj['message'] = 'Problem executing database query ' & e['message'];
                
      }
		
		} else {
    
		  resObj['success'] = false;
      resObj['message'] = 'Incorrect user id provided.';
    
		}

    return resObj;

  }
    
  public struct function updatePassword(
		required numeric userid, 
		required any structform) 
		hint = 'Update user password'
	{
                
    var resObj = {};

		qryCheckUser = new Query(datasource = request.dsn);    

		qryCheckUser.setSQL('
			SELECT *
			FROM users u
			WHERE u.userid = :userid
		');
				
		qryCheckUser.addParam(
			name = 'userid', value = trim(arguments.userid), cfsqltype = 'cf_sql_integer');

		qryCheckUser = qryCheckUser.execute().getResult();	
        
    if (qryCheckUser.recordcount) {

      if (Hash(qryCheckUser.salt & structform.oldpassword) eq qryCheckUser.password) {

				try {
                   
					hashpwd = hash(qryCheckUser.salt & structform.password);
                    
					qryUpdatePassword = new Query(datasource = request.dsn);    

					qryUpdatePassword.setSQL('
						UPDATE users
						SET password = :password
						WHERE userid = :userid
					');
									
					qryUpdatePassword.addParam(
						name = 'password', value = trim(hashpwd), cfsqltype = 'cf_sql_varchar');
					qryUpdatePassword.addParam(
						name = 'userid', value = arguments.userid, cfsqltype = 'cf_sql_integer');

					qryUpdatePassword.execute();

          resObj['success'] = true;
          resObj['message'] = 'Password updated successfully.';
										
        } catch (any e) {
        
				  resObj['success'] = false;
          resObj['message'] = 'Problem executing database query ' & e['message'];
                    
        }

				resObj['success'] = true;
        resObj['message'] = 'Password updated successfully.';
							
      } else {
      
			  resObj['success'] = false;
        resObj['message'] = 'Incorrect old password.';
      }
		
		} else {
        
				resObj['success'] = false;
        resObj['message'] = 'Incorrect user id provided.';
        
		}
        
    return resObj;

  }

}