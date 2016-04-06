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
				callback: callbackId,
				params: args
			}

			webkit.messageHandlers.nativeServer.postMessage(JSON.stringify(cmd));
		},

		receive: function (method, args, callback) {
			if (rcb.callbacks[method]) {
				try {
                    rcb.callbacks[method](args, callback);
				}
				catch (e) {
					console.log("Callback Error: " + method + " = " + e);
				}

				delete rcb.callbacks[method];
			}
		},
 
        handleMessageFromNative: function (msg) {
            var cmd = JSON.parse(msg)

            rcb.receive(cmd["method"], cmd["params"], cmd["callback"]);
        }
	}
})()