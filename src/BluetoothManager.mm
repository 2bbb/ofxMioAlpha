//
//  BluetoothManager.mm
//
//  Created by ISHII 2bit on 2014/02/01.
//  Copyright (c) 2014 buffer Renaiss co., ltd. All rights reserved.
//

#import "BluetoothManager.h"

NSString * const BMBluetoothDeviceFoundNotification = @"BMBluetoothDeviceFoundNotification";
NSString * const BMBluetoothUpdateValueNotification = @"BMBluetoothUpdateValueNotification";
NSString * const BMBluetoothConnectedNotification = @"BMBluetoothConnectedNotification";
NSString * const BMBluetoothDisconnectedNotification = @"BMBluetoothDisconnectedNotification";
NSString * const BMBluetoothDidFailToConnectNotification = @"BMBluetoothDidFailToConnectNotification";

NSString * const BMHeartRateBPMKey = @"BMHeartRateBPMKey";
NSString * const BMLocalNameKey = @"BMLocalNameKey";
NSString * const BMDeviceKey = @"BMDeviceKey";
NSString * const BMDeviceIsInTargetsKey = @"BMDeviceIsInTargetsKey";
NSString * const BMErrorDescriptionKey = @"BMErrorDescriptionKey";

NSString * const BMTargetServiceUUIDStringPresentation = @"180D";
NSString * const BMTargetCharacteristicStringPresentation = @"2A37";

#define CompareUUIDs(u1, u2) memcmp(CFUUIDGetUUIDBytes(u1), CFUUIDGetUUIDBytes(u2)

typedef struct {
    unsigned char valueFormat : 1;
    unsigned char sensorContactStatus : 2;
    unsigned char energyExpendedStatus : 1;
    unsigned char rrInterval : 1;
    unsigned char future : 3;
} HeartRateBitFlags;

@implementation BluetoothManager

static BluetoothManager *sharedManager = nil;

+ (BluetoothManager *)sharedManager {
    if(sharedManager == nil) {
        @synchronized(self) {
            sharedManager = [[BluetoothManager alloc] init];
        }
    }
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        targetUUIDs = [NSMutableArray new];
        peripherals = [NSMutableDictionary new];
        targetLocalNames = [NSMutableArray new];
    }
    return self;
}

- (void)addTargetUUID:(NSString *)uuid {
    if(![targetUUIDs containsObject:uuid]) {
        [targetUUIDs addObject:uuid];
    }
}

- (void)addTargetLocalName:(NSString *)localName {
    if(![targetLocalNames containsObject:localName]) {
        [targetLocalNames addObject:localName];
    }
}

- (BOOL)scan {
    if(centralManager.state == CBCentralManagerStatePoweredOn) {
        NSLog(@"start scanning now!!");
        [centralManager scanForPeripheralsWithServices:nil options:nil];
        [centralManager retrieveConnectedPeripherals];
        return YES;
    } else {
        NSLog(@"can't start scanning.");
        return NO;
    }
}

- (void)stopScan {
    [centralManager stopScan];
}

- (void)disconnect {
    for(CBPeripheral *peripheral in [peripherals allValues]) {
        [centralManager cancelPeripheralConnection:peripheral];
    }
}

