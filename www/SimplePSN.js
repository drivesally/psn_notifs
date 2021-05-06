var SimplePSN = function() {
};


// Call this to register for push notifications. Content of [options] depends on whether we are working with APNS (iOS) or GCM (Android)
SimplePSN.prototype.register = function(successCallback, errorCallback, options) {
    if (errorCallback == null) { errorCallback = function() {}}

    if (typeof errorCallback != "function")  {
        console.log("SimplePSN.register failure: failure parameter not a function");
        return
    }

    if (typeof successCallback != "function") {
        console.log("SimplePSN.register failure: success callback parameter must be a function");
        return
    }

    cordova.exec(successCallback, errorCallback, "SimplePSN", "register", [options]);
};

// Call this to unregister for push notifications
SimplePSN.prototype.unregister = function(successCallback, errorCallback, options) {
    if (errorCallback == null) { errorCallback = function() {}}

    if (typeof errorCallback != "function")  {
        console.log("SimplePSN.unregister failure: failure parameter not a function");
        return
    }

    if (typeof successCallback != "function") {
        console.log("SimplePSN.unregister failure: success callback parameter must be a function");
        return
    }

     cordova.exec(successCallback, errorCallback, "SimplePSN", "unregister", [options]);
};

// Call this to set the application icon badge
SimplePSN.prototype.setApplicationIconBadgeNumber = function(successCallback, errorCallback, badge) {
    if (errorCallback == null) { errorCallback = function() {}}

    if (typeof errorCallback != "function")  {
        console.log("SimplePSN.setApplicationIconBadgeNumber failure: failure parameter not a function");
        return
    }

    if (typeof successCallback != "function") {
        console.log("SimplePSN.setApplicationIconBadgeNumber failure: success callback parameter must be a function");
        return
    }

    cordova.exec(successCallback, errorCallback, "SimplePSN", "setApplicationIconBadgeNumber", [{badge: badge}]);
};

//-------------------------------------------------------------------

if(!window.plugins) {
    window.plugins = {};
}
if (!window.plugins.SimplePSN) {
    window.plugins.SimplePSN = new SimplePSN();
}

if (typeof module != 'undefined' && module.exports) {
  module.exports = SimplePSN;
}



