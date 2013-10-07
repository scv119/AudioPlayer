//
//  APMyFileViewController.m
//  AudioPlayerDemo
//
//  Created by shen chen on 13-10-1.
//  Copyright (c) 2013年 me.scv119. All rights reserved.
//

#import "APMyFileViewController.h"
#import "APFileManager.h"
#import "util.h"
#import "APAudioTableCell.h"
#import "APAudioFile.h"
#import "APAudioPlayerViewController.h"

@interface APMyFileViewController ()

@property (nonatomic, strong) NSMutableArray *downloading;
@property (nonatomic, strong) NSMutableArray *finished;
@property (nonatomic, strong) APFileManager *fileManager;
@property (nonatomic, strong) NSMutableArray *current;
@property (nonatomic, strong) UIBarButtonItem *playButton;

@end

@implementation APMyFileViewController

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
    
    UIImage *playImg = [UIImage imageNamed:@"playnow.png"];
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playBtn.bounds = CGRectMake( 0, 0, playImg.size.width, playImg.size.height );
    [playBtn setImage:playImg forState:UIControlStateNormal];
    
    self.playButton= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playButtonClicked)];
    self.playButton.tintColor = [UIColor darkGrayColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerNotification:) name:playerNotification object:nil];
    
    
    self.fileManager = [APFileManager instance];
    self.downloading = self.fileManager.downloading;
    self.finished = self.fileManager.finished;
    self.current = self.finished;
    
    [self.tableView setSeparatorColor:UIColorFromRGB(0xc1c1c2)];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    
    [self.segmentControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDownloading:) name:downloadingListAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDownloading:) name:downloadingListRemovedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addFinished:) name:finishedListAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeFinished:) name:finishedListRemovedNotification object:nil];

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
    return [self.current count];
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
    
    APAudioFile *file = [self.current objectAtIndex:indexPath.row];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 69;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"clicked");
    APAudioPlayerViewController *playerView = [APAudioPlayerViewController getInstance];
    playerView.previousNav = [self navigationController];
    APAudioFile *file = [self.current objectAtIndex:indexPath.row];
    NSURL *localStorage = nil;
    NSLog(@"%d %d", file.status, FINISHED);
    NSLog(@"%@", file.path);
    if (file.status == FINISHED) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:file.path];
        localStorage = [[NSURL alloc] initFileURLWithPath: path];
        //        NSLog(@"%@ %@", path, [localStorage description]);
        
    }
    [playerView setAudioFile: file withLocalStorage:localStorage withPlayList:self.current];
    [[self navigationController] presentViewController:playerView animated:YES completion:nil];
    [playerView playButtonClicked:nil];
}

-(void) segmentAction:(UISegmentedControl *) seg
{
    NSInteger index = seg.selectedSegmentIndex;
    NSLog(@"segment %d selected", index);
    self.current = (index == 0?self.finished : self.downloading);
    [self.tableView reloadData];
}

-(void) addDownloading:(NSNotification *)noti
{
    if (self.segmentControl.selectedSegmentIndex == 1) {
        NSNumber *value = noti.object;
         NSLog(@"added %d item from table view", value.intValue);
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[value intValue] inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void) removeDownloading:(NSNotification *)noti
{
    if (self.segmentControl.selectedSegmentIndex == 1) {
        NSNumber *value = noti.object;
         NSLog(@"removed %d item from table view", value.intValue);
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[value intValue] inSection:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}

-(void) addFinished:(NSNotification *)noti
{
    if (self.segmentControl.selectedSegmentIndex == 0) {
        NSNumber *value = noti.object;
        NSLog(@"added %d item from table view", value.intValue);
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[value intValue] inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void) removeFinished:(NSNotification *)noti
{
    if (self.segmentControl.selectedSegmentIndex == 0) {
        NSNumber *value = noti.object;
         NSLog(@"removed %d item from table view", value.intValue);
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[value intValue] inSection:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
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

@end
