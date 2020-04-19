using Toybox.WatchUi;

class LockMenuDelegate extends WatchUi.MenuInputDelegate {
    var mOnActionSelected;
    var mVehicleId;

    function initialize(vehicleId, onActionSelected) {
        mOnActionSelected = onActionSelected;
        mVehicleId = vehicleId;
        ConfirmationDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :item_lock) {
            mOnActionSelected.invoke(mVehicleId, Lock);
        } else if (item == :item_unlock) {
            mOnActionSelected.invoke(mVehicleId, Unlock);
        }
    }
}
