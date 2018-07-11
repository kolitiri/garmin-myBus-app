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
	* Generate the url, parameters and callback for a stops request.
	* 
	* @return requestInfo (dict): A dictionary with the request variables
	*/
	function getTFLStopsEndpoint() {	
		var lat = posnInfo.position.toDegrees()[0].toString();
		var lon = posnInfo.position.toDegrees()[1].toString();

		var url = "https://api.tfl.gov.uk/Stoppoint";

		var parameters = {
			"lat" => lat,
			"lon" => lon,
			"radius" => searchRadius,
			"stoptypes" => "NaptanPublicBusCoachTram"
		};
		
		var requestInfo = {
			"url" => url,
			"parameters" => parameters,
			"callback" => :onReceiveStops
		};
		return requestInfo;
	}

	/**
	* Generate the url, parameters and callback for a predictions request.
	* 
	* @return requestInfo (dict): A dictionary with the request variables
	*/
	function getTFLPredictionsEndpoint() {
		var naptanId = null;
		for(var i = 0; i < availableStops.size(); i ++) {
			if (availableStops[i]["stopLetter"] == selectedStop) {
				naptanId = availableStops[i]["naptanId"];
				break;
			}
		}
		
		var url = "https://api.tfl.gov.uk/StopPoint/" + naptanId + "/Arrivals?mode=bus";
		
		var requestInfo = {
			"url" => url,
			"parameters" => {},
			"callback" => :onReceivePredictions
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

		for(var i = 0; i < buses.keys().size(); i ++) {
			var key = buses.keys()[i];
			result += key + " in: " + buses[key].toString() + "\n"; 
		}

		responseInfo["result"] = result;

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