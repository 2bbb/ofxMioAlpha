//
//  ofxBluetoothManager.mm
//
//  Created by ISHII 2bit on 2014/02/01.
//  Copyright (c) 2014 buffer Renaiss co., ltd. All rights reserved.
//

#import "BluetoothManager.h"

NSString * const BMBluetoothUpdateValueNotification = @"BMBluetoothUpdateValueNotification";
NSString * const BMBluetoothConnectedNotification = @"BMBluetoothConnectedNotification";
NSString * const BMBluetoothDisconnectedNotification = @"BMBluetoothDisconnectedNotification";

NSString * const BMHeartRateBPMKey = @"BMHeartRateBPMKey";
NSString * const BMDeviceKey = @"BMDeviceKey";

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
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        isConnected = NO;
        targetUUIDs = [NSMutableArray new];
        peripherals = [NSMutableArray new];
    }
    return self;
}

- (void)addTargetUUID:(NSString *)uuid {
    [targetUUIDs addObject:uuid];
}

- (BOOL)scan {
    if(centralManager.state == CBCentralManagerStatePoweredOn) {
        NSLog(@"start scan success!!");
        [centralManager scanForPeripheralsWithServices:nil options:nil];
        return YES;
    } else {
        NSLog(@"start scan failure...");
        return NO;
    }
}

- (void)stopScan {
    [centralManager stopScan];
}

- (void)disconnect {
    for(CBPeripheral *peripheral in peripherals) {
        [centralManager cancelPeripheralConnection:peripheral];
    }
}

- (BOOL)isConnected {
    return isConnected;
}

- (float)rssi {
    return rssi;
}

#pragma mark CentralManager

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"update state");
    if(centralManager.state == CBCentralManagerStatePoweredOn) {
        NSLog(@"started!");
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    NSString *targetStr = (NSString *)CFUUIDCreateString(NULL, [peripheral UUID]);
    
    static NSString *mioName = @"MIO GLOBAL";
    NSLog(@"%@ : %@", [advertisementData objectForKey:CBAdvertisementDataLocalNameKey], targetStr);
    BOOL isTarget = NO;
    for(NSString *uuid in targetUUIDs) {
        isTarget = [uuid isEqualToString:targetStr];
        
        if(isTarget) {
            break;
        }
    }
    
    NSString *dataLocalName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if([[advertisementData objectForKey:CBAdvertisementDataLocalNameKey] isEqualToString:mioName] && isTarget) {
        [peripherals addObject:peripheral];
        [peripheral setDelegate:self];
        [centralManager connectPeripheral:peripheral
                                  options:nil];
        rssi = [RSSI floatValue];
    } else if([dataLocalName isEqualToString:mioName]) {
        NSLog(@"Found Mio Device: %@", targetStr);
    }
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"success to connect %@", peripheral);
    [peripheral discoverServices:nil];
    isConnected = YES;
    rssi = [[peripheral RSSI] floatValue];
    
    NSString *uuid = (NSString *)CFUUIDCreateString(NULL, [peripheral UUID]);
//    [[NSNotificationCenter defaultCenter] postNotificationName:BMBluetoothConnectedNotification
//                                                        object:@{BMDeviceKey:uuid}];
    NSNotification *notification = [NSNotification notificationWithName:BMBluetoothConnectedNotification
                                                                 object:nil
                                                               userInfo:@{BMDeviceKey:uuid}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    NSLog(@"disconnect from %@", peripheral);
    [self scan];
    isConnected = NO;
    rssi = -1000000;
    NSString *uuid = (NSString *)CFUUIDCreateString(NULL, [peripheral UUID]);
//    [[NSNotificationCenter defaultCenter] postNotificationName:BMBluetoothDisconnectedNotification
//                                                        object:@{BMDeviceKey:uuid}];

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
    isConnected = NO;
    rssi = -1000000;
    NSString *uuid = (NSString *)CFUUIDCreateString(NULL, [peripheral UUID]);
//    [[NSNotificationCenter defaultCenter] postNotificationName:BMBluetoothDisconnectedNotification
//                                                        object:@{BMDeviceKey:uuid}];
    NSNotification *notification = [NSNotification notificationWithName:BMBluetoothDisconnectedNotification
                                                                 object:nil
                                                               userInfo:@{BMDeviceKey:uuid}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark Peripheral

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error
{
    NSLog(@"did discover charcteristic for service %@", peripheral);
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service %@", service);
        
        NSLog(@"Discovering characteristics for service %@", service);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    for(CBCharacteristic *characteristic in service.characteristics) {
        CBUUID *uuid = [characteristic UUID];
        CBUUID *target = [CBUUID UUIDWithString:@"2A37"];
        NSLog(@"Discovered characteristic %@", [[characteristic UUID] description]);
        
        if([uuid isEqual:target]) {
            NSLog(@"Mio is %@", [[characteristic UUID] description]);
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
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
//    [[NSNotificationCenter defaultCenter] postNotificationName:BMBluetoothUpdateValueNotification
//                                                        object:info];
    NSNotification *notification = [NSNotification notificationWithName:BMBluetoothUpdateValueNotification
                                                                 object:nil
                                                               userInfo:info];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    rssi = [[peripheral RSSI] floatValue];
}

- (void)dealloc {
    [self disconnect];
    
    [super dealloc];
}

@end
