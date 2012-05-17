jQuery(document).ready( function () {
	var $ = jQuery;

	var tw = $("#typewriting");

	var text = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
	         + "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. "
	         + "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. "
	         + "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

	var offset = 0;

	var mistake = false;

	function randomString(string_length) {
		var chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz";
		var randomstring = '';

		for (var i = 0; i < string_length; i++) {
			var rnum = Math.floor(Math.random() * chars.length);
			randomstring += chars.substring(rnum, rnum + 1);
		}

		return randomstring;
	}

	function draw() {
		if (offset > text.length) {
			offset = 0;
			tw.append(" ");
		}

		if (mistake) {
			var txt = tw.text()
			tw.text( txt.substring(0, txt.length - 1) );
			mistake = false;
			return;
		}

		if (Math.random() > 0.9) {
			tw.append(randomString(1));
			mistake = true;
		} else {
			tw.append(text[offset]);
			offset++;
		}
	}

	function main_loop() {
		draw();

		var timeout;

		if (mistake) {
			timeout = 50 + Math.random() * Math.random() * 2000;
		} else {
			timeout = 50 + Math.random() * Math.random() * 1000;
		}

		setTimeout( main_loop, timeout );
	}

	main_loop();
} );