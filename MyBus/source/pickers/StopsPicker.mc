using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;


/**
* StopsPicker Model Object
*
* @author Christos Liontos
*/
class StopsPicker extends Ui.Picker {

	function initialize(stopNames) {
		var title = "Select stop";
		var ttl = new Ui.Text({:text=>title, :locX =>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color=>Gfx.COLOR_WHITE, :font=>Gfx.FONT_TINY});
		var factory = new WordFactory(stopNames, {:font=>Gfx.FONT_MEDIUM});
		Picker.initialize({:title=>ttl, :pattern=>[factory]});
	}

	function onUpdate(dc) {
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		dc.clear();
		Picker.onUpdate(dc);
	}
}

/**
* StopsPickerDelegate Model Object
* 
* @author Christos Liontos
*/
class StopsPickerDelegate {
	var APIRequestInstance;

	function initialize(instance) {
		// Allow the picker to access the request instance
		APIRequestInstance = instance;
	}

	function onAccept(values) {
		APIRequestInstance.setSelectedStop(values[0]);
		var predictionsEndpoint = APIRequestInstance.predictionsEndpoint;
		// Now that we have the stop name, make a predictions request,
		// to retrieve all the bus predictions for this stop.
		APIRequestInstance.makeWebRequest(predictionsEndpoint);
		Ui.popView(Ui.SLIDE_IMMEDIATE);
	}

	function onCancel() {
		Ui.popView(Ui.SLIDE_IMMEDIATE);
	}
}