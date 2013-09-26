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

@interface APSettingController ()

@property APSetting *setting;

@end

@implementation APSettingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.setting = [APSetting instance];
//    self.audioSwitch.on = self.setting.enablehighQuality;
    self.cellularSwitch.on = self.setting.enableCelluarData;
    self.backgroundSwitch.on = self.setting.enableBackground;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *theCellClicked = [self.tableView cellForRowAtIndexPath:indexPath];
    if (theCellClicked == self.feedBackCell)
        [UMFeedback showFeedback:self withAppkey:@"5243fcf056240bea3500cfab"];
}


@end
