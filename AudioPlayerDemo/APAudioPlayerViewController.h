//
//  APAudioPlayerViewController.h
//  AudioPlayerDemo
//
//  Created by shen chen on 13-8-5.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "APAudioFile.h"
#import "util.h"


extern NSString* playerNotification;

@interface APAudioPlayerViewController : UIViewController

@property (nonatomic, strong) IBOutlet UISlider *slider;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) IBOutlet UISlider *volumeSlider;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UILabel *timePlayedLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLeftLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIButton *pauseButton;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;



@property (weak) UINavigationController *previousNav;

-(IBAction) playButtonClicked:(id)sender;
-(IBAction) pauseButtonClicked:(id)sender;
-(IBAction) sliderTouched:(id)sender;
-(IBAction) sliderRelease:(id)sender;
-(IBAction) backClicked:(id)sender;
-(IBAction) volumSliderChange:(id)sender;
-(IBAction) previousButtonClicked:(id)sender;
-(IBAction) nextButtonClicked:(id)sender;

-(void) reset;

-(BOOL) isPlaying;

-(void) setAudioFile:(APAudioFile *)file withLocalStorage:(NSURL *) path withPlayList:(NSArray *)list;
-(void) changePlayList:(NSArray *)list;
+(id) getInstance;
+(BOOL) isCurrentPlaying:(long long) fileId;

@end
