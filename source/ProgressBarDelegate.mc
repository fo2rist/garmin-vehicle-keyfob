using Toybox.WatchUi;

class ProgressBarDelegate extends WatchUi.BehaviorDelegate {
    var mOnProgressDismissed;

    function initialize(onProgressDismissed) {
        mOnProgressDismissed = onProgressDismissed;
        BehaviorDelegate.initialize();
    }

    function onBack() {
        mOnProgressDismissed.invoke();
        return true;
    }
}
