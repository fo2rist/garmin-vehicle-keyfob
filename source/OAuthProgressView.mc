using Toybox.WatchUi;

//TODO rename to generic progress view
class OAuthProgressView extends WatchUi.ProgressBar {
}

class OAuthProgressDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() {
        WatchUi.popView( WatchUi.SLIDE_UP );
        return true;
    }
}