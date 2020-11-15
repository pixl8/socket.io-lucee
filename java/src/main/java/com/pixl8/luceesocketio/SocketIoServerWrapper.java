package com.pixl8.luceesocketio;

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
				try{
					mCfcHandler.callMethod( "onConnect", luceeArgs );
				} catch( Exception e ) {
					e.printStackTrace();
				}

				socket.on( "disconnecting", new Emitter.Listener() {
					@Override
					public void call(Object... args) {
						try{
							mCfcHandler.callMethod( "onDisconnecting", luceeArgs );
						} catch( Exception e ) {
							e.printStackTrace();
						}
					}
				} );

				socket.on( "disconnect", new Emitter.Listener() {
					@Override
					public void call(Object... args) {
						try{
							mCfcHandler.callMethod( "onDisconnect", luceeArgs );
						} catch( Exception e ) {
							e.printStackTrace();
						}
						mSockets.remove( socket.getId() );
					}
				} );
			}
		});

		return ns;
	}

	public int getPort() {
		return mAddress.getPort();
	}

	public String getHostName() {
		return mAddress.getHostName();
	}

	public SocketIoServer getSocketIoServer() {
		return mSocketIoServer;
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