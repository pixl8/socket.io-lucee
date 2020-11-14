component {

	public any function init( uri ) {
		variables._client = CreateObject( "java", "com.pixl8.websocketclient.Client", _getLib() ).init( JavaCast( "String", uri ) );
	}

	public any function testConnection() {
		return variables._client.testConnection();
	}

// PRIVATE HELPERS
	private array function _getLib() {
		return DirectoryList( ExpandPath( "/tests/util/lib" ), false, "path", "*.jar" );
	}

}