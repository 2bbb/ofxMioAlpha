//
//  ofxMioAlphaBridgeImpl.h
//  ofxMioAlphaExample
//
//  Created by ISHII 2bit on 2014/06/06.
//
//

#import <Foundation/Foundation.h>

class ofxMioAlphaBridge;

@interface ofxMioAlphaBridgeImpl : NSObject {
    ofxMioAlphaBridge *bridge;
}

- (instancetype)initWithBridge:(ofxMioAlphaBridge *)bridge;
- (void)addDeviceUUID:(NSString *)uuid;
- (BOOL)startScan;

@end