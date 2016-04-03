;
(function(){
	if (typeof (webkit) == "undefined") {
		messageHandler = {
			postMessage: function (msg) {
				rcb_sendMessageToNative(msg)
			}
		}

		webkit = {
			messageHandlers: {
				nativeServer: messageHandler
			}
		}
	}

	rcb = {
		uniqueId: 0,
		callbacks: [],

		send: function (method, args, callback) {
			if (callback === undefined) callback = null;
			if (args === undefined || args == null || typeof (args) != 'object') args = {};

			var callbackId = '';

			if (callback && typeof (callback) == 'function') {
				callbackId = 'cb_' + method + '_' + (++rcb.uniqueId);

				rcb.callbacks[callbackId] = callback;
			}

			var cmd = {
				method: method,
				callbackId: callbackId,
				args: args
			}

			webkit.messageHandlers.nativeServer.postMessage(JSON.stringify(cmd));
		},

		handle: function (callbackId, args) {
			if (rcb.callbacks[callbackId]) {
				try {
					if (rcb.callbacks[callbackId]) rcb.callbacks[callbackId](args);
				}
				catch (e) {
					console.log("Callback Error: " + callbackId + " = " + e);
				}

				delete rcb.callbacks[callbackId];
			}
		},
	}

	function _handleMessage(msg) {
		var cmd = JSON.parse(msg)

		rcb.handle(cmd["method"], cmd["args"]);
	}
})()