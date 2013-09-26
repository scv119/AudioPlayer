//
//  APSetting.h
//  AudioPlayerDemo
//
//  Created by shen chen on 13-9-26.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *settingChangedNotification;

@interface APSetting : NSObject {
//    BOOL _highQuality;
    BOOL _celluarData;
    BOOL _backGround;
}

//@property (nonatomic) BOOL enablehighQuality;
@property (nonatomic) BOOL enableCelluarData;
@property (nonatomic) BOOL enableBackground;


+(APSetting *) instance;

@end
