//
//  APSetting.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-9-26.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APSetting.h"

@implementation APSetting

NSString *settingChangedNotification = @"SETTING_UPDATED";
static id sharedInstance;

@synthesize enableBackground = _backGround;
@synthesize enableCelluarData = _celluarData;
@synthesize enablehighQuality = _highQuality;

-(id) init
{
    if (sharedInstance != nil) {
        NSAssert(NO, @"should never be called");
        return nil;
    }
    self = [super init];
    _celluarData =[[NSUserDefaults standardUserDefaults] boolForKey:@"cellularData"];
    _backGround =[[NSUserDefaults standardUserDefaults] boolForKey:@"backgroundDownload"];
    _highQuality =[[NSUserDefaults standardUserDefaults] boolForKey:@"audioQuality"];
    return self;
}

+(APSetting *) instance
{
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedInstance = [[super allocWithZone:nil] init];
    });
    
    return sharedInstance;
}

-(void) setEnableBackground:(BOOL) val
{
    _backGround = val;
    [[NSUserDefaults standardUserDefaults] setBool:val forKey:@"backgroundDownload"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self notifyStatusChange];
    NSLog(@"backgroundDownload changed %d", val);
}

-(void) setEnableCelluarData:(BOOL) val
{
    _celluarData = val;
    [[NSUserDefaults standardUserDefaults] setBool:val forKey:@"cellularData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self notifyStatusChange];
    NSLog(@"cellularData changed %d", val);
}

-(void) setEnablehighQuality:(BOOL) val
{
    _highQuality = val;
    [[NSUserDefaults standardUserDefaults] setBool:val forKey:@"audioQuality"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self notifyStatusChange];
    NSLog(@"audioQuality changed %d", val);
}

-(void) notifyStatusChange
{
    [[NSNotificationCenter defaultCenter] postNotificationName:settingChangedNotification object:nil];
}



@end
