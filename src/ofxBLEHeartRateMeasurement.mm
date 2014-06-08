//
//  ofxBLEHeartRateMeasurement.cpp
//
//  Created by ISHII 2bit on 2014/06/08.
//

#include "ofxBLEHeartRateMeasurement.h"
#import "ofxBLEHeartRateMeasurementBridge.h"
#import "BluetoothManager.h"

ofxBLEHeartRateMeasurement::ofxBLEHeartRateMeasurement() {
    bridge = NULL;
}

ofxBLEHeartRateMeasurement::~ofxBLEHeartRateMeasurement() {
    if(bridge != NULL) {
        [(ofxBLEHeartRateMeasurementBridge *)bridge release];
        bridge = NULL;
    }
    this->stopScan();
}

void ofxBLEHeartRateMeasurement::setup(ofxBLEHeartRateMeasurementInterface *interface) {
    bridge = (void *)[[ofxBLEHeartRateMeasurementBridge alloc] initWithInterface:this];
    this->interface = interface;
}

void ofxBLEHeartRateMeasurement::addDeviceUUID(const string &_uuid) {
    deviceConnectionInfos.insert(map<string, bool>::value_type(_uuid, false));
    latestHeartRates.insert(map<string, vector<int> >::value_type(_uuid, vector<int>()));
    NSString *uuid = [NSString stringWithUTF8String:_uuid.c_str()];
    [[BluetoothManager sharedManager] addTargetUUID:uuid];
}

void ofxBLEHeartRateMeasurement::addLocalNameFilter(const string _localName) {
    NSString *locaName = [NSString stringWithUTF8String:_localName.c_str()];
    [[BluetoothManager sharedManager] addTargetLocalName:locaName];
}

bool ofxBLEHeartRateMeasurement::startScan() {
    return (bool)[[BluetoothManager sharedManager] scan];
}

void ofxBLEHeartRateMeasurement::stopScan() {
    [[BluetoothManager sharedManager] stopScan];
}

void ofxBLEHeartRateMeasurement::disconnect() {
    [[BluetoothManager sharedManager] disconnect];
}

#pragma mark getter

vector<int> ofxBLEHeartRateMeasurement::getLatestHeartBeatsFromDevice(const string &uuid) {
    vector<int> results = latestHeartRates[uuid];
    latestHeartRates[uuid].clear();
    
    return results;
}

bool ofxBLEHeartRateMeasurement::isConnectedToDevice(const string &uuid) const {
    return deviceConnectionInfos.at(uuid);
}

const vector<string> &ofxBLEHeartRateMeasurement::getConnectedDeviceUUIDs() const {
    return connectedDeviceUUIDs;
}

const vector<string> &ofxBLEHeartRateMeasurement::getUnknownDeviceUUIDs() const {
    return unknownDeviceUUIDs;
}

#pragma mark implementation of ofxBLEHeartRateMeasurementInterface

void ofxBLEHeartRateMeasurement::foundDevice(const string &uuid, bool isInTarget) {
    if(isInTarget) {
        
    } else {
        vector<string>::iterator result = find(unknownDeviceUUIDs.begin(), unknownDeviceUUIDs.end() , uuid);
        
        if(result == unknownDeviceUUIDs.end()){
            unknownDeviceUUIDs.push_back(uuid);
        }
        ofLogVerbose() << uuid << " is found.";
    }
}

void ofxBLEHeartRateMeasurement::receiveHeartRate(const string &uuid, int heartRate) {
    latestHeartRates[uuid].push_back(heartRate);
    
    if(interface) interface->receiveHeartRate(uuid, heartRate);
}

void ofxBLEHeartRateMeasurement::updateConnectionState(const string &uuid, bool isConnected) {
    deviceConnectionInfos[uuid] = isConnected;
    
    if(interface) interface->updateConnectionState(uuid, isConnected);
}