using Toybox.WatchUi;

class VehiclesMenu extends WatchUi.Menu2 {
    function initialize(vehiclesList) {
        View.initialize();

        setTitle("Keyfob");
        for( var i = 0; i < vehiclesList.size(); i++ ) {
            addItem(
                new MenuItem(
                    vehiclesList[i],
                    "subLabel",
                    vehiclesList[i],
                    {}
                )
            );
        }
    }
}


class VehiclesMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(menuItem) {
        System.print(menuItem.getLabel() + " ");
        System.println(menuItem.getId());
        return true;
    }
}