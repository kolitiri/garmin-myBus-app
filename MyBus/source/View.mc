using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;


/**
* View Model Object
*
* @author Christos Liontos
*/
class View extends Ui.View {

	hidden var mMessage = "Press menu button";
	hidden var mModel;
	var posnInfo;

	function initialize() {
		View.initialize();
	}

	function onLayout(dc) {
		mMessage = "Press start button";
	}

	function onUpdate(dc) {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		dc.clear();
		dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_TINY, mMessage, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

		// Every time we have an update, we need to draw the GPS bar
		drawGpsBar(dc);
	}

	function setPosition(info) {
		posnInfo = info;
	}

	function onReceive(args) {
		if (args instanceof Lang.String) {
			mMessage = args;
		}
		else if (args instanceof Dictionary) {
			// Print the arguments duplicated and returned by jsonplaceholder.typicode.com
			var keys = args.keys();
			mMessage = "";
			for( var i = 0; i < keys.size(); i++ ) {
				mMessage += Lang.format("$1$: $2$\n", [keys[i], args[keys[i]]]);
			}
		}
		Ui.requestUpdate();
	}

	/**
	* Draws the GPS bar on the UI
	*
	* @param info (Toybox::Graphics::Dc): The device context
	*/
	function drawGpsBar(dc) {
		// Draw the GPS word
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		dc.drawText(dc.getWidth()/2, 25, Graphics.FONT_XTINY, "GPS", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

		// Draw the white GPS bar (background)
		dc.setPenWidth(3);
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
		dc.drawArc(dc.getWidth()/2, 100, 90, dc.ARC_CLOCKWISE, 120, 60);

		if (posnInfo == null) {
			return;
		}

		var acc = posnInfo.accuracy;

		// Select the foreground color according to the strength of the GPS accuracy
		switch (acc) {
			case 0:
				return;
			case 1:
				dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
				break;
			case 2:
				dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
				break;
			default:
				dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
				break;
		}

		// Draw the foreground
		var x = dc.getWidth()/2;
		var y = 100;
		var r = 90;
		var attr = dc.ARC_CLOCKWISE;
		var degreeStart = 120;
		var degreeEnd = 120-(acc*15);

		dc.drawArc(x, y, r, attr, degreeStart, degreeEnd);
	}
}