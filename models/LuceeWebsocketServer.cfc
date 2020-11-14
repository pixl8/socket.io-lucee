component {

// CONSTRUCTOR
	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	public void function registerBundle() {
		var cfmlEngine = CreateObject( "java", "lucee.loader.engine.CFMLEngineFactory" ).getInstance();
		var osgiUtil   = CreateObject( "java", "lucee.runtime.osgi.OSGiUtil" );
		var lib        = ExpandPath( GetDirectoryFromPath( GetCurrentTemplatePath() ) & "../lib/cfsocket-1.0.0.jar" );
		var resource   = cfmlEngine.getResourceUtil().toResourceExisting( getPageContext(), lib );
		var bundle     = osgiUtil.installBundle( cfmlEngine.getBundleContext(), resource, true );

bundle.start();
		// osgiUtil.uninstall( bundle );
		// osgiUtil.installBundle( cfmlEngine.getBundleContext(), resource, true );
	}

	// public void function startServer() {
	// 	_getServer().start();
	// }
	// public void function stopServer() {
	// 	_getServer().stop();
	// }

	// public void function onConnect( exchange, channel ) {
	// 	$systemoutput( "onConnect called, channel: #channel.getUrl()#" );
	// }

	// public void function onFullTextMessage( channel, message ) {
	// 	$systemoutput( "onFullTextMessage called from: #channel.getUrl()#. Message: #message#" );
	// 	createObject( "java", "io.undertow.websockets.core.WebSockets", "com.pixl8.CfSocket" ).sendText(
	// 		  "Oi #Now()#"
	// 		, channel
	// 		, NullValue()
	// 	);
	// }


// PRIVATE HELPERS
	// private any function _getServer() {
	// 	if ( !StructKeyExists( variables, "_websocketServer" ) ) {
	// 		var CFMLEngine = createObject( "java", "lucee.loader.engine.CFMLEngineFactory" ).getInstance();
	// 		var OSGiUtil = createObject( "java", "lucee.runtime.osgi.OSGiUtil" );
	// 		var resource = CFMLEngine.getResourceUtil().toResourceExisting( getPageContext(), _getLib()[ 1 ] );

	// 		var bundle = OSGiUtil.installBundle(
 //    			CFMLEngine.getBundleContext(),
 //    			resource,
 //    			true
 //    		);

	// 		variables._websocketServer = createObject( "java", "com.pixl8.cfsocket.CfSocketServer", "com.pixl8.CfSocket" ).init(
	// 			  this                                     // handlerCfc
	// 			, ExpandPath( "/" )                        // contextRoot
	// 			, getPageContext().getApplicationContext() // appCOntext
	// 			, "127.0.0.1"                              // host
	// 			, 8888
	// 		);
	// 	}

	// 	return variables._websocketServer;
	// }

	// private array function _getLib() {
	// 	if ( !StructKeyExists( variables, "_lib" ) ) {
	// 		var path = GetDirectoryFromPath( GetCurrentTemplatePath() ) & "lib/";

	// 		variables._lib = DirectoryList( path, false, "path", "*.jar" );
	// 	}

	// 	return variables._lib;
	// }

// GETTERS AND SETTERS

}