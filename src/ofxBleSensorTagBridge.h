//
//  ofxBleSensorTagBridge.h
//
//  Created by Morimasa Aketa on 2015/12/12.
//  Based on the code by ISHII 2bit on 2014/02/01.
//  Copyright (c) 2015 Morimasa Aketa
//
//

#pragma once

#import "ofxBleSensorTagInterface.h"
#import <Foundation/Foundation.h>

@interface ofxBleSensorTagBridge : NSObject {
    ofxBleSensorTagInterface *interface;
}

- (instancetype)initWithInterface:(ofxBleSensorTagInterface *)interface;

@end