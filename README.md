# ofxMioAlpha

## How to use

1. Add IOBluetooth.framework to your project
2. Include ofxMioAlpha.h

## API

### ofxMioAlpha

* void setup(ofxMioAlphaInterface *interface = NULL);

you can use _interface_, if you create custom callback reciver class that inherits ofxMioAlphaInterface.
default is NULL, that means only ofxMioAlpha instance receives callback.

* void  addDeviceUUID(const string &uuid);

add uuid of Mio device that you want to connect.
this uuid becomes the key to pull data from ofxMioAlpha instance and identifies data in receive callback.

* bool startScan();

start to scan devices. true is returned when it succeeds.

* void stopScan();

stop scanning the device.

* void disconnect();

disconnect all devices.

* vector<int> getLatestHeartBeatsFromDevice(const string &uuid);

get latest heart rates receive from device that has _uuid_.

* bool isConnectedToDevice(const string &uuid) const;

get latest connection status of device that has _uuid_.

### ofxMioAlphaInterface

this is abstract interface of callback receiver. you create class inherits this class, if you want to custom callback receiver.

* virtual void receiveHeartRate(const string &uuid, int heartRate);
* virtual void updateConnectionState(const string &uuid, bool isConnected);


## Update history

### ver 0.01 [beta] release

maybe buggy now...

### ver 0.02 [beta] release

maybe corresponded to iOS.

## License

MIT License.

## Author

* ISHII 2bit [[bufferRenaiss co., ltd.](http://buffer-renaiss.com)]
* ishii[at]buffer-renaiss.com

## Special Thanks

* [Kyle McDonald](https://twitter.com/kcimc)

## At the last

Please create new issue, if there is a problem.

And please throw pull request, if you have a cool idea!!