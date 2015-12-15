//
//  BluetoothManager.mm
//
//  Created by Morimasa Aketa on 2015/12/12.
//  Based on the code by ISHII 2bit on 2014/02/01.
//  Copyright (c) 2015 Morimasa Aketa
//

#import "BluetoothManager.h"

NSString * const BMBluetoothDeviceFoundNotification = @"BMBluetoothDeviceFoundNotification";
NSString * const BMBluetoothUpdateValueNotification = @"BMBluetoothUpdateValueNotification";
NSString * const BMBluetoothConnectedNotification = @"BMBluetoothConnectedNotification";
NSString * const BMBluetoothDisconnectedNotification = @"BMBluetoothDisconnectedNotification";

NSString * const BMValueKey = @"BMValueKey";
NSString * const BMSensorTypeKey = @"BMSensorTypeKey";
NSString * const BMDeviceKey = @"BMDeviceKey";
NSString * const BMDeviceIsInTargetsKey = @"BMDeviceIsInTargetsKey";

//NSString * const BMTargetServiceCharacteristicStringPresentation = @"2A37";

#define CompareUUIDs(u1, u2) memcmp(CFUUIDGetUUIDBytes(u1), CFUUIDGetUUIDBytes(u2)

// this struct is not used.
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
       knownPeripherls = [[BlePeripherals alloc]init];

        targetUUIDs = [NSMutableArray new];

        peripherals = [NSMutableDictionary new];
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
    for(CBPeripheral *peripheral in [peripherals allValues]) {
        [centralManager cancelPeripheralConnection:peripheral];
    }
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
    NSString *uuid = (NSString *)CFUUIDCreateString(NULL, [peripheral UUID]);
    NSLog(@"peripheral: %@ RSSI: %@dB", [peripheral description], RSSI);
//   NSLog(@"advertismentData: %@", [advertisementData description]);

    BOOL isTarget = NO;
    for(NSString *targetUUID in targetUUIDs) {
        if((isTarget = [targetUUID isEqualToString:uuid])) {
            break;
        }
    }
    
    NSString *dataLocalName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];

    
    // TODO: fix this more excellent.
    // filterfing device named 'MIO GLOBAL'
    //    if([targetLocalNames containsObject:dataLocalName]) {
//    NSLog(@"datalocalName: %@", dataLocalName);
    if([knownPeripherls.targetAdvertisementNames containsObject:dataLocalName]) {
        if(isTarget) {
            NSLog(@"Connectiong start: %@", uuid);
            [peripherals setObject:peripheral forKey:uuid];
            [peripheral setDelegate:self];
            [centralManager connectPeripheral:peripheral
                                      options:nil];
        } else {
            NSLog(@"Found targeted Device: %@", uuid);
        }
        NSDictionary *userInfo = @{BMDeviceKey: uuid, BMDeviceIsInTargetsKey: @(isTarget)};
        NSNotification *notification = [NSNotification notificationWithName:BMBluetoothDeviceFoundNotification
                                                                     object:nil
                                                                   userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"success to connect %@", peripheral);
    [peripheral discoverServices:nil];
    NSString *uuid = (NSString *)CFUUIDCreateString(NULL, [peripheral UUID]);
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
    NSString *uuid = (NSString *)CFUUIDCreateString(NULL, [peripheral UUID]);
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
    NSNotification *notification = [NSNotification notificationWithName:BMBluetoothDisconnectedNotification
                                                                 object:nil
                                                               userInfo:@{BMDeviceKey:uuid}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark Peripheral

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error
{
//    NSLog(@"did discover charcteristic for service %@", [peripheral UUID]);
    for (CBService *service in peripheral.services) {
//        NSLog(@"Discovered service %@", [service UUID]);

        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
//    NSLog(@"service %@ charactaristics: %@", service, service.characteristics);
     // loop for read
    for(CBCharacteristic *characteristic in service.characteristics) {
        CBUUID *uuid = [characteristic UUID];
        //        if([uuid isEqual:targetServiceCharacteristic]) {
        if( BleCharacteristic *targetCharacteristic
            =  [knownPeripherls findCharacteristicForUUID:[uuid UUIDString] ]){
            [targetCharacteristic setupWithPeripheral:peripheral Service:service];
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
//    NSLog(@"characterristic %@", [characteristic UUID]);


    CBUUID *uuid = [characteristic UUID];
    if( BleCharacteristic *localCharacteristic = [knownPeripherls findCharacteristicForUUID:[uuid UUIDString]]){
        double sensorValue = [localCharacteristic calcData:data];
//        NSLog(@"value: %f", sensorValue);
        NSString *puuid = (NSString *)CFUUIDCreateString(NULL, [peripheral UUID]);
        NSDictionary *info = @{ BMValueKey : @(sensorValue),
                                BMSensorTypeKey : @(localCharacteristic.type),
                                BMDeviceKey: puuid};
        NSNotification *notification = [NSNotification notificationWithName:BMBluetoothUpdateValueNotification
                                                                     object:nil
                                                                   userInfo:info];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }

}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {

}

- (void)dealloc {
    [self disconnect];
    
    [super dealloc];
}

@end
