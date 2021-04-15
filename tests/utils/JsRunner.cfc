component {

	public static string function executeScript( String script ) {
		var output = "";
		var erroroutput = "";

		execute name="/usr/bin/node" arguments="#ExpandPath( script )#" timeout=30 variable="output" errorvariable="erroroutput";

		if ( Len( Trim( local.erroroutput ?: "" ) ) ) {
			throw( type="node.error", message="Error output was returned.", detail=erroroutput );
		}

        return output;
    }
}