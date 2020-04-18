const OAUTH_REDIRECT_URI = "https://localhost";

const ACCESS_TOKEN_KEY = "access_token";
const REFRESH_TOKEN_KEY = "refresh_token";
const EXPIRES_IN_KEY = "expires_in";

const RESPOSE_CODE_KEY = "code";
const ERROR_KEY = "error";

class CarApi {
    var refreshToken = null;
    var accessToken = null;

    function getCachedCars() {
        return ["Camaro", "Corvette"];
    }

    function loadCars() {
        //if yes check if needed to refresh the token and refresh
        if (refreshToken == null) {
            initiateOAuth();
        } 
        //or get cars list
        else {
            makeVehiclesRequest(accessToken);
            //then
            //get car name
            //display list of car
            //or show the controls if there is only one
        }
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
        accessToken = data[$.ACCESS_TOKEN_KEY];
        System.println("Access Token : " + accessToken);
        refreshToken = data[$.REFRESH_TOKEN_KEY];
        System.println("Refresh Token: " + refreshToken);
        System.println("Expires in s.: " + data[$.EXPIRES_IN_KEY]);
        
        makeRefreshTokenRequest(refreshToken);
    }

    function makeRefreshTokenRequest(refreshToken) {
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_POST,      
            :headers => {                                           
                    "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
                    "Authorization" => "Basic " + $.BASIC_AUTH_CREDENTIALS
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        var body = {
            "refresh_token" => refreshToken,
            "grant_type" => "refresh_token",
        };
        Communications.makeWebRequest(
            "https://auth.smartcar.com/oauth/token", body, options, method(:onReceiveAccessToken));
    }

    function onReceiveAccessToken(responseCode, data) {
        //here 100% the same code as on main token received
        if (responseCode != 200) {
            System.println("Error Code: " + responseCode);
            System.println("Data: " + data);
        }

        System.println("Request Successful: " + data);
        accessToken = data[$.ACCESS_TOKEN_KEY];
        System.println("Access Token : " + accessToken);
        refreshToken = data[$.REFRESH_TOKEN_KEY];
        System.println("Refresh Token: " + refreshToken);
        System.println("Expires in s.: " + data[$.EXPIRES_IN_KEY]);

        makeVehiclesRequest(accessToken);
    }

    function makeVehiclesRequest(accessToken) {
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,      
            :headers => {                                           
                    "Authorization" => "Bearer " + accessToken,
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        
        Communications.makeWebRequest(
            "https://api.smartcar.com/v1.0/vehicles", {}, options, method(:onReceiveVehicle));
    }

    function onReceiveVehicle(responseCode, data) {
        System.println("Get " + data);
        makeVehiclesInfoRequest(accessToken, data["vehicles"][0]);
    }

    function makeVehiclesInfoRequest(accessToken, vehicleId) {
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,      
            :headers => {                                           
                    "Authorization" => "Bearer " + accessToken,
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        
        Communications.makeWebRequest(
            "https://api.smartcar.com/v1.0/vehicles/" + vehicleId, {}, options, method(:onReceiveVehicleInfo));
    }

    function onReceiveVehicleInfo(responseCode, data) {
        System.println("Get " + data);
    }
}