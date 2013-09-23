//
//  APAudioFile.h
//  AudioPlayerDemo
//
//  Created by shen chen on 13-7-29.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APAudioFile : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSString *serialName;
@property (nonatomic, strong) NSString *serialNo;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSDate   *created;
@property (nonatomic, strong) NSURL *coverUrl;
@property (nonatomic, strong) NSURL *fileUrl;
@property (nonatomic) long long fileSize;
@property (nonatomic) int timeSpan;
@property (nonatomic) BOOL hasLyric;

+(APAudioFile *) instanceByDict:(NSDictionary *) dict;

@end
