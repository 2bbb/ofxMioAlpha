//
//  ofxMioAlphaBridge.mm
//
//  Created by ISHII 2bit on 2014/06/06.
//
//

#import "ofxBLEHeartRateMeasurementBridge.h"
#import "BluetoothManager.h"

@interface ofxBLEHeartRateMeasurementBridge ()

- (void)foundDevice:(NSNotification *)notification;
- (void)updateValue:(NSNotification *)notification;
- (void)connected:(NSNotification *)notification;
- (void)disconnected:(NSNotification *)notification;

@end

@implementation ofxBLEHeartRateMeasurementBridge

- (instancetype)initWithInterface:(ofxBLEHeartRateMeasurementInterface *)_interface {
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
    int heartRate = [[userInfo objectForKey:BMHeartRateBPMKey] intValue];
    string uuid([[userInfo objectForKeyedSubscript:BMDeviceKey] cStringUsingEncoding:NSUTF8StringEncoding]);
    interface->receiveHeartRate(uuid, heartRate);
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

