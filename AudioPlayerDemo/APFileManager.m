//
//  APFileManager.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-9-24.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APFileManager.h"
#import "APDownloadManager.h"
#import "util.h"

NSString *finishedListAddedNotification = @"FILE_MANAGER_FINISH_NOTIFICATION_ADD";
NSString *downloadingListAddedNotification = @"FILE_MANAGER_DOWNLOA_CHANGED_ADD";

NSString *finishedListRemovedNotification = @"FILE_MANAGER_FINISH_NOTIFICATION_RMV";
NSString *downloadingListRemovedNotification = @"FILE_MANAGER_DOWNLOA_CHANGED_RMV";

@interface APFileManager ()

@property NSMutableArray *files;
@property NSMutableDictionary *dict;
@property NSMutableDictionary *finishedDict;
@property NSMutableDictionary *downloadingDict;
@property NSDate* timeStamp;
@property APDownloadManager *downloadManager;





@end


@implementation APFileManager {
    NSComparator comparator;
}

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
    
    comparator = ^(id<APDownloadTask> obj1, id<APDownloadTask> obj2){
        if ([obj1.statusUpdated timeIntervalSinceDate:obj2.statusUpdated] > 0) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1.statusUpdated timeIntervalSinceDate:obj2.statusUpdated] < 0) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    [self readFile];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadStatusChanged:) name:downloadStatusNotification object:nil];
    

    
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
        [self saveFile];
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
        [self saveFile];
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
            [self saveFile];
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
        self.finished = [[NSMutableArray alloc] init];
        self.downloading = [[NSMutableArray alloc] init];
        self.finishedDict = [[NSMutableDictionary alloc] init];
        self.downloadingDict = [[NSMutableDictionary alloc] init];
        
        for (id item in data) {
            NSDictionary *dict = (NSDictionary*) item;
            APAudioFile *file = [APAudioFile instanceByDict:dict];
            [self.files addObject:file];
            [self.dict setObject:file forKey:[NSNumber numberWithLongLong:file.fileId]];
            
            if ([self fileExist:file]) {
                file.status = FINISHED;
                [self.finished addObject:file];
                [self.finishedDict setObject:file forKey:[NSNumber numberWithLongLong:file.fileId]];
            }
            
            if (file.status == STARTED || file.status == QUEUED) {
                [self.downloading addObject:file];
                [self.downloadingDict setObject:file forKey:[NSNumber numberWithLongLong:file.fileId]];
                [self.downloadManager add:file];
            }
        }
        
        [self.finished sortUsingComparator:comparator];
        [self.downloading sortUsingComparator:comparator];
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
        addSkipBackupAttributeToItemAtURL([NSURL fileURLWithPath:stringsPlistPath]);
        self.timeStamp = [[NSDate alloc] init];
    }
}

-(void) downloadStatusChanged:(NSNotification *) notification
{
    APAudioFile *task = notification.object;
    
    if (task.status == QUEUED || task.status == STARTED) {
        if ([self.downloadingDict objectForKey:[NSNumber numberWithLongLong:task.fileId]] == nil) {
            @synchronized(self) {
                if ([self.downloadingDict objectForKey:[NSNumber numberWithLongLong:task.fileId]] == nil) {
                    [self.downloadingDict setObject:task forKey:[NSNumber numberWithLongLong:task.fileId]];
                    [self.downloading addObject:task];
                    [[NSNotificationCenter defaultCenter] postNotificationName:downloadingListAddedNotification object:[NSNumber numberWithInt:[self.downloading count] - 1]];
                }
            }
        }
    } else if (task.status == FINISHED) {
        if ([self.finishedDict objectForKey:[NSNumber numberWithLongLong:task.fileId]] == nil) {
            @synchronized(self) {
                if ([self.finishedDict objectForKey:[NSNumber numberWithLongLong:task.fileId]] == nil) {
                    [self.finishedDict setObject:task forKey:[NSNumber numberWithLongLong:task.fileId]];
                    [self.finished addObject:task];
                   [[NSNotificationCenter defaultCenter] postNotificationName:finishedListAddedNotification object:[NSNumber numberWithInt:[self.finished count] - 1]];
                }
            }
        }
        
        if ([self.downloadingDict objectForKey:[NSNumber numberWithLongLong:task.fileId]] != nil) {
            @synchronized(self) {
                if ([self.downloadingDict objectForKey:[NSNumber numberWithLongLong:task.fileId]] != nil) {
                    [self.downloadingDict removeObjectForKey:[NSNumber numberWithLongLong:task.fileId]];
                    int idx = [self.downloading indexOfObject:task];
                    [self.downloading removeObjectAtIndex:idx];
                    [[NSNotificationCenter defaultCenter] postNotificationName:downloadingListRemovedNotification object:[NSNumber numberWithInt:idx]];
                }
            }
        }
    } else if (task.status == STOPED) {
        if ([self.downloadingDict objectForKey:[NSNumber numberWithLongLong:task.fileId]] != nil) {
            @synchronized(self) {
                if ([self.downloadingDict objectForKey:[NSNumber numberWithLongLong:task.fileId]] != nil) {
                    [self.downloadingDict removeObjectForKey:[NSNumber numberWithLongLong:task.fileId]];
                    int idx = [self.downloading indexOfObject:task];
                    [self.downloading removeObjectAtIndex:idx];
                    [[NSNotificationCenter defaultCenter] postNotificationName:downloadingListRemovedNotification object:[NSNumber numberWithInt:idx]];
                }
            }
        }
        
    }
    
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
