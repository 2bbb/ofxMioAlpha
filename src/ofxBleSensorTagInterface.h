//
//  ofxBleSensorTagInterface.h
//
//  Created by Morimasa Aketa on 2015/12/12.
//  Based on the code by ISHII 2bit on 2014/02/01.
//  Copyright (c) 2015 Morimasa Aketa
//
//

#ifndef __ofxBleSensorTagInterface__
#define __ofxBleSensorTagInterface__

#include "ofMain.h"

class ofxBleSensorTagInterface {
public:
    virtual void findDevice(const string &uuid, bool isInTarget) {};
    virtual void receiveValue(const string &uuid, double value, int type) = 0;
    virtual void updateConnectionState(const string &uuid, bool isConnected) = 0;
};

#endif
