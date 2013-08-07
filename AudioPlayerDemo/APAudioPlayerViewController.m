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
@property (nonatomic, strong) NSTimer *timer;
@property BOOL slideWithProgress;


@end

@implementation APAudioPlayerViewController


static id sharedInstance;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.slider.maximumTrackTintColor = [UIColor clearColor];
    NSLog(@"%@", [[self.slider minimumTrackTintColor] description]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) setAudioFile:(APAudioFile *)file withLocalStorage:(NSURL *) path
{
    if (self.audioFile == nil || self.audioFile != file) {
        self.audioFile = file;
        self.storage = path;
        if (self.storage == nil)
            self.storage = self.audioFile.fileUrl;
        [self.player replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc] initWithURL:self.storage]];
    }

}

- (NSTimeInterval) availableDuration
{
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    if ([loadedTimeRanges count] == 0)
        return 0;
    CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}

-(void) preparePlayer
{
    NSLog(@"inited");
    self.player = [[AVPlayer alloc] init];
    self.slideWithProgress = YES;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:(self) selector:@selector(updateSlider) userInfo:nil repeats:YES];
    [self.timer fire];
}

-(void) updateSlider
{
    CMTime endTime = CMTimeConvertScale (self.player.currentItem.asset.duration, self.player.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
    [self.progressView setProgress: [self availableDuration]/CMTimeGetSeconds(self.player.currentItem.duration)];
    if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
        double normalizedTime = (double) self.player.currentTime.value / (double) endTime.value;
        // NSLog(@"%f", normalizedTime);
        if (self.slideWithProgress)
            [self.slider setValue:normalizedTime animated:YES];
        NSLog(@"%f %f", [self availableDuration], endTime.value);
    }
}

+(id) getInstance
{
    if (sharedInstance == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        sharedInstance = [storyboard instantiateViewControllerWithIdentifier:@"APAudioPlayerViewController"];
        [sharedInstance preparePlayer];
    }
    return sharedInstance;
}

-(IBAction) playButtonClicked:(id)sender
{
    //self.slider.value = 0;
    if ([self.player rate] == 0.0)
        [self.player play];
    else
        [self.player pause];
}

-(IBAction) sliderTouched:(id)sender
{
    NSLog(@"slider touched");
    self.slideWithProgress = NO;
}

-(IBAction) sliderRelease:(id)sender
{
     NSLog(@"slider release");
    
    [self.player seekToTime:CMTimeMultiplyByFloat64(self.player.currentItem.duration, self.slider.value) completionHandler: ^(BOOL finished){
        self.slideWithProgress = YES;
    }];
}

@end
