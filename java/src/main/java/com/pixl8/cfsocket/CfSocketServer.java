package com.pixl8.cfsocket;

import io.undertow.Undertow;
import io.undertow.server.handlers.resource.ClassPathResourceManager;
import io.undertow.server.handlers.PathHandler;
import io.undertow.websockets.core.AbstractReceiveListener;
import io.undertow.websockets.core.BufferedTextMessage;
import io.undertow.websockets.core.WebSocketChannel;
import io.undertow.websockets.core.WebSockets;
import io.undertow.websockets.WebSocketConnectionCallback;
import io.undertow.websockets.spi.WebSocketHttpExchange;

import static io.undertow.Handlers.path;
import static io.undertow.Handlers.resource;
import static io.undertow.Handlers.websocket;

import javax.servlet.ServletException;
import lucee.runtime.exp.PageException;
import lucee.runtime.Component;
import lucee.runtime.listener.ApplicationContext;

public class CfSocketServer {
	private Undertow      server;
	private String        host;
	private int           port;
	private LuceeCfcProxy cfcHandler;

	public CfSocketServer( Component handlerCfc, String contextRoot, ApplicationContext appContext, String host, int port ) throws PageException, ServletException {
		this.cfcHandler = new LuceeCfcProxy( handlerCfc, contextRoot, appContext, host );
		this.host       = host;
		this.port       = port;
	}

	public void start() {
		if (server == null) {
			server = Undertow.builder()
			                 .addListener( port, host )
			                 .setHandler( getWebSocketHandler() )
			                 .build();
		}

		server.start();
	}

	public void stop() {
		if (server != null) {
			server.stop();
		}
	}

	private PathHandler getWebSocketHandler() {
		return path().addPrefixPath( "/", websocket( new WebSocketConnectionCallback() {
			@Override
			public void onConnect( WebSocketHttpExchange exchange, WebSocketChannel channel ) {
				Object[] onConnectArgs = { exchange, channel };
				try {
					cfcHandler.callMethod( "onConnect", onConnectArgs );
				} catch( Exception e ) {
					// todo
				}

				channel.getReceiveSetter().set( new AbstractReceiveListener() {
					@Override
					protected void onFullTextMessage( WebSocketChannel channel, BufferedTextMessage message ) {
						Object[] onFullTextMessageArgs = { channel, message.getData() };

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
