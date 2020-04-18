//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Application;
using Toybox.Communications;
using Toybox.StringUtil;
using Toybox.WatchUi;

// const OAUTH_REDIRECT_URI = "https://localhost";

// const ACCESS_TOKEN_KEY = "access_token";
// const REFRESH_TOKEN_KEY = "refresh_token";
// const EXPIRES_IN_KEY = "expires_in";

// const RESPOSE_CODE_KEY = "code";
// const ERROR_KEY = "error";


class VehicleKeychainApp extends Application.AppBase {
    var refreshToken = null;
    var accessToken = null;

    var carApi = new CarApi();

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new VehiclesMenu(carApi), new VehiclesMenuDelegate(carApi) ];
    }
}
