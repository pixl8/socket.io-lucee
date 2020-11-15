package com.pixl8.socketiolucee;

import io.socket.socketio.server.*;
import io.socket.engineio.server.EngineIoServer;
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

	public SocketIoServerWrapper( Component handlerCfc, String contextRoot, ApplicationContext appContext, String host, int port ) throws PageException, ServletException {
		mCfcHandler     = new LuceeCfcProxy( handlerCfc, contextRoot, appContext, host );
		mAddress        = new InetSocketAddress( host, port );
		mServer         = new Server( mAddress );
		mEngineIoServer = new EngineIoServer();
		mSocketIoServer = new SocketIoServer( mEngineIoServer );

		mSockets = Collections.synchronizedMap( new HashMap<String, SocketIoSocket>());

		_setupJettyServer();
	}

	public void startServer() throws Exception {
		mServer.start();
	}

	public void stopServer() throws Exception {
		mServer.stop();
	}

	public SocketIoNamespace registerNamespace( String name ) {
		SocketIoNamespace ns = mSocketIoServer.namespace( name );

		ns.on( "connect", new Emitter.Listener() {
			@Override
			public void call(Object... args) {
				SocketIoSocket socket = (SocketIoSocket) args[0];
				mSockets.put( socket.getId(), socket );
				Object[] luceeArgs = new Object[] { ns.getName(), socket.getId() };

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
			}
		});

		return ns;
	}

// NAMESPACE PROXIES
	public void namespaceBroadcast( String ns, String room, String event, Object... args ) {
		mSocketIoServer.namespace( ns ).broadcast( room, event, args );
	}
	public void namespaceBroadcast( String ns, String[] rooms, String event, Object... args ) {
		mSocketIoServer.namespace( ns ).broadcast( rooms, event, args );
	}

// SOCKET PROXIES
	public void socketBroadcast( String socketId, String room, String event, Object... args ) {
		SocketIoSocket socket = _getSocket( socketId );

		if ( socket != null ) {
			socket.broadcast( room, event, args );
		}
	}
	public void socketBroadcast( String socketId, String[] rooms, String event, Object... args ) {
		SocketIoSocket socket = _getSocket( socketId );

		if ( socket != null ) {
			socket.broadcast( rooms, event, args );
		}
	}

	public void socketDisconnect( String socketId, boolean close ) {
		SocketIoSocket socket = _getSocket( socketId );

		if ( socket != null ) {
			socket.disconnect( close );
		}
	}

	public void socketJoinRoom( String socketId, String... rooms ) {
		SocketIoSocket socket = _getSocket( socketId );

		if ( socket != null ) {
			socket.joinRoom( rooms );
		}
	}

	public void socketLeaveRoom( String socketId, String... rooms ) {
		SocketIoSocket socket = _getSocket( socketId );

		if ( socket != null ) {
			socket.leaveRoom( rooms );
		}
	}

	public void socketLeaveAllRooms( String socketId ) {
		SocketIoSocket socket = _getSocket( socketId );

		if ( socket != null ) {
			socket.leaveAllRooms();
		}
	}

	public void socketSend( String socketId, String event, Object... args ) {
		SocketIoSocket socket = _getSocket( socketId );

		if ( socket != null ) {
			socket.send( event, args );
		}
	}

	public void socketSendWithCallback( String socketId, String event, Object[] args, String callbackRef ) {
		SocketIoSocket socket = _getSocket( socketId );

		if ( socket != null ) {
			socket.send( event, args, new SocketIoSocket.ReceivedByRemoteAcknowledgementCallback(){
				@Override
				public void onReceivedByRemote(Object... args) {
					Object[] arrayArgs = args;
					Object[] luceeArgs = { socketId, event, callbackRef, args };

					_luceeCall( "onSocketSendCallback", luceeArgs );
				}
			} );
		}
	}

	public void socketOn( String socketId, String event, String callbackRef ) {
		SocketIoSocket socket = _getSocket( socketId );

		if ( socket != null ) {
			socket.on( event, new Emitter.Listener() {
				@Override
				public void call(Object... args) {
					Object[] arrayArgs = args;
					Object[] luceeArgs = { socketId, event, callbackRef, args };

					_luceeCall( "onSocketEvent", luceeArgs );
				}
			} );
		}
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