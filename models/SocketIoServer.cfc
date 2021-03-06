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
	/**
	 * Initialize the SocketIO Server.
	 *
	 * @host.hint Hostname on which the server listens, e.g. 127.0.0.1
	 * @port.hint The port on which the server listens
	 * @start.hint Whether or not to immediately start the server
	 */
	public any function init(
		  string  host  = ListFirst( cgi.http_host, ":" )
		, string  port  = 3000
		, boolean start = true
	) {
		variables._host = arguments.host;
		variables._port = arguments.port;

		if ( arguments.start ) {
			this.start();
		}

		return this;
	}

// PUBLIC API

	/**
	 * Get a Socket-io namespace object. The namespace will be registered
	 * if it does not already exist.
	 *
	 * @namespace.hint The name of the namespace
	 *
	 */
	public SocketIoNamespace function of( required string namespace ) {
		return this.namespace( arguments.namespace );
	}

	/**
	 * Slightly less weirdly named alias of the 'of' method!
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

	/**
	 * Register an event listener with the default namespace (proxy to namespace.on()).
	 *
	 * @event.hint The name of the event to listen to, valid values are: connect, disconnect and disconnecting
	 * @callback.hint Closure function with which to handle the event. The function will be passed a socket object as its single argument.
	 */
	public void function on( required string event, required any callback ) {
		return this.of( "/" ).on( argumentCollection=arguments );
	}


// START/STOP SERVER
	/**
	 * Starts the server, if it has not already started.
	 *
	 */
	public void function start() {
		_getJavaServer().startServer();
	}

	/**
	 * Stops the server, should it be running.
	 *
	 */
	public void function stop() {
		if ( _serverIsRegistered() ) {
			_getJavaServer().stopServer();
		}
	}
	/**
	 * Alias of Stop()
	 */
	public void function close() { this.stop(); }
	/**
	 * Alias of Stop()
	 */
	public void function shutdown() { this.stop(); }

// PACKAGE METHODS FOR INTERNAL USE
	/**
	 * Internal use for namespace and socket objects
	 * to communicate with underlying Java framework.
	 */
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
			if ( ArrayLen( arguments.rooms ) ) {
				_getJavaServer().namespaceBroadcast(
					  arguments.namespace
					, JavaCast( "String[]", arguments.rooms )
					, arguments.event
					, JavaCast( "Object[]", _prepareArgs( arguments.args ) )
				);
			} else {
				_getJavaServer().namespaceBroadcast(
					  arguments.namespace
					, arguments.event
					, JavaCast( "Object[]", _prepareArgs( arguments.args ) )
				);
			}
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

	/**
	 * Internal use for namespace and socket objects
	 * to communicate with underlying Java framework.
	 */
	package void function $send(
		  required string socketId
		, required string event
		,          any    args = []
	) {
		if ( !IsArray( arguments.args ) ) {
			arguments.args = [ arguments.args ];
		}
		_getJavaServer().socketSend(
			  arguments.socketId
			, arguments.event
			, _prepareArgs( args )
		);
	}

	/**
	 * Internal use for namespace and socket objects
	 * to communicate with underlying Java framework.
	 */
	package void function $joinRoom( required string socketId, required string roomName ) {
		_getJavaServer().socketJoinRoom( arguments.socketId, arguments.roomName );
	}

	/**
	 * Internal use for namespace and socket objects
	 * to communicate with underlying Java framework.
	 */
	package void function $leaveRoom( required string socketId, required string roomName ) {
		_getJavaServer().socketLeaveRoom( arguments.socketId, arguments.roomName );
	}

	/**
	 * Internal use for namespace and socket objects
	 * to communicate with underlying Java framework.
	 */
	package void function $leaveAllRooms( required string socketId ) {
		_getJavaServer().socketLeaveAllRooms( arguments.socketId );
	}

	/**
	 * Internal use for namespace and socket objects
	 * to communicate with underlying Java framework.
	 */
	package void function $registerOn( required string namespace, required string socketId, required string event ) {
		_getJavaServer().socketOn( arguments.namespace, arguments.socketId, arguments.event );
	}

	/**
	 * Internal use for namespace and socket objects
	 * to communicate with underlying Java framework.
	 */
	package void function $disconnect( required string socketId, required boolean close ) {
		_getJavaServer().socketDisconnect( arguments.socketId, arguments.close );
	}


// UNDER-THE-HOOD LISTENER INTERFACE
	/**
	 * Internal use for the underlying Java framework
	 * to communicate with our CFML layer.
	 */
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

	/**
	 * Internal use for the underlying Java framework
	 * to communicate with our CFML layer.
	 */
	public void function onDisconnecting( required string namespace, required string socketId ) {
		var ns     = this.namespace( arguments.namespace );
		var socket = ns.$getSocket( arguments.socketId );

		ns.$runEvent( "disconnecting", [ socket ] );
	}

	/**
	 * Internal use for the underlying Java framework
	 * to communicate with our CFML layer.
	 */
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

	/**
	 * Internal use for the underlying Java framework
	 * to communicate with our CFML layer.
	 */
	public void function onSocketEvent( required string namespace, required string socketId, required string event, array args=[] ) {
		var ns     = this.namespace( arguments.namespace );
		var socket = ns.$getSocket( arguments.socketId );

		socket.$runEvent( arguments.event, args );
	}

// PRIVATE HELPERS
	/**
	 * Private access helper to retrieve our underlying
	 * java server API, instantiating it if it does not
	 * already exist.
	 */
	private any function _getJavaServer() {
		if ( !_serverIsRegistered() ) {
			_registerBundle();

			variables._javaServer = createObject( "java", "com.pixl8.socketiolucee.SocketIoServerWrapper", "com.pixl8.socketio-lucee" ).init(
				  this                                     // handlerCfc
				, ExpandPath( "/" )                        // contextRoot
				, getPageContext().getApplicationContext() // appContext
				, variables._host                          // host
				, variables._port                          // port
			);

			// handy public alias for the default namespace
			this.sockets = of( "/" );
		}

		return variables._javaServer;
	}

	/**
	 * Private helper to determine whether or not we have initiated our
	 * internal Java API.
	 */
	private boolean function _serverIsRegistered() {
		return StructKeyExists( variables, "_javaServer" );
	}

	/**
	 * Private helper to register OSGi bundle with Lucee
	 * for painfree class loading.
	 */
	private void function _registerBundle() {
		var cfmlEngine = CreateObject( "java", "lucee.loader.engine.CFMLEngineFactory" ).getInstance();
		var osgiUtil   = CreateObject( "java", "lucee.runtime.osgi.OSGiUtil" );
		var lib        = ExpandPath( GetDirectoryFromPath( GetCurrentTemplatePath() ) & "../lib/socketio-lucee-1.0.0.jar" );
		var resource   = cfmlEngine.getResourceUtil().toResourceExisting( getPageContext(), lib );

		osgiUtil.installBundle( cfmlEngine.getBundleContext(), resource, true );
	}

	/**
	 * Private helper to help with cross language
	 * communication of callback arguments.
	 */
	private array function _prepareArgs( required array args ) {
		var javaServer = _getJavaServer();

		for( var i=1; i<=ArrayLen( arguments.args ); i++ ) {
			if ( !IsSimpleValue( arguments.args[ i ] ) ) {
				arguments.args[ i ] = javaServer.toJsonObj( SerializeJson( arguments.args[ i ] ) );
			}
		}

		return arguments.args;
	}

}