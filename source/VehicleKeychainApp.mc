using Toybox.Application;
using Toybox.Communications;
using Toybox.StringUtil;
using Toybox.WatchUi;

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
        var menuView = new VehiclesMenu(carApi);
        var menuDelegate = new VehiclesMenuDelegate(menuView);
        return [ menuView, menuDelegate ];
    }
}
