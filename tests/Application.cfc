component {

	this.name = "luceesocketiotests";

	this.mappings[ "/tests" ]         = ExpandPath( "/" );
	this.mappings[ "/luceesocketio" ] = ExpandPath( "/../" );
	this.mappings[ "/testbox" ]       = ExpandPath( "/testbox" );

	processingdirective preserveCase="true";

}