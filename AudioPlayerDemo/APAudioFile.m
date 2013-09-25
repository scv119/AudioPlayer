//
//  APAudioFile.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-7-29.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APAudioFile.h"

@interface APAudioFile ()

@end

@implementation APAudioFile



-(NSDictionary *) toDict
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.name forKey:@"name"];
    [dict setObject:self.author forKey:@"author"];
    [dict setObject:self.serialName forKey:@"serialName"];
    [dict setObject:self.serialNO forKey:@"serialNO"];
    [dict setObject:[self.fileUrl absoluteString] forKey:@"fileUrl"];
    [dict setObject:[NSString stringWithFormat:@"%lld", self.fileSize] forKey:@"fileSize"];
    [dict setObject:self.hasLyric ? @"yes":@"no" forKey:@"hasLyric"];
    [dict setObject:[NSString stringWithFormat:@"%d", self.duration] forKey:@"duration"];
    [dict setObject:[NSString stringWithFormat:@"%lld", self.fileId] forKey:@"id"];
    [dict setObject:[NSString stringWithFormat:@"%lld", self.finishedSize] forKey:@"finishedSize"];
    [dict setObject:self.path forKey:@"path"];
    [dict setObject:[NSString stringWithFormat:@"%d", self.status] forKey:@"status"];
    return dict;
}

+(APAudioFile *) instanceByDict:(NSDictionary *) dict
{
    APAudioFile *file = [[APAudioFile alloc] init];
    file.name = [dict objectForKey:@"name"];
    file.author = [dict objectForKey:@"author"];
    file.serialName = [dict objectForKey:@"serialName"];
    file.serialNO = [dict objectForKey:@"serialNO"];
    file.fileUrl  = [[NSURL alloc] initWithString: [dict objectForKey:@"fileUrl"]];
    file.fileSize = [[dict objectForKey:@"fileSize"] longLongValue];
    file.hasLyric = [@"yes" isEqualToString:[dict objectForKey:@"hasLyric"]] ? YES:NO;
    file.duration = (int)[[dict objectForKey:@"duration"] floatValue];
    file.fileId = [[dict objectForKey:@"id"] longLongValue];
    file.taskId = file.fileId;
    if ([dict objectForKey:@"finishedSize"]!=nil)
        file.finishedSize = [[dict objectForKey:@"finishedSize"] longLongValue];
    else
        file.finishedSize = 0;
    if ([dict objectForKey:@"path"] != nil)
        file.path = [dict objectForKey:@"path"];
    else
        file.path = [NSString stringWithFormat:@"%lld.mp3", file.taskId];
    if ([dict objectForKey:@"status"] != nil)
        file.status = [[dict objectForKey:@"status"] integerValue];
    else
        file.status = STOPED;
    
    return file;
}

-(void) updateByItem:(APAudioFile *)item
{
    self.name = item.name;
    self.author = item.author;
    self.serialName = item.serialName;
    self.serialNO = item.serialNO;
    self.fileUrl = [item.fileUrl copy];
    self.fileSize = item.fileSize;
    self.hasLyric = item.hasLyric;
    self.duration = item.duration;
    self.fileId = item.fileId;
    self.taskId = item.taskId;
    self.finishedSize = item.finishedSize;
    self.path = item.path;
    self.status = item.status;
}

- (id)copyWithZone:(NSZone *)zone {
    APAudioFile *file = [[[self class] allocWithZone:zone] init];
    [file updateByItem:self];
    return file;
}

@end
