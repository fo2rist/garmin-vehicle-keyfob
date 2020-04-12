//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Application;
using Toybox.Communications;
using Toybox.StringUtil;
using Toybox.WatchUi;

const OAUTH_REDIRECT_URI = "https://localhost";
const CLIENT_ID = "3657eda5-fb34-489c-93f9-9e1357bea1e4";

const ACCESS_TOKEN_KEY = "access_token";
const REFRESH_TOKEN_KEY = "refresh_token";
const EXPIRES_IN_KEY = "expires_in";

const RESPOSE_CODE_KEY = "code";
const ERROR_KEY = "error";


class NumberPickerApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
        // register a callback to capture results from OAuth requests
        Communications.registerForOAuthMessages(method(:onOAuthMessage));
        System.println("It's registered");
        getOAuthToken();
        System.println("Started fetching");
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new NumberPickerView(), new BaseInputDelegate() ];
    }

    // wrap the OAuth request in a function
    function getOAuthToken() {
        var status = "Look at OAuth screen\n";
        WatchUi.requestUpdate();

        // set the makeOAuthRequest parameters
        var params = {
            "scope" => Communications.encodeURL("control_security"),
            "redirect_uri" => $.OAUTH_REDIRECT_URI,
            "response_type" => "code",
            "client_id" => $.CLIENT_ID
        };

        // makeOAuthRequest triggers login prompt on mobile device.
        // "responseCode" and "responseError" are the parameters passed
        // to the resultUrl. Check the oauth provider's documentation
        // to determine the correct strings to use.
        Communications.makeOAuthRequest(
            "https://connect.smartcar.com/oauth/authorize",
            params,
            "https://connect.smartcar.com/oauth/authorize",
            Communications.OAUTH_RESULT_TYPE_URL,
            {$.RESPOSE_CODE_KEY => "responseCode", $.ERROR_KEY => "responseError"}
        );
    }

    // implement the OAuth callback method
    function onOAuthMessage(message) {
        if (message.data == null) {
            System.println("Failed");
            return;
        }
        var error = message.data[$.ERROR_KEY];
        if (error != null) {
            System.print("Error " + error);
            return;
        }

        System.println("Got response");
        System.println(message.data);
        var code = message.data[$.RESPOSE_CODE_KEY];
        System.print("Code " + code);
        makeRequest(code);
    }

    function makeRequest(code) {
        var params = {                                              // set the parameters
            "code" => code,
            "redirect_uri" => $.OAUTH_REDIRECT_URI,
            "grant_type" => "authorization_code",
        };

        var options = {                                             // set the options
            :method => Communications.HTTP_REQUEST_METHOD_GET,      // set HTTP method
            :headers => {                                           // set headers
                    "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
                    "Authorization" => "Basic " + StringUtil.encodeBase64(CLIENT_ID + ":" + )},
                                                                    // set response type
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        Communications.makeWebRequest("https://auth.smartcar.com/oauth/token",
                params, options, method(:onReceive));
    }

    // set up the response callback function
    function onReceive(responseCode, data) {
        if (responseCode == 200) {
            System.println("Request Successful" + data);            // print success
            System.println("Access T : " + data[$.ACCESS_TOKEN_KEY])
            System.println("Refresh T: " + data[$.REFRESH_TOKEN_KEY])
            System.println("Expires  : " + data[$.EXPIRES_IN_KEY])
        }
        else {
            System.println("Response: " + responseCode);            // print response code
        };
    };
}