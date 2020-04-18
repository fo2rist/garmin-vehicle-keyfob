using Toybox.WatchUi;

private const ADD_CARS_MENU_ID = "add_cars";

class VehiclesMenu extends WatchUi.Menu2 {
    
    function initialize(carApi) {
        View.initialize();

        var vehicle = carApi.getCachedVehicle();

        setTitle("Keyfob");
        if (vehicle != null) {
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
        } else {
            addItem(new MenuItem(
                    "Add car",
                    "on phone",
                    ADD_CARS_MENU_ID,
                    {}
                ));
        }

    }
}


class VehiclesMenuDelegate extends WatchUi.Menu2InputDelegate {
    var mCarApi;
    var mProgressBar;

    function initialize(carApi) {
        Menu2InputDelegate.initialize();
        mCarApi = carApi;
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
        System.println("Got callback: " + result);
        //TODO update menu with fresh data
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
