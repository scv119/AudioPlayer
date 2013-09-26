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
    NetworkStatus _status;
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
    _status = NotReachable;
    NSLog(@"networking manager started");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatus:) name:kReachabilityChangedNotification object:nil];
    return self;
}

-(NetworkStatus) getStatus
{
    return _status;
}

-(void) updateStatus:(NSNotification *)notification
{
    _status = [_hostReach currentReachabilityStatus];
    NSLog(@"network status changed %d", _status);
}

@end
