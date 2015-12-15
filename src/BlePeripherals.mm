//
//  BlePeripherals.mm
//  BleSensorTag
//
//  Created by Morimasa Aketa on 2015/12/12.
//
//

#import "BlePeripherals.h"

#pragma mark Base BLE device(peripheral) classes
@implementation BlePeripherals
@synthesize targetAdvertisementNames, peripherals, characteristicsDict;

- (id) init{
    self = [super init];

    self.peripherals = [NSMutableArray new];
    self.targetAdvertisementNames = [NSMutableArray new];

    [self.targetAdvertisementNames addObjectsFromArray:@[@"MIO GLOBAL",
                                                         @"MIO GLOBAL LINK",
                                                         @"CC2650 SensorTag",
                                                         @"TI BLE Sensor Tag",
                                                         @"SensorTag"]];


    BlePeripheral *mio = [BlePeripheral new];
    [mio.characteristics addObject:[MioAlphaPulse new]];
    [self.peripherals addObject:mio];

    BlePeripheral *sensorTag = [BlePeripheral new];
    [sensorTag.characteristics addObject:[SensorTagLux new]];
    [self.peripherals addObject:sensorTag];

    
    BlePeripheral *sensorTagV1 = [BlePeripheral new];
    [sensorTagV1.characteristics addObject:[SensorTagIrTemperture new]];
    [self.peripherals addObject:sensorTagV1];

    
    
    self.characteristicsDict = [NSMutableDictionary new];
    for ( BlePeripheral *p in self.peripherals){
        for ( BleCharacteristic *c in p.characteristics){
            [self.characteristicsDict setObject:c forKey:c.uuidString];
        }
    }
    return self;
}

-(BleCharacteristic *) findCharacteristicForUUID:(NSString *)sUUID {
    return [self.characteristicsDict objectForKey:sUUID];
}

@end

@implementation BlePeripheral
@synthesize characteristics;
-(id) init{
    self = [super init];
    self.characteristics = [[NSMutableArray alloc]init];
    return self;

    
}
@end;

@implementation BleCharacteristic
@synthesize name, uuidString, type;
- (id) init{
    self = [super init];
    self.name = @"";
    self.uuidString = @"";
    type = 0;
    return self;
}

- (bool) setupWithPeripheral:(CBPeripheral *)peripheral
                     Service:(CBService *)service{
    return true;
}
- (double) calcData:(NSData *)data {
    return 0.0;
}

@end

#pragma mark MioAlpha of generic heart rate pulse bpm charasteristic class
@implementation MioAlphaPulse

-(id) init{
    self = [super init];
    self.name = @"mio alpha pluse";
    self.uuidString = @"2A37";
    type = 1;
}

-(double) calcData: (NSData *) data{
    const uint8_t *reportData = (const uint8_t *)[data bytes]; // bytes returns pointer
    uint16_t bpm = 0.0;

    if ((reportData[0] & 0x01) == 0) {
        /* uint8 bpm */ /* mio alpha sends uint8 */
        bpm = reportData[1];
    } else {
        /* uint16 bpm */
        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
    }

    return (double)bpm;
    
}
@end;

#pragma mark SensorTag specific base characteristic
@implementation SensorTagCharacteristic

- (bool) setupWithPeripheral:(CBPeripheral *)peripheral
                     Service:(CBService *)service{
    for(CBCharacteristic *characteristic in service.characteristics) {
        CBUUID *uuid = [characteristic UUID];
        if([uuid isEqual:[CBUUID UUIDWithString: configUuidString]]){
            uint8_t data = 0x01;
            [peripheral writeValue:[NSData dataWithBytes:&data length:1]
                 forCharacteristic:characteristic
                              type:CBCharacteristicWriteWithResponse];
            break;
        }
    }
    return true;
}

@end



@implementation SensorTagLux
- (id) init{
    self = [super init];
    self.name = @"sensor tag lux";
    self.uuidString = @"F000AA71-0451-4000-B000-000000000000";
    configUuidString = @"F000AA72-0451-4000-B000-000000000000";

    type = 2;
}

- (double) calcData: (NSData *)data{
    const uint8_t *reportData = (const uint8_t *)[data bytes];
    uint16_t lux = 0 ;
    double output;
    double magnitude;
    int mantissa;
    int exponent;

    lux = (uint16_t)reportData[1] << 8;
    lux += (uint16_t)reportData[0];

    mantissa = (int)lux & 0x0fff;
    exponent = (int)(lux >> 12) & 0xff;
    magnitude = pow(2.0, (double)exponent);
    output =  (double)mantissa * magnitude;
//    NSLog(@"lux: %f", output/100.0);
    return output / 100.0;
}

@end

@implementation SensorTagIrTemperture
- (id) init{
    self = [super init];
    self.name = @"sensor tag1 IR tempereture";
    self.uuidString =  @"F000AA01-0451-4000-B000-000000000000";
    configUuidString = @"F000AA02-0451-4000-B000-000000000000";
    periodUuidString = @"F000AA03-0451-4000-B000-000000000000";

    type = 2;
}


- (bool) setupWithPeripheral:(CBPeripheral *)peripheral
                     Service:(CBService *)service{
    for(CBCharacteristic *characteristic in service.characteristics) {
        CBUUID *uuid = [characteristic UUID];
        if([uuid isEqual:[CBUUID UUIDWithString: configUuidString]]){
            uint8_t data = 0x01; // set on to this sensor
            [peripheral writeValue:[NSData dataWithBytes:&data length:1]
                 forCharacteristic:characteristic
                              type:CBCharacteristicWriteWithResponse];
        }
        if([uuid isEqual:[CBUUID UUIDWithString: periodUuidString]]){
            uint8_t data = 30; // setting updating period to 300ms
            [peripheral writeValue:[NSData dataWithBytes:&data length:1]
                 forCharacteristic:characteristic
                              type:CBCharacteristicWriteWithResponse];
        }
    
    }
    return true;
}

- (double) calcData: (NSData *)data{
    char scratchVal[data.length];
    int16_t objTemp;
    int16_t ambTemp;
    [data getBytes:&scratchVal length:data.length];
    objTemp = (scratchVal[0] & 0xff)| ((scratchVal[1] << 8) & 0xff00);
    ambTemp = ((scratchVal[2] & 0xff)| ((scratchVal[3] << 8) & 0xff00));
    
    float temp = (float)((float)ambTemp / (float)128);
    long double Vobj2 = (double)objTemp * .00000015625;
    long double Tdie2 = (double)temp + 273.15;
    long double S0 = 6.4*pow(10,-14);
    long double a1 = 1.75*pow(10,-3);
    long double a2 = -1.678*pow(10,-5);
    long double b0 = -2.94*pow(10,-5);
    long double b1 = -5.7*pow(10,-7);
    long double b2 = 4.63*pow(10,-9);
    long double c2 = 13.4f;
    long double Tref = 298.15;
    long double S = S0*(1+a1*(Tdie2 - Tref)+a2*pow((Tdie2 - Tref),2));
    long double Vos = b0 + b1*(Tdie2 - Tref) + b2*pow((Tdie2 - Tref),2);
    long double fObj = (Vobj2 - Vos) + c2*pow((Vobj2 - Vos),2);
    long double Tobj = pow(pow(Tdie2,4) + (fObj/S),.25);
    Tobj = (Tobj - 273.15);
    //    return (double)Tobj;
    return (double)Tobj * 1000;
}



@end