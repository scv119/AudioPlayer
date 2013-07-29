//
//  APAudioTableCell.h
//  AudioPlayerDemo
//
//  Created by shen chen on 13-7-29.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APAudioFile.h"
#import "AFNetworking.h"

@interface APAudioTableCell : UITableViewCell

@property (nonatomic, strong) APAudioFile *audio;
@property (nonatomic, retain) UILabel *fileSizeLabel;
@property (nonatomic, retain) UILabel *timeSpanLabel;

@end
