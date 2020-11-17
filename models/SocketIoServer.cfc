/**
 * Entrypoint object for the system.
 *
 * The server object controls the Socket.io server state
 * as well as providing access to namespaces and, in turn,
 * sockets that both provide socket communication.
 *
 */
component {

	variables._namespaces = {};

	this.sockets = new SocketIoNamespace(); // this will be alias for root namespace

// CONSTRUCTOR
	public any function init(
		  string  host  = ListFirst( cgi.http_host, ":" )
		, string  port  = 3000
		, boolean start = true
	) {
		_setHost( arguments.host );
		_setPort( arguments.port );

		if ( arguments.start ) {
			this.start();
		}

		return this;
	}

// PUBLIC API

	/**
	 * This is what socket.io server named their method
	 * for getting a namespace. I'm sure it make sense so
	 * am keeping it here for those that want to use it.
	 * Just an alias of 'namespace'.
	 *
	 */
	public SocketIoNamespace function of( required string namespace ) {
		return this.namespace( arguments.namespace );
	}

	/**
	 * Retrieve a Socket.io namespace object. This will be used to emit and
	 * receive messages.
	 *
	 */
	public SocketIoNamespace function namespace( required string namespace ) {
		_getJavaServer().registerNamespace( arguments.namespace );

		if ( !StructKeyExists( variables._namespaces, arguments.namespace ) ) {
			var ns = new SocketIoNamespace(
				  name     = arguments.namespace
				, ioserver = this
			);

			variables._namespaces[ arguments.namespace ] = ns;
		}

		return variables._namespaces[ arguments.namespace ];
	}

// START/STOP SERVER
	public void function start() {
		_getJavaServer().startServer();
	}

	public void function stop() {
		if ( _serverIsRegistered() ) {
			_getJavaServer().stopServer();
		}
	}
	// aliases
	public void function close() { this.stop(); }
	public void function shutdown() { this.stop(); }

// PACKAGE METHODS FOR INTERNAL USE
	package void function $broadcast(
		  required string event
		,          any    args  = []
		,          any    rooms = []
		,          string namespace = ""
		,          string socketId  = ""
	) {
		if ( !IsArray( arguments.args ) ) {
			arguments.args = [ arguments.args ];
		}
		if ( !IsArray( arguments.rooms ) ) {
			arguments.rooms = [ arguments.rooms ];
		}

		if ( Len( arguments.namespace ) ) {
			_getJavaServer().namespaceBroadcast(
				  arguments.namespace
				, JavaCast( "String[]", arguments.rooms )
				, arguments.event
				, JavaCast( "Object[]", _prepareArgs( arguments.args ) )
			);
		} else if ( Len( arguments.socketId ) ) {
			if ( ArrayLen( arguments.rooms ) ) {
				_getJavaServer().socketBroadcast(
					  arguments.socketId
					, JavaCast( "String[]", arguments.rooms )
					, arguments.event
					, JavaCast( "Object[]", _prepareArgs( arguments.args ) )
				);
			} else {
				_getJavaServer().socketBroadcast(
					  arguments.socketId
					, arguments.event
					, JavaCast( "Object[]", _prepareArgs( arguments.args ) )
				);
			}

		}

	}

	package void function $send(
		  required string socketId
		, required string event
		,          array  args = []
	) {
		_getJavaServer().socketSend(
			  arguments.socketId
			, arguments.event
			, _prepareArgs( args )
		);
	}

	package void function $joinRoom( required string socketId, required string roomName ) {
		_getJavaServer().socketJoinRoom( arguments.socketId, arguments.roomName );
	}

	package void function $leaveRoom( required string socketId, required string roomName ) {
		_getJavaServer().socketLeaveRoom( arguments.socketId, arguments.roomName );
	}

	package void function $leaveAllRooms( required string socketId ) {
		_getJavaServer().socketLeaveAllRooms( arguments.socketId );
	}

	package void function $registerOn( required string namespace, required string socketId, required string event ) {
		_getJavaServer().socketOn( arguments.namespace, arguments.socketId, arguments.event );
	}

	package void function $disconnect( required string socketId, required boolean close ) {
		_getJavaServer().socketDisconnect( arguments.socketId, arguments.close );
	}


// UNDER-THE-HOOD LISTENER INTERFACE
	public void function onConnect( required string namespace, required string socketId, required any initialRequest ) {
		var ns     = this.namespace( arguments.namespace );
		var socket = ns.$registerSocket( arguments.socketId );

		socket.setHttpRequest( new SocketIoRequest(
			  cookies     = arguments.initialRequest.get( "cookies"     )
			, headers     = arguments.initialRequest.get( "headers"     )
			, uri         = arguments.initialRequest.get( "uri"         )
			, queryString = arguments.initialRequest.get( "querystring" )
			, remoteUser  = arguments.initialRequest.get( "remoteUser"  )
		) );

		ns.$runEvent( "connect", [ socket ] );
	}
	public void function onDisconnecting( required string namespace, required string socketId ) {
		var ns     = this.namespace( arguments.namespace );
		var socket = ns.$getSocket( arguments.socketId );

		ns.$runEvent( "disconnecting", [ socket ] );
	}
	public void function onDisconnect( required string namespace, required string socketId ) {
		var ns     = this.namespace( arguments.namespace );
		var socket = ns.$getSocket( arguments.socketId );

		try {
			ns.$runEvent( "disconnect", [ socket ] );
		} catch( any e ) {
			rethrow;
		} finally {
			ns.$deRegisterSocket( arguments.socketId );
		}
	}
	public void function onSocketEvent( required string namespace, required string socketId, required string event, array args=[] ) {
		var ns     = this.namespace( arguments.namespace );
		var socket = ns.$getSocket( arguments.socketId );

		socket.$runEvent( arguments.event, args );
	}

// PRIVATE HELPERS
	private any function _getJavaServer() {
		if ( !_serverIsRegistered() ) {
			_registerBundle();

			variables._javaServer = createObject( "java", "com.pixl8.socketiolucee.SocketIoServerWrapper", "com.pixl8.socketio-lucee" ).init(
				  this                                     // handlerCfc
				, ExpandPath( "/" )                        // contextRoot
				, getPageContext().getApplicationContext() // appContext
				, _getHost()                               // host
				, _getPort()                               // port
			);

			this.sockets = of( "/" );
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

	private array function _prepareArgs( required array args ) {
		var javaServer = _getJavaServer();

		for( var i=1; i<=ArrayLen( arguments.args ); i++ ) {
			if ( !IsSimpleValue( arguments.args[ i ] ) ) {
				arguments.args[ i ] = javaServer.toJsonObj( SerializeJson( arguments.args[ i ] ) );
			}
		}

		return arguments.args;
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