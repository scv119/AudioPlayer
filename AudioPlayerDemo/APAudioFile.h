//
//  APAudioFile.h
//  AudioPlayerDemo
//
//  Created by shen chen on 13-7-29.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APDownloadManager.h"

@interface APAudioFile : NSObject<APDownloadTask, NSCopying>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSString *serialName;
@property (nonatomic, strong) NSString *serialNO;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSDate   *created;
@property (nonatomic, strong) NSURL *coverUrl;
@property (nonatomic, strong) NSURL *fileUrl;
@property (nonatomic) long long fileSize;
@property (nonatomic) int duration;
@property (nonatomic) BOOL hasLyric;
@property (nonatomic) long long fileId;
@property (nonatomic) long long taskId;
@property (nonatomic) long long finishedSize;
@property (nonatomic, strong) NSString *path;
@property APDownloadStatus status;

-(NSDictionary *) toDict;
+(APAudioFile *) instanceByDict:(NSDictionary *) dict;
-(void) updateByItem:(APAudioFile *)item;

@end
