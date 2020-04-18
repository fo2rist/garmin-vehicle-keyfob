private const OAUTH_REDIRECT_URI = "https://localhost";

private const ACCESS_TOKEN_KEY = "access_token";
private const REFRESH_TOKEN_KEY = "refresh_token";
private const EXPIRES_IN_KEY = "expires_in";

private const ID_KEY = "id";
private const MAKE_KEY = "make";
private const MODEL_KEY = "model";

private const RESPOSE_CODE_KEY = "code";
private const ERROR_KEY = "error";

class CarApi {
    var mRefreshToken = null;
    var mAccessToken = null;

    var mCurrentLoadingFinishedCallback = null;

    function initialize() {
        var token = loadToken();
        if (token != null) {
            mRefreshToken = token[$.REFRESH_TOKEN_FIELD];
            mAccessToken = token[$.ACCESS_TOKEN_FIELD];
        }
    }

    function getCachedVehicle() {
        var vehicle = loadVehicle();
        if (mRefreshToken != null) {
            return vehicle;
        } else {
            return null;
        }
    }

    function authenticateOAuth(loadingFinishedCallback) {
        mCurrentLoadingFinishedCallback = loadingFinishedCallback;

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
            mCurrentLoadingFinishedCallback.invoke(null);
            return;
        }
        var error = message.data[$.ERROR_KEY];
        if (error != null) {
            System.println("OAuth Error: " + error);
            mCurrentLoadingFinishedCallback.invoke(null);
            return;
        }
        if (message.data.isEmpty()) {
            System.println("OAuth Empty response");
            mCurrentLoadingFinishedCallback.invoke(null);
            return;
        }

        System.println("OAuth Response: " + message.data);
        var code = message.data[$.RESPOSE_CODE_KEY];
        makeInitialTokenRequest(code);
    }

    private function makeInitialTokenRequest(code) {
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

    function refreshToken(loadingFinishedCallback) {
        mCurrentLoadingFinishedCallback = loadingFinishedCallback;
        makeTokenRefreshRequest();
    }

    private function makeTokenRefreshRequest() {
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_POST,      
            :headers => {                                           
                    "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
                    "Authorization" => "Basic " + $.BASIC_AUTH_CREDENTIALS
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        var body = {
            "refresh_token" => mRefreshToken,
            "grant_type" => "refresh_token",
        };
        Communications.makeWebRequest(
            "https://auth.smartcar.com/oauth/token", body, options, method(:onReceiveAccessToken));
    }

    function onReceiveToken(responseCode, data) {
        if (responseCode != 200) {
            System.println("Token Error Code: " + responseCode);
            System.println("Data: " + data);
            mCurrentLoadingFinishedCallback.invoke(null);
            return;
        }

        System.println("Got Token: " + data);
        mRefreshToken = data[$.REFRESH_TOKEN_KEY];
        mAccessToken = data[$.ACCESS_TOKEN_KEY];
        var token = createToken(mRefreshToken, mAccessToken, null); //TODO calculate actual timestamp
        saveToken(token);
        mCurrentLoadingFinishedCallback.invoke(token);
    }

    function fetchVehicleInfo(loadingFinishedCallback) {
        mCurrentLoadingFinishedCallback = loadingFinishedCallback;
        makeVehicleRequest();
    }

    function makeVehicleRequest() {
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,      
            :headers => {                                           
                    "Authorization" => "Bearer " + mAccessToken,
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        
        Communications.makeWebRequest(
            "https://api.smartcar.com/v1.0/vehicles", {}, options, method(:onReceiveVehicle));
    }

    function onReceiveVehicle(responseCode, data) {
        if (responseCode != 200) {
            System.println("Vehicle ID Error Code: " + responseCode);
            System.println("Data: " + data);
            mCurrentLoadingFinishedCallback.invoke(null);
            return;
        }

        System.println("Get vehicle id: " + data);
        makeVehiclesInfoRequest(mAccessToken, data["vehicles"][0]);
    }

    private function makeVehiclesInfoRequest(accessToken, vehicleId) {
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
        if (responseCode != 200) {
            System.println("Vehicle Info Error Code: " + responseCode);
            System.println("Data: " + data);
            mCurrentLoadingFinishedCallback.invoke(null);
            return;
        }

        System.println("Get vehicle: " + data);
        var vehicle = createCar(data[$.ID_KEY], data[$.MAKE_KEY], data[$.MODEL_KEY]);
        saveVehicle(vehicle);
        mCurrentLoadingFinishedCallback.invoke(vehicle);
    }
}