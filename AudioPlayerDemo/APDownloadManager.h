//
//  APDownloadManager.h
//  AudioPlayerDemo
//
//  Created by shen chen on 13-7-30.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum APDownloadStatus{
    QUEUED,
    STARTED,
    PAUSED,
    FINISHED
} APDownloadStatus;



#pragma protocal

@protocol APDownloadTask <NSObject>


@property (nonatomic) int fileSize;
@property (nonatomic) int finishedSize;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *path;

-(void) statusChanged:(APDownloadStatus)status;
@end

#pragma manager

@interface APDownloadManager : NSObject


+(APDownloadManager *) instance;


-(void) start;
-(void) start:(int)threadNum;
-(void) stop;
-(BOOL) isRunning;


-(void) pushTask:(id<APDownloadTask>) task;
-(void) removeTask:(id<APDownloadTask>) task;
-(int)  taskCount;
-(id<APDownloadTask>) taskAtIndex:(int) index;

@end


