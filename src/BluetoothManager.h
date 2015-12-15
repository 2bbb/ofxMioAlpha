//
//  BluetoothManager.h
//
//  Created by Morimasa Aketa on 2015/12/12.
//  Based on the code by ISHII 2bit on 2014/02/01.
//  Copyright (c) 2015 Morimasa Aketa
//

#import <Foundation/Foundation.h>
#import "BlePeripherals.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#   import <CoreBluetooth/CoreBluetooth.h>
#elif TARGET_OS_MAC
#   import <IOBluetooth/IOBluetooth.h>
#endif

extern NSString * const BMBluetoothDeviceFoundNotification;
extern NSString * const BMBluetoothUpdateValueNotification;
extern NSString * const BMBluetoothConnectedNotification;
extern NSString * const BMBluetoothDisconnectedNotification;

extern NSString * const BMValueKey;
extern NSString * const BMSensorTypeKey;
extern NSString * const BMDeviceKey;
extern NSString * const BMDeviceIsInTargetsKey;
extern NSString * const BMLocalName;

@interface BluetoothManager : NSObject <
    CBCentralManagerDelegate,
    CBPeripheralDelegate
> {
    CBCentralManager *centralManager;
    __strong CBPeripheral *aPeripheral;
    BlePeripherals *knownPeripherls;
    
    NSMutableArray *targetUUIDs;
    NSMutableDictionary *peripherals;

}

+ (BluetoothManager *)sharedManager;

- (void)addTargetUUID:(NSString *)uuid;
- (BOOL)scan;
- (void)stopScan;
- (void)disconnect;

@end