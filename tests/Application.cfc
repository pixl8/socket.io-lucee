component {

	this.name = "luceesocketiotests";

	this.mappings[ "/tests" ]         = ExpandPath( "/" );
	this.mappings[ "/socketiolucee" ] = ExpandPath( "/../" );
	this.mappings[ "/testbox" ]       = ExpandPath( "/testbox" );

	processingdirective preserveCase="true";

}