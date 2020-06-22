using Toybox.WatchUi;

private const MENU_ID_LOCK = "lock";
private const MENU_ID_UNLOCK = "unlock";
private const MENU_ID_ATHORIZE_CAR = "authorize_car";

class VehiclesMenu extends WatchUi.Menu2 {
    private var mCarApi;

    //So far only support one, but need to keep track of displayed vehicles.
    private var mNumberOfItemsInMenu = 0;
    private var mTokenIsFresh = false;

    private var mProgressBar;

    function initialize(carApi) {
        mCarApi = carApi;
        View.initialize();

        var vehicle = carApi.getCachedVehicle();

        if (vehicle == null) {
            displayInitialMenu();
        } else {
            displayVehicleMenu(vehicle);
        }
    }

    // Show menu items with vehicle actions (go to lock-menu, forget)
    function displayVehicleMenu(vehicle) {
        mNumberOfItemsInMenu = 3;
        addItem(new MenuItem(
                    Rez.Strings.menu_item_lock,
                    "",
                    MENU_ID_LOCK,
                    {}
                ));

        addItem(new MenuItem(
                    Rez.Strings.menu_item_unlock,
                    "",
                    MENU_ID_UNLOCK,
                    {}
                ));
        addItem(new MenuItem(
                    Rez.Strings.menu_item_change_car,
                    Rez.Strings.menu_description_on_phone,
                    MENU_ID_ATHORIZE_CAR,
                    {}
                ));
        var manufacturer = vehicle[$.MAKE_FIELD];
        var model = vehicle[$.MODEL_FIELD];
        if ((manufacturer + model).length() < 10) {
            setTitle(manufacturer + " " + model);
        } else {
            setTitle(model);
        }
    }

    // Show menu item with log in prompt
    function displayInitialMenu() {
        mTokenIsFresh = true;

        mNumberOfItemsInMenu = 1;
        addItem(new MenuItem(
            Rez.Strings.menu_item_log_in,
            Rez.Strings.menu_description_on_phone,
            MENU_ID_ATHORIZE_CAR,
            {}
        ));
        setTitle(Rez.Strings.title);
    }

    function clearMenu() {
        for (var i=0; i<mNumberOfItemsInMenu; i++) {
            deleteItem(0);
        }
    }

    function showProgress(message) {
        if (mProgressBar != null) {
            updateProgress(message);
            return;
        }

        mProgressBar = new WatchUi.ProgressBar(stringify(message), null);
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
        mProgressBar.setDisplayString(stringify(message));
    }

    function onProgressDismissed() {
        mProgressBar = null;
    }

    function authenticateOAuth() {
        showProgress(Rez.Strings.message_finish_on_phone);
        mCarApi.authenticateOAuth(method(:onAuthenticated));
    }

    function onAuthenticated(token) {
        if (token != null) {
            updateProgress(Rez.Strings.message_loading_info);
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
            displayVehicleMenu(vehicle);
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
        showProgress(Rez.Strings.message_checking_access);
        mCarApi.refreshToken(method(:onTokenRefreshed));
    }

    function onTokenRefreshed(token) {
        mTokenIsFresh = true;
        hideProgress();
    }

    function onLockUnlockMenuSelected(vehicleId, action) {
        showProgress(action == Lock ? Rez.Strings.message_locking : Rez.Strings.message_unlocking);

        var vehicle = mCarApi.getCachedVehicle();
        var vehicleId = vehicle[$.ID_FIELD];
        mCarApi.lockUnlock(vehicleId, action, method(:onLockFinishes));
    }

    function onLockFinishes(result) {
        //TODO support errors
        hideProgress();
    }
}

class VehiclesMenuDelegate extends WatchUi.Menu2InputDelegate {
    var mView;

    function initialize(view) {
        mView = view;
        Menu2InputDelegate.initialize();
    }

    function onSelect(menuItem) {
        System.println("Menu click: " + menuItem.getLabel());

        if (menuItem.getId() == MENU_ID_ATHORIZE_CAR) {
            mView.authenticateOAuth();
        } else if (menuItem.getId() == MENU_ID_LOCK) {
            mView.onLockUnlockMenuSelected(null, Lock);
        } else if (menuItem.getId() == MENU_ID_UNLOCK) {
            mView.onLockUnlockMenuSelected(null, Unlock);
        }
        return true;
    }
}
