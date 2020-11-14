component implements="luceesocketio.models.server.ILuceeWebsocketServerListener" {

	variables.connections = [];
	variables.messages    = [];

	public void function onConnect( any connection, numeric channel, string channelUrl ) {
		connections.append( { channel=channel, channelUrl=channelUrl } );
	}

	public void function onFullTextMessage( numeric channel, string message ) {
		messages.append( { channel=channel, message=message } );
	}

}