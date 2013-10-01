//
//  APAudioPlayerViewController.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-8-5.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APAudioPlayerViewController.h"

NSString* playerNotification = @"PLAYER_PLAYED_NOTIFICATION";

@interface APAudioPlayerViewController ()

@property (nonatomic, strong) APAudioFile *audioFile;
@property (nonatomic, strong) NSURL *storage;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSTimer *timer;
@property BOOL slideWithProgress;
@property MPMusicPlayerController* musicPlayer;
@property UILabel *timeLabel;


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
    CGSize result = [[UIScreen mainScreen] bounds].size;
    NSLog(@"size is %f, %f", result.width, result.height);
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_playscreen"]];
    [self.imageView setFrame:CGRectMake(0 - (result.height - 480)/2, 42, result.height - 160, result.height - 160)];
    [self.view addSubview:self.imageView];
	// Do any additional setup after loading the view.
    self.slider.maximumTrackTintColor = [UIColor clearColor];
    self.slider.minimumTrackTintColor = UIColorFromRGB(0x0099ff);
    self.progressView.progressTintColor = UIColorFromRGB(0x525a68);
    [self.volumeSlider setThumbImage:[UIImage imageNamed:@"icon_volumn1"] forState:UIControlStateNormal];
    self.volumeSlider.maximumValue = 1;
    self.musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(volumeChanged:)
     name:@"AVSystemController_SystemVolumeDidChangeNotification"
     object:nil];
    self.timeLabel = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, 35, 20))];
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    [self.timeLabel setBackgroundColor:[UIColor clearColor]];
    [self adjustLabelForSlider:self.slider];
    [[self.slider superview] addSubview: self.timeLabel];
    [self.slider addTarget:self action:@selector(adjustLabelForSlider:) forControlEvents:UIControlEventValueChanged];
    [self.slider setThumbImage:[UIImage imageNamed:@"slider-icon"] forState:UIControlStateNormal];


    NSLog(@"%@", [[self.slider minimumTrackTintColor] description]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    if (self.audioFile != nil) {
        NSLog(@"called");
        self.titleLabel.text = self.audioFile.name;
        self.titleLabel.font = [UIFont systemFontOfSize:20];
    }
    self.volumeSlider.value = self.musicPlayer.volume;
    [super viewWillAppear:animated];
}

-(void) setAudioFile:(APAudioFile *)file withLocalStorage:(NSURL *) path
{
    if (self.audioFile == nil || self.audioFile != file) {
        self.audioFile = file;
        self.storage = path;
        if (self.storage == nil)
            self.storage = self.audioFile.fileUrl;
        AVPlayerItem* playerItem = [[AVPlayerItem alloc] initWithURL:self.storage];
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
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
        if (self.slideWithProgress) {
            [self.slider setValue:normalizedTime animated:NO];
            [self adjustLabelForSlider:self.slider];
        }
     //   NSLog(@"%f %f", [self availableDuration], (double)self.player.currentTime.value);
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:playerNotification object:[NSNumber numberWithBool:[self isPlaying]]];
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


-(IBAction) backClicked:(id)sender
{
    NSLog(@"back clicked");
    [self.previousNav dismissViewControllerAnimated:YES completion:nil];
//    [[self navigationController] popViewControllerAnimated:YES];
}


-(IBAction) volumSliderChange:(id)sender
{
    self.musicPlayer.volume = self.volumeSlider.value;
}



- (void)volumeChanged:(NSNotification *)notification
{
    self.volumeSlider.value =
    [[[notification userInfo]
      objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"]
     floatValue];
    
}

-(void)adjustLabelForSlider:(id)slider
{
    CGRect trackRect = [self.slider trackRectForBounds:self.slider.bounds];
    CGRect thumbRect = [self.slider thumbRectForBounds:self.slider.bounds
                                             trackRect:trackRect
                                                 value:self.slider.value];
    int second = (int)([self availableDuration] * self.slider.value);
    NSString *sstr = second%60 < 10 ? [NSString stringWithFormat:@"0%d", second%60] : [NSString stringWithFormat:@"%d", second%60];
    self.timeLabel.text = [NSString stringWithFormat:@"%d:%@", second/60, sstr];
    self.timeLabel.center = CGPointMake(thumbRect.origin.x + self.slider.frame.origin.x + 25,  self.slider.frame.origin.y + 9);
}

-(BOOL) isPlaying
{
    return (self.player != nil && self.player.rate != 0.0);
}

-(void) itemDidFinishPlaying
{
    [[NSNotificationCenter defaultCenter] postNotificationName:playerNotification object:[NSNumber numberWithBool:[self isPlaying]]];
}

@end
