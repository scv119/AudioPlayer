//
//  APAudioPlayerViewController.h
//  AudioPlayerDemo
//
//  Created by shen chen on 13-8-5.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "APAudioFile.h"


@interface APAudioPlayerViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISlider *slider;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;

-(IBAction) playButtonClicked:(id)sender;
-(IBAction) sliderTouched:(id)sender;
-(IBAction) sliderRelease:(id)sender;

-(void) setAudioFile:(APAudioFile *)file withLocalStorage:(NSURL *) path;

@end
