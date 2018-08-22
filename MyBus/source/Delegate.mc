using Toybox.Position as Position;
using Toybox.WatchUi as Ui;


/**
* Delegate Model Object
*
* @author Christos Liontos
*/
class Delegate extends Ui.BehaviorDelegate {

	var notify;
	var posnInfo;
	var APIRequestInstance;
	var gps_ready_msg = true;

	function initialize(handler) {
		BehaviorDelegate.initialize();
		notify = handler;
		// Create a request instance so that we can handle
		// request and responses to the city's specific API
		APIRequestInstance = new TFLRequestAPI(handler);
		APIRequestInstance = new GmmybusRequestAPI(handler);
	}

	function onMenu() {
		return true;
	}

	function onSelect() {
		if( posnInfo != null ) {
			notify.invoke("Executing\nrequest");

			// Since we have a position, we don't need the message anymore
			gps_ready_msg = false;

			APIRequestInstance.setPosition(posnInfo);
			var stopsEndpoint = APIRequestInstance.stopsEndpoint;
			// Make a request to the stops endpoint
			APIRequestInstance.makeWebRequest(stopsEndpoint);
		} else {
			notify.invoke("Waiting for GPS");
			// If we are here for a second time, (gps_ready_msg is already false),
			// it means we lost the signal. Reset the boolean
			if (gps_ready_msg == false) {
				gps_ready_msg = true;
			}
		}
		return true;
	}

	function setPosition(info) {
		posnInfo = info;
		// If we have a position for the first time, notify the user
		if (gps_ready_msg) {
			notify.invoke("GPS ready\nPress start button");
		}
	}
}