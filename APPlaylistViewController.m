//
//  APPlaylistViewController.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-7-29.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APPlaylistViewController.h"
#import "AFJSONRequestOperation.h"
#import "APFileManager.h"
#import "MBProgressHUD.h"

@interface APPlaylistViewController ()

@property (nonatomic, strong) NSMutableArray *audioList;
@property (nonatomic, strong) APFileManager *fileManager;

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
    navigationBar.topItem.title = @"化性谈";
    UIBarButtonItem *buttionItem = [navigationBar.topItem rightBarButtonItem];
    [self.tableView setSeparatorColor:UIColorFromRGB(0xc1c1c2)];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    
    self.audioList = [[NSMutableArray alloc] init];
    self.fileManager = [APFileManager instance];
    [self loadFeed];
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
    NSLog(@"clicked");
    APAudioPlayerViewController *playerView = [APAudioPlayerViewController getInstance];
    playerView.previousNav = [self navigationController];
    [playerView setAudioFile: [self.audioList objectAtIndex:indexPath.row] withLocalStorage:nil];
    [[self navigationController] presentViewController:playerView animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 69;
}

-(void) loadFeed
{
    MBProgressHUD *hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"加载中";
    NSURL *url = [NSURL URLWithString:@"http://huaxingtan.cn/api/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"fetch feed success");
        NSArray *array = (NSArray *)JSON;
        [self.audioList removeAllObjects];
        for (id item in array) {
            NSDictionary *dict = (NSDictionary*) item;
            APAudioFile *file = [APAudioFile instanceByDict:dict];
            APAudioFile *managedFile = [self.fileManager getFile:file.fileId];
            if (managedFile != nil) {
                [file updateByItem:managedFile];
            }
            [self.audioList addObject: file];
        }
        [self.tableView reloadData];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // Do something...
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"fetch feed failed");
        hud.labelText = @"加载失败";
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // Do something...
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }];
    
    [operation start];
    
}

@end
