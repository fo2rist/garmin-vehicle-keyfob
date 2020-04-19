using Toybox.WatchUi;

private const ADD_CARS_MENU_ID = "add_cars";

class VehiclesMenu extends WatchUi.Menu2 {
    private var mCarApi;

    //So far only support one, but need to keep track of displayed vehicles.
    private var mNumberOfVehiclesInMenu = 0;
    private var mTokenIsFresh = false;

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
                vehicle,
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
        mTokenIsFresh = true;
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

    function showProgress(message) {
        if (mProgressBar != null) {
            updateProgress(message);
            return;
        }
        mProgressBar = new WatchUi.ProgressBar(message, null);
        WatchUi.pushView(mProgressBar, new ProgressBarDelegate(method(:onProgressDismissed)), WatchUi.SLIDE_DOWN);
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

    function onProgressDismissed() {
        mProgressBar = null;
    }

    function authenticateOAuth() {
        showProgress("Finish\nauthentication\non phone");
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

    function onShow() {
        //TODO properly check here if need to refresh
        if (!mTokenIsFresh) {
            refreshAuthToken();
        }
    }

    private function refreshAuthToken() {
        showProgress("Checking\naccess");
        mCarApi.refreshToken(method(:onTokenRefreshed));
    }

    function onTokenRefreshed(token) {
        mTokenIsFresh = true;
        hideProgress();
    }

    function displayVehicleControls(vehicle) {
        var lockMenu = new Rez.Menus.LockMenu();
        lockMenu.setTitle(vehicle[$.MAKE_FIELD]+" "+vehicle[$.MODEL_FIELD]);
        WatchUi.pushView(lockMenu, new LockMenuDelegate(vehicle[$.ID_FIELD], method(:onLockUnlockMenuSelected)),
                WatchUi.SLIDE_IMMEDIATE);
    }

    function onLockUnlockMenuSelected(vehicleId, action) {
        showProgress(action == Lock ? "Locking" : "Unlocking");
        mCarApi.lockUnlock(vehicleId, action, method(:onLockFinishes));
    }

    function onLockFinishes(result) {
        //TODO support errors
        hideProgress();
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); // close menu
    }
}

class VehiclesMenuDelegate extends WatchUi.Menu2InputDelegate {
    var mView;

    function initialize(view) {
        mView = view;
        Menu2InputDelegate.initialize();
    }

    function onSelect(menuItem) {
        System.println(menuItem.getLabel());

        if (menuItem.getId() == ADD_CARS_MENU_ID) {
            mView.authenticateOAuth();
        } else {
            mView.displayVehicleControls(menuItem.getId());
        }
        return true;
    }
}
