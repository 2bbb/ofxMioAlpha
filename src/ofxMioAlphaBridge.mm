//
//  ofxMioAlphaBridge.mm
//
//  Created by ISHII 2bit on 2014/06/06.
//
//

#import "ofxMioAlphaBridge.h"
#import "BluetoothManager.h"
#import "ofxMioAlphaBridgeImpl.h"

ofxMioAlphaBridge::ofxMioAlphaBridge() {
    bridgeImpl = NULL;
}

ofxMioAlphaBridge::~ofxMioAlphaBridge() {
    if(bridgeImpl != NULL) {
        [(ofxMioAlphaBridgeImpl *)bridgeImpl release];
        bridgeImpl = NULL;
    }
}

void ofxMioAlphaBridge::setup(ofxMioAlphaInterface *interface) {
    this->interface = interface;
    bridgeImpl = (ofxMioAlphaBridgeImpl *)[[ofxMioAlphaBridgeImpl alloc] initWithBridge:this];
}

void ofxMioAlphaBridge::addDeviceUUID(const string &uuid) {
    ofxMioAlphaBridgeImpl *impl = (ofxMioAlphaBridgeImpl *)bridgeImpl;
    [impl addDeviceUUID:[NSString stringWithCString:uuid.c_str()
                                           encoding:NSUTF8StringEncoding]];
}

bool ofxMioAlphaBridge::startScan() {
    return (bool)[(ofxMioAlphaBridgeImpl *)bridgeImpl startScan];
}

void ofxMioAlphaBridge::setConnected(bool bConnected) {
    interface->updateConnectionState("", bConnected);
}

void ofxMioAlphaBridge::receiveHeartrate(int heartRate) {
    interface->receiveHeartRate("", heartRate);
}