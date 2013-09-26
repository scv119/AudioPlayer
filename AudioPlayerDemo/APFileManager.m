//
//  APFileManager.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-9-24.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APFileManager.h"
#import "APDownloadManager.h"


@interface APFileManager ()

@property NSMutableArray *files;
@property NSMutableDictionary *dict;
@property NSDate* timeStamp;
@property APDownloadManager *downloadManager;

@end


@implementation APFileManager

static id sharedInstance;
static id stringsPlistPath;

-(id) init
{
    if (sharedInstance != nil) {
        NSAssert(NO, @"should never be called");
        return nil;
    }
    self = [super init];
    NSLog(@"file manager started");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    stringsPlistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"downloadFile.plist"];
    self.downloadManager = [APDownloadManager instance];
    [self readFile];
    return self;
}

+(APFileManager *) instance
{
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedInstance = [[super allocWithZone:nil] init];
    });
    
    return sharedInstance;
}




-(APAudioFile *) getFile:(long long )fileId
{
    return [self.dict objectForKey:[NSNumber numberWithLongLong:fileId]];
}

-(void) startDownloadFile:(APAudioFile *)file;
{
    @synchronized(self) {
        APAudioFile *current = [self.dict objectForKey:[NSNumber numberWithLongLong:file.fileId]];
        if (current == nil) {
            [self.files addObject:file];
            [self.dict setObject:file forKey:[NSNumber numberWithLongLong:file.fileId]];
            current = file;
        }
        [self.downloadManager add:current];
        [self maySaveFile];
    }
}

-(void) stopDownloadFiles:(APAudioFile *)file
{
    @synchronized(self) {
        APAudioFile *current = [self.dict objectForKey:[NSNumber numberWithLongLong:file.fileId]];
        if (current == nil) {
            return;
        }
        [self.downloadManager remove:current.fileId];
        [self maySaveFile];
    }
}



-(void) deleteFile:(APAudioFile *)file
{
    @synchronized(self) {
        BOOL matched = NO;
        for (int i = 0; i < [self.files count]; i++) {
            APAudioFile *current = [self.files objectAtIndex:i];
            if (current.fileId == file.fileId) {
                [self stopDownloadFiles:file];
                [self.files removeObjectAtIndex:i];
                [self.dict removeObjectForKey:[NSNumber numberWithLongLong:file.fileId]];
                break;
            }
        }
        
        if (matched) {
            [self maySaveFile];
        }
    }

}

-(void) flush
{
    [self saveFile];
}

-(void) readFile
{
    @synchronized(self) {
        NSArray *data = [NSArray arrayWithContentsOfFile:stringsPlistPath];
        self.files = [[NSMutableArray alloc] init];
        self.dict = [[NSMutableDictionary alloc] init];
        
        for (id item in data) {
            NSDictionary *dict = (NSDictionary*) item;
            APAudioFile *file = [APAudioFile instanceByDict:dict];
            [self.files addObject:file];
            [self.dict setObject:file forKey:[NSNumber numberWithLongLong:file.fileId]];
            
            if ([self fileExist:file])
                file.status = FINISHED;
            
            if (file.status == STARTED || file.status == QUEUED) {
                [self.downloadManager add:file];
            }
        }
    }
}

-(void) saveFile {
    if (self.files == nil || [self.files count] == 0)
        return;
    @synchronized(self) {
        NSLog(@"file saved");
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[self.files count]];
        for (id item in self.files) {
            APAudioFile *file = item;
            [array addObject:[file toDict]];
        }
        [array writeToFile:stringsPlistPath atomically:YES];
        self.timeStamp = [[NSDate alloc] init];
    }
}

-(void) maySaveFile
{
    BOOL save = NO;
    if (self.timeStamp == nil)
        save = YES;
    else {
        if ([[[NSDate alloc] init] timeIntervalSinceDate:self.timeStamp] > 60)
            save = YES;
    }
    
    if (save)
        [self saveFile];
}

-(BOOL) fileExist:(APAudioFile *)file
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:file.path];
    
    return[[NSFileManager defaultManager] fileExistsAtPath:path];
}

@end
