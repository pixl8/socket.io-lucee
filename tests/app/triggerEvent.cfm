<cfscript>
	io.of( "/admin" ).broadcast( "alert", ["Wake up everyone, it's #Now()#!"], [ "secure" ] );
</cfscript>

<p>Nothing to see here, alert should have been sent to connected clients is all.</p>