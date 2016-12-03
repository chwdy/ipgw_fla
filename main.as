import flash.events.KeyboardEvent;
import flash.desktop.*
import flash.ui.Keyboard
import flash.events.MouseEvent;
import flash.net.*
import flash.events.HTTPStatusEvent;
import flash.events.ProgressEvent;



var aa: SharedObject = SharedObject.getLocal("account_info")
account_text.restrict = "0-9"
var readyexit = false
var timetick
var backcount = 0
var show_left = false
var urlLoader: URLLoader;
var loader_on = false;
include "update_data.as" ////更新数据的都在这里
version_text.text = aa.data.version

if (aa.data.version < aa.data.online_version) {
	version_text.textColor = 0xd22222;
	version_text.text = "发现新版本"
	version_text.addEventListener(MouseEvent.MOUSE_UP, function () {
		var url = aa.data.pages.toString()
		navigateToURL(new URLRequest(url), '_blank')
	})

}
if (aa.data.savename == true) {
	account_text.text = aa.data.uid
	if (aa.data.uid != "用户名" && aa.data.uid != "") {
		this.account_text.textColor = 0x000000;
	}
}
if (aa.data.savepass == true) {
	this.password_text.text = aa.data.password
	if (aa.data.password != "密码" && aa.data.password != "") {
		this.password_text.displayAsPassword = true
		this.password_text.textColor = 0x000000
		this.password_text.text = "";
		this.password_text.text = aa.data.password
	}
	sp.settrue()
}
if (aa.data.saveshow == true) {
	show_left = true
	ss.settrue()
} else if (aa.data.saveshow == null) {
	show_left = false
	aa.data.saveshow == false
	ss.setfalse()
}
conbtn.addEventListener(MouseEvent.MOUSE_DOWN, con_down)
//conbtn.addEventListener(MouseEvent.MOUSE_OVER, con_down)
function con_down(e) {
	timetick = setInterval(show_extra, 50)
}
function show_extra() {
	clearInterval(timetick)
	extra_btn.x = 20;

}
conbtn.addEventListener(MouseEvent.MOUSE_UP, con_up)

function con_up(e) {
	clearInterval(timetick)
	extra_btn.x = 900
	if (account_text.text != "" && password_text.text != "") {
		request(4)
		show.a1.text = "断开中(1/2)"
		show.gotoAndStop("wait")
		show.circle.gotoAndPlay(1)
		show.down()
	} else {
		show.a1.text = "信息不完整"
		show.gotoAndStop("warning")

		show.down()
	}
}
extra_btn.only_conbtn.addEventListener(MouseEvent.MOUSE_UP, only_con_down)
function only_con_down(e) {
	clearInterval(timetick)
	extra_btn.x = 900
	if (account_text.text != "" && password_text.text != "") {
		request(1)
		show.a1.text = "连接中"
		show.gotoAndStop("wait")
		show.circle.gotoAndPlay(1)
		show.down()
	} else {
		show.a1.text = "信息不完整"
		show.gotoAndStop("warning")

		show.down()
	}
}
disbtn.addEventListener(MouseEvent.MOUSE_UP, dis_down)

