//
//  APFileManager.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-9-24.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APFileManager.h"


@interface APFileManager ()

@property NSMutableArray* files;
@property NSDate* timeStamp;

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
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    stringsPlistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"downloadFile.plist"];
    [self readFile];
}

+(APFileManager *) instance
{
    static dispatch_once_t _singletonPredicate;
    
    dispatch_once(&_singletonPredicate, ^{
        sharedInstance = [[super allocWithZone:nil] init];
    });
    
    return sharedInstance;
}


-(NSArray *) listFiles
{
    return [[NSArray alloc] initWithArray:self.files copyItems:YES];
}

-(void) updateFile:(APAudioFile *)file
{
    @synchronized(self) {
        BOOL matched = NO;
        for (int i = 0; i < [self.files count]; i++) {
            APAudioFile *current = [self.files objectAtIndex:i];
            if (current.finishedSize == file.fileId) {
                [current updateByItem:file];
                matched = YES;
                break;
            }
        }
        
        if (!matched) {
            [self.files addObject:file];
        }
        [self maySaveFile];
    }
}

-(void) deleteFile:(APAudioFile *)file
{
    @synchronized(self) {
        BOOL matched = NO;
        for (int i = 0; i < [self.files count]; i++) {
            APAudioFile *current = [self.files objectAtIndex:i];
            if (current.finishedSize == file.fileId) {
                [self.files removeObjectAtIndex:i];
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
        for (id item in data) {
            NSDictionary *dict = (NSDictionary*) item;
            APAudioFile *file = [APAudioFile instanceByDict:dict];
            [self.files addObject:file];
        }
    }
}

-(void) saveFile {
    if (self.files == nil || [self.files count] == 0)
        return;
    @synchronized(self) {
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
    if (self.timeStamp == NO)
        save = YES;
    else {
        if ([[[NSDate alloc] init] timeIntervalSinceDate:self.timeStamp] > 10)
            save = YES;
    }
    
    if (save)
        [self saveFile];
}

@end
