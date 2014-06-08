//
//  ofxBLEHeartRateMeasurement.h
//
//  Created by ISHII 2bit on 2014/06/08.
//

#pragma once

#include "ofxBLEHeartRateMeasurementInterface.h"

class ofxBLEHeartRateMeasurement : public ofxBLEHeartRateMeasurementInterface {
public:
    ofxBLEHeartRateMeasurement();
    virtual ~ofxBLEHeartRateMeasurement();
    
    void setup(ofxBLEHeartRateMeasurementInterface *interface = NULL);
    void addDeviceUUID(const string &uuid);
    void addLocalNameFilter(const string localName);
    bool startScan();
    void stopScan();
    void disconnect();
    
    vector<int> getLatestHeartBeatsFromDevice(const string &uuid);
    bool isConnectedToDevice(const string &uuid) const;
    
    const vector<string> &getConnectedDeviceUUIDs() const;
    const vector<string> &getUnknownDeviceUUIDs() const;
    
    void foundDevice(const string &uuid, bool isInTarget);
    void receiveHeartRate(const string &uuid, int heartRate);
    void updateConnectionState(const string &uuid, bool isConnected);
    
protected:
    map<string, bool> deviceConnectionInfos;
    map<string, vector<int> > latestHeartRates;
    
    vector<string> connectedDeviceUUIDs;
    vector<string> unknownDeviceUUIDs;
    
    ofxBLEHeartRateMeasurementInterface *interface;
    void *bridge;
};