function dis_down(e) {
	if (account_text.text != "" && password_text.text != "") {
		request(3)
		show.a1.text = "断开中"
		show.gotoAndStop("wait")
		show.circle.gotoAndPlay(1)
		show.down()
	}
}
function request(act) {

	var requestVars: URLVariables = new URLVariables();
	requestVars.username = account_text.text
	requestVars.password = password_text.text
	var url: String
	if (act == 1) {
		requestVars.action = "login";
		url = "https://ipgw.neu.edu.cn/srun_portal_pc.php?ac_id=1&url=";
	} else if (act == 3) {
		requestVars.action = "logout";
		requestVars.ajax = 1;
		url = "https://ipgw.neu.edu.cn/include/auth_action.php";
	} else if (act == 4) {
		requestVars.action = "logout";
		requestVars.ajax = 1;
		url = "https://ipgw.neu.edu.cn/include/auth_action.php";
	}
	var request: URLRequest = new URLRequest(url)
	aa.data.uid = account_text.text

	if (sp.thistrue == true) {
		aa.data.password = password_text.text
	}
	aa.flush();
	if (act == 1) {
		requestVars.ac_id = "1";
		requestVars.user_ip = ""
		requestVars.nas_ip = ""
		requestVars.user_mac = ""
		requestVars.save_me = "1"
		requestVars.url = "\"\""

	}
	request.data = requestVars;
	request.method = URLRequestMethod.POST;
	urlLoader = new URLLoader();
	urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
	urlLoader.addEventListener(Event.COMPLETE, loaderCompleteHandler, false, 0, true);
	try {

		if (loader_on) {
			clearInterval(timetick)
			urlLoader.close();
			loader_on = false;
		}
	} catch (e: Error) {
		trace(e);
	}
	try {

		loader_on = true
		urlLoader.load(request);
		timetick = setInterval(timeout, 60000)
	} catch (e: Error) {
		trace(e);
	}
	var sss;

	function timeout() {
		clearInterval(timetick)
		urlLoader.close()
		show.a1.text = "超时"
		show.gotoAndStop("warning")
	}

	function loaderCompleteHandler(e: Event): void {
		trace(1)
		clearInterval(timetick)
		trace(e.target.data)
		var str = e.target.data.toString();

		if (str.indexOf("您似乎") >= 0 || str.indexOf("网络已断开") >= 0) {
			trace(2222)
			if (act == 4) {
				show.a1.text = "连接中(2/2)"
				show.down()
				show.gotoAndStop("wait")
				MovieClip(root).request(1)
			}
			if (act == 3) {
				show.a1.text = "成功断开!"
				show.gotoAndStop("success")
				exit(200)
			}
		} else if (str.indexOf("E2553") >= 0) {
			show.a1.text = "密码错误"
			show.down()
			show.gotoAndStop("error")

		} else if (str.indexOf("E2620") >= 0) {
			show.a1.text = "成功连接!"
			show.gotoAndStop("success")
			if (show_left) {
				MovieClip(root).check()
				MovieClip(root).check_update()
			} else {
				exit(500)
			}
		} else if (str.indexOf("E2901") >= 0) {
			show.a1.text = "密码错误"
			show.gotoAndStop("error")
			show.down()
		} else if (str.indexOf("E2807") >= 0) {
			show.a1.text = "账户信息未找到"
			show.gotoAndStop("error")
			show.down()
		} else if (str.indexOf("E2531") >= 0) {
			show.a1.text = "用户不存在"
			show.gotoAndStop("error")
			show.down()
		}  else if (str.indexOf("E2616") >= 0) {
			show.a1.text = "已欠费"
			show.gotoAndStop("error")
			show.down()
		}else if (str.indexOf("网络已连接") >= 0) {
			if (act == 1) {
				show.a1.text = "成功连接!"
				show.gotoAndStop("success")
				if (show_left) {
					MovieClip(root).check()
					MovieClip(root).check_update()
				} else {
					exit(50)
				}
			}
		}
		else if (str.indexOf("login_ok") >= 0) {
			if (act == 1) {
				show.a1.text = "成功连接!"
				show.gotoAndStop("success")
				if (show_left) {
					MovieClip(root).check()
					MovieClip(root).check_update()
				} else {
					exit(50)
				}
			}
		}
	}
	function httpStatusHandler(e: HTTPStatusEvent): void {
		trace("httpStatusHandler:" + e.currentTarget + ">" + e.status + ">" + e.target);
	}
	function securityErrorHandler(e: SecurityErrorEvent): void {
		trace("securityErrorHandler:" + e);
	}
	function ioErrorHandler(e: IOErrorEvent): void {
		trace("ORNLoader:ioErrorHandler: " + e.errorID);
		//dispatchEvent(e);
	}
	function responses_status_handler(e) {
		trace("response: " + e.currentTarget + ">" + e.responseURL + ">" + e.responseHeaders + ">" + e.status + ">" + e.redirected + ">" + e.target);
		//dispatchEvent(e);
	}
	function progress_handler(e) {
		trace("progress: " + e.bytesTotal + ">" + e.target);
		//dispatchEvent(e);
	}
}

