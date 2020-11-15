interface {
	public void function onConnect( required string namespace, required string socketId );
	public void function onDisconnecting( required string namespace, required string socketId );
	public void function onDisconnect( required string namespace, required string socketId );
	public void function onSocketSendCallback( required string socketId, required string event, required string callbackRef, array args );
	public void function onSocketEvent( required string socketId, required string event, required string callbackRef, array args );
}