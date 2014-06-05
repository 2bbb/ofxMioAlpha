//
//  ofxMioAlphaBridgeImpl.mm
//  ofxMioAlphaExample
//
//  Created by ISHII 2bit on 2014/06/06.
//
//

#include "ofxMioAlphaBridgeImpl.h"
#import "ofxMioAlphaBridge.h"
#import "BluetoothManager.h"

@interface ofxMioAlphaBridgeImpl()

- (void)updateValue:(NSNotification *)notification;
- (void)connected:(NSNotification *)notification;
- (void)disconnected:(NSNotification *)notification;

@end

@implementation ofxMioAlphaBridgeImpl

- (instancetype)initWithBridge:(ofxMioAlphaBridge *)_bridge {
    self = [super init];
    if(self) {
        bridge = _bridge;
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self
                          selector:@selector(updateValue:)
                              name:BMBluetoothUpdateValueNotification
                            object:nil];
        [defaultCenter addObserver:self
                          selector:@selector(connected:)
                              name:BMBluetoothConnectedNotification
                            object:nil];
        [defaultCenter addObserver:self
                          selector:@selector(disconnected:)
                              name:BMBluetoothDisconnectedNotification
                            object:nil];
    }
    return self;
}

- (void)addDeviceUUID:(NSString *)uuid {
    [[BluetoothManager sharedManager] addTargetUUID:uuid];
}

- (BOOL)startScan {
    return [[BluetoothManager sharedManager] scan];
}

- (void)updateValue:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    int heartRate = [[userInfo objectForKey:BMHeartRateBPMKey] intValue];
    bridge->receiveHeartrate(heartRate);
}

- (void)connected:(NSNotification *)notification {
    bridge->setConnected(true);
}

- (void)disconnected:(NSNotification *)notification {
    bridge->setConnected(false);
}

- (void)dealloc {
    
    [super dealloc];
}

@end
