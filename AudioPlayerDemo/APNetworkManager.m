//
//  APNetworkManager.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-9-26.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APNetworkManager.h"

@implementation APNetworkManager {
    Reachability *_hostReach;
}

static id sharedInstance;

+(instancetype) instance
{
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedInstance = [[super allocWithZone:nil] init];
    });
    
    return sharedInstance;
}

-(id) init
{
    if (sharedInstance != nil) {
        NSAssert(NO, @"should never be called");
        return nil;
    }
    
    _hostReach = [Reachability reachabilityWithHostName:@"www.huaxingtan.cn"];
    [_hostReach startNotifier];
    NSLog(@"networking manager started");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatus:) name:kReachabilityChangedNotification object:nil];
    return self;
}

-(NetworkStatus) getStatus
{
    return [_hostReach currentReachabilityStatus];
}

-(void) updateStatus:(NSNotification *)notification
{
    NSLog(@"network status changed %d", [_hostReach currentReachabilityStatus]);
}

@end
