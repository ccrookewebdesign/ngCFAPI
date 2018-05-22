component hint = 'rest controller' rest = 'true' restpath = 'cfapi' {

  objUser = new cfc.user();

  public any function checkToken() {
  
    var response = {};
    requestData = GetHttpRequestData();
    
    if (StructKeyExists(requestData.Headers, 'authorization')) {

      token = requestData.Headers.authorization;
      
      try {
        
        jwt = new cfc.jwt(application.jwtkey);
        result = jwt.decode(token);
        response['success'] = true;

      } catch (any e) {
        
        response['success'] = false;
        response['message'] = e.message;

        return response;

      }

    } else {

      response['success'] = false;
      response['message'] = 'Authorization token invalid or not present.';

    }

    return response;
  
  }

  remote struct function loginUser(required any structform) 
    restpath = 'login' 
    httpmethod = 'post'
    produces = 'application/json'
  {

    var response = {};
    response = objUser.loginUser(structform);
    
    return response;
  
  }

  remote struct function insertUser(required any structform) 
    restpath = 'insertuser'
    httpmethod = 'post'
    produces = 'application/json' 
  {
		
		var response = {};

		/* blnsignup = objUser.insertUser(structform);
		
    if (blnsignup) {

			response['success'] = true;
			response['message'] = 'User created successfully';

    } else {

			response['success'] = false;
			response['message'] = 'Username already exists.';

		} */

    response = objUser.insertUser(structform);
    
    return response;

		return response;
		
	}
  
  remote struct function getUser(required any id restargsource = 'path') 
    restpath = 'user/{id}'
    httpmethod = 'get'
    produces = 'application/json'
  {
    
    var response = {};

    verify = checkToken();
    
    if (!verify.success) {

      response['success'] = false;
      response['message'] = verify.message;
      response['errcode'] = 'no-token';

    } else {

      response = objUser.getUser(arguments.id);

    }

    return response;

  }
  
  remote struct function getUsers() 
    restpath = 'users'
    httpmethod = 'get'
    produces = 'application/json'
  {
    
    var response = {};

    verify = checkToken();
    
    if (!verify.success) {

      response['success'] = false;
      response['message'] = verify.message;
      response['errcode'] = 'no-token';

    } else {

      response = objUser.getUsers();

    }

    return response;

  }

  remote struct function updateUser(
    required any id restargsource = 'path', 
    required any structform
    ) 
    restpath = 'user/{id}'
    httpmethod = 'put'
    produces = 'application/json'
  {

		var response = {};

		verify = checkToken();

		if (!verify.success) {

			response['success'] = false;
			response['message'] = verify.message;
		  response['errcode'] = 'no-token';

		} else {

			response = objUser.updateUser(arguments.id, arguments.structform);

		}

	  return response;
  
  }

  remote struct function deleteUser(
    required any id restargsource = 'path', 
    required any structform
    ) 
    restpath = 'delete/{id}'
    httpmethod = 'delete'
    produces = 'application/json'
  {

		var response = {};

		verify = checkToken();

		if (!verify.success) {

			response['success'] = false;
			response['message'] = verify.message;
		  response['errcode'] = 'no-token';

		} else {

			response = objUser.deleteUser(arguments.id);

		}

	  return response;
  
  }

  remote struct function updatePassword(
    required numeric id restargsource = 'path',
    required any structform) 
    restpath = 'password/{id}'
    httpmethod = 'put'
    produces = 'application/json'
  {
    
    var response = {};

    verify = checkToken();

    if (!verify.success) {

      response['success'] = false;
      response['message'] = verify.message;
     	response['errcode'] = 'no-token';

    } else {

      response = objUser.updatePassword(arguments.id, arguments.structform);

    }
    
    return response;

  }

}