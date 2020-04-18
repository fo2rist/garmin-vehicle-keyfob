using Toybox.Application.Storage;

private const TOKEN_KEY = "token";
private const VEHICLES_LIST_KEY = "vehicles_list";

function saveToken(token) {
    Storage.setValue(TOKEN_KEY, token);
}

function loadToken() {
    return Storage.getValue(TOKEN_KEY);
}

function saveVehicle(vehicle) {
    Storage.setValue(VEHICLES_LIST_KEY, [vehicle]);
}

function loadVehicle() {
    return Storage.getValue(VEHICLES_LIST_KEY)[0];
}