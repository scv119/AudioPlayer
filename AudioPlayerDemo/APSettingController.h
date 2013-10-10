//
//  APSettingController.h
//  AudioPlayerDemo
//
//  Created by shen chen on 13-7-29.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APSettingController : UITableViewController

//@property (nonatomic, strong) IBOutlet UISwitch *audioSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *cellularSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *backgroundSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *backgroundPlaySwith;
@property (nonatomic, strong) IBOutlet UITableViewCell *feedBackCell;


//-(IBAction) toggleAudioQuality:(id)sender;
-(IBAction) toggleCellularData:(id)sender;
-(IBAction) toggleBackgroundDownload:(id)sender;
-(IBAction) toggleBackgroundPlay:(id)sender;
@end
