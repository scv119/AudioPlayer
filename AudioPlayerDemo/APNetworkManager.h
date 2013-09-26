//
//  APNetworkManager.h
//  AudioPlayerDemo
//
//  Created by shen chen on 13-9-26.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface APNetworkManager : NSObject

@property (readonly)NetworkStatus stauts;

+(instancetype) instance;

@end
