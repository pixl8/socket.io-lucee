component {

// CONSTRUCTOR
	public any function init(
		  string host = ListFirst( cgi.http_host, ":" )
		, string port = 3000
	) {
		_setHost( arguments.host );
		_setPort( arguments.port );

		return this;
	}

// PUBLIC API METHODS
	public void function registerBundle() {
		var cfmlEngine = CreateObject( "java", "lucee.loader.engine.CFMLEngineFactory" ).getInstance();
		var osgiUtil   = CreateObject( "java", "lucee.runtime.osgi.OSGiUtil" );
		var lib        = ExpandPath( GetDirectoryFromPath( GetCurrentTemplatePath() ) & "../lib/cfsocket-1.0.0.jar" );
		var resource   = cfmlEngine.getResourceUtil().toResourceExisting( getPageContext(), lib );

		osgiUtil.installBundle( cfmlEngine.getBundleContext(), resource, true );
	}

	public void function startServer() {
		_getServer().start();
	}

	public void function stopServer() {
		_getServer().stop();
	}

	public any function getStatus() {
		WriteDump(_getServer() );abort;
	}

	// public void function onConnect( exchange, channel ) {
	// 	$systemoutput( "onConnect called, channel: #channel.getUrl()#" );
	// }

	// public void function onFullTextMessage( channel, message ) {
	// 	$systemoutput( "onFullTextMessage called from: #channel.getUrl()#. Message: #message#" );
	// 	createObject( "java", "io.undertow.websockets.core.WebSockets", "com.pixl8.CfSocket" ).sendText(
	// 		  "Oi #Now()#"
	// 		, channel
	// 		, NullValue()
	// 	);
	// }


// PRIVATE HELPERS
	private any function _getServer() {
		if ( !StructKeyExists( variables, "_websocketServer" ) ) {
			variables._websocketServer = createObject( "java", "com.pixl8.cfsocket.CfSocketServer", "com.pixl8.cfsocket" ).init(
				  this                                     // handlerCfc
				, ExpandPath( "/" )                        // contextRoot
				, getPageContext().getApplicationContext() // appCOntext
				, _getHost()                               // host
				, _getPort()                               // port
			);
		}

		return variables._websocketServer;
	}

	// private array function _getLib() {
	// 	if ( !StructKeyExists( variables, "_lib" ) ) {
	// 		var path = GetDirectoryFromPath( GetCurrentTemplatePath() ) & "lib/";

	// 		variables._lib = DirectoryList( path, false, "path", "*.jar" );
	// 	}

	// 	return variables._lib;
	// }

// GETTERS AND SETTERS
	private string function _getHost() {
	    return _host;
	}
	private void function _setHost( required string host ) {
	    _host = arguments.host;
	}

	private numeric function _getPort() {
	    return _port;
	}
	private void function _setPort( required numeric port ) {
	    _port = arguments.port;
	}

}