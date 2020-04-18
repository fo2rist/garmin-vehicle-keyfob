using Toybox.WatchUi;

private const ADD_CARS_MENU_ID = "add_cars";

class VehiclesMenu extends WatchUi.Menu2 {

    //So far only support one, but need to keep track of displayed vehicles.
    private var mNumberOfVehiclesInMenu = 0;
    
    function initialize(carApi) {
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
}


class VehiclesMenuDelegate extends WatchUi.Menu2InputDelegate {
    var mMenu;
    var mCarApi;
    var mProgressBar;

    function initialize(menu, carApi) {
        mMenu = menu;
        mCarApi = carApi;
        Menu2InputDelegate.initialize();
    }

    function onSelect(menuItem) {
        System.println(menuItem.getLabel());

        if (menuItem.getId() == ADD_CARS_MENU_ID) {
            showProgress();
            mCarApi.updateVehicle(method(:onLoadingFinished));
        }

        return true;
    }

    function onLoadingFinished(result) {
        //TODO support error messages
        if (result != null) {
            mMenu.clearMenu();
            mMenu.displayVehicleInMenu(result);
        }
        hideProgress();
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
}
