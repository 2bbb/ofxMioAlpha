//
//  ofxMioAlphaInterface.h
//
//  Created by ISHII 2bit on 2014/06/06.
//
//

#ifndef __ofxMioAlphaInterface__
#define __ofxMioAlphaInterface__

#include "ofMain.h"

class ofxMioAlphaInterface {
public:
    virtual void receiveHeartRate(const string &uuid, int heartRate) = 0;
    virtual void updateConnectionState(const string &uuid, bool isConnected) = 0;
};

#endif
