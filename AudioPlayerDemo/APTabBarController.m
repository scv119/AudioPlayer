//
//  APTabBarController.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-9-16.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APTabBarController.h"

@interface APTabBarController ()

@end

@implementation APTabBarController

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
	UITabBarItem *globalItem = [[self.tabBar items] objectAtIndex:0];
    UITabBarItem *myItem = [[self.tabBar items] objectAtIndex:1];
    UITabBarItem *settingItem = [[self.tabBar items] objectAtIndex:2];
    
//    [globalItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_global.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_global_unactive.png"]];
//    [myItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_my.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_my_unactive.png"]];
//    [settingItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_setting.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_setting_unactive.png"]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
