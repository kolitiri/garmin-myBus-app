# MyBus Garmin watch app
This is a Garmin watch application that helps you keep track of the bus arrivals on your nearest bus stops.

It currently works only for London as it makes use of the TFL's unified API that can be found [here](https://api.tfl.gov.uk/)

The application is using the internal GPS of the watch to pick up your current location. It then makes two requests:
* The first request returns the bus stops within a radius (selected by the user) of your location.
* The second request returns the buses and their prediction times for the stop that you select.

All traffic goes through a proxy service which filters TFL responses before it forwards them back to the watch. The service can be found [here](https://github.com/chris220688/myBus-web-service)

This way I can handle a lot bigger TFL responses without the watch crashing, which should get rid of the errors that occur when there are many bus stops around.

### Installation

If you already own a Garmin watch, go ahead and download the application through Garmin IQ Connect [here](https://apps.garmin.com/en-US/apps/32c1e832-9bab-4ce3-9461-fb61d8d546a8)

### Supported devices

The app has been tested on a Garmin fenix3 watch.

It should be functional on any fenix 3, fenix 5 and Chronos series and might as well run on more Garmin watches, depending on screen dimensions.

### Issues

1. The application currently supports bus stops only within London since it is only using TFL's API. However, it is very easy to extend it by plugging in a class that extends APIRequest. See RequestAPIs/Samples for more information.

2. The accuracy depends on the information returned by the TFL's endpoints. After multiple tests, I found that using a small radius (<20m) won't return results even though there might be bus stops within that range. That being said, I have made the radius configurable by the users so that they can increase it and broaden the search.

### Acknowledgements

This application is Powered by TfL Open Data and contains OS data © Crown copyright and database rights 2016

### Authors

Chris Liontos
