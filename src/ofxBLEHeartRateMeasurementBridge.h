//
//  ofxMioAlphaBridge.h
//
//  Created by ISHII 2bit on 2014/06/06.
//
//

#pragma once

#import "ofxBLEHeartRateMeasurementInterface.h"
#import <Foundation/Foundation.h>

@interface ofxBLEHeartRateMeasurementBridge : NSObject {
    ofxBLEHeartRateMeasurementInterface *interface;
}

- (instancetype)initWithInterface:(ofxBLEHeartRateMeasurementInterface *)interface;

@end