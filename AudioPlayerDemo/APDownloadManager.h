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



#pragma protocal

@protocol APDownloadTask <NSObject>

@property (nonatomic, strong) NSURL *fileUrl;
@property (nonatomic) long long fileSize;
@property (nonatomic) long long finishedSize;
@property (nonatomic, strong) NSString *path;
@property APDownloadStatus status;

@end

#pragma manager

@interface APDownloadManager : NSObject


+(APDownloadManager *) instance;


-(void) start;
-(void) start:(int)threadNum;

-(void) pushTask:(id<APDownloadTask>) task;
-(void) removeTask:(id<APDownloadTask>) task;

-(NSArray *) cancelAllTask;


@end