function check() {
	var k = Math.floor(Math.random() * (100000 + 1));
	var url: String = "https://ipgw.neu.edu.cn/include/auth_action.php";
	var request: URLRequest = new URLRequest(url);
	var requestVars1: URLVariables = new URLVariables();
	requestVars1.action = "get_online_info"
	requestVars1.key = k
	request.data = requestVars1;
	request.method = URLRequestMethod.POST;
	urlLoader = new URLLoader();
	urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
	urlLoader.addEventListener(Event.COMPLETE, loaderCompleteHandler, false, 0, true);
	urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
	urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
	urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
	try {

		if (loader_on) {
			clearInterval(timetick)
			urlLoader.close();
			loader_on = false;
		}
	} catch (e: Error) {
		trace(e);
	}

	try {
		loader_on = true;
		urlLoader.load(request);
	} catch (e: Error) {
		trace(e);
	}

	function loaderCompleteHandler(e: Event): void {
		
		var arr3 = e.target.data.toString().split(",");
		var q = format_flux(arr3[0]).toString()
		trace(format_flux(arr3[0]))
		show.a1.text = "余额：" + arr3[2] + "元";
		show.a1.appendText("\n已用流量：" + q);
		show.a1.y = 0
		exit(800)
	}
	function httpStatusHandler(e: HTTPStatusEvent): void {
		trace("httpStatusHandler:" + e);
	}
	function securityErrorHandler(e: SecurityErrorEvent): void {
		trace("securityErrorHandler:" + e);
	}
	function ioErrorHandler(e: IOErrorEvent): void {
		trace("ORNLoader:ioErrorHandler: " + e);
		dispatchEvent(e);
	}

}
function check_update() {
	var url: String = "https://api.github.com/repos/chwdy/ipgw_fla/releases/latest";
	var request: URLRequest = new URLRequest(url);
	request.method = URLRequestMethod.GET;
	urlLoader = new URLLoader();
	urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
	urlLoader.addEventListener(Event.COMPLETE, loaderCompleteHandler, false, 0, true);
	urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
	urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
	urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
	try {
		if (loader_on) {
			clearInterval(timetick)
			urlLoader.close();
			loader_on = false;
		}
	} catch (e: Error) {
		trace(e);
	}
	try {
		loader_on = true;
		urlLoader.load(request);
	} catch (e: Error) {
		trace(e);
	}
	function loaderCompleteHandler(e: Event): void {
		var arr3 = e.target.data.toString()
		var online_ver = arr3.substring((arr3.indexOf("tag_name") + 11), (arr3.indexOf(",", (arr3.indexOf("tag_name") + 11)) - 1))
		var pages = arr3.substring((arr3.indexOf("html_url") + 11), (arr3.indexOf(",", (arr3.indexOf("html_url") + 11)) - 1))
		aa.data.online_version = online_ver
		aa.data.pages = pages
		aa.flush();
	}
	function httpStatusHandler(e: HTTPStatusEvent): void {
		//trace("httpStatusHandler:" + e);
	}
	function securityErrorHandler(e: SecurityErrorEvent): void {
		trace("securityErrorHandler:" + e);
	}
	function ioErrorHandler(e: IOErrorEvent): void {
		trace("ORNLoader:ioErrorHandler: " + e);
		dispatchEvent(e);
	}
}
account_text.addEventListener(FocusEvent.FOCUS_IN, atfi)

function atfi(e) {
	account_text.textColor = 0x000000;
	if (account_text.text == "用户名") {
		account_text.text = ""
	}
	account_text.removeEventListener(FocusEvent.FOCUS_IN, atfi)
	account_text.addEventListener(FocusEvent.FOCUS_OUT, atfo)
}
function atfo(e) {
	if (account_text.text == "") {
		account_text.text = "用户名"
		account_text.textColor = 0xcccccc;
	}
	account_text.removeEventListener(FocusEvent.FOCUS_OUT, atfo)
	account_text.addEventListener(FocusEvent.FOCUS_IN, atfi)
}

password_text.addEventListener(FocusEvent.FOCUS_IN, ptfi)

function ptfi(e) {
	password_text.textColor = 0x000000;
	if (password_text.text == "密码") {
		password_text.text = ""
	}
	password_text.displayAsPassword = true;
	password_text.removeEventListener(FocusEvent.FOCUS_IN, ptfi)
	password_text.addEventListener(FocusEvent.FOCUS_OUT, ptfo)
}
function ptfo(e) {
	password_text.displayAsPassword = true;
	if (password_text.text == "") {
		password_text.displayAsPassword = false;
		password_text.text = "密码"
		password_text.textColor = 0xcccccc;

	}

	password_text.removeEventListener(FocusEvent.FOCUS_OUT, ptfo)
	password_text.addEventListener(FocusEvent.FOCUS_IN, ptfi)
}
sp.addEventListener(MouseEvent.MOUSE_UP, spd)
function spd(e) {
	if (sp.thistrue == true) {

		sp.setfalse()

		aa.data.savepass = false
		aa.flush()

	} else {

		sp.settrue()
		aa.data.savename = true
		aa.data.savepass = true
		aa.flush()
	}

}
ss.addEventListener(MouseEvent.MOUSE_UP, ssd)
function ssd(e) {
	if (ss.thistrue == true) {
		ss.setfalse()
		aa.data.saveshow = false
		show_left = false
		aa.flush()
	} else {
		ss.settrue()
		aa.data.saveshow = true
		show_left = true
		aa.flush()
	}

}
stage.addEventListener(MouseEvent.MOUSE_UP, function () {
	extra_btn.x = 900
})
function urlencodeGB2312(str: String): String {
	var result: String = "";
	var byte: ByteArray = new ByteArray();
	byte.writeMultiByte(str, "gb2312");
	for (var i: int; i < byte.length; i++) {
		result += escape(String.fromCharCode(byte[i]));
	}
	return result;
}

