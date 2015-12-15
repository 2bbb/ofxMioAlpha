//
//  ofxBleSensorTagBridge.mm
//
//  Created by Morimasa Aketa on 2015/12/12.
//  Based on the code by ISHII 2bit on 2014/02/01.
//  Copyright (c) 2015 Morimasa Aketa
//
//

#import "ofxBleSensorTagBridge.h"
#import "BluetoothManager.h"

@interface ofxBleSensorTagBridge ()

- (void)foundDevice:(NSNotification *)notification;
- (void)updateValue:(NSNotification *)notification;
- (void)connected:(NSNotification *)notification;
- (void)disconnected:(NSNotification *)notification;

@end

@implementation ofxBleSensorTagBridge

- (instancetype)initWithInterface:(ofxBleSensorTagInterface *)_interface {
    self = [super init];
    if(self) {
        interface = _interface;
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self
                          selector:@selector(foundDevice:)
                              name:BMBluetoothDeviceFoundNotification
                            object:nil];
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

- (void)foundDevice:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    BOOL isInTargets = [[userInfo objectForKey:BMDeviceIsInTargetsKey] boolValue];
    string uuid([[userInfo objectForKeyedSubscript:BMDeviceKey] cStringUsingEncoding:NSUTF8StringEncoding]);
    interface->findDevice(uuid, (bool)isInTargets);
}

- (void)updateValue:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    double value = [[userInfo objectForKey:BMValueKey] doubleValue];
    int type = [[userInfo objectForKey:BMSensorTypeKey] integerValue];
    string uuid([[userInfo objectForKeyedSubscript:BMDeviceKey] cStringUsingEncoding:NSUTF8StringEncoding]);
    interface->receiveValue(uuid, value, type);
}

- (void)connected:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    string uuid = string([[userInfo objectForKeyedSubscript:BMDeviceKey] cStringUsingEncoding:NSUTF8StringEncoding]);
    interface->updateConnectionState(uuid, true);
}

- (void)disconnected:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    string uuid([[userInfo objectForKeyedSubscript:BMDeviceKey] cStringUsingEncoding:NSUTF8StringEncoding]);
    interface->updateConnectionState(uuid, false);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

@end

