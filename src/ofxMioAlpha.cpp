//
//  ofxMioAlpha.mm
//
//  Created by ISHII 2bit
//

#include "ofxMioAlpha.h"
#import "ofxMioAlphaBridge.h"

void ofxMioAlpha::setup(ofxMioAlphaInterface *interface) {
    bridge = new ofxMioAlphaBridge();
    bridge->setup(this);
    bridge->startScan();
    
    this->interface = interface;
}

void ofxMioAlpha::addDeviceUUID(const string &uuid) {
    bridge->addDeviceUUID(uuid);
}

bool ofxMioAlpha::startScan() {
    return bridge->startScan();
}

vector<int> ofxMioAlpha::getLatestHeartBeatsFromDevice(const string &uuid) {
    vector<int> results = latestHeartRates[uuid];
    latestHeartRates[uuid].clear();
    
    return results;
}

bool ofxMioAlpha::isConnectedToDevice(const string &uuid) const {
    return deviceConnectionInfos.at(uuid);
}

void ofxMioAlpha::receiveHeartRate(const string &uuid, int heartRate) {
    latestHeartRates[uuid].push_back(heartRate);
    
    if(interface) interface->receiveHeartRate(uuid, heartRate);
}

void ofxMioAlpha::updateConnectionState(const string &uuid, bool isConnected) {
    deviceConnectionInfos[uuid] = isConnected;
    
    if(interface) interface->updateConnectionState(uuid, isConnected);
}