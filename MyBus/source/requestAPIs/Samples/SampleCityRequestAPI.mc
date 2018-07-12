/**
* SampleCityRequestAPI Model Object
*
* Use this class as a blueprint to create classes
* for different APIs.
*
* This class should be a subclass of APIRequest which is
* actually making the requests and receives the responses.
*
* @author Christos Liontos
*/
class SampleCityRequestAPI extends APIRequest {

	var availableStops;

	/**
	* Constructor.
	*
	* The constructor will initialize the superclass's functions.
	*
	* @param handler: The handler of the application's view delegate.
	* @param stopsEndpoint (symbol): Function the returns the stops endpoint url
	* @param predictionsEndpoint (symbol): Function the returns the predictions endpoint url
	* @param stopsCallback (symbol): Function that is invoked once we have a stops response 
	* @param predictionsCallback (symbol): Function that is invoked once we have a predictions response 
	*/
	function initialize(handler) {
		stopsEndpoint = :getSampleCityStopsEndpoint;
		predictionsEndpoint = :getSampleCityPredictionsEndpoint;
		stopsCallback = :onReceiveSampleCityStops;
		predictionsCallback = :onReceiveSampleCityPredictions;
		APIRequest.initialize(handler, stopsEndpoint, predictionsEndpoint, stopsCallback, predictionsCallback);
	}

	/**
	* Generate the url, parameters and callback for a stops request.
	* 
	* @return requestInfo (dict): A dictionary with the request variables
	*/
	function getSampleCityStopsEndpoint() {

		// Construct the url, parameters and name of the callback
		// function for the API stops request that you will be calling

		var url = "";

		var parameters = {};
		
		var requestInfo = {
			"url" => url,
			"parameters" => parameters,
			"callback" => :onReceiveStops
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
	function onReceiveSampleCityStops(data) {

		// Parse the response received by the request to the stops endpoint.

		var stopNames = [];

		// The stopNames returned in the dictionary should be a list of strings
		// that represent the stop names around the GPS's position.
		var responseInfo = {
			"stopNames" => null,
			"error" => null
		};

		return responseInfo;
	}

	/**
	* Generate the url, parameters and callback for a predictions request.
	* 
	* @return requestInfo (dict): A dictionary with the request variables
	*/
	function getSampleCityPredictionsEndpoint() {

		// At this point we should have a list of available stops and the one that is
		// selected by the user. Construct the url, parameters and name of the callback
		// function for the API predictons request that you will be calling.

		// TIP: use SampleCityRequestAPI.availableStops and RequestAPI.selectedStop
		// variables to iterate over and find the one selected by the user.

		var url = "";

		var parameters = {};

		var requestInfo = {
			"url" => url,
			"parameters" => parameters,
			"callback" => :onReceivePredictions
		};
		return requestInfo;
	}

	/**
	* Function that is invoked by the onReceivePredictions callback.
	* It parses the response and works out all the buses that pass
	* by the stop that was selected by the user.
	* 
	* @param data (dict): The response data of a request to the predictions endpoint
	* @return responseInfo (dict): A dictionary with the response information
	*/
	function onReceiveSampleCityPredictions(data) {

		// Parse the response received by the request to the predictions endpoint.

		var result = "";

		var responseInfo = {
			"result" => result,
			"error" => null
		};

		return responseInfo;
	}
}