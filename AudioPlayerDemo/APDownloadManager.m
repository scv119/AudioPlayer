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
@property (atomic, strong) NSFileHandle *file;
@property (atomic) APDownloadStatus status;

@end

@implementation APDownloadOperation

-(void) setTask:(id<APDownloadTask>)task
{
    self.task = task;
    [self prepareFile];
    [self prepareURLRequest];
    self.connection = [NSURLConnection alloc];
    self.connectionLock = [[NSLock alloc] init];
    self.status = QUEUED;
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
        [self.connectionLock lock];
        [self.connection start];
        [self.connectionLock lock];
        [self.connectionLock unlock];
    }
}

-(void) cancel
{
    if (self.status == STARTED) {
        self.status = CANCELED;
        [self.connection cancel];
        [self.task statusChanged: self.status];
    }
    
    [super cancel];
}

#pragma NSURLConnectionDataDelegate


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.status != CANCELED)
        self.status = FAILED;
    [self.file closeFile];
    [self.connectionLock unlock];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    self.status = STARTED;
    return request;
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.file writeData:data];
    self.task.finishedSize += [data length];
    [self.task statusChanged: self.status];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.status = FINISHED;
    [self.file closeFile];
    [self.connectionLock unlock];
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
    [self.queue  cancelAllOperations];
    [self.queue waitUntilAllOperationsAreFinished];
    for (APDownloadOperation *op in operations) {
        if (op.status != FINISHED)
            [ret addObject:op];
    }
    return ret;
}



@end
