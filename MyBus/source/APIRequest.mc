using Toybox.Application as App;
using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;


/**
* APIRequest Model Object that provides an interface
* for making web requests and handling the responses.
*
* This class acts as a wrapper and it requires a subclass
* that implements the actual functions that perform the
* operations. This makes it easy to extend the functionality
* for more cities by simply creating a new subclass. See:
* requestAPIs.Samples.SampleCityRequestAPI
*
* @author Christos Liontos
*/
class APIRequest {

	var name;
	var notify;
	var posnInfo;
	var selectedStop;

	var stopsEndpoint;
	var predictionsEndpoint;
	var stopsCallback;
	var predictionsCallback;
	var validatePosition;

	/**
	* Constructor.
	*
	* The constructor is actually invoked by the subclass which is extending the APIRequest.
	* 
	* @param handler: The handler of the application's view delegate.
	* @param stopsEndpoint (symbol): Function the returns the stops endpoint url
	* @param predictionsEndpoint (symbol): Function the returns the predictions endpoint url
	* @param stopsCallback (symbol): Function that is invoked once we have a stops response 
	* @param predictionsCallback (symbol): Function that is invoked once we have a predictions response 
	*/
	function initialize(handler, stopsEndpoint, predictionsEndpoint, stopsCallback, predictionsCallback) {
		notify = handler;
		stopsEndpoint = stopsEndpoint;
		predictionsEndpoint = predictionsEndpoint;
		stopsCallback = stopsCallback;
		predictionsCallback = predictionsCallback;
	}

	/**
	* Set the position information acquired by the GPS
	*
	* @param info (Toybox::Position::Info): The GPS information
	*/
	function setPosition(info) {
		posnInfo = info;
	}

	/**
	* Set the stop that was selected by the StopsPicker
	*
	* @param stop (String): The name of the stop (i.e stop letter)
	*/
	function setSelectedStop(stop) {
		selectedStop = stop;
	}

	/**
	* Make a web request to a specific endpoint.
	*
	* Delegates the request execution to the apiInstance object,
	* so that new classes can be easily created to support other
	* cities with different APIs.
	* 
	* @param requestType (symbol): The type of function to retrieve request variables.
	*/
	function makeWebRequest(requestType) {
		notify.invoke("Executing\nrequest");

		// Generate the request information. This will invoke the functions
		// of the subclass (i.e TFLRequestApi) and works out the variables.
		var requestInfo = method(requestType).invoke();

		var url = requestInfo["url"];
		var parameters = requestInfo["parameters"];
		var callback = requestInfo["callback"];
		var error = requestInfo["error"];

		if (error != null) {
			notify.invoke(error);
			return;
		}

		var options;
		var api_pref = App.getApp().getProperty("useDirectTFL");
		if (api_pref == true) {
			options = {
				:method => Communications.HTTP_REQUEST_METHOD_GET,
				:headers => {
						"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
				},
				:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
			};
		} else {
			options = {
				:method => Communications.HTTP_REQUEST_METHOD_POST,
				:headers => {
						"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
				},
				:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
			};
		}

		Comm.makeWebRequest(
			url,
			parameters,
			options,
			method(callback)
		);
	}

	/**
	* Callback function that is invoked when there is a
	* response to a request to the stops endpoint.
	*
	* Delegates the response handling to the subclass object.
	* 
	* @param responseCode (string): Garmin SDK response code
	* @param data (dict): The response data
	*/
	function onReceiveStops(responseCode, data) {
		if (responseCode == 200) {

			// Handle the stops response. This will invoke the functions
			// of the subclass (i.e TFLRequestApi) and works out the information.
			var responseInfo = method(stopsCallback).invoke(data);

			var stopNames = responseInfo["stopNames"];
			var error = responseInfo["error"];

			if (error == null && stopNames != null) {
				// We have a stops list. Create a picker with these stops
				Ui.pushView(new StopsPicker(stopNames), new StopsPickerDelegate(self), Ui.SLIDE_IMMEDIATE);
			} else {
				notify.invoke(error);
			}
		} else {
			if (responseCode == -104) {
				notify.invoke("Not connected to phone\nTurn on BT and try again");
			} else if (responseCode == -402) {
				notify.invoke("Stops response\ntoo large");
			} else {
				notify.invoke(responseCode.toString() + "\nonReceiveStops");
			}
		}
	}

	/**
	* Callback function that is invoked when there is a
	* response to a request to the predictions endpoint.
	*
	* Delegates the response handling to the subclass object.
	* 
	* @param responseCode (string): Garmin SDK response code
	* @param data (dict): The response data
	*/
	function onReceivePredictions(responseCode, data) {
		if (responseCode == 200) {

			// Handle the predictions responce. This will invoke the functions
			// of the subclass (i.e TFLRequestApi) and works out the information.
			var responseInfo = method(predictionsCallback).invoke(data);

			var result = responseInfo["result"];
			var error = responseInfo["error"];

			if (error == null) {
				notify.invoke(result);
			} else {
				notify.invoke(error);
			}
		} else {
			if (responseCode == -104) {
				notify.invoke("Not connected to phone");
			} else if (responseCode == -402) {
				notify.invoke("Predictions response\ntoo large");
			} else {
				notify.invoke(responseCode.toString() + "\nonReceivePredictions");
			}
		}
	}
}