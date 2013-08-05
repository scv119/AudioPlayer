//
//  APAudioTableCell.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-7-29.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APAudioTableCell.h"

static UIImage *coverPlaceholderImage;

@interface APAudioTableCell ()

@property (nonatomic, strong) APAudioFile *audio;
@property (nonatomic, retain) UILabel *fileSizeLabel;
@property (nonatomic, retain) UILabel *timeSpanLabel;

@end

@implementation APAudioTableCell {
    
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!coverPlaceholderImage)
        coverPlaceholderImage = [UIImage imageNamed:@"first"];
    
    self.fileSizeLabel = [[UILabel alloc] init];
    self.timeSpanLabel = [[UILabel alloc] init];
    if (!self)
        return nil;
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setAudio:(APAudioFile *)audio withDownloadBar:(BOOL) flag
{
    self.audio = audio;
    NSLog(@"%@", [audio.coverUrl description]);
    [self.imageView setImageWithURL:self.audio.coverUrl placeholderImage:coverPlaceholderImage];
    NSLog(@"%@", [self.imageView.image description]);
    self.textLabel.text = self.audio.name;
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [self addSubview:self.fileSizeLabel];
    [self addSubview:self.timeSpanLabel];

    [self setNeedsLayout];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, 10, 10);
}


@end
