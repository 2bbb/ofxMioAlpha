//
//  ofxBleSensorTag.h
//
//  Created by Morimasa Aketa on 2015/12/12.
//  Based on the code by ISHII 2bit on 2014/02/01.
//  Copyright (c) 2015 Morimasa Aketa
//

#pragma once

#include "ofxBleSensorTagInterface.h"

class ofxBleSensorTag : public ofxBleSensorTagInterface {
public:
    ofxBleSensorTag();
    virtual ~ofxBleSensorTag();
    
    void setup(ofxBleSensorTagInterface *interface = NULL);
    void addDeviceUUID(const string &uuid);
    bool startScan();
    void stopScan();
    void disconnect();
    
    vector<int> getLatestHeartBeatsFromDevice(const string &uuid);
    bool isConnectedToDevice(const string &uuid) const;
    
    const vector<string> &getConnectedDeviceUUIDs() const;
    const vector<string> &getUnknownDeviceUUIDs() const;
    
    void findDevice(const string &uuid, bool isInTarget);
    void receiveValue(const string &uuid, double value, int type);
    void updateConnectionState(const string &uuid, bool isConnected);
    
private:
    map<string, bool> deviceConnectionInfos;
    map<string, vector<int> > latestHeartRates;
    
    vector<string> connectedDeviceUUIDs;
    vector<string> unknownDeviceUUIDs;
    
    ofxBleSensorTagInterface *interface;
    void *bridge;
};