#pragma mark CentralManager

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if(centralManager.state == CBCentralManagerStatePoweredOn) {
        NSLog(@"ready for start scanning!");
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    NSString *uuid = (NSString *)CFUUIDCreateString(NULL, [peripheral UUID]);
    
    BOOL isTarget = NO;
    for(NSString *targetUUID in targetUUIDs) {
        if((isTarget = [targetUUID isEqualToString:uuid])) {
            break;
        }
    }
    
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if(localName == nil) {
        localName = @"[null]";
    }
    NSLog(@"data local name: %@", localName);
    // TODO: fix this more excellent.
    if(([targetLocalNames count] == 0) || [targetLocalNames containsObject:localName]) {
        if(isTarget) {
            NSLog(@"Connectiong start: %@", uuid);
            [peripherals setObject:peripheral forKey:uuid];
            [peripheral setDelegate:self];
            [centralManager connectPeripheral:peripheral
                                      options:nil];
        } else {
            NSLog(@"Found Device: %@", uuid);
        }
    }
    NSDictionary *userInfo = @{BMLocalNameKey: localName,
                               BMDeviceKey: uuid,
                               BMDeviceIsInTargetsKey: @(isTarget)};
    NSNotification *notification = [NSNotification notificationWithName:BMBluetoothDeviceFoundNotification
                                                                 object:nil
                                                               userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"success to connect %@", peripheral);
    [peripheral discoverServices:nil];
    
    NSString *uuid = (NSString *)CFUUIDCreateString(NULL, [peripheral UUID]);
    NSDictionary *userInfo = @{BMDeviceKey:uuid};
    NSNotification *notification = [NSNotification notificationWithName:BMBluetoothConnectedNotification
                                                                 object:nil
                                                               userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)centralManager:(CBCentralManager *)central
didRetrieveConnectedPeripherals:(NSArray *)connectedPeripherals
{
    NSLog(@"did retrieve connected peripherals %d", connectedPeripherals.count);
    for(CBPeripheral *peripheral in connectedPeripherals) {
//        [central cancelPeripheralConnection:peripheral];
        [peripheral discoverServices:nil];
        
        NSString *uuid = (NSString *)CFUUIDCreateString(NULL, [peripheral UUID]);
        NSDictionary *userInfo = @{BMDeviceKey:uuid};
        NSNotification *notification = [NSNotification notificationWithName:BMBluetoothConnectedNotification
                                                                     object:nil
                                                                   userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    NSLog(@"disconnect from %@", peripheral);
    NSString *uuid = (NSString *)CFUUIDCreateString(NULL, [peripheral UUID]);
    [centralManager cancelPeripheralConnection:peripheral];
    [peripherals removeObjectForKey:uuid];
    NSNotification *notification = [NSNotification notificationWithName:BMBluetoothDisconnectedNotification
                                                                 object:nil
                                                               userInfo:@{BMDeviceKey:uuid}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                      error:(NSError *)error
{
    NSLog(@"failure to connect... %@", error);
    NSString *uuid = (NSString *)CFUUIDCreateString(NULL, [peripheral UUID]);
    NSString *errorDescription = [error localizedDescription];
    NSDictionary *userInfo = @{BMDeviceKey: uuid,
                               BMErrorDescriptionKey: errorDescription};
    NSNotification *notification = [NSNotification notificationWithName:BMBluetoothDidFailToConnectNotification
                                                                 object:nil
                                                               userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark Peripheral

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error
{
    for(CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil
                                 forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    for(CBCharacteristic *characteristic in service.characteristics) {
        CBUUID *uuid = [characteristic UUID];
        CBUUID *targetServiceCharacteristic = [CBUUID UUIDWithString:BMTargetCharacteristicStringPresentation];

        if([uuid isEqual:targetServiceCharacteristic]) {
            [peripheral setNotifyValue:YES
                     forCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    if(error) {
        NSLog(@"Error changing notification state: %@", [error localizedDescription]);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    NSData *data = [characteristic value];
    
    const uint8_t *reportData = (const uint8_t *)[data bytes];
    uint16_t bpm = 0;
    
    if ((reportData[0] & 0x01) == 0) {
        /* uint8 bpm */
        bpm = reportData[1];
    } else {
        /* uint16 bpm */
        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
    }
    
    NSString *uuid = (NSString *)CFUUIDCreateString(NULL, [peripheral UUID]);
    NSDictionary *info = @{ BMHeartRateBPMKey : @(bpm),
                            BMDeviceKey: uuid};
    NSNotification *notification = [NSNotification notificationWithName:BMBluetoothUpdateValueNotification
                                                                 object:nil
                                                               userInfo:info];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {}

- (void)dealloc {
    [self disconnect];
    
    [super dealloc];
}

@end
