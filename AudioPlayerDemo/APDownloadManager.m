//
//  APDownloadManager.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-7-30.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APDownloadManager.h"


#pragma operation


@interface APDownloadOperation : NSOperation<NSURLConnectionDataDelegate>

@property (nonatomic, strong) id<APDownloadTask> task;
@property (atomic, strong) NSURLConnection *connection;
@property (atomic, strong) NSURLRequest *request;
@property (atomic, strong) NSLock *connectionLock;

@end

@implementation APDownloadOperation

-(void) setTask:(id<APDownloadTask>)task
{
    self.task = task;
    self.request = [NSURLRequest requestWithURL:[NSURL URLWithString: task.url ]];
    self.connection = [NSURLConnection alloc];}

-(void) main
{
    if (![self isCancelled]) {
        self.connection = [self.connection initWithRequest:self.request delegate:self];
        [self.connection start];
    }
}

-(void) cancel
{
    [self.connection cancel];
    [self.task statusChanged: PAUSED];
    [super cancel];
}

@end



@interface APDownloadManager()

@property (atomic, strong) NSMutableArray *taskArray;
@property (atomic, strong) NSOperationQueue *queue;

@end


@implementation APDownloadManager

static id sharedInstance;

-(id) init
{
    if (sharedInstance != nil) {
        NSAssert(NO, @"should never be called");
        return nil;
    }
    self = [super init];
    self.taskArray = [[NSMutableArray alloc] init];
    self.queue = [[NSOperationQueue alloc] init];
    
    return self;
}

+(APDownloadManager *) instance
{
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedInstance = [[super allocWithZone:nil] init];
    });
    
    return sharedInstance;
}

-(void) pushTask:(id<APDownloadTask>) task {}

-(void) start
{
    
}

-(void) stop
{
    
}

-(int)  count
{
    
}

-(id<APDownloadTask>) taskAtIndex:(int) index
{
    
}

-(id<APDownloadTask>) popTask
{
    
}


@end
