component accessors=true {
	property name="cookies"     type="array";
	property name="headers"     type="struct";
	property name="uri"         type="string";
	property name="queryString" type="string";
	property name="remoteUser"  type="string";

	public struct function getRequestParams() {
		var keyValuePairs = ListToArray( getQueryString(), "&" );
		var params = {};

		for( var kvp in keyValuePairs ) {
			params[ ListFirst( kvp, "=" ) ] = ListRest( kvp, "=" );
		}

		return params;
	}

	public string function getCookieValue( required string cookieName, string defaultValue="" ) {
		for( var cookie in getCookies() ) {
			var name = cookie.get( "name" );
			if ( ( local.name ?: "" ) == arguments.cookieName ) {
				var value = cookie.get( "value" );

				return local.value ?: arguments.defaultValue;
			}
		}

		return arguments.defaultValue;
	}
}