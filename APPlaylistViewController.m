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
@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, strong) UIBarButtonItem *playButton;

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
    
    if (refreshTableView == nil) {
        refreshTableView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0,  0 - self.tableView.bounds.size.height, self.tableView.bounds.size.width,  self.tableView.bounds.size.height)];
        refreshTableView.delegate = self;
        [self.tableView addSubview:refreshTableView];
        
        [refreshTableView refreshLastUpdatedDate];
    }

    self.playButton= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playButtonClicked)];
    self.playButton.tintColor = [UIColor darkGrayColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerNotification:) name:playerNotification object:nil];
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.topItem.title = @"化性谈";
    [self.tableView setSeparatorColor:UIColorFromRGB(0xc1c1c2)];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    
    self.audioList = [[NSMutableArray alloc] init];
    self.fileManager = [APFileManager instance];
    [self reloadTableViewDataSource:YES];
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
    APAudioFile *file = [self.audioList objectAtIndex:indexPath.row];
    NSURL *localStorage = nil;
    NSLog(@"%d %d", file.status, FINISHED);
    NSLog(@"%@", file.path);
    if (file.status == FINISHED) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:file.path];
        localStorage = [[NSURL alloc] initFileURLWithPath: path];
//        NSLog(@"%@ %@", path, [localStorage description]);
        
    }
    APAudioPlayerViewController *playerView =  [APAudioPlayerViewController getInstance];
    if (![APAudioPlayerViewController isCurrentPlaying:file.fileId]) {
        [playerView reset];
        [playerView setAudioFile: file withLocalStorage:localStorage withPlayList:self.audioList];
    } else {
        [playerView changePlayList:self.audioList];
    }
    playerView.previousNav = [self navigationController];
    [[self navigationController] presentViewController:playerView animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 69;
}

-(void) loadFeedFirstTime:(BOOL) firstTime
{
    MBProgressHUD *hud = nil;
    if (firstTime) {
        hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"正在加载";
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://huaxingtan.cn/api/?version=%@", version]];
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
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.2];
        
        if (firstTime) {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Do something...
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"fetch feed failed");
        MBProgressHUD *hud1 = hud;
        if (hud1 == nil)
            hud1 =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud1.mode = MBProgressHUDModeText;
        hud1.labelText = @"加载失败";
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // Do something...
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.2];
    }];
    
    [operation start];
    
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource:(BOOL) firstTime{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    if (_reloading == NO) {
    _reloading = YES;
    [self loadFeedFirstTime:firstTime];
    }
    
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    [refreshTableView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [refreshTableView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [refreshTableView egoRefreshScrollViewDidEndDragging:scrollView];
    
}



#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSource:NO];
    
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
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
