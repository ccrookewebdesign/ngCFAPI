	<cfset request.dsn = "cfbookclub">
	
<!---	<cfquery name="q" datasource="#request.dsn#">
		/* create table users ( 
			userid integer, 
			firstname varchar(100),
			lastname varchar(100),
			email varchar(255),
			username varchar(20),
			salt varchar(15),
			lastlogin timestamp
		) */ 
		/* insert into users (
			userid, firstname, lastname, email, username
		) values (
			10, 'Chris', 'Crooke', 'chris@ccrooke.com', 'ccrooke'
		) */
		/* drop table users */

		/* create table expenses ( 
			expenseid integer, 
			userid integer, 
			expensedate date,
			expensetype varchar(50),
			expenseamount double,
			expensedesc varchar(255)
		) */
/* update users set password_nohash = '4Testing!' */
		/* select * from users */
		/* alter table users add column password_nohash varchar(250) */
delete from users
	</cfquery>--->
		<cfquery name="q" datasource="#request.dsn#">

		select * from users
		

	</cfquery>

	<cftry>
	<cfdump var="#q#"></cfdump>
	<cfcatch></cfcatch>
	</cftry>

<p>done!</p>