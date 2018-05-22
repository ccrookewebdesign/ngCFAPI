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
		
		request.dsn = 'cfbookclub';
	
	}

}	