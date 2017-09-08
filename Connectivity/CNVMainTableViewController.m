//
//  CNVMainTableViewController.m
//  Connectivity
//
//  Created by user on 9/8/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import "CNVMainTableViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "CNVHostListTableViewController.h"


@interface CNVMainTableViewController () <CNVHostListDelegate>

@property (strong, nonatomic) MCPeerID *selectedPeer;
@property (strong, nonatomic) NSArray *tableMap;

@end

static NSString * const kNetworkCellIdentifier = @"networkSettingsCell";
static NSString * const kCurrentConnectionCellIdentifier = @"currentConnectionCell";
static NSString * const kHostConnectionCellIdentifier = @"hostConnectionCell";
static NSString * const kJoinConnectionCellIdentifier = @"joinConnectionCell";


@implementation CNVMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    [self initializeTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeTableView {
    NSDictionary *settingsSection = @{ kNetworkCellIdentifier: [NSIndexPath indexPathForRow:0 inSection:0] };
    
    
    NSDictionary *connectionSection = @{ kCurrentConnectionCellIdentifier : [NSIndexPath indexPathForRow:0 inSection:1],
                                         kHostConnectionCellIdentifier    : [NSIndexPath indexPathForRow:1 inSection:1],
                                         kJoinConnectionCellIdentifier    : [NSIndexPath indexPathForRow:2 inSection:1]
                                        };
    self.tableMap = @[settingsSection, connectionSection];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableMap ? self.tableMap.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.tableMap) {
        return 0;
    }
    
    return ((NSDictionary *)[self.tableMap objectAtIndex:section]).count;
}


-(void)hostList:(CNVHostListTableViewController *)hostList didSelectPeerToConnect:(MCPeerID *)peerID {
    self.selectedPeer = peerID;
    
    UITableViewCell *currentConnectionCell = [self.tableView cellForRowAtIndexPath:self.tableMap[1][kCurrentConnectionCellIdentifier]];
    currentConnectionCell.detailTextLabel.text = peerID ? peerID.displayName : @"No Connection";
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier" forIndexPath:indexPath];
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"hostListSegue"]) {
        CNVHostListTableViewController *destination = segue.destinationViewController;
        destination.selectedPeer = self.selectedPeer;
        destination.delegate = self;
    }
    
}


@end
