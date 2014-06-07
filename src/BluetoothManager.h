//
//  ofxBluetoothManager.h
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

extern NSString * const BMHeartRateBPMKey;
extern NSString * const BMDeviceKey;
extern NSString * const BMDeviceIsInTargetsKey;

extern NSString * const BMLocalName;

@interface BluetoothManager : NSObject <
    CBCentralManagerDelegate,
    CBPeripheralDelegate
> {
    CBCentralManager *centralManager;
    __strong CBPeripheral *aPeripheral;
    
    NSMutableArray *targetUUIDs;
    NSMutableDictionary *peripherals;
    
    CBUUID *targetServiceCharacteristic;
}

+ (BluetoothManager *)sharedManager;

- (void)addTargetUUID:(NSString *)uuid;
- (BOOL)scan;
- (void)stopScan;
- (void)disconnect;

@end