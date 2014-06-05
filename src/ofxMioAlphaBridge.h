//
//  ofxMioAlphaBridge.h
//
//  Created by ISHII 2bit on 2014/06/06.
//
//

#pragma once

#import "ofxMioAlphaInterface.h"
#import <Foundation/Foundation.h>

@interface ofxMioAlphaBridge : NSObject {
    ofxMioAlphaInterface *interface;
}

- (instancetype)initWithInterface:(ofxMioAlphaInterface *)interface;

@end