//
//  APPlaylistViewController.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-7-29.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APPlaylistViewController.h"

@interface APPlaylistViewController ()

@property (nonatomic, strong) NSMutableArray *audioList;

@end

@implementation APPlaylistViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.topItem.title = @"化性谈——我的随身播经机";
    UIBarButtonItem *buttionItem = [navigationBar.topItem rightBarButtonItem];
    [self.tableView setSeparatorColor:UIColorFromRGB(0xc1c1c2)];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    
    self.audioList = [[NSMutableArray alloc] init];
    for (int i = 0; i < 5; ++ i) {
        APAudioFile *file = [[APAudioFile alloc] init];
        file.name = [NSString stringWithFormat:@"2013北京化性谈讲座第%d讲", i];
        file.author = @"孙景华居士";
        file.serialName = @"北京";
        file.serialNo = @"01";
        file.created = [[NSDate alloc] init];
        file.coverUrl = [[NSURL alloc] initWithString: @"http://124.205.11.211/static/cover.gif"];
        file.fileUrl  = [[NSURL alloc] initWithString: @"http://huaxingtan.cn/mp3/20130923/130801_001.mp3"];
        file.fileSize = 808639;
        file.detail = @"这是一个测试数据咿呀咿呀哟哟哟哟哦哟哟哟哟哟哟哟哟哟哟哟哦哟哟哟哟哟哟哟哟哟哟哟哦哟哟哟哟哟哟哟";
        file.hasLyric = (i%2 == 0);
        file.timeSpan = 10;
        [self.audioList addObject: file];
    }

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.audioList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    APAudioTableCell *cell;
    //cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    if (cell == nil) {
        cell = [[APAudioTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    APAudioFile *file = [self.audioList objectAtIndex:indexPath.row];
    
    [cell setAudio:file withDownloadBar:NO];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    APAudioPlayerViewController *playerView = [APAudioPlayerViewController getInstance];
    playerView.previousNav = [self navigationController];
    [playerView setAudioFile: [self.audioList objectAtIndex:indexPath.row] withLocalStorage:nil];
    [[self navigationController] presentViewController:playerView animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 69;
}

@end
