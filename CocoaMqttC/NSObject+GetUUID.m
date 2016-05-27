//
//  NSObject+GetUUID.m
//  CocoaMqttC
//
//  Created by iotn2n on 16/5/27.
//  Copyright © 2016年 iot. All rights reserved.
//

#import "NSObject+GetUUID.h"

@implementation GetUUID 

-(NSString*) uuid {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

@end
