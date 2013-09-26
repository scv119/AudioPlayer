//
//  APDownloadManager.h
//  AudioPlayerDemo
//
//  Created by shen chen on 13-7-30.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum APDownloadStatus{
    STOPED,
    QUEUED,
    STARTED,
    FINISHED
} APDownloadStatus;

extern NSString *downloadStatusNotification;

#pragma protocal

@protocol APDownloadTask <NSObject>

@property (nonatomic, strong) NSURL *fileUrl;
@property (nonatomic) long long fileSize;
@property (nonatomic) long long finishedSize;
@property (nonatomic, strong) NSString *path;
@property APDownloadStatus status;
@property long long taskId;

@end

#pragma manager

@interface APDownloadManager : NSObject


+(instancetype) instance;


-(void) start;
-(void) stop;
-(BOOL) isInRunningStatus;

-(void) add:(id<APDownloadTask>)task;
-(void) remove:(long long) taskId;


@end


