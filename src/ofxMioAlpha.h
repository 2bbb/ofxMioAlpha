//
//  ofxMioAlpha.h
//
//  Created by ISHII 2bit
//

#pragma once

#include "ofMain.h"
#include "ofxMioAlphaInterface.h"

class ofxMioAlpha : public ofxMioAlphaInterface {
public:
    void setup(ofxMioAlphaInterface *interface = NULL);
    void addDeviceUUID(const string &uuid);
    bool startScan();
    void stopScan();
    
    vector<int> getLatestHeartBeatsFromDevice(const string &uuid);
    bool isConnectedToDevice(const string &uuid) const;
    
    void receiveHeartRate(const string &uuid, int heartRate);
    void updateConnectionState(const string &uuid, bool isConnected);
    
private:
    map<string, bool> deviceConnectionInfos;
    map<string, vector<int> > latestHeartRates;
    ofxMioAlphaInterface *interface;
    void *bridge;
};
