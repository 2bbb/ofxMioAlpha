//
//  ofxBluetoothManager.h
//
//  Created by ISHII 2bit on 2014/02/01.
//  Copyright (c) 2014 buffer Renaiss co., ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>

extern NSString * const BMBluetoothUpdateValueNotification;
extern NSString * const BMBluetoothConnectedNotification;
extern NSString * const BMBluetoothDisconnectedNotification;
extern NSString * const BMHeartRateBPMKey;
extern NSString * const BMDeviceKey;

@interface BluetoothManager : NSObject <
    CBCentralManagerDelegate,
    CBPeripheralDelegate
> {
    CBCentralManager *centralManager;
    __strong CBPeripheral *aPeripheral;
    
    BOOL isConnected;
    float rssi;
    NSMutableArray *targetUUIDs;
}

+ (BluetoothManager *)sharedManager;

- (void)addTargetUUID:(NSString *)uuid;
- (BOOL)scan;
- (void)stopScan;
- (void)disconnect;

- (BOOL)isConnected;
- (float)rssi;

@end