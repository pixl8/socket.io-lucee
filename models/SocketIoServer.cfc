component {

// CONSTRUCTOR
	public any function init(
		  string  host  = ListFirst( cgi.http_host, ":" )
		, string  port  = 3000
		, boolean start = true
	) {
		_setHost( arguments.host );
		_setPort( arguments.port );

		if ( arguments.start ) {
			start();
		}

		return this;
	}

// PUBLIC API
	public SocketIoNamespace function of( required string namespace ) {

	}

// START/STOP SERVER
	public void function start() {
		_getServer().startServer();
	}

	public void function stop() {
		if ( serverIsRegistered() ) {
			_getServer().stopServer();
		}
	}
	// aliases
	public void function close() { stop(); }
	public void function shutdown() { stop(); }

// UNDER-THE-HOOD LISTENER INTERFACE
	public void function onConnect( required string namespace, required string socketId ) {
		// TODO
	}
	public void function onDisconnecting( required string namespace, required string socketId ) {
		// TODO
	}
	public void function onDisconnect( required string namespace, required string socketId ) {
		// TODO
	}
	public void function onSocketSendCallback( required string socketId, required string event, required string callbackRef, array args ) {
		// TODO
	}
	public void function onSocketEvent( required string socketId, required string event, required string callbackRef, array args ) {
		// TODO
	}


// PRIVATE HELPERS
	private any function _getServer() {
		if ( !serverIsRegistered() ) {
			_registerBundle();

			variables._javaServer = createObject( "java", "com.pixl8.socketiolucee.SocketIoServerWrapper", "com.pixl8.socketio-lucee" ).init(
				  this                                     // handlerCfc
				, ExpandPath( "/" )                        // contextRoot
				, getPageContext().getApplicationContext() // appContext
				, _getHost()                               // host
				, _getPort()                               // port
			);
		}

		return variables._javaServer;
	}

	private boolean function _serverIsRegistered() {
		return StructKeyExists( variables, "_javaServer" );
	}

	private void function _registerBundle() {
		var cfmlEngine = CreateObject( "java", "lucee.loader.engine.CFMLEngineFactory" ).getInstance();
		var osgiUtil   = CreateObject( "java", "lucee.runtime.osgi.OSGiUtil" );
		var lib        = ExpandPath( GetDirectoryFromPath( GetCurrentTemplatePath() ) & "../lib/socketio-lucee-1.0.0.jar" );
		var resource   = cfmlEngine.getResourceUtil().toResourceExisting( getPageContext(), lib );

		osgiUtil.installBundle( cfmlEngine.getBundleContext(), resource, true );
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