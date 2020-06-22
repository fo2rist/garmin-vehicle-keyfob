using Toybox.WatchUi;
using Toybox.Lang;

// convert string or string resource into string
function stringify(strinOrRes) {
    if (strinOrRes instanceof Toybox.Lang.String) {
        return strinOrRes;
    } else if (strinOrRes instanceof Toybox.Lang.Number) {
        return WatchUi.loadResource(strinOrRes);
    } else {   
        throw new Lang.UnexpectedTypeException("Error, unknown type of string or resource: " + strinOrRes, null, null);
    }
}