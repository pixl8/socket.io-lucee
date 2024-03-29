package com.pixl8.socketiolucee;

import io.socket.socketio.server.*;
import io.socket.socketio.server.SocketIoSocket.ReceivedByRemoteAcknowledgementCallback;
import io.socket.engineio.server.EngineIoServer;
import io.socket.engineio.server.EngineIoServerOptions;
import io.socket.engineio.server.JettyWebSocketHandler;
import io.socket.emitter.Emitter;
import org.eclipse.jetty.http.pathmap.ServletPathSpec;
import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.handler.HandlerList;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;
import org.eclipse.jetty.util.log.Log;
import org.eclipse.jetty.util.log.Logger;
import org.eclipse.jetty.websocket.server.WebSocketUpgradeFilter;
import org.json.JSONObject;

import java.util.*;
import java.net.InetSocketAddress;
import java.io.IOException;
import javax.servlet.ServletException;
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
		Log.setLog(new JettyNoLogging());
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
		System.setProperty("org.eclipse.jetty.util.log.class", "org.eclipse.jetty.util.log.StdErrLog");
		System.setProperty("org.eclipse.jetty.LEVEL", "OFF");

		ServletContextHandler servletContextHandler = new ServletContextHandler( ServletContextHandler.SESSIONS );
		servletContextHandler.setContextPath( "/" );

		servletContextHandler.addServlet( new ServletHolder( new SocketIoServlet( mEngineIoServer ) ), "/socket.io/*" );

		try {
			WebSocketUpgradeFilter webSocketUpgradeFilter = WebSocketUpgradeFilter.configureContext(servletContextHandler);
			webSocketUpgradeFilter.addMapping(
					new ServletPathSpec( "/socket.io/*" ),
					( servletUpgradeRequest, servletUpgradeResponse ) -> new JettyWebSocketHandler( mEngineIoServer ) );
		} catch ( ServletException ex ) {
			ex.printStackTrace();
		}

		HandlerList handlerList = new HandlerList();
		handlerList.setHandlers( new Handler[] { servletContextHandler } );
		mServer.setHandler( handlerList );
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

	private static final class JettyNoLogging implements Logger {

		@Override
		public String getName() {
			return "no";
		}

		@Override
		public void warn(String s, Object... objects) {
		}

		@Override
		public void warn(Throwable throwable) {
		}

		@Override
		public void warn(String s, Throwable throwable) {
		}

		@Override
		public void info(String s, Object... objects) {
		}

		@Override
		public void info(Throwable throwable) {
		}

		@Override
		public void info(String s, Throwable throwable) {
		}

		@Override
		public boolean isDebugEnabled() {
			return false;
		}

		@Override
		public void setDebugEnabled(boolean b) {
		}

		@Override
		public void debug(String s, Object... objects) {
		}

		@Override
		public void debug(String s, long l) {
		}

		@Override
		public void debug(Throwable throwable) {
		}

		@Override
		public void debug(String s, Throwable throwable) {
		}

		@Override
		public Logger getLogger(String s) {
			return this;
		}

		@Override
		public void ignore(Throwable throwable) {
		}
	}
}