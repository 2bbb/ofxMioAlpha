//
//  BlePeripherals.h
//  BleSensorTag
//
//  Created by Morimasa Aketa on 2015/12/12.
//
//

#ifndef BlePeripherals_h
#define BlePeripherals_h
#endif /* BlePeripherals_h */

#import <Foundation/Foundation.h>


#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#   import <CoreBluetooth/CoreBluetooth.h>
#elif TARGET_OS_MAC
#   import <IOBluetooth/IOBluetooth.h>
#endif


enum BPSensorType {
    BPUnknown,
    BPMioHeartRate,
    BPSensorTagLux,
};

#pragma mark Base characteristic class

@interface BleCharacteristic: NSObject{
    NSString *name;
    NSString *uuidString;
    int type;
}
@property  (nonatomic,retain) NSString *name;
@property  (atomic) int type;
@property  (nonatomic,retain) NSString *uuidString;
-(bool) setupWithPeripheral:(CBPeripheral *) peripheral
                    Service:(CBService *) service;

-(double) calcData: (NSData *)data;

@end

#pragma mark MioAlpha of generic heart rate pulse bpm charasteristic class
@interface MioAlphaPulse: BleCharacteristic
@end


#pragma mark SensorTag specific base characteristic
@interface SensorTagCharacteristic: BleCharacteristic{
    NSString *configUuidString;
    NSString *periodUuidString;
}
@end

@interface SensorTagLux: SensorTagCharacteristic
@end

@interface SensorTagIrTemperture: SensorTagCharacteristic
@end;

#pragma mark Base BLE device(peripheral) classes
@interface BlePeripherals: NSObject{
    NSMutableArray *peripherals;
    NSMutableArray *targetAdvertisementNames;
    NSMutableDictionary *characteristicsDict;
}
@property (nonatomic,retain) NSMutableArray *peripherals;
@property (nonatomic,retain) NSMutableArray *targetAdvertisementNames;
@property (nonatomic,retain) NSMutableDictionary *characteristicsDict;
-(id) init;
-(BleCharacteristic *) findCharacteristicForUUID:(NSString *)sUUID;
@end

@interface BlePeripheral: NSObject{
    NSMutableArray *characteristics;
}
@property (nonatomic, retain) NSMutableArray *characteristics;
@end
