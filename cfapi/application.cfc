component hint="application component" {

	this.name = 'cfapi';
	this.restsettings.cfclocation = './';
  this.restsettings.skipcfcwitherror = true;

	function onApplicationStart() {

		application.jwtkey = '!4dS2$m@DX81';
		
		restInitApplication(
			getDirectoryFromPath(getCurrentTemplatePath()) & 'restapi', 'api'
		);

		return true;
	}

	function onRequestStart() {
		
		if (isdefined('url.reload') and url.reload eq 'cfboom') {
		
			lock 
				timeout = '10'
				throwontimeout = 'no'
				type = 'exclusive'
				scope = 'application' {
				
				OnApplicationStart();
			
			};
		
		}

		/* expdt =  dateAdd("n",30,now());
  	utcDate = dateDiff(
			's', dateConvert('utc2Local', createDateTime(1970, 1, 1, 0, 0, 0)), expdt
		);

    jwt = new restapi.cfc.jwt(application.jwtkey);
    payload = {"ts" = now(), "userid" = 10, "exp" = utcDate};
    application.token = jwt.encode(payload); */

		request.dsn = 'cfbookclub';
	}

}	