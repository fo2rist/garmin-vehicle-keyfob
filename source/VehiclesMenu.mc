using Toybox.WatchUi;

const ADD_CARS_MENU_ID = "add_cars";

class VehiclesMenu extends WatchUi.Menu2 {
    
    function initialize(carApi) {
        View.initialize();

        var vehiclesList = carApi.getCachedCars();

        setTitle("Keyfob");
        for( var i = 0; i < vehiclesList.size(); i++ ) {
            addItem(new MenuItem(
                    vehiclesList[i],
                    "subLabel",
                    vehiclesList[i],
                    {}
                ));
        }

        addItem(new MenuItem(
                    "Add cars",
                    "authenticate on phone",
                    ADD_CARS_MENU_ID,
                    {}
                ));
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
            //TODO add callback to close menu if the auth completed/cancelled
            mCarApi.loadCars();

            var mProgressBar = new WatchUi.ProgressBar( "Finish authentication on phone", null );
            WatchUi.pushView( mProgressBar, new OAuthProgressDelegate(), WatchUi.SLIDE_DOWN );
        }

        return true;
    }
}