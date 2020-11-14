component implements="luceesocketio.models.server.ILuceeWebsocketServerListener" {

	variables.disconnections = [];
	variables.connections    = [];
	variables.messages       = [];

	public void function onConnect( any connectionDetail, numeric connectionId, string connectionUrl ) {
		connections.append( { connectionId=connectionId, connectionUrl=connectionUrl } );
	}

	public void function onFullTextMessage( numeric connectionId, string message ) {
		messages.append( { connectionId=connectionId, message=message } );
	}

	public void function onDisconnect( numeric connectionId ) {
		disconnections.append( connectionId );
	}

	public struct function getMemento() {
		return {
			  disconnections = variables.disconnections
			, connections    = variables.connections
			, messages       = variables.messages
		};
	}

}