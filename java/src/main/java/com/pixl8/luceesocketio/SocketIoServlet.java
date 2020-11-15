package com.pixl8.luceesocketio;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletRequestWrapper;

import io.socket.engineio.server.EngineIoServer;

@WebServlet(value = "/engine.io/*", asyncSupported = true)
public class SocketIoServlet extends HttpServlet {

	private EngineIoServer mEngineIoServer;

	public SocketIoServlet( EngineIoServer server ) {
		mEngineIoServer = server;
	}

	@Override
	protected void service( HttpServletRequest request, HttpServletResponse response ) throws IOException {
		mEngineIoServer.handleRequest( new HttpServletRequestWrapper( request ) {
			@Override
			public boolean isAsyncSupported() {
				return true;
			}
		}, response );
	}
}