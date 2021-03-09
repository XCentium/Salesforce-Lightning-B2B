// Singleton controller that manages CometD subscriptions for a
// Salesforce Lighting App Page
window.eventHub = (function() {

    // Local variables
    var cometd = null;
    var subscriptions = [];
    var debug = false;


    return {

        // Enables debug logging in browser console
        setDebug: function(on) {
            debug = on;
        },

        // Initialize CometD (if required) and subscribe to an event
        subscribe: function(sessionId, parentComponent, eventName, callback, showHistorical) {

            // Only the first component should initialize CometD
            if (!cometd) {

                // Construct CometD.
                cometd = new org.cometd.CometD();

                // Configure CometD.
                var cometdUrl = window.location.protocol + '//' + window.location.hostname + '/cometd/41.0/';
                cometd.configure({
                    url: cometdUrl,
                    requestHeaders: {
                        Authorization: 'OAuth ' + sessionId
                    },
                    appendMessageTypeToURL: false
                });

                // Disable Websockets
                cometd.websocketEnabled = false;

                // Establish CometD connection
                cometd.handshake(function(handshakeReply) {
                    if (handshakeReply.successful) {
                        console.log('CometD has been initialized');
                    } else
                        console.error('Failed to connected to CometD.');
                });
            }

            if (showHistorical == true) {
                eventHub.getHistorical(cometd, eventName);
            }


            // Subscribe to platform event
            var newSubscription = cometd.subscribe('/event/' + eventName,
                function(platformEvent) {
                    if (debug) {
                        console.log('Platform event received: ' + JSON.stringify(platformEvent));
                    }
                    callback(parentComponent, platformEvent);
                }
            );

            // Save subscription for later
            subscriptions.push(newSubscription);

        },


        getHistorical: function(cometd, eventName) {

            var cometdReplayExtension = function() {
                var REPLAY_FROM_KEY = "replay";

                var _cometd;
                var _extensionEnabled;
                var _replay;
                var _channel;

                this.setExtensionEnabled = function(extensionEnabled) {
                    _extensionEnabled = extensionEnabled;
                }

                this.setReplay = function(replay) {
                    _replay = parseInt(replay, 10);
                }

                this.setChannel = function(channel) {
                    _channel = channel;
                }

                this.registered = function(name, cometd) {
                    _cometd = cometd;
                };

                this.incoming = function(message) {

                    if (message.channel === '/meta/handshake') {
                        if (message.ext && message.ext[REPLAY_FROM_KEY] == true) {
                            _extensionEnabled = true;
                        }
                    } else if (message.channel === _channel && message.data && message.data.event && message.data.event.replayId) {
                        _replay = message.data.event.replayId;
                    }
                }

                this.outgoing = function(message) {
                    // console.log("outgoing");

                    if (message.channel === '/meta/subscribe') {
                        if (_extensionEnabled) {
                            if (!message.ext) {
                                message.ext = {};
                            }

                            var replayFromMap = {};
                            replayFromMap[_channel] = _replay;

                            // add "ext : { "replay" : { CHANNEL : REPLAY_VALUE }}" to subscribe message
                            message.ext[REPLAY_FROM_KEY] = replayFromMap;
                        }
                    }
                };
            };

            var replayExtension = new cometdReplayExtension();
            replayExtension.setChannel('/event/' + eventName);
            replayExtension.setReplay(-2);

            replayExtension.setExtensionEnabled(true);
            // cometd.registerExtension('myReplayExtensionName', replayExtension);
            let extensionName = "ext" + Math.floor(Math.random() * 1000);
            cometd.registerExtension(extensionName, replayExtension);
        }

    }

}());