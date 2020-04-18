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

    function getCachedVehicle() {
        var vehicle = loadVehicle();
        return vehicle;
    }

    function updateVehicle(loadingFinishedCallback) {
        mCurrentLoadingFinishedCallback = loadingFinishedCallback;
        initiateOAuth();
    }

    private function initiateOAuth() {
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
            mCurrentLoadingFinishedCallback.invoke(null);
        }

        System.println("Request Successful: " + data);
        mRefreshToken = data[$.REFRESH_TOKEN_KEY];
        System.println("Refresh Token: " + mRefreshToken);
        mAccessToken = data[$.ACCESS_TOKEN_KEY];
        System.println("Access Token : " + mAccessToken);
        System.println("Expires in s.: " + data[$.EXPIRES_IN_KEY]);
        saveToken(createToken(mRefreshToken, mAccessToken, null)); //TODO calculate actual timesamp
        
        makeRefreshTokenRequest(mRefreshToken);
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
            mCurrentLoadingFinishedCallback.invoke(null);
            return;
        }

        System.println("Request Successful: " + data);
        mRefreshToken = data[$.REFRESH_TOKEN_KEY];
        System.println("Refresh Token: " + mRefreshToken);
        mAccessToken = data[$.ACCESS_TOKEN_KEY];
        System.println("Access Token : " + mAccessToken);
        System.println("Expires in s.: " + data[$.EXPIRES_IN_KEY]);
        saveToken(createToken(mRefreshToken, mAccessToken, null)); //TODO calculate actual timesamp

        makeVehiclesRequest(mAccessToken);
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
        makeVehiclesInfoRequest(mAccessToken, data["vehicles"][0]);
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
        var vehicle = createCar(data[$.ID_KEY], data[$.MAKE_KEY], data[$.MODEL_KEY]);
        saveVehicle(vehicle);
        mCurrentLoadingFinishedCallback.invoke(vehicle);
    }
}