//
//  APAppDelegate.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-7-29.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APAppDelegate.h"
#import "APDownloadManager.h"
#import "APFileManager.h"
#import "APNetworkManager.h"

@implementation APAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [TestFlight takeOff:@"351c4264-ba3e-46fc-969b-69d0c4aa5b06"];
//    [self listAllFonts];
    
//    UIImage *image = imageWithColor(UIColorFromRGB(0x3e3e47));
//    UIImage *navBackground = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    [[UINavigationBar appearance] setTitleTextAttributes:
//     [NSDictionary dictionaryWithObjectsAndKeys:
//      [UIColor whiteColor], UITextAttributeTextColor,
//      [UIFont fontWithName:@"STLiti" size:20], UITextAttributeFont,nil]];
//    [[UINavigationBar appearance] setBackgroundImage:navBackground forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor darkTextColor]];
    APDownloadManager *downloadManager = [APDownloadManager instance];
    [APFileManager instance];
    [downloadManager start];
    [APNetworkManager instance];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    APDownloadManager *downloadManager = [APDownloadManager instance];
    [downloadManager stop];
    APFileManager *fileManager = [APFileManager instance];
    [fileManager flush];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    APDownloadManager *downloadManager = [APDownloadManager instance];
    [downloadManager start];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    APDownloadManager *downloadManager = [APDownloadManager instance];
    [downloadManager stop];
    APFileManager *fileManager = [APFileManager instance];
    [fileManager flush];
}

- (void)listAllFonts
{
    NSArray *familyNames =[[NSArray alloc]initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily, indFont;

    
    for(indFamily=0;indFamily<[familyNames count];++indFamily)     
	{
		NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
        fontNames =[[NSArray alloc]initWithArray:[UIFont fontNamesForFamilyName:[familyNames objectAtIndex:indFamily]]];
		for(indFont=0; indFont<[fontNames count]; ++indFont)            
		{
			NSLog(@"\tFont name: %@",[fontNames objectAtIndex:indFont]);
        }
	}
}

@end
