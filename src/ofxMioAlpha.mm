//
//  ofxMioAlpha.mm
//
//  Created by ISHII 2bit
//

#include "ofxMioAlpha.h"
#import "ofxMioAlphaBridge.h"
#import "BluetoothManager.h"

ofxMioAlpha::ofxMioAlpha() {
    bridge = NULL;
}

ofxMioAlpha::~ofxMioAlpha() {
    if(bridge != NULL) {
        [(ofxMioAlphaBridge *)bridge release];
        bridge = NULL;
    }
    this->stopScan();
}

void ofxMioAlpha::setup(ofxMioAlphaInterface *interface) {
    bridge = (void *)[[ofxMioAlphaBridge alloc] initWithInterface:this];
    this->interface = interface;
}

void ofxMioAlpha::addDeviceUUID(const string &uuid) {
    deviceConnectionInfos.insert(map<string, bool>::value_type(uuid, false));
    latestHeartRates.insert(map<string, vector<int> >::value_type(uuid, vector<int>()));
    NSString *uuidStr = [NSString stringWithCString:uuid.c_str()
                                           encoding:NSUTF8StringEncoding];
    [[BluetoothManager sharedManager] addTargetUUID:uuidStr];
}

bool ofxMioAlpha::startScan() {
    return (bool)[[BluetoothManager sharedManager] scan];
}

void ofxMioAlpha::stopScan() {
    [[BluetoothManager sharedManager] stopScan];
}

void ofxMioAlpha::disconnect() {
    [[BluetoothManager sharedManager] disconnect];
}

#pragma mark getter

vector<int> ofxMioAlpha::getLatestHeartBeatsFromDevice(const string &uuid) {
    vector<int> results = latestHeartRates[uuid];
    latestHeartRates[uuid].clear();
    
    return results;
}

bool ofxMioAlpha::isConnectedToDevice(const string &uuid) const {
    return deviceConnectionInfos.at(uuid);
}

const vector<string> &ofxMioAlpha::getConnectedDeviceUUIDs() const {
    return connectedDeviceUUIDs;
}

const vector<string> &ofxMioAlpha::getUnknownDeviceUUIDs() const {
    return unknownDeviceUUIDs;
}

#pragma mark implementation of ofxMioAlphaInterface

void ofxMioAlpha::findDevice(const string &uuid, bool isInTarget) {
    if(isInTarget) {
        
    } else {
        vector<string>::iterator result = find(unknownDeviceUUIDs.begin(), unknownDeviceUUIDs.end() , uuid);
        
        if(result == unknownDeviceUUIDs.end()){
            unknownDeviceUUIDs.push_back(uuid);
        }
        ofLogVerbose() << uuid << " is found.";
    }
}

void ofxMioAlpha::receiveHeartRate(const string &uuid, int heartRate) {
    latestHeartRates[uuid].push_back(heartRate);
    
    if(interface) interface->receiveHeartRate(uuid, heartRate);
}

void ofxMioAlpha::updateConnectionState(const string &uuid, bool isConnected) {
    deviceConnectionInfos[uuid] = isConnected;
    
    if(interface) interface->updateConnectionState(uuid, isConnected);
}