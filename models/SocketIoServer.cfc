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
	 * @enableCorsHandling.hint Whether or not to enable CORS handling
	 * @pingInterval.hint How often the server + client will ping/pong to verify connection is still alive (in ms)
	 * @pingTimeout.hint How long to wait for ping/pong responses before judging that the connection has gone away (in ms)
	 * @maxTimeoutThreadPoolSize.hint Max size of java thread pool for threads that do timeout logic on comms
	 * @allowedCorsOrigins.hint When CORS enabled, string array of allowed origins - defaults to [ "*" ]
	 * @eventRunner.hint Pass a custom event runner to allow alternative methods for executing socket and namespace listeners and ack callbacks
	 * @adapter.hint Pass a custom ISocketIoAdapter instance to allow alternative methods for tracking sockets joining namespaces and rooms and to broadcast to those sockets
	 */
	public any function init(
		  string               host                     = ListFirst( cgi.http_host, ":" )
		, string               port                     = 3000
		, boolean              enableCorsHandling       = false
		, numeric              pingInterval             = 5000
		, numeric              pingTimeout              = 25000
		, numeric              maxTimeoutThreadPoolSize = 20
		, array                allowedCorsOrigins       = [ "*" ]
		, boolean              start                    = true
		, ISocketIoEventRunner eventRunner              = new SocketIoDefaultEventRunner()
		, ISocketIoAdapter     adapter                  = new SocketIoDefaultAdapter()
	) {
		variables._host                     = arguments.host;
		variables._port                     = arguments.port;
		variables._enableCorsHandling       = arguments.enableCorsHandling;
		variables._pingInterval             = arguments.pingInterval;
		variables._pingTimeout              = arguments.pingTimeout;
		variables._maxTimeoutThreadPoolSize = arguments.maxTimeoutThreadPoolSize;
		variables._allowedCorsOrigins       = arguments.allowedCorsOrigins;
		variables._eventRunner              = arguments.eventRunner;
		variables._adapter                  = arguments.adapter;

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
				  name        = arguments.namespace
				, ioserver    = this
				, eventRunner = variables._eventRunner
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

	/**
	 * Gets array of registered namespace names
	 *
	 */
	public array function getRegisteredNamespaces() {
		return StructKeyArray( variables._namespaces );
	}


// START/STOP SERVER + STATUS
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

	/**
	 * Returns whether or not the server is running
	 *
	 */
	public boolean function isRunning() {
		return _serverIsRegistered() && _getJavaServer().isServerRunning();
	}

	/**
	 * Gets the state of the embedded server. One of:
	 *
	 * NOTINITIALIZED,FAILED,RUNNING,STARTED,STARTING,STOPPED,STOPPING
	 */
	public string function getState() {
		return _serverIsRegistered() ? _getJavaServer().getServerState() : "NOTINITIALIZED";
	}

// PACKAGE METHODS FOR INTERNAL USE
	/**
	 * Internal use for namespace and socket objects
	 * to communicate with underlying broadcast adapter
	 */
	package void function $broadcast(
		  required string event
		,          string socketId  = ""
		,          string namespace = ""
		,          any    args      = []
		,          any    rooms     = []
	) {
		if ( !IsArray( arguments.args ) ) {
			arguments.args = [ arguments.args ];
		}
		if ( !IsArray( arguments.rooms ) ) {
			arguments.rooms = [ arguments.rooms ];
		}

		if ( Len( arguments.namespace ) ) {
			variables._adapter.namespaceBroadcast(
				  namespace = arguments.namespace
				, event     = arguments.event
				, rooms     = arguments.rooms
				, args      = arguments.args
			);
		} else if ( Len( arguments.socketId ) ) {
			variables._adapter.socketBroadcast(
				  socketId = arguments.socketId
				, event    = arguments.event
				, rooms    = arguments.rooms
				, args     = arguments.args
			);
		}

	}

	/**
	 * Internal use for namespace and socket objects
	 * to communicate with underlying Java framework.
	 */
	package void function $send(
		  required string socketId
		, required string namespace
		, required string event
		,          any    args  = []
		,          string ackId = ""
	) {
		if ( !IsArray( arguments.args ) ) {
			arguments.args = [ arguments.args ];
		}

		if ( Len( arguments.ackId ) ) {
			_getJavaServer().socketSend(
				  arguments.namespace
				, arguments.socketId
				, arguments.event
				, _prepareArgs( args )
				, arguments.ackId
			);
		} else {
			_getJavaServer().socketSend(
				  arguments.namespace
				, arguments.socketId
				, arguments.event
				, _prepareArgs( args )
			);
		}
	}

	/**
	 * Internal use for namespace and socket objects
	 * to communicate with underlying broadcast adapter
	 */
	package void function $joinRoom( required string socketId, required string roomName ) {
		variables._adapter.joinRoom( arguments.socketId, arguments.roomName );
	}

	/**
	 * Internal use for namespace and socket objects
	 * to communicate with underlying broadcast adapter
	 */
	package void function $leaveRoom( required string socketId, required string roomName ) {
		variables._adapter.leaveRoom( arguments.socketId, arguments.roomName );
	}

	/**
	 * Internal use for namespace and socket objects
	 * to communicate with underlying broadcast adapter
	 */
	package void function $leaveAllRooms( required string socketId ) {
		variables._adapter.leaveAllRooms( arguments.socketId );
	}

	/**
	 * Internal use for namespace and socket objects
	 * to communicate with underlying Java framework.
	 */
	package void function $disconnect( required string socketId, required boolean close ) {
		variables._adapter.deregisterSocket( arguments.socketId );
		_getJavaServer().socketDisconnect( arguments.socketId, arguments.close );
	}


// UNDER-THE-HOOD LISTENER INTERFACE
	/**
	 * Internal use for the underlying Java framework
	 * to communicate with our CFML layer.
	 */
	public void function onConnect( required string namespace, required string socketId, required any initialRequest ) {
		var ns     = this.namespace( arguments.namespace );
		var socket = ns.$registerSocket( arguments.socketId, arguments.initialRequest );

		variables._adapter.registerSocket( socket );

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
			variables._adapter.deRegisterSocket( arguments.socketId );
		}
	}

	/**
	 * Internal use for the underlying Java framework
	 * to communicate with our CFML layer.
	 */
	public void function onSocketEvent( required string namespace, required string socketId, required string event, array args=[] ) {
		var ns     = this.namespace( arguments.namespace );
		var socket = ns.$getSocket( arguments.socketId );

		socket.$runEvent( arguments.event, SocketIoUtils::eventArgsToCf( args ) );
	}

	/**
	 * Internal use for the underlying Java framework
	 * to communicate with our CFML layer
	 *
	 */
	public void function onAckCallback(
		  required string namespace
		, required string socketId
		, required string ackId
		, required array  args
	) {
		var ns     = this.namespace( arguments.namespace );
		var socket = ns.$getSocket( arguments.socketId );

		socket.$runAckCallback( arguments.ackId, arguments.args );
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
				, !variables._enableCorsHandling           // corsHandlingDisabled
				, variables._pingInterval                  // pingInterval
				, variables._pingTimeout                   // pingTimeout
				, variables._maxTimeoutThreadPoolSize      // maxTimeoutThreadPoolSize
				, _getAllowedCorsOrigins()                 // allowedCorsOrigins
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

	/**
	 * Utility to pass back CORS origins in format that
	 * is useful for our java lib
	 *
	 */
	private any function _getAllowedCorsOrigins() {
		if ( !ArrayLen( variables._allowedCorsOrigins ) || ArrayFind( variables._allowedCorsOrigins, "*" ) ) {
			return JavaCast( "null", NullValue() );
		}
		return JavaCast( "String[]", variables._allowedCorsOrigins );
	}
}