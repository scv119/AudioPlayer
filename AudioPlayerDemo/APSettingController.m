//
//  APSettingController.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-7-29.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APSettingController.h"
#import "APSetting.h"
#import "UMFeedback.h"
#import "APAudioPlayerViewController.h"

@interface APSettingController ()

@property UIBarButtonItem *playButton;
@property APSetting *setting;

@end

@implementation APSettingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playButton= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playButtonClicked)];
    self.playButton.tintColor = [UIColor darkGrayColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerNotification:) name:playerNotification object:nil];
    
    self.setting = [APSetting instance];
//    self.audioSwitch.on = self.setting.enablehighQuality;
    self.cellularSwitch.on = self.setting.enableCelluarData;
    self.backgroundSwitch.on = self.setting.enableBackground;
    self.backgroundPlaySwith.on = self.setting.enableBackgroundPlay;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated
{
    APAudioPlayerViewController *playerView = [APAudioPlayerViewController getInstance];
    if ([playerView isPlaying]) {
        [self.navigationItem setRightBarButtonItem:self.playButton animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//
//-(IBAction) toggleAudioQuality:(id)sender {
//    
//    self.setting.enablehighQuality = self.audioSwitch.on;
//}

-(IBAction) toggleCellularData:(id)sender
{
    self.setting.enableCelluarData = self.cellularSwitch.on;
    
}
-(IBAction) toggleBackgroundDownload:(id)sender
{
    self.setting.enableBackground = self.backgroundSwitch.on;
}


-(IBAction) toggleBackgroundPlay:(id)sender
{
    self.setting.enableBackgroundPlay = self.backgroundPlaySwith.on;
}


-(IBAction) commentOnStore:(id)sender
{
    NSString *iTunesLink;
    iTunesLink = @"https://itunes.apple.com/us/app/hua-xing-tan/id725215424?ls=1&mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}

- (void) playerNotification:(NSNotification *)noti
{
    NSNumber *number = noti.object;
    if ([number boolValue]) {
        [self.navigationItem setRightBarButtonItem:self.playButton animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
}

-(void) playButtonClicked
{
    NSLog(@"clicked");
    APAudioPlayerViewController *playerView = [APAudioPlayerViewController getInstance];
    playerView.previousNav = [self navigationController];
    [[self navigationController] presentViewController:playerView animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *theCellClicked = [self.tableView cellForRowAtIndexPath:indexPath];
    if (theCellClicked == self.feedBackCell)
        [UMFeedback showFeedback:self withAppkey:@"5243fcf056240bea3500cfab"];
    if (theCellClicked == self.commentCell)
        [self commentOnStore:nil];
}


@end