function exit(k) {
	readyexit = true
	stage.addEventListener(MouseEvent.MOUSE_DOWN, cancel_exit)
	stage.addEventListener(KeyboardEvent.KEY_DOWN, cancel_exit)
	timetick = setInterval(closeapp, k)
}

function cancel_exit(e) {
	clearInterval(timetick)
	if (show.a1.y == 0) {
		show.a1.y = 10
		show.a1.text = ""
		show.up();
	}
	readyexit = false;
	stage.removeEventListener(MouseEvent.MOUSE_DOWN, cancel_exit)
	stage.removeEventListener(MouseEvent.MOUSE_DOWN, cancel_exit)
}
stage.addEventListener(KeyboardEvent.KEY_DOWN, kd);
function kd(pEvent: KeyboardEvent): void {
	if (pEvent.keyCode == Keyboard.BACK) {
		pEvent.preventDefault();
		backcount++
		show.down()
		show.a1.y = 10
		show.a1.text = "再按一次返回键退出"
		show.gotoAndStop("warning")
		if (backcount == 2) {
			try {
				NativeApplication.nativeApplication.exit()
			} catch (e: Error) {
				trace(e);
			}
		}
		timeclick = setInterval(clearcount, 1000)
		function clearcount() {
			clearInterval(timeclick)
			backcount = 0
			show.up()
		}
	} else if (pEvent.keyCode == Keyboard.TAB) //tab
	{

		if (stage.focus == this.getChildByName("account_text")) {
			this.focus = getChildByName("password_text");
		} else if (stage.focus == this.getChildByName("password_text")) {
			this.focus = getChildByName("account_text")
		} else {
			this.focus = getChildByName("account_text")
		}
	} else if (pEvent.keyCode == Keyboard.ENTER) {

		if (account_text.text != "" && password_text.text != "") {

			this.request(4)
			show.down()
			show.a1.text = "断开中(1/2)"
			show.gotoAndStop("wait")
		}


	}
	if (readyexit) {
		readyexit = false
		clearInterval(timetick)
		if (show.a1.y == 0) {
			show.a1.y = 10
			show.a1.text = ""
			show.up();
		}
	}
}
function closeapp() {
	try {
		fscommand("quit");
	} catch (e: Error) {
		trace(e);
	}
	try {
		NativeApplication.nativeApplication.exit()
	} catch (e: Error) {
		trace(e);
	}

	trace("exit")
}
help_btn.addEventListener(MouseEvent.MOUSE_OVER, help_down)
help_btn.addEventListener(MouseEvent.MOUSE_DOWN, help_down)
function help_down(e) {
	help_btn.gotoAndStop(2);
	help_btn.addEventListener(MouseEvent.MOUSE_OUT, help_up)
	help_btn.addEventListener(MouseEvent.MOUSE_UP, help_up)
	help_btn.removeEventListener(MouseEvent.MOUSE_OVER, help_down)
	help_btn.removeEventListener(MouseEvent.MOUSE_DOWN, help_down)
}
function help_up(e) {
	help_btn.gotoAndStop(1);
	help_btn.removeEventListener(MouseEvent.MOUSE_OUT, help_up)
	help_btn.removeEventListener(MouseEvent.MOUSE_UP, help_up)
	help_btn.addEventListener(MouseEvent.MOUSE_OVER, help_down)
	help_btn.addEventListener(MouseEvent.MOUSE_DOWN, help_down)
}

function format_flux(byte) //格式化流量
{
	if (byte > (1000 * 1000))
		return (format_number((byte / (1000 * 1000)), 2) + "M");
	if (byte > 1000)
		return (format_number((byte / 1000), 2) + "K");
	return byte + "b";
}
function format_number(num, count) //格式化数字
{
	var n = Math.pow(10, count);
	var t = Math.floor(num * n);
	return t / n;
}