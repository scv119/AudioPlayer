//
//  APAudioTableCell.h
//  AudioPlayerDemo
//
//  Created by shen chen on 13-7-29.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APAudioFile.h"


@interface APAudioTableCell : UITableViewCell


- (void) setAudio:(APAudioFile *)audio withDownloadBar:(BOOL) flag;

@end
