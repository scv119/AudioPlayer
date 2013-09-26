//
//  APDownloadManager.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-7-30.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APDownloadManager.h"
#import "AFDownloadRequestOperation.h"

NSString *downloadNotification = @"DOWNLOAD_NOTIFICATION";
NSString *downloadStatusNotification = @"DOWNLOAD_STATUS_CHANGED";

@interface APDownloadManager()

@property BOOL isRunning;
@property AFDownloadRequestOperation *operation;
@property id<APDownloadTask> currentTask;
@property NSDate *lastNoti;
@property NSMutableArray *queue;
@property long long removeId;

@end


@implementation APDownloadManager

static id sharedInstance;

-(id) init
{
    if (sharedInstance != nil) {
        NSAssert(NO, @"should never be called");
        return nil;
    }
    NSLog(@"download manager started");
    self = [super init];
    self.isRunning = NO;
    self.currentTask = nil;
    self.operation = nil;
    self.queue = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startDownload) name:downloadNotification object:nil];
    return self;
}

+(instancetype) instance
{
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedInstance = [[super allocWithZone:nil] init];
    });
    
    return sharedInstance;
}


-(void) start
{
    @synchronized(self) {
        if (self.isRunning)
            return;
        self.isRunning = YES;
        [self notifyStartDownload];
    }
}

-(void) stop;
{
    @synchronized(self) {
        if (!self.isRunning)
            return;
        self.isRunning = NO;
        if (self.operation != nil) {
            [self.operation cancel];
        }
    }
}


-(BOOL) isInRunningStatus
{
    return self.isRunning;
}

-(void) add:(id<APDownloadTask>)task
{
    if (task.status == FINISHED)
        return;
    @synchronized(self) {
        
        for (int i = 0; i < [self.queue count]; i++) {
            id<APDownloadTask> item = [self.queue objectAtIndex:i];
            if (item.taskId == task.taskId) {
                return;
            }
        }
        
        [self.queue addObject:task];
        task.status = QUEUED;
        [self notifyTaskStatus:task noDelay:YES];
        [self notifyStartDownload];
    }
}

-(void) remove:(long long) taskId
{
    @synchronized(self) {
        id<APDownloadTask> removedTask;
        for (int i = 0; i < [self.queue count]; i++) {
            id<APDownloadTask> item = [self.queue objectAtIndex:i];
            if (item.taskId == taskId) {
                removedTask = item;
                [self.queue removeObjectAtIndex:i];
                break;
            }
        }
        
        if (self.currentTask != nil && self.currentTask.taskId == taskId) {
            self.removeId = self.currentTask.taskId;
            [self.operation cancel];
        } else {
            removedTask.status = STOPED;
            [self notifyTaskStatus:removedTask noDelay:YES];
        }
    }
}

-(void) startTask:(id<APDownloadTask>) task
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:task.path];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:task.fileUrl];
    self.operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:path shouldResume:YES];
    self.currentTask = task;
    self.removeId = -1;
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    NSLog(@"%d", fileExists);
    if (fileExists) {
        task.status = FINISHED;
        [self notifyTaskStatus:task noDelay:YES];
        [self finishOperation];
        [self notifyStartDownload];
        return;
    }

    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file to %@", path);
        APDownloadManager *downloadManager = [APDownloadManager instance];
        task.status = FINISHED;
        [downloadManager notifyTaskStatus:task noDelay:YES];
        [downloadManager finishOperation];
        [downloadManager notifyStartDownload];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        APDownloadManager *downloadManager = [APDownloadManager instance];
        task.status = QUEUED;
        if (task.taskId == downloadManager.removeId)
            task.status = STOPED;
        
        NSLog(@"Error: %@ Task status changed: %d", error, task.status);
        [downloadManager notifyTaskStatus:task noDelay:YES];
        [downloadManager finishOperation];
        [downloadManager notifyStartDownload];
    }];
    [self.operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"Operation%i: bytesRead: %d", 1, bytesRead);
        NSLog(@"Operation%i: totalBytesRead: %lld", 1, totalBytesRead);
        NSLog(@"Operation%i: totalBytesExpectedToRead: %lld", 1, totalBytesExpectedToRead);
        task.finishedSize = task.fileSize - (totalBytesExpectedToRead - totalBytesRead);
        APDownloadManager *downloadManager = [APDownloadManager instance];
        task.status = STARTED;
        [downloadManager notifyTaskStatus:task noDelay:NO];
    }];
    task.status = STARTED;
    [self notifyTaskStatus:task noDelay:YES];
    [self.operation start];
}

-(void) notifyStartDownload
{
    NSLog(@"notification sent!");
    [[NSNotificationCenter defaultCenter] postNotificationName:downloadNotification object:nil];
}

-(void) notifyTaskStatus:(id<APDownloadTask>)task noDelay:(BOOL) noDelay
{
    if (!noDelay && self.lastNoti != nil) {
        NSDate *now = [[NSDate alloc] init];
        if ([now timeIntervalSinceDate:self.lastNoti] > 0.05f) {
            noDelay = YES;
        }
    } else
        noDelay = YES;
    
    if (noDelay) {
        [[NSNotificationCenter defaultCenter] postNotificationName:downloadStatusNotification object: task];
    }
}

-(void) startDownload
{
    if (!self.isRunning)
        return;
    @synchronized(self) {
        if (!self.isRunning)
            return;
        if (self.operation == nil && [self.queue count] > 0) {
            [self startTask:[self.queue objectAtIndex:0]];
        }
    }
}

-(void) finishOperation {
    @synchronized(self) {
        if (self.operation != nil) {
            self.operation = nil;
            if (self.currentTask.status == FINISHED || self.currentTask.status == STOPED)
                [self remove:self.currentTask.taskId];
            self.currentTask = nil;
        }
    }
}

@end
