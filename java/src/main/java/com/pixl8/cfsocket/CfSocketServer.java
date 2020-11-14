package com.pixl8.cfsocket;

import io.undertow.Undertow;
import io.undertow.server.handlers.resource.ClassPathResourceManager;
import io.undertow.server.handlers.PathHandler;
import io.undertow.websockets.core.*;
import io.undertow.websockets.WebSocketConnectionCallback;
import io.undertow.websockets.spi.WebSocketHttpExchange;

import static io.undertow.Handlers.path;
import static io.undertow.Handlers.resource;
import static io.undertow.Handlers.websocket;

import java.io.IOException;
import java.util.*;
import javax.servlet.ServletException;
import lucee.runtime.exp.PageException;
import lucee.runtime.Component;
import lucee.runtime.listener.ApplicationContext;

public class CfSocketServer {
	private Undertow                   server;
	private String                     host;
	private int                        port;
	private LuceeCfcProxy              cfcHandler;
	private Map<Integer, WebSocketChannel> connections;

	public CfSocketServer( Component handlerCfc, String contextRoot, ApplicationContext appContext, String host, int port ) throws PageException, ServletException {
		this.cfcHandler = new LuceeCfcProxy( handlerCfc, contextRoot, appContext, host );
		this.host       = host;
		this.port       = port;

		Map<Integer, WebSocketChannel> unsafeMap = new HashMap<>();
		this.connections = Collections.synchronizedMap( unsafeMap );
	}

	public void start() {
		if (server == null) {
			server = Undertow.builder()
							 .addListener( port, host )
							 .setHandler( _getWebSocketHandler() )
							 .build();
		}

		server.start();
	}

	public void stop() {
		if (server != null) {
			server.stop();
		}
	}

	public void sendText( String message, int channelId ) {
		WebSocketChannel channel = getChannel( channelId );

		if ( channel != null ) {
			WebSockets.sendText( message, channel, null );
		}
	}

	public void sendText( String message, int[] channelIds ) {
		for ( int i = 0; i < channelIds.length; i++ ) {
			sendText( message, channelIds[ i ] );
		}
	}

	public int getConnectionCount() {
		return connections.size();
	}

	public WebSocketChannel getChannel( int channelId ) {
		WebSocketChannel channel = connections.get( channelId );

		if ( !channel.isOpen() ) {
			connections.remove( channelId );
			return null;
		}

		return channel;
	}

	public void closeChannel( int channelId ) throws IOException {
		WebSocketChannel channel = getChannel( channelId );

		if ( channel != null ) {
			channel.close();
			connections.remove( channelId );
		}
	}

// PRIVATE HELPERS
	private PathHandler _getWebSocketHandler() {
		return path().addPrefixPath( "/", websocket( new WebSocketConnectionCallback() {
			@Override
			public void onConnect( WebSocketHttpExchange exchange, WebSocketChannel channel ) {
				int channelId = channel.hashCode();
				connections.put( channelId, channel );

				Object[] onConnectArgs = { exchange, channelId, channel.getUrl() };
				try {
					cfcHandler.callMethod( "onConnect", onConnectArgs );
				} catch( Exception e ) {
					// todo
				}

				channel.getReceiveSetter().set( new AbstractReceiveListener() {
					@Override
					protected void onFullTextMessage( WebSocketChannel channel, BufferedTextMessage message ) {
						int channelId = channel.hashCode();
						Object[] onFullTextMessageArgs = { channelId, message.getData() };

						try {
							cfcHandler.callMethod( "onFullTextMessage", onFullTextMessageArgs );
						} catch( Exception e ) {
							// todo
						}
					}
				});

				channel.resumeReceives();
			}
		} ) );
	}
}
