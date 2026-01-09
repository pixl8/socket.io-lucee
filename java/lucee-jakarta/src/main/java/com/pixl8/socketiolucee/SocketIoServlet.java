package com.pixl8.socketiolucee;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpServletRequestWrapper;

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