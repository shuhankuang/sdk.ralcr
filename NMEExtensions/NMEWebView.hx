#if openfl

class NMEWebView {
	
	public var didFinishLoad :RCSignal<String->Void>;
	public var didFinishWithError :RCSignal<String->Void>;
	
#if android

	var checkTimer :haxe.Timer;
	var ralcr_new_web_view :Dynamic;
	var ralcr_destroy_web_view :Dynamic;
	var ralcr_did_finish_load_with_url :Dynamic;
	
	/**
	 *  Creates a native WebView with a native frame of x,y,w,h and starts loading the page at url
	 **/
	public function new (x:Float, y:Float, w:Float, h:Float, url:String) {
		
		didFinishLoad = new RCSignal<String->Void>();
		
		ralcr_did_finish_load_with_url = openfl.utils.JNI.createStaticMethod("NMEWebView", "ralcr_did_finish_load_with_url", "()Ljava/lang/String;");
		ralcr_new_web_view = openfl.utils.JNI.createStaticMethod("NMEWebView", "ralcr_new_web_view", "(IIIILjava/lang/String;)Landroid/view/View;");
		
		nme.Lib.postUICallback ( function() { ralcr_new_web_view (x, y, w, h, url); });
		
		checkTimer = haxe.Timer.delay (checkLoadingStatus, 500);
	}
	function checkLoadingStatus () {
		
		if (checkTimer != null)
			checkTimer.stop();
		
		var url :String = ralcr_did_finish_load_with_url();
		if (url != null) {
			if (didFinishLoad != null) didFinishLoad.dispatch ( url );
		}
		checkTimer = haxe.Timer.delay (checkLoadingStatus, 100);
	}
    
	public function destroy() :Void {
		if (checkTimer != null)
			checkTimer.stop();
			checkTimer = null;
		ralcr_destroy_web_view = openfl.utils.JNI.createStaticMethod("NMEWebView", "ralcr_destroy_web_view", "()V");
		nme.Lib.postUICallback ( function() { ralcr_destroy_web_view();});
	}
	
#else
	
	/**
	 *  Creates a native WebView with a native frame of x,y,w,h and starts loading the page at url
	 **/
	public function new (x:Float, y:Float, w:Float, h:Float, url:String) {
		
		didFinishLoad = new RCSignal<String->Void>();
		
		ralcr_set_did_finish_load_handle ( didFinishLoadHandler );
		ralcr_new_web_view (x, y, w, h, url);
	}
	function didFinishLoadHandler (e:Dynamic) {
		didFinishLoad.dispatch ( Std.string(e) );
	}
    
	public function destroy() :Void {
		ralcr_destroy_web_view();
	}
    
	static var ralcr_new_web_view = flash.Lib.load("nme", "ralcr_new_web_view", 5);
	static var ralcr_destroy_web_view = flash.Lib.load("nme", "ralcr_destroy_web_view", 0);
	static var ralcr_set_did_finish_load_handle = flash.Lib.load("nme", "ralcr_set_did_finish_load_handle", 1);
#end
}
#end