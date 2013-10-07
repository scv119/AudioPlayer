//
//  APAudioPlayerViewController.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-8-5.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APAudioPlayerViewController.h"

NSString* playerNotification = @"PLAYER_PLAYED_NOTIFICATION";

static UIImage* playHLImage;
static UIImage* nextHLImage;
static UIImage* backHLImage;
static UIImage* pauseHLImage;

@interface APAudioPlayerViewController ()

@property (nonatomic, strong) APAudioFile *audioFile;
@property (nonatomic, strong) NSURL *storage;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSTimer *timer;
@property BOOL slideWithProgress;
@property MPMusicPlayerController* musicPlayer;
@property NSArray* playList;


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
    
    if (playHLImage == nil) {
        playHLImage = imageByApplyingAlpha([UIImage imageNamed:@"play.png"], 0.2);
        nextHLImage = imageByApplyingAlpha([UIImage imageNamed:@"forward.png"], 0.2);
        backHLImage = imageByApplyingAlpha([UIImage imageNamed:@"back.png"], 0.2);
        pauseHLImage = imageByApplyingAlpha([UIImage imageNamed:@"pause.png"], 0.2);
    }
    
//    self.navBar.tintColor = [UIColor whiteColor];
    CGSize result = [[UIScreen mainScreen] bounds].size;
    NSLog(@"size is %f, %f", result.width, result.height);
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_playscreen"]];
    [self.imageView setFrame:CGRectMake(0 - (result.height - 480)/2, 42, result.height - 160, result.height - 140)];
    [self.view addSubview:self.imageView];
	// Do any additional setup after loading the view.
    self.slider.maximumTrackTintColor = [UIColor clearColor];
    self.slider.minimumTrackTintColor = UIColorFromRGB(0x0099ff);
    self.progressView.progressTintColor = UIColorFromRGB(0x525a68);
    self.volumeSlider.maximumValue = 1;
    [self.volumeSlider setHidden:YES];
    self.musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(volumeChanged:)
     name:@"AVSystemController_SystemVolumeDidChangeNotification"
     object:nil];
    [self adjustLabelForSlider:self.slider];
    [self.slider addTarget:self action:@selector(adjustLabelForSlider:) forControlEvents:UIControlEventValueChanged];
    
    [self.playButton setImage:playHLImage forState:UIControlStateHighlighted];
    [self.backButton setImage:backHLImage forState:UIControlStateHighlighted];
    [self.nextButton setImage:nextHLImage forState:UIControlStateHighlighted];
    [self.pauseButton setImage:pauseHLImage forState:UIControlStateHighlighted];

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
        self.navBar.topItem.title = self.audioFile.name;
    }

    self.volumeSlider.value = self.musicPlayer.volume;
    if (self.player.rate == 0) {
        [self.pauseButton setHidden:YES];
        [self.playButton setHidden:NO];
    } else
    {
        [self.pauseButton setHidden:NO];
        [self.playButton setHidden:YES];
    }
    [super viewWillAppear:animated];
}

-(void) setAudioFile:(APAudioFile *)file withLocalStorage:(NSURL *) path withPlayList:(NSArray *)list
{
    if (self.audioFile == nil || self.audioFile != file) {
        self.playList = list;
        self.audioFile = file;
        self.storage = path;
        if (self.storage == nil)
            self.storage = self.audioFile.fileUrl;
        AVPlayerItem* playerItem = [[AVPlayerItem alloc] initWithURL:self.storage];
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        
        self.navBar.topItem.title = self.audioFile.name;
    }

}

- (double) availablePercentage
{
   
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    if ([loadedTimeRanges count] == 0)
        return 0;
    NSTimeInterval result = 0;
    for (id item in loadedTimeRanges) {
        CMTimeRange timeRange = [item CMTimeRangeValue];
        result += (CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration));
    }
    return result/CMTimeGetSeconds(self.player.currentItem.duration);
    
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
    [self.progressView setProgress: [self availablePercentage]];
    if (CMTimeGetSeconds(self.player.currentItem.duration) > 0) {
        double normalizedTime = CMTimeGetSeconds(self.player.currentTime) / CMTimeGetSeconds(self.player.currentItem.duration);
//        NSLog(@"%f", normalizedTime);
        if (self.slideWithProgress) {
            [self.slider setValue:normalizedTime animated:NO];
            [self adjustLabelForSlider:self.slider];
        }
//        NSLog(@"%f %f %f", [self availablePercentage], (double)self.player.currentTime.value, [self.player rate]);
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

    [self.player play];
    [self.playButton setHidden:YES];
    [self.pauseButton setHidden:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:playerNotification object:[NSNumber numberWithBool:[self isPlaying]]];
}

-(IBAction) pauseButtonClicked:(id)sender
{
    
    [self.player pause];
    [self.playButton setHidden:NO];
    [self.pauseButton setHidden:YES];
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
    
    CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(self.player.currentItem.duration) * self.slider.value, 1);
    [self.player seekToTime:time completionHandler: ^(BOOL finished){
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

-(IBAction) previousButtonClicked:(id)sender
{
    int idx = -1;
    for (int i = 0; i < self.playList.count; i ++) {
        if ([self.playList objectAtIndex:i] == self.audioFile) {
            idx = i;
            break;
        }
    }
    
    if (idx >0) {
        idx = idx - 1;
        id nextItem = [self.playList objectAtIndex:idx];
        if (nextItem != nil) {
            APAudioFile *nextFile = nextItem;
            NSURL *localStorage = nil;
            if (nextFile.status == FINISHED) {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:nextFile.path];
                localStorage = [[NSURL alloc] initFileURLWithPath: path];
            }
            [self setAudioFile:nextItem withLocalStorage:localStorage withPlayList:self.playList];
            [self playButtonClicked:nil];
        }
    }
}

-(IBAction) nextButtonClicked:(id)sender
{
    NSLog(@"next button clicked");
    int idx = -1;
    for (int i = 0; i < self.playList.count; i ++) {
        if ([self.playList objectAtIndex:i] == self.audioFile) {
            idx = i;
            break;
        }
    }
    
    if (idx >= 0 && idx < self.playList.count - 1) {
        idx = idx + 1;
        id nextItem = [self.playList objectAtIndex:idx];
        if (nextItem != nil) {
            APAudioFile *nextFile = nextItem;
            NSURL *localStorage = nil;
            if (nextFile.status == FINISHED) {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:nextFile.path];
                localStorage = [[NSURL alloc] initFileURLWithPath: path];
            }
            [self setAudioFile:nextItem withLocalStorage:localStorage withPlayList:self.playList];
            [self playButtonClicked:nil];
        }
    }
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
    int second = CMTimeGetSeconds(self.player.currentTime);
    NSString *sstr = second%60 < 10 ? [NSString stringWithFormat:@"0%d", second%60] : [NSString stringWithFormat:@"%d", second%60];
    self.timePlayedLabel.text = [NSString stringWithFormat:@"%d:%@", second/60, sstr];
    second =(int)CMTimeGetSeconds(self.player.currentItem.duration) - second;
    sstr = second%60 < 10 ? [NSString stringWithFormat:@"0%d", second%60] : [NSString stringWithFormat:@"%d", second%60];
    self.timeLeftLabel.text = [NSString stringWithFormat:@"%d:%@", second/60, sstr];
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
