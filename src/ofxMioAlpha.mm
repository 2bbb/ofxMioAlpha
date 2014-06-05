//
//  ofxMioAlpha.mm
//
//  Created by ISHII 2bit
//

#include "ofxMioAlpha.h"
#import "ofxMioAlphaBridge.h"
#import "BluetoothManager.h"

void ofxMioAlpha::setup(ofxMioAlphaInterface *interface) {
    bridge = (void *)[[ofxMioAlphaBridge alloc] initWithInterface:this];
    this->interface = interface;
}

void ofxMioAlpha::addDeviceUUID(const string &uuid) {
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

#pragma mark getter

vector<int> ofxMioAlpha::getLatestHeartBeatsFromDevice(const string &uuid) {
    vector<int> results = latestHeartRates[uuid];
    latestHeartRates[uuid].clear();
    
    return results;
}

bool ofxMioAlpha::isConnectedToDevice(const string &uuid) const {
    return deviceConnectionInfos.at(uuid);
}

#pragma mark implementation of ofxMioAlphaInterface

void ofxMioAlpha::receiveHeartRate(const string &uuid, int heartRate) {
    latestHeartRates[uuid].push_back(heartRate);
    
    if(interface) interface->receiveHeartRate(uuid, heartRate);
}

void ofxMioAlpha::updateConnectionState(const string &uuid, bool isConnected) {
    deviceConnectionInfos[uuid] = isConnected;
    
    if(interface) interface->updateConnectionState(uuid, isConnected);
}