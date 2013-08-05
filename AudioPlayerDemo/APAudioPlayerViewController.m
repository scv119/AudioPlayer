//
//  APAudioPlayerViewController.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-8-5.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APAudioPlayerViewController.h"

@interface APAudioPlayerViewController ()

@property (nonatomic, strong) APAudioFile *audioFile;
@property (nonatomic, strong) NSURL *storage;
@property (nonatomic, strong) AVPlayer *player;
@property BOOL slider_touched;

@end

@implementation APAudioPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) setAudioFile:(APAudioFile *)file withLocalStorage:(NSURL *) path
{
    self.audioFile = file;
    self.storage = path;
    if (self.storage == nil)
        self.storage = self.audioFile.fileUrl;
    self.player = [[AVPlayer alloc] initWithURL: self.storage];
    id playbackObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:nil usingBlock: ^(CMTime time){
        CMTime endTime = CMTimeConvertScale (self.player.currentItem.asset.duration, self.player.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
        if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
            double normalizedTime = (double) self.player.currentTime.value / (double) endTime.value;
           // NSLog(@"%f", normalizedTime);
            if (!self.slider_touched)
                [self.slider setValue:normalizedTime animated:YES];
            NSLog(@"%f %f", [self availableDuration], endTime.value);
            [self.progressView setProgress: [self availableDuration]/CMTimeGetSeconds(self.player.currentItem.duration)];
        }
    }];
}


- (NSTimeInterval) availableDuration
{
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}

-(IBAction) playButtonClicked:(id)sender
{
    //self.slider.value = 0;
    [self.player play];
}

-(IBAction) sliderTouched:(id)sender
{
    NSLog(@"slider touched");
    self.slider_touched = YES;
}

-(IBAction) sliderRelease:(id)sender
{
     NSLog(@"slider release");
    
    [self.player seekToTime:CMTimeMultiplyByFloat64(self.player.currentItem.duration, self.slider.value) completionHandler: ^(BOOL finished){
        self.slider_touched = NO;
    }];
}

@end
