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
#import "CNVConnectivityManager.h"

@interface CNVMainTableViewController () <CNVHostListDelegate, CNVConnectivityDelegate>

@property (strong, nonatomic) MCPeerID *selectedPeer;
@property (strong, nonatomic) NSArray *tableMap;

@end

static NSString * const kNetworkCellIdentifier           = @"networkSettingsCell";
static NSString * const kCurrentConnectionCellIdentifier = @"currentConnectionCell";
static NSString * const kHostConnectionCellIdentifier    = @"hostConnectionCell";
static NSString * const kJoinConnectionCellIdentifier    = @"joinConnectionCell";
static NSString * const kConnectCellIdentifier           = @"connectCell";


@implementation CNVMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    [self initializeTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [CNVConnectivityManager sharedManager].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeTableView {
    NSDictionary *settingsSection = @{ kNetworkCellIdentifier: [NSIndexPath indexPathForRow:0 inSection:0] };
    
    
    NSDictionary *connectionSection = @{ kCurrentConnectionCellIdentifier : [NSIndexPath indexPathForRow:0 inSection:1],
                                         kHostConnectionCellIdentifier    : [NSIndexPath indexPathForRow:1 inSection:1],
                                         kJoinConnectionCellIdentifier    : [NSIndexPath indexPathForRow:2 inSection:1],
                                         kConnectCellIdentifier           : [NSIndexPath indexPathForRow:3 inSection:1],
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = tableView.rowHeight;
    
    NSIndexPath *connectIndexPath = self.tableMap[1][kConnectCellIdentifier];
    if ([indexPath isEqual:connectIndexPath] && self.selectedPeer == nil) {
        height = 0;
    }
    
    return height;
}



#pragma mark - Delegates

- (void)hostList:(CNVHostListTableViewController *)hostList didSelectPeerToConnect:(MCPeerID *)peerID {
    self.selectedPeer = peerID;
    
    UITableViewCell *currentConnectionCell = [self.tableView cellForRowAtIndexPath:self.tableMap[1][kJoinConnectionCellIdentifier]];
    currentConnectionCell.textLabel.text = peerID ? peerID.displayName : @"Search for others";
    
    [self.tableView reloadData];
}


- (void)browserLostPeer:(MCPeerID *)peerID {
    if ((uint32_t)peerID.hash == (uint32_t)self.selectedPeer.hash) {
        self.selectedPeer = nil;
        
        UITableViewCell *currentConnectionCell = [self.tableView cellForRowAtIndexPath:self.tableMap[1][kJoinConnectionCellIdentifier]];
        currentConnectionCell.textLabel.text = @"Search for others";
        
        [self.tableView reloadData];
    }
}



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
