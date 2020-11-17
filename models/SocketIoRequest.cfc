/**
 * Represents the initial request made by a client
 * and contains information about the client's connection
 * such as the originating query string, and URI.
 *
 * It can be retrieved from a Socket object with socket.getHttpRequest().
 *
 */
component accessors=true {
	property name="cookies"     type="array";
	property name="headers"     type="struct";
	property name="uri"         type="string";
	property name="queryString" type="string";
	property name="remoteUser"  type="string";

	/**
	 * Helper method to get the query string as a
	 * struct of params.
	 *
	 */
	public struct function getRequestParams() {
		var keyValuePairs = ListToArray( getQueryString(), "&" );
		var params = {};

		for( var kvp in keyValuePairs ) {
			params[ ListFirst( kvp, "=" ) ] = ListRest( kvp, "=" );
		}

		return params;
	}

	/**
	 * Helper method to get the value of cookie.
	 *
	 * @cookieName.hint The name of the cookie to get
	 * @defaultValue.hint Value to return should the cookie does not exist
	 *
	 */
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