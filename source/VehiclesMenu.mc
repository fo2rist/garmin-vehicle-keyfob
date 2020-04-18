using Toybox.WatchUi;

private const ADD_CARS_MENU_ID = "add_cars";

class VehiclesMenu extends WatchUi.Menu2 {
    private var mCarApi;

    //So far only support one, but need to keep track of displayed vehicles.
    private var mNumberOfVehiclesInMenu = 0;

    private var mProgressBar;
    
    function initialize(carApi) {
        mCarApi = carApi;
        View.initialize();

        var vehicle = carApi.getCachedVehicle();

        setTitle("Keyfob");
        if (vehicle != null) {
            displayVehicleInMenu(vehicle);
        } else {
            displayInitialMenu();
        }
    }

    function displayVehicleInMenu(vehicle) {
        mNumberOfVehiclesInMenu = 1;
        addItem(new MenuItem(
                vehicle[$.MAKE_FIELD],
                vehicle[$.MODEL_FIELD],
                vehicle[$.ID_FIELD],
                {}
            ));
        addItem(new MenuItem(
                    "Change car",
                    "on phone",
                    ADD_CARS_MENU_ID,
                    {}
                ));
    }

    function displayInitialMenu() {
        mNumberOfVehiclesInMenu = 0;
        addItem(new MenuItem(
            "Add car",
            "on phone",
            ADD_CARS_MENU_ID,
            {}
        ));
    }

    function clearMenu() {
        for (var i=0; i<mNumberOfVehiclesInMenu+1; i++) {
            deleteItem(0);
        }
    }

    function showProgress() {
        if (mProgressBar != null) {
            return;
        }
        mProgressBar = new WatchUi.ProgressBar( "Finish\nauthentication\non phone", null );
        WatchUi.pushView( mProgressBar, new OAuthProgressDelegate(), WatchUi.SLIDE_DOWN );
    }

    function hideProgress() {
        if (mProgressBar == null) {
            return;
        }
        mProgressBar = null;
        WatchUi.popView(WatchUi.SLIDE_UP);
    }

    function updateProgress(message) {
        mProgressBar.setDisplayString(message);
    }

    function authenticateOAuth() {
        showProgress();
        mCarApi.authenticateOAuth(method(:onAuthenticated));
    }

    function onAuthenticated(token) {
        if (token != null) {
            updateProgress("Loading\nvehicle info");
            mCarApi.fetchVehicleInfo(method(:onVehicleLoaded));
        } else {
            //TODO support error messages
            hideProgress();
        }
    }

    function onVehicleLoaded(vehicle) {
        //TODO support error messages
        if (vehicle != null) {
            clearMenu();
            displayVehicleInMenu(vehicle);
        }
        hideProgress();
    }
}


class VehiclesMenuDelegate extends WatchUi.Menu2InputDelegate {
    var mView;

    function initialize(view, carApi) {
        mView = view;
        Menu2InputDelegate.initialize();
    }

    function onSelect(menuItem) {
        System.println(menuItem.getLabel());

        if (menuItem.getId() == ADD_CARS_MENU_ID) {
            mView.authenticateOAuth();
        } else {
            //TODO show lock/unlock controls
        }
        return true;
    }
}
