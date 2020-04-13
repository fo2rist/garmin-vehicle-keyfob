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
        //check if creds are already present
        //if yes check if needed to refresh the token and refresh
        //get cars list
        //get car name
        //display list of car
        //or show the controls if there is only one

        // Here tell user that we need to authenticate on device
        // WatchUi.requestUpdate();
        initiateOAuth();
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new NumberPickerView(), new BaseInputDelegate() ];
    }

    function initiateOAuth() {
        // register a callback to capture results from OAuth requests
        Communications.registerForOAuthMessages(method(:onOAuthMessage));
        var params = {
            "scope" => Communications.encodeURL("required:control_security required:read_vehicle_info read_location"),
            "redirect_uri" => $.OAUTH_REDIRECT_URI,
            "response_type" => "code",
            "client_id" => $.CLIENT_ID,
            "approval_prompt" => "force",
            "single_select" => "true",
            "mode" => "test"
        };

        System.println("Initiate OAuth");
        Communications.makeOAuthRequest(
            "https://connect.smartcar.com/oauth/authorize",
            params,
            "https://connect.smartcar.com/oauth/authorize",
            Communications.OAUTH_RESULT_TYPE_URL,
            {$.RESPOSE_CODE_KEY => $.RESPOSE_CODE_KEY, $.ERROR_KEY => $.ERROR_KEY}
        );
    }

    function onOAuthMessage(message) {
        if (message.data == null) {
            System.println("OAuth Failed");
            return;
        }
        var error = message.data[$.ERROR_KEY];
        if (error != null) {
            System.println("OAuth Error: " + error);
            return;
        }
        if (message.data.isEmpty()) {
            System.println("OAuth Empty response");
            return;
        }

        System.println("OAuth Response: " + message.data);
        var code = message.data[$.RESPOSE_CODE_KEY];
        makeTokenRequest(code);
    }

    function makeTokenRequest(code) {
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_POST,      
            :headers => {                                           
                    "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
                    "Authorization" => "Basic " + $.BASIC_AUTH_CREDENTIALS
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        var body = {
            "code" => code,
            "redirect_uri" => $.OAUTH_REDIRECT_URI,
            "grant_type" => "authorization_code",
        };

        Communications.makeWebRequest(
            "https://auth.smartcar.com/oauth/token", body, options, method(:onReceiveToken));
    }

    function onReceiveToken(responseCode, data) {
        if (responseCode != 200) {
            System.println("Error Code: " + responseCode);
            System.println("Data: " + data);
        }

        System.println("Request Successful: " + data);
        System.println("Access Token : " + data[$.ACCESS_TOKEN_KEY]);
        System.println("Refresh Token: " + data[$.REFRESH_TOKEN_KEY]);
        System.println("Expires in s.: " + data[$.EXPIRES_IN_KEY]);
    }
}
