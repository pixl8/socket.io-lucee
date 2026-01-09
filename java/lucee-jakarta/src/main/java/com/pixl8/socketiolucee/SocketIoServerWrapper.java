package com.pixl8.socketiolucee;

import io.socket.socketio.server.*;
import io.socket.socketio.server.SocketIoSocket.ReceivedByRemoteAcknowledgementCallback;
import io.socket.engineio.server.EngineIoServer;
import io.socket.engineio.server.EngineIoServerOptions;
import io.socket.engineio.server.JettyWebSocketHandler;
import io.socket.emitter.Emitter;
import io.socket.parseqs.ParseQS;
import org.eclipse.jetty.http.pathmap.ServletPathSpec;
import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.ee10.servlet.ServletContextHandler;
import org.eclipse.jetty.ee10.servlet.ServletHolder;
import org.eclipse.jetty.websocket.server.WebSocketUpgradeHandler;
import org.eclipse.jetty.websocket.server.ServerWebSocketContainer;
import org.eclipse.jetty.websocket.server.WebSocketCreator;
import org.eclipse.jetty.websocket.server.ServerUpgradeRequest;
import org.eclipse.jetty.websocket.server.ServerUpgradeResponse;
import org.json.JSONObject;

import java.util.*;
import java.net.InetSocketAddress;
import java.io.IOException;
import jakarta.servlet.ServletException;
import lucee.runtime.exp.PageException;
import lucee.runtime.Component;
import lucee.runtime.listener.ApplicationContext;

public class SocketIoServerWrapper {

	private InetSocketAddress           mAddress;
	private Server                      mServer;
	private EngineIoServer              mEngineIoServer;
	private SocketIoServer              mSocketIoServer;
	private LuceeCfcProxy               mCfcHandler;
	private Map<String, SocketIoSocket> mSockets;

	static {
		// Jetty 12 uses SLF4J - disable logging via system properties
		System.setProperty("org.slf4j.simpleLogger.defaultLogLevel", "off");
	}

	public SocketIoServerWrapper(
		  Component          handlerCfc
		, String             contextRoot
		, ApplicationContext appContext
		, String             host
		, int                port
		, boolean            corsHandlingDisabled
		, long               pingInterval
		, long               pingTimeout
		, int                maxTimeoutThreadPoolSize
		, String[]           allowedCorsOrigins
	) throws PageException, ServletException {

		mCfcHandler     = new LuceeCfcProxy( handlerCfc, contextRoot, appContext, host );
		mAddress        = new InetSocketAddress( host, port );
		mServer         = new Server( mAddress );
		mEngineIoServer = new EngineIoServer( _setupEngineIoOptions( corsHandlingDisabled, pingInterval, pingTimeout, maxTimeoutThreadPoolSize, allowedCorsOrigins ) );
		mSocketIoServer = new SocketIoServer( mEngineIoServer );

		mSockets = Collections.synchronizedMap( new HashMap<String, SocketIoSocket>());

		_setupJettyServer();
		registerNamespace( "/", true );
	}

	public void startServer() throws Exception {
		mServer.start();
	}

	public void stopServer() throws Exception {
		mServer.stop();
	}

	public boolean isServerRunning() {
		return mServer.isRunning();
	}

	public String getServerState() {
		return mServer.getState();
	}

	public void registerNamespace( String namespace ) {
		registerNamespace( namespace, false );
	}

	public void registerNamespace( String namespace, boolean force ) {
		if ( !force && hasNamespace( namespace ) ) {
			return;
		}

		SocketIoNamespace ns = mSocketIoServer.namespace( namespace );

		ns.on( "connect", new Emitter.Listener() {
			@Override
			public void call(Object... args) {
				SocketIoSocket socket = (SocketIoSocket) args[0];

				mSockets.put( socket.getId(), socket );
				Object[] luceeArgs = new Object[] { ns.getName(), socket.getId(), socket.getConnection().getInitialRequest() };

				_luceeCall( "onConnect", luceeArgs );

				socket.on( "disconnecting", new Emitter.Listener() {
					@Override
					public void call(Object... args) {
						_luceeCall( "onDisconnecting", luceeArgs );
					}
				} );

				socket.on( "disconnect", new Emitter.Listener() {
					@Override
					public void call(Object... args) {
						_luceeCall( "onDisconnect", luceeArgs );
						mSockets.remove( socket.getId() );
					}
				} );

				socket.registerAllEventListener( new SocketIoSocket.AllEventListener() {
					@Override
					public void event(String eventName, Object... args) {
						Object[] arrayArgs = args;
						Object[] luceeArgs = { namespace, socket.getId(), eventName, arrayArgs };

						_luceeCall( "onSocketEvent", luceeArgs );
					}
				} );
			}
		});
	}

	public boolean hasNamespace( String namespace ) {
		return mSocketIoServer.hasNamespace( namespace );
	}

// SOCKET PROXIES
	public void socketDisconnect( String socketId, boolean close ) {
		SocketIoSocket socket = _getSocket( socketId );

		if ( socket != null ) {
			socket.disconnect( close );
		}
	}

	public void socketSend( String namespace, String socketId, String event, Object... args ) {
		SocketIoSocket socket = _getSocket( socketId );

		if ( socket != null ) {
			socket.send( event, args );
		}
	}

	public void socketSend( String namespace, String socketId, String event, Object[] args, String ackId ) {
		SocketIoSocket socket = _getSocket( socketId );

		if ( socket != null ) {
			socket.send( event, args, new SocketIoSocket.ReceivedByRemoteAcknowledgementCallback() {
				@Override
				public void onReceivedByRemote(Object... ackArgs) {
					Object[] arrayArgs = ackArgs;
					Object[] luceeArgs = { namespace, socketId, ackId, arrayArgs };

					_luceeCall( "onAckCallback", luceeArgs );
				}
			} );
		}
	}

// HELPERS
	public JSONObject toJsonObj( String json ){
		return new JSONObject( json );
	}

// PRIVATE
	private void _setupJettyServer() {
		// Jetty 12 uses SLF4J - disable logging via system properties
		System.setProperty("org.eclipse.jetty.LEVEL", "OFF");

		ServletContextHandler servletContextHandler = new ServletContextHandler( ServletContextHandler.SESSIONS );
		servletContextHandler.setContextPath( "/" );

		servletContextHandler.addServlet( new ServletHolder( new SocketIoServlet( mEngineIoServer ) ), "/socket.io/*" );

		try {
			WebSocketUpgradeHandler webSocketHandler = WebSocketUpgradeHandler.from(mServer, servletContextHandler, (ServerWebSocketContainer container) -> {
				WebSocketCreator creator = (ServerUpgradeRequest upgradeRequest, ServerUpgradeResponse upgradeResponse, org.eclipse.jetty.util.Callback callback) -> {
					JettyWebSocketHandler handler = new JettyWebSocketHandler(mEngineIoServer);
					// Extract query string from upgrade request
					String queryString = upgradeRequest.getHttpURI().getQuery();
					if (queryString != null) {
						handler.setQuery(ParseQS.decode(queryString));
					}
					return handler;
				};
				container.addMapping("/socket.io/*", creator);
			});
			servletContextHandler.insertHandler(webSocketHandler);
		} catch ( Exception ex ) {
			ex.printStackTrace();
		}

		Handler.Sequence handlers = new Handler.Sequence( servletContextHandler );
		mServer.setHandler( handlers );
	}

	private SocketIoSocket _getSocket( String socketId ) {
		return mSockets.get( socketId );
	}

	private void _luceeCall( String method, Object[] args ) {
		try{
			mCfcHandler.callMethod( method, args );
		} catch( Exception e ) {
			e.printStackTrace();
		}
	}

	public EngineIoServerOptions _setupEngineIoOptions(
		  boolean  corsHandlingDisabled
		, long     pingInterval
		, long     pingTimeout
		, int      maxTimeoutThreadPoolSize
		, String[] allowedCorsOrigins
	) {
		EngineIoServerOptions options = EngineIoServerOptions.newFromDefault();

		options.setCorsHandlingDisabled( corsHandlingDisabled );
		options.setPingInterval( pingInterval );
		options.setPingTimeout( pingTimeout );
		options.setAllowedCorsOrigins( allowedCorsOrigins );
		options.setMaxTimeoutThreadPoolSize( maxTimeoutThreadPoolSize );
		options.setInitialPacket( null );

		return options;
    }

}