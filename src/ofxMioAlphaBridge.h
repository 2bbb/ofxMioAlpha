//
//  ofxMioAlphaBridge.h
//
//  Created by ISHII 2bit on 2014/06/06.
//
//

#pragma once

#include "ofxMioAlphaInterface.h"

class ofxMioAlphaBridge {
public:
    ofxMioAlphaBridge();
    virtual ~ofxMioAlphaBridge();
    
    void setup(ofxMioAlphaInterface *interface);
    void addDeviceUUID(const string &uuid);
    bool startScan();
    
    void setConnected(bool bConnected);
    
    void receiveHeartrate(int heartRate);

private:
    ofxMioAlphaInterface *interface;
    void *bridgeImpl;
};