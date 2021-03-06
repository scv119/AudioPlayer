//
//  APAudioTableCell.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-7-29.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "APAudioTableCell.h"
#import "AFNetworking.h"
#import "util.h"
#import "APDownloadManager.h"
#import "APFileManager.h"
#import "MBProgressHUD.h"


static UIImage *coverPlaceholderImage;
static UIImage *downloadAlphaImage;
static UIImage *downloadFinishAlphaImage;
static UIImage *iconImage;

@interface APAudioTableCell ()

@property (nonatomic, strong) APAudioFile *audio;
@property (nonatomic, retain) UILabel *fileSizeLabel;
@property (nonatomic, retain) UILabel *timeSpanLabel;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *authorLabel;
@property (nonatomic, retain) UILabel *serialNameLabel;
@property (nonatomic, retain) UILabel *serialNoLabel;
@property (nonatomic, retain) UILabel *lyricLabel;
@property (nonatomic, retain) UIView *lineView;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIButton *downloadFinishButton;
@property (nonatomic, strong) UILabel *downloadLabel;
@property (nonatomic) BOOL inDownloadTab;
@property UIImage* downloadImage;
@property UIImage* downloadFinishImage;
@property APFileManager *fileManager;
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
    
    self.downloadImage = [UIImage imageNamed:@"download.png"];
    self.downloadFinishImage = [UIImage imageNamed:@"downloadfinish.png"];
    
    if (downloadAlphaImage == nil) {
        downloadAlphaImage = imageByApplyingAlpha(self.downloadImage, 0.2);
    }
    
    if (downloadFinishAlphaImage == nil) {
        downloadFinishAlphaImage = imageByApplyingAlpha(self.downloadFinishImage, 0.2);
    }
    
    if (iconImage == nil) {
        CGRect rect = CGRectMake(0, 0, 69, 69);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context,
                                       [UIColorFromRGB(0xc1c1c2) CGColor]);
        //  [[UIColor colorWithRed:222./255 green:227./255 blue: 229./255 alpha:1] CGColor]) ;
        CGContextFillRect(context, rect);
        iconImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setFrame:CGRectMake(69+14, 22, 180, 13)];
    [self.titleLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:(12)]];
    
    self.authorLabel = [[UILabel alloc] init];
    [self.authorLabel setFrame:CGRectMake(69+14, 38, 150, 13)];
    [self.authorLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:(12)]];
    
    
    self.lyricLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 38, 37, 15)];
    [self.lyricLabel setBackgroundColor:UIColorFromRGB(0x2b92eb)];
    [self.lyricLabel setTextColor:[UIColor whiteColor]];
    [self.lyricLabel setFont: [UIFont fontWithName:@"STLiti" size:12]];
    [self.lyricLabel setTextAlignment:NSTextAlignmentCenter];
    self.lyricLabel.layer.cornerRadius = 3;
    
    self.imageView.image = iconImage;
    
    
    self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 68, 320, 1)];
    [self.lineView setBackgroundColor:UIColorFromRGB(0xc1c1c2)];
    
    self.serialNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, 69, 24)];
    [self.serialNameLabel setFont:[UIFont fontWithName:@"STLiti" size:(24)]];
    self.serialNameLabel.textColor = [UIColor whiteColor];
    [self.serialNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.serialNameLabel setBackgroundColor: [UIColor clearColor]];
    [self.imageView addSubview:self.serialNameLabel];
  
    self.serialNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 38, 69, 18)];
    [self.serialNoLabel setFont:[UIFont fontWithName:@"STLiti" size:(18)]];
    self.serialNoLabel.textColor = [UIColor whiteColor];
    [self.serialNoLabel setTextAlignment:NSTextAlignmentCenter];
    [self.serialNoLabel setBackgroundColor: [UIColor clearColor]];
    [self.imageView addSubview:self.serialNoLabel];
    
    self.downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.downloadButton setFrame:CGRectMake(264, 10, 50, 50)];
    [self.downloadButton setImage:self.downloadImage forState:UIControlStateNormal];
    [self.downloadButton setImage:downloadAlphaImage forState:UIControlStateHighlighted];
    
    self.downloadFinishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.downloadFinishButton setFrame:CGRectMake(264, 10, 50, 50)];
    [self.downloadFinishButton setImage:self.downloadFinishImage forState:UIControlStateNormal];
    [self.downloadFinishButton setImage:downloadFinishAlphaImage forState:UIControlStateHighlighted];
    
    self.downloadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 36, 50, 15)];
    [self.downloadLabel setBackgroundColor:[UIColor clearColor]];
    [self.downloadLabel setTextColor:[UIColor blackColor]];
    [self.downloadLabel setText:@"下载中  0%"];
    [self.downloadLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:9]];
    [self.downloadLabel setTextAlignment:NSTextAlignmentCenter];
    [self.downloadButton addTarget:self action:@selector(downloadButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.downloadFinishButton addTarget:self action:@selector(downloadButtonClicked) forControlEvents:UIControlEventTouchUpInside];

    if (!self)
        return nil;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadStatusChanged:) name:downloadStatusNotification object:nil];
    self.fileManager = [APFileManager instance];
    
    
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected) 
        [self.lyricLabel setHidden:TRUE];
    else
        [self.lyricLabel setHidden:FALSE];
    [super setSelected:selected animated:animated];


    // Configure the view for the selected state
}

- (void) setAudio:(APAudioFile *)audio withDownloadBar:(BOOL) flag
{
    self.audio = audio;
    [self addSubview:self.lineView];
    [self addSubview:self.downloadButton];
    [self addSubview:self.downloadFinishButton];
    [self.downloadButton addSubview:self.downloadLabel];
    NSLog(@"%@", [audio.coverUrl description]);
    NSLog(@"%@", [self.imageView.image description]);
    self.titleLabel.text = self.audio.name;
    self.authorLabel.text = [NSString stringWithFormat:@"主讲人: %@", self.audio.author];
    self.serialNameLabel.text = self.audio.serialName;
    self.serialNoLabel.text = self.audio.serialNO;
    self.lyricLabel.text = @"字幕";
    
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.authorLabel];
    if (self.audio.hasLyric)
        [self addSubview:self.lyricLabel];
    
    [self addSubview:self.fileSizeLabel];
    [self addSubview:self.timeSpanLabel];
   
    self.inDownloadTab = NO;
    [self statusChanged];

    [self setNeedsLayout];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, 69, 69);

}

-(void) downloadStatusChanged:(NSNotification *)notification
{
    APAudioFile *file = notification.object;
    if(file.fileId == self.audio.fileId) {
        [self.audio updateByItem:file];
        [self statusChanged];
    }
}

-(void) statusChanged
{
    int percentage = (int)(1.0f * self.audio.finishedSize/self.audio.fileSize * 100);
    NSString *labelText = nil;
    if (percentage < 10)
        labelText = [NSString stringWithFormat:@"下载中  %d%%", percentage];
    else
        labelText = [NSString stringWithFormat:@"下载中 %d%%", percentage];
    switch (self.audio.status) {
        case STOPED:
            [self.downloadLabel setHidden:YES];
            [self.downloadButton setHidden:NO];
            [self.downloadFinishButton setHidden:YES];
            break;
        case STARTED:

            [self.downloadLabel setText:labelText];
            [self.downloadLabel setHidden:NO];
            [self.downloadButton setHidden:NO];
            [self.downloadFinishButton setHidden:YES];
            break;
            
        case QUEUED:
            [self.downloadLabel setText:@"等待中"];
            [self.downloadLabel setHidden:NO];
            [self.downloadButton setHidden:NO];
            [self.downloadFinishButton setHidden:YES];
            break;
        case FINISHED:
            [self.downloadLabel setText:@"已下载"];
            [self.downloadLabel setHidden:NO];
            [self.downloadButton setHidden:YES];
            [self.downloadFinishButton setHidden:NO];
            break;
        default:
            break;
    }
}

-(void) downloadButtonClicked
{
    NSLog(@"triggled");
    if (self.audio.status == STOPED) {
        [self.fileManager startDownloadFile:self.audio];
        [self displayHud:@"已加入下载队列" withMode:MBProgressHUDModeText];
    } else if (self.audio.status == STARTED || self.audio.status == QUEUED) {
        [self.fileManager stopDownloadFiles:self.audio];
        [self displayHud:@"已停止下载" withMode:MBProgressHUDModeText];
    } else {
        [self displayHud:@"已下载" withMode:MBProgressHUDModeText];
    }

}

-(void) displayHud:(NSString *)text withMode:(MBProgressHUDMode) mode
{
    UIView *superView = self.superview;
    MBProgressHUD *hud =[MBProgressHUD showHUDAddedTo:superView animated:YES];
    hud.mode = mode;
    hud.labelText = text;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        [MBProgressHUD hideHUDForView:superView animated:YES];
    });
}

@end
