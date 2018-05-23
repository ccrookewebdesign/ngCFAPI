component hint = 'user rest functions' displayname = 'user' {
  
  public struct function getUser(required numeric userid)
    hint = 'Get user details' {
      
    var resObj = {};
    
    qryGetUser = returnUser(arguments.userid);
    
    if (!qryGetUser.recordcount) {
      
      resObj['success'] = false;
      resObj['message'] = 'Incorrect user id provided.';
      
    } else {
      
      userStruct = setUserStruct(qryGetUser);
            
      resObj['success'] = true;
      resObj['message'] = 'User (userid: ' & userid & ') retrieved successfully';
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
        
        userStruct = setUserStruct(user);
        ArrayAppend(returnArray, userStruct);
        
      }
      
      resObj['success'] = true;
      resObj['message'] = qryGetUser.recordcount & ' user records returned';
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
      
      token = setToken(qryLoginUser.userid);
      
      resObj['success'] = true;
      resObj['message'] = 'User successfully logged in';
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
      resObj['message'] = 'Incorrect login credentials.';
      
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
      
      hashpwd = hashPassword(structform.password);
      
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
        name = 'password', value = trim(hashpwd.password), cfsqltype = 'cf_sql_varchar');
      qryInsertUser.addParam(
        name = 'password_nohash', value = trim(structform.password), cfsqltype = 'cf_sql_varchar');
      qryInsertUser.addParam(
        name = 'salt', value = trim(hashpwd.salt), cfsqltype = 'cf_sql_varchar');
        
      qryInsertUser.execute();
      
      token = setToken(newID);
      
      resObj['success'] = true;
      resObj['message'] = 'User created successfully';
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
    hint = 'Update user details' {
    
    var resObj = {};
    
    qryCheckUser = returnUser(arguments.userid);

    if (qryCheckUser.recordcount) {

      qryCheckUserName = new Query(datasource = request.dsn);
    
      qryCheckUserName.setSQL('
        SELECT *
        FROM users u
        WHERE u.username = :username 
          AND u.userid != :userid
      ');
      
      qryCheckUserName.addParam(
        name = 'username', value = trim(structform.username), cfsqltype = 'cf_sql_varchar');
      qryCheckUserName.addParam(
        name = 'userid', value = trim(arguments.userid), cfsqltype = 'cf_sql_integer');
        
      qryCheckUserName = qryCheckUserName.execute().getResult();

      if (!qryCheckUserName.recordcount) {
        
        try {
          hashpwd = hashPassword(structform.password);

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
          
          qryUpdateUser.addParam(
            name = 'firstname', value = trim(structform.firstname), cfsqltype = 'cf_sql_varchar');
          qryUpdateUser.addParam(
            name = 'lastname', value = trim(structform.lastname), cfsqltype = 'cf_sql_varchar');
          qryUpdateUser.addParam(
            name = 'email', value = trim(structform.email), cfsqltype = 'cf_sql_varchar');
          qryUpdateUser.addParam(
            name = 'username', value = trim(structform.username), cfsqltype = 'cf_sql_varchar');
          qryUpdateUser.addParam(
            name = 'password', value = trim(hashpwd.password), cfsqltype = 'cf_sql_varchar');
          qryUpdateUser.addParam(
            name = 'password_nohash', value = trim(structform.password), cfsqltype = 'cf_sql_varchar');
          qryUpdateUser.addParam(
            name = 'salt', value = hashpwd.salt, cfsqltype = 'cf_sql_varchar');
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
            'password':structform.password
          };
          
        } catch (any e) {
          
          resObj['success'] = false;
          resObj['message'] = 'Problem executing database query ' & e['message'];
        
        }
      
      } else {

        resObj['success'] = false;
        resObj['message'] = 'This username is taken. Please choose another';

      }

    } else {
      
      resObj['success'] = false;
      resObj['message'] = 'Incorrect user id provided.';
      
    }
    
    return resObj;
    
  }
  
  public struct function deleteUser(required numeric userid)
    hint = 'Update user details' {
    
    var resObj = {};
    
    qryCheckUser = returnUser(arguments.userid);
    
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
    
  private query function returnUser(required numeric userid)
    hint = 'runs query to get user by userid' 
  {

    qryGetUser = new Query(datasource = request.dsn);
      
    qryGetUser.setSQL('
      SELECT *
      FROM users u
      WHERE u.userid = :userid
    ');
      
    qryGetUser.addParam(
      name = 'userid', value = trim(arguments.userid), cfsqltype = 'cf_sql_integer');
        
    return qryGetUser.execute().getResult();

  } 

  private struct function setUserStruct(required any user)
    hint = 'returns a struct populated with user info'
  {
    userStruct = StructNew();
    userStruct['userid'] = user.userid;
    userStruct['firstname'] = user.firstname;
    userStruct['lastname'] = user.lastname;
    userStruct['username'] = user.username;
    userStruct['email'] = user.email;
    userStruct['password'] = user.password_nohash;
    userStruct['lastlogin'] = user.lastlogin;

    return userStruct;

  }

  private struct function hashPassword(required string password)
    hint = 'encrypts the password' {

    str="";
      
    for (i = 1; i <= 12; i = i + 1) {
      str = str & chr(RandRange(65,90));
    }
      
    return { password: Hash(str & arguments.password), salt: str };

  }

  private any function setToken(required numeric userid)
    hint = 'sets the token' {

    expdt =  dateAdd('n', 30, now());
    utcDate = dateDiff('s', dateConvert('utc2Local', createDateTime(1970, 1, 1, 0, 0, 0)), expdt);
     
    jwt = new jwt(Application.jwtkey);
    
    payload = {
      'ts' = now(),
      'userid' = arguments.userid,
      'Exp' = utcDate
    };
    
    return jwt.encode(payload);
    
  }
}