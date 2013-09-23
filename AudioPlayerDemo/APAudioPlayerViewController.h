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

@interface APAudioPlayerViewController : UIViewController

@property (nonatomic, strong) IBOutlet UISlider *slider;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) IBOutlet UISlider *volumeSlider;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;


@property (weak) UINavigationController *previousNav;

-(IBAction) playButtonClicked:(id)sender;
-(IBAction) sliderTouched:(id)sender;
-(IBAction) sliderRelease:(id)sender;
-(IBAction) backClicked:(id)sender;
-(IBAction) volumSliderChange:(id)sender;

-(void) setAudioFile:(APAudioFile *)file withLocalStorage:(NSURL *) path;

+(id) getInstance;

@end
