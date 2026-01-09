package io.socket.engineio.server;

import io.socket.parseqs.ParseQS;
import org.eclipse.jetty.websocket.api.Session;
import org.eclipse.jetty.websocket.api.Session.Listener;
import org.eclipse.jetty.websocket.api.Callback;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Map;

/**
 * Adapter for Jetty WebSocket implementation.
 */
public final class JettyWebSocketHandler extends EngineIoWebSocket implements Listener {

    private final EngineIoServer mServer;

    private Session mSession;
    private Map<String, String> mQuery;

    @SuppressWarnings("WeakerAccess")
    public JettyWebSocketHandler(EngineIoServer server) {
        mServer = server;
    }

    /* EngineIoWebSocket */

    @Override
    public Map<String, String> getQuery() {
        return mQuery;
    }

    @Override
    public void write(String message) throws IOException {
        assert mSession != null;

        mSession.sendText(message, Callback.NOOP);
    }

    @Override
    public void write(byte[] message) throws IOException {
        assert mSession != null;

        mSession.sendBinary(ByteBuffer.wrap(message), Callback.NOOP);
    }

    @Override
    public void close() {
        if (mSession != null)
            mSession.close();
    }

    /* Session.Listener.AutoDemanding */

    public void setQuery(Map<String, String> query) {
        mQuery = query;
    }

    public void onOpen(Session session) {
        mSession = session;
        // Query string will be set via setQuery() method before this is called
        if (mQuery == null) {
            mQuery = java.util.Collections.emptyMap();
        }

        mServer.handleWebSocket(this);
    }

    public void onClose(Session session, int statusCode, String reason) {
        emit("close");
        mSession = null;
    }

    public void onError(Session session, Throwable cause) {
        emit("error", "write error", cause.getMessage());
    }

    public void onMessage(Session session, ByteBuffer payload) {
        byte[] message;
        if (payload.hasArray() && payload.arrayOffset() == 0 && payload.array().length == payload.remaining()) {
            message = payload.array();
        } else {
            message = new byte[payload.remaining()];
            payload.get(message);
        }

        emit("message", (Object) message);
    }

    public void onMessage(Session session, String message) {
        emit("message", (Object) message);
    }
}
