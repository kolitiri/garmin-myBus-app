using Toybox.Application as App;
using Toybox.Position as Position;
using Toybox.WatchUi as Ui;


 /**
 * MyBusApp Model Object
 * 
 * @author Christos Liontos
 */
class MyBusApp extends App.AppBase {

    var positionView;
    hidden var mView;

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        mView = new View();
        positionView = new Delegate(mView.method(:onReceive));
        return [mView, positionView];
    }

    function onStart(state) {
    	Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    function onStop(state) {
    	Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    function onPosition(info) {
    	// Set the position on the view object
        positionView.setPosition(info);
        // Set the position on the view delegate object
        mView.setPosition(info);
        Ui.requestUpdate();
    }
}
