//
//  ofxBluetoothManager.h
//
//  Created by ISHII 2bit on 2014/02/01.
//  Copyright (c) 2014 buffer Renaiss co., ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_IPHONE_SIMULATOR
#   import <CoreBlutooth/CoreBluetooth.h>
#elif TARGET_OS_IPHONE
#   import <CoreBlutooth/CoreBluetooth.h>
#elif TARGET_OS_MAC
#   import <IOBluetooth/IOBluetooth.h>
#endif

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
    NSMutableArray *peripherals;
}

+ (BluetoothManager *)sharedManager;

- (void)addTargetUUID:(NSString *)uuid;
- (BOOL)scan;
- (void)stopScan;
- (void)disconnect;

- (BOOL)isConnected;
- (float)rssi;

@end