using Toybox.WatchUi as Ui;


/**
* TFLRequestAPI Model Object that provides a number of
* functions that deal with the London's TFL API.
*
* This class is a subclass of APIRequest which is
* actually making the requests and receives the responses.
*
* @author Christos Liontos
*/
class TFLRequestAPI extends APIRequest {

	// Default radius to 100m. To be overridden by the user
	var searchRadius = 100;
	var availableStops;
	var stopPointEndpoint = "https://api.tfl.gov.uk/StopPoint/";

	/**
	* Constructor.
	*
	* The constructor is initializing the superclass's functions.
	* 
	* @param handler: The handler of the application's view delegate.
	* @param stopsEndpoint (symbol): Function the returns the stops endpoint url
	* @param predictionsEndpoint (symbol): Function the returns the predictions endpoint url
	* @param stopsCallback (symbol): Function that is invoked once we have a stops response 
	* @param predictionsCallback (symbol): Function that is invoked once we have a predictions response
	*/
	function initialize(handler) {
		stopsEndpoint = :getTFLStopsEndpoint;
		predictionsEndpoint = :getTFLPredictionsEndpoint;
		stopsCallback = :onReceiveTFLStops;
		predictionsCallback = :onReceiveTFLPredictions;
		validatePosition = :validatePosition;
		APIRequest.initialize(handler, stopsEndpoint, predictionsEndpoint, stopsCallback, predictionsCallback);

		// Ask user input for the search radius
		Ui.pushView(new RadiusPicker(), new RadiusPickerDelegate(self), Ui.SLIDE_IMMEDIATE);
	}

	/**
	* Set the radius within which we will search for stops.
	*
	* This is set up by the user via the RadiusPicker
	* 
	* @param radius (int): The radius of the search
	*/
	function setRadius(radius) {
		searchRadius = radius;
	}

	/**
	* Validate the user's location. Should be within UK bounds
	* 
	* @param lat (int): The latitude
	* @param lon (int): The longtitude
	*/
	function validatePosition(lat,lon) {
		if (lat < 49.9 || lat > 58.7 || lon < -11.05 || lon > 1.78) {
			return 0;
		}
		return 1;
	}

	/**
	* Generate the url, parameters and callback for a stops request.
	*
	* i.e
	* https://api.tfl.gov.uk/StopPoint?lat=51.492632&&lon=-0.223061&stoptypes=NaptanPublicBusCoachTram&radius=60&returnLines=False
	* 
	* @return requestInfo (dict): A dictionary with the request variables
	*/
	function getTFLStopsEndpoint() {
		var requestInfo = {
			"url" => null,
			"parameters" => null,
			"callback" => :onReceiveStops,
			"error" => null
		};

		var lat = posnInfo.position.toDegrees()[0];
		var lon = posnInfo.position.toDegrees()[1];

		if (validatePosition(lat,lon) == 0) {
			requestInfo["error"] = "Oops! It appears your\nlocation is out\nof the UK bounds";
		}

		requestInfo["url"] = stopPointEndpoint;

		requestInfo["parameters"] = {
			"lat" => lat.toString(),
			"lon" => lon.toString(),
			"radius" => searchRadius,
			"stoptypes" => "NaptanPublicBusCoachTram",
			"returnLines" => "False"
		};

		return requestInfo;
	}

	/**
	* Generate the url, parameters and callback for a predictions request.
	*
	* i.e
	* https://api.tfl.gov.uk/StopPoint/490007705L/Arrivals?mode=bus
	* 
	* @return requestInfo (dict): A dictionary with the request variables
	*/
	function getTFLPredictionsEndpoint() {
		var requestInfo = {
			"url" => null,
			"parameters" => null,
			"callback" => :onReceivePredictions
		};

		var naptanId = null;
		for(var i = 0; i < availableStops.size(); i ++) {
			if (availableStops[i]["stopLetter"] == selectedStop) {
				naptanId = availableStops[i]["naptanId"];
				break;
			}
		}

		requestInfo["url"] = stopPointEndpoint + naptanId + "/Arrivals";

		requestInfo["parameters"] = {
			"mode" => "bus"
		};

		return requestInfo;
	}

	/**
	* Function that is invoked by the onReceiveStops callback.
	* It parses the response and works out all the stops that
	* are around the location picked up by the GPS.
	* 
	* @param data (dict): The response data of a request to the stops endpoint
	* @return responseInfo (dict): A dictionary with the response information
	*/
	function onReceiveTFLStops(data) {
		var responseInfo = {
			"stopNames" => null,
			"error" => null
		};

		availableStops = parseStops(data);

		if (availableStops.size() > 0) {
			var stopNames = [];
			for(var i = 0; i < availableStops.size(); i ++) {
				var stop = availableStops[i]["stopLetter"];
				if (stop != null) {
					stopNames.add(stop);
				}
			}
			responseInfo["stopNames"] = stopNames;
		} else {
			responseInfo["error"] = "No stops around";
		}

		return responseInfo;
	}

	/**
	* Function that is invoked by the onReceivePredictions callback.
	* It parses the response and works out all the buses that pass
	* by the stop that was selected by the user.
	* 
	* @param data (dict): The response data of a request to the predictions endpoint
	* @return responseInfo (dict): A dictionary with the response information
	*/
	function onReceiveTFLPredictions(data) {
		var responseInfo = {
			"result" => null,
			"error" => null
		};

		var result = "Stop " + selectedStop + "\n";
		var buses = parseBuses(data);

		if (buses.size() > 0) {
			// Construct the string to show in the watch screen
			for(var i = 0; i < buses.keys().size(); i ++) {
				var key = buses.keys()[i];
				var bus_list_to_str = buses[key].toString();
				// Remove the brackets from the bus_list
				var bus_list = bus_list_to_str.substring(1, bus_list_to_str.length() - 1);
				result += key + " in: " + bus_list + "\n";
			}
			responseInfo["result"] = result;
		} else {
			responseInfo["error"] = "Apparently there are\nno buses running at\nbus stop " + selectedStop + "\nat the moment!";
		}

		return responseInfo;
	}

	function parseStops(data) {
		var stopPoints = data["stopPoints"];

		var stops = [];
		for(var i = 0; i < stopPoints.size(); i ++) {
			var stopLetter = stopPoints[i]["stopLetter"];
			var naptanId = stopPoints[i]["naptanId"];
			var distance = stopPoints[i]["distance"];
			var stop = {
				"stopLetter" => stopLetter,
				"naptanId" => naptanId,
				"distance" => distance
			};
			stops.add(stop);
		}
		return stops;
	}

	function parseBuses(data) {
		var buses = {};
		for(var i = 0; i < data.size(); i ++) {
			var bus = data[i]["lineName"].toString();
			var timeToStation = (data[i]["timeToStation"] / 60);

			if (buses[bus] == null) {
				var bus_list = [];
				bus_list.add(timeToStation);
				buses[bus] = bus_list;
			} else {
				buses[bus].add(timeToStation);
			}
		}

		for(var i = 0; i < buses.keys().size(); i ++) {
			var bus_list = buses[buses.keys()[i]];

			sort(bus_list);
		}
		return buses;
	}
	
	function sort(list) {
		var len = list.size();
		for(var i = 0; i < len; i ++) {
			for(var j = 0; j < len-1; j ++) {
				if (list[i] < list[j]) {
					var tmp = list[i];
					list[i] = list[j];
					list[j] = tmp;
				}
			}
		}
		return list;
	}
}