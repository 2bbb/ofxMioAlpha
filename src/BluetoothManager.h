//
//  BluetoothManager.h
//
//  Created by ISHII 2bit on 2014/02/01.
//  Copyright (c) 2014 buffer Renaiss co., ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#   import <CoreBluetooth/CoreBluetooth.h>
#elif TARGET_OS_MAC
#   import <IOBluetooth/IOBluetooth.h>
#endif

extern NSString * const BMBluetoothDeviceFoundNotification;
extern NSString * const BMBluetoothUpdateValueNotification;
extern NSString * const BMBluetoothConnectedNotification;
extern NSString * const BMBluetoothDisconnectedNotification;
extern NSString * const BMBluetoothDidFailToConnectNotification;

extern NSString * const BMHeartRateBPMKey;
extern NSString * const BMLocalNameKey;
extern NSString * const BMDeviceKey;
extern NSString * const BMDeviceIsInTargetsKey;
extern NSString * const BMErrorDescriptionKey;

@interface BluetoothManager : NSObject <
    CBCentralManagerDelegate,
    CBPeripheralDelegate
> {
    CBCentralManager *centralManager;
    
    NSMutableArray *targetUUIDs;
    NSMutableDictionary *peripherals;
    
    NSMutableArray *targetLocalNames;
}

+ (BluetoothManager *)sharedManager;

- (void)addTargetUUID:(NSString *)uuid;
- (void)addTargetLocalName:(NSString *)localName;
- (BOOL)scan;
- (void)stopScan;
- (void)disconnect;

@end