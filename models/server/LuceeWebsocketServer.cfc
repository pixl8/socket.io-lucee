component {

// CONSTRUCTOR
	public any function init(
		  required ILuceeWebsocketServerListener listener
		,          string                        host = ListFirst( cgi.http_host, ":" )
		,          string                        port = 3000
	) {
		_setListener( arguments.listener );
		_setHost( arguments.host );
		_setPort( arguments.port );

		return this;
	}

// PUBLIC API METHODS
	public void function registerBundle() {
		var cfmlEngine = CreateObject( "java", "lucee.loader.engine.CFMLEngineFactory" ).getInstance();
		var osgiUtil   = CreateObject( "java", "lucee.runtime.osgi.OSGiUtil" );
		var lib        = ExpandPath( GetDirectoryFromPath( GetCurrentTemplatePath() ) & "../../lib/cfsocket-1.0.0.jar" );
		var resource   = cfmlEngine.getResourceUtil().toResourceExisting( getPageContext(), lib );

		osgiUtil.installBundle( cfmlEngine.getBundleContext(), resource, true );
	}

	public void function startServer() {
		_getServer().start();
	}

	public void function stopServer() {
		_getServer().stop();
	}

	public numeric function getConnectionCount() {
		_getServer().getConnectionCount();
	}

// PRIVATE HELPERS
	private any function _getServer() {
		if ( !StructKeyExists( variables, "_websocketServer" ) ) {
			variables._websocketServer = createObject( "java", "com.pixl8.cfsocket.CfSocketServer", "com.pixl8.cfsocket" ).init(
				  _getListener()                           // handlerCfc
				, ExpandPath( "/" )                        // contextRoot
				, getPageContext().getApplicationContext() // appContext
				, _getHost()                               // host
				, _getPort()                               // port
			);
		}

		return variables._websocketServer;
	}

// GETTERS AND SETTERS
	private any function _getListener() {
	    return _listener;
	}
	private void function _setListener( required any listener ) {
	    _listener = arguments.listener;
	}

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