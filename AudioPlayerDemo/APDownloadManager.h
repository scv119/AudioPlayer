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
    CANCELED,
    FAILED,
    FINISHED
} APDownloadStatus;



#pragma protocal

@protocol APDownloadTask <NSObject>


@property (nonatomic) unsigned long long fileSize;
@property (nonatomic) unsigned long long finishedSize;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *path;

-(void) statusChanged:(APDownloadStatus)status;
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


