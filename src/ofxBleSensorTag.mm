//
//  ofxBleSensorTag.mm
//
//  Created by Morimasa Aketa on 2015/12/12.
//  Based on the code by ISHII 2bit on 2014/02/01.
//  Copyright (c) 2015 Morimasa Aketa
//

#include "ofxBleSensorTag.h"
#import "ofxBleSensorTagBridge.h"
#import "BluetoothManager.h"

ofxBleSensorTag::ofxBleSensorTag() {
    bridge = NULL;
}

ofxBleSensorTag::~ofxBleSensorTag() {
    if(bridge != NULL) {
        [(ofxBleSensorTagBridge *)bridge release];
        bridge = NULL;
    }
    this->stopScan();
}

void ofxBleSensorTag::setup(ofxBleSensorTagInterface *interface) {
    bridge = (void *)[[ofxBleSensorTagBridge alloc] initWithInterface:this];
    this->interface = interface;

}

void ofxBleSensorTag::addDeviceUUID(const string &uuid) {
    deviceConnectionInfos.insert(map<string, bool>::value_type(uuid, false));
    latestHeartRates.insert(map<string, vector<int> >::value_type(uuid, vector<int>()));
    NSString *uuidStr = [NSString stringWithCString:uuid.c_str()
                                           encoding:NSUTF8StringEncoding];
    [[BluetoothManager sharedManager] addTargetUUID:uuidStr];
}

bool ofxBleSensorTag::startScan() {
    return (bool)[[BluetoothManager sharedManager] scan];
}

void ofxBleSensorTag::stopScan() {
    [[BluetoothManager sharedManager] stopScan];
}

void ofxBleSensorTag::disconnect() {
    [[BluetoothManager sharedManager] disconnect];
}

#pragma mark getter

vector<int> ofxBleSensorTag::getLatestHeartBeatsFromDevice(const string &uuid) {
    vector<int> results = latestHeartRates[uuid];
    latestHeartRates[uuid].clear();
    
    return results;
}

bool ofxBleSensorTag::isConnectedToDevice(const string &uuid) const {
    return deviceConnectionInfos.at(uuid);
}

const vector<string> &ofxBleSensorTag::getConnectedDeviceUUIDs() const {
    return connectedDeviceUUIDs;
}

const vector<string> &ofxBleSensorTag::getUnknownDeviceUUIDs() const {
    return unknownDeviceUUIDs;
}

#pragma mark implementation of ofxBleSensorTagInterface

void ofxBleSensorTag::findDevice(const string &uuid, bool isInTarget) {
    if(isInTarget) {
        
    } else {
        vector<string>::iterator result = find(unknownDeviceUUIDs.begin(), unknownDeviceUUIDs.end() , uuid);
        
        if(result == unknownDeviceUUIDs.end()){
            unknownDeviceUUIDs.push_back(uuid);
        }
        ofLogVerbose() << uuid << " is found.";
    }
}

void ofxBleSensorTag::receiveValue(const string &uuid, double value,int  type) {
    latestHeartRates[uuid].push_back((int)value);
    
    if(interface) interface->receiveValue(uuid, value, type);
}

void ofxBleSensorTag::updateConnectionState(const string &uuid, bool isConnected) {
    deviceConnectionInfos[uuid] = isConnected;
    
    if(interface) interface->updateConnectionState(uuid, isConnected);
}