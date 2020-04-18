private const REFRESH_TOKEN_FIELD = "refresh_token";
private const ACCESS_TOKEN_FIELD = "access_token";
private const EXPIRATION_DATE_FIELD = "expires";

function createToken(refreshToken, accessToken, expirationDate) {
    return { REFRESH_TOKEN_FIELD => refreshToken, ACCESS_TOKEN_FIELD => accessToken, EXPIRATION_DATE_FIELD => expirationDate};
}