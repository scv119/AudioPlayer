//
//  APSettingController.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-7-29.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APSettingController.h"

@interface APSettingController ()

@end

@implementation APSettingController

- (void)viewDidLoad
{
    [super viewDidLoad];

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



-(IBAction) toggleAudioQuality:(id)sender {
    
    NSLog(@"audioQuality changed %d", self.audioSwitch.on);
}

-(IBAction) toggleCellularData:(id)sender {
    NSLog(@"cellularData changed %d", self.cellularSwitch.on);
    
}
-(IBAction) toggleBackgroundDownload:(id)sender {
    NSLog(@"backgroundDownload changed %d", self.backgroundSwitch.on);

    
}


@end
