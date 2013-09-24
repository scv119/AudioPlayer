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
@property (atomic, strong) NSFileHandle *file;

@end

@implementation APDownloadOperation

-(void) setTask:(id<APDownloadTask>)task
{
    self.task = task;
    [self prepareFile];
    [self prepareURLRequest];
    self.connection = [NSURLConnection alloc];
    self.task.status = QUEUED;
    [self notifyStatusChanged];
}

-(void) prepareURLRequest
{
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:self.task.fileUrl];
    NSDictionary *oldHeader = [request allHTTPHeaderFields];
    NSMutableDictionary *newHeader = [[NSMutableDictionary alloc] initWithDictionary:oldHeader copyItems:YES];
    [newHeader setObject:[NSString stringWithFormat:@"%lld", self.task.finishedSize] forKey:@"Range"];
    [request setAllHTTPHeaderFields:newHeader];
    NSLog(@"the request now is %@", [request description]);
    self.request = request;
}

-(void) prepareFile
{
//    NSFileManager *manager = [NSFileManager defaultManager];
    NSFileHandle * file = [NSFileHandle fileHandleForUpdatingAtPath: self.task.path];
    self.task.finishedSize = [file seekToEndOfFile];
    self.file = file;
}


#pragma NSOperation

-(void) main
{
    if (![self isCancelled]) {
        self.connection = [self.connection initWithRequest:self.request delegate:self];
        [self.connection start];
    }
}

-(void) cancel
{
    if (self.task.status == STARTED) {
        [self.connection cancel];
    }
    
    [super cancel];
    self.task.status = STOPED;
    [self notifyStatusChanged];
}

#pragma NSURLConnectionDataDelegate


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.task.status = STOPED;
    [self notifyStatusChanged];
    [self.file closeFile];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    self.task.status = STARTED;
    [self notifyStatusChanged];
    return request;
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.file writeData:data];
    self.task.finishedSize += [data length];
    self.task.status = STARTED;
    [self notifyStatusChanged];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.task.status = FINISHED;
    [self notifyStatusChanged];
    [self.file closeFile];
}

-(void) notifyStatusChanged
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DOWNLOAD_STATUS_CHANGED" object:self.task];
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
    NSLog(@"download manager started");
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

-(void) start
{
    return [self start:1];
}

-(void) start:(int) threadNum
{
    [self.queue setMaxConcurrentOperationCount:threadNum];
}



-(void) pushTask:(id<APDownloadTask>) task
{
    APDownloadOperation *operation = [[APDownloadOperation alloc] init];
    operation.task = task;
    [self.queue addOperation:operation];
}

-(void) removeTask:(id<APDownloadTask>) task
{
    NSArray* operations = self.queue.operations;
    for (APDownloadOperation* operation in operations) {
            if (operation.task == task)
                [operation cancel];
    }
}

-(int) taskCount
{
    return [self.queue operationCount];
}


-(NSArray *) cancelAllTask
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSArray *operations = self.queue.operations;
    [self.queue cancelAllOperations];
    [self.queue waitUntilAllOperationsAreFinished];
    for (APDownloadOperation *op in operations) {
        if (op.task.status != FINISHED)
            [ret addObject:op];
    }
    return ret;
}

@end
