using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;


 /**
 * RadiusPicker Model Object
 * 
 * @author Christos Liontos
 */
class RadiusPicker extends Ui.Picker {

	var radiusFloor = 20;
	var radiusCeil = 200;
	var radiusStep = 20;

    function initialize() {
    	var title = "Select search radius";
        var ttl = new Ui.Text({:text=>title, :locX =>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color=>Gfx.COLOR_WHITE, :font=>Gfx.FONT_TINY});
        var factory = new NumberFactory(radiusFloor, radiusCeil, radiusStep, {:font=>Gfx.FONT_MEDIUM});
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
class RadiusPickerDelegate {
	var APIRequestInstance;

	function initialize(instance) {
		// Allow the picker to access the request instance
		APIRequestInstance = instance;
	}

    function onAccept(values) {
    	APIRequestInstance.setRadius(values[0]);
    	Ui.popView(Ui.SLIDE_IMMEDIATE);
    }

    function onCancel() {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
    }
}