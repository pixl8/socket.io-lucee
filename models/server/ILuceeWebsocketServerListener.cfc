interface {
	public void function onConnect( any connectionDetail, numeric connectionId, string connectionUrl );
	public void function onDisconnect( numeric connectionId );
	public void function onFullTextMessage( numeric connectionId, string message );
}