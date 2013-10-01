//
//  APFileManager.h
//  AudioPlayerDemo
//
//  Created by shen chen on 13-9-24.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APAudioFile.h"

extern NSString *finishedListAddedNotification ;
extern NSString *downloadingListAddedNotification ;

extern NSString *finishedListRemovedNotification ;
extern NSString *downloadingListRemovedNotification ;

@interface APFileManager : NSObject


@property NSMutableArray *finished;
@property NSMutableArray *downloading;

-(void) startDownloadFile:(APAudioFile *)file;
-(void) stopDownloadFiles:(APAudioFile *)file;
-(void) deleteFile:(APAudioFile *)file;
-(APAudioFile *) getFile:(long long )fileId;
-(void) flush;

+(APFileManager *) instance;

@end
