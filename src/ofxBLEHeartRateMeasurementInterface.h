//
//  ofxBLEHeartRateMeasurementInterface.h
//
//  Created by ISHII 2bit on 2014/06/06.
//
//

#ifndef __ofxBLEHeartRateMeasurementInterface__
#define __ofxBLEHeartRateMeasurementInterface__

#include "ofMain.h"

class ofxBLEHeartRateMeasurementInterface {
public:
    virtual void foundDevice(const string &uuid, const string &localName, bool isInTarget) {};
    virtual void connectionFailure(const string &uuid, const string &errorDescription) {};
    virtual void updateConnectionState(const string &uuid, bool isConnected) = 0;
    virtual void receiveHeartRate(const string &uuid, int heartRate) = 0;
};

#endif
