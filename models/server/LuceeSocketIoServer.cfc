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
		var lib        = ExpandPath( GetDirectoryFromPath( GetCurrentTemplatePath() ) & "../lib/socketio-lucee-1.0.0.jar" );
		var resource   = cfmlEngine.getResourceUtil().toResourceExisting( getPageContext(), lib );

		osgiUtil.installBundle( cfmlEngine.getBundleContext(), resource, true );
	}

	public boolean function serverIsRegistered() {
		return StructKeyExists( variables, "_javaServer" );
	}

	public void function startServer() {
		_getServer().startServer();
	}

	public void function stopServer() {
		if ( serverIsRegistered() ) {
			_getServer().stopServer();
		}
	}

// PRIVATE HELPERS
	private any function _getServer() {
		if ( !serverIsRegistered() ) {
			variables._javaServer = createObject( "java", "com.pixl8.socketiolucee.SocketIoServerWrapper", "com.pixl8.socketio-lucee" ).init(
				  _getListener()                           // handlerCfc
				, ExpandPath( "/" )                        // contextRoot
				, getPageContext().getApplicationContext() // appContext
				, _getHost()                               // host
				, _getPort()                               // port
			);
		}

		return variables._javaServer;
	}

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