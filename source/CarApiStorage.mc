using Toybox.Application.Storage;

private const TOKEN_KEY = "token";
private const VEHICLES_LIST_KEY = "vehicles_list";

function saveToken(token) {
    Storage.setValue(TOKEN_KEY, token);
}

function loadToken() {
    var value = Storage.getValue(TOKEN_KEY);
    return (value != null) ? value : null;
}

function saveVehicle(vehicle) {
    Storage.setValue(VEHICLES_LIST_KEY, [vehicle]);
}

function loadVehicle() {
    var value = Storage.getValue(VEHICLES_LIST_KEY);
    return (value != null) ? value[0] : null;
}