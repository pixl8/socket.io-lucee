package com.pixl8.websocketclient;

import java.net.URI;
import java.util.concurrent.TimeUnit;
import java.net.URISyntaxException;

import org.eclipse.jetty.websocket.client.ClientUpgradeRequest;
import org.eclipse.jetty.websocket.client.WebSocketClient;

public class Client {
	private WebSocketClient client;
	private Socket socket;
	private URI serverUri;

	public Client( String serverUri ) throws URISyntaxException {
		this.client = new WebSocketClient();
        this.socket = new Socket();
        this.serverUri = new URI(serverUri);
    }

    public void testConnection() {
        try {
            client.start();
            ClientUpgradeRequest request = new ClientUpgradeRequest();
            client.connect(socket, serverUri, request);
            socket.awaitClose(5, TimeUnit.SECONDS);
        } catch (Throwable t) {
            t.printStackTrace();
        } finally {
            try {
                client.stop();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
	}
}