//
//  CNVHostListTableViewController.m
//  Connectivity
//
//  Created by user on 9/8/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import "CNVHostListTableViewController.h"
#import "CNVConnectivityManager.h"
#import <Colours.h>

@interface CNVHostListTableViewController () <CNVConnectivityDelegate>

@property (strong, nonatomic) NSArray<MCPeerID *> *peers;

@end


static NSString * const kServiceType = @"CNV-service";
static NSString * const kPeerCellIdentifier = @"peerCell";


@implementation CNVHostListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(donePressed:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    [self addActivityIndicatorToTitle];
    [self startBrowsing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startBrowsing {
    self.peers = @[];
    [CNVConnectivityManager sharedManager].delegate = self;
    [[CNVConnectivityManager sharedManager] startBrowsing];
}



#pragma mark - Multipeer Connectivity Delegate

- (void)browserFoundPeer:(MCPeerID *)peerID {
    self.peers = [CNVConnectivityManager sharedManager].peers;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.peers.count - 1 inSection:0];
    
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)browserLostPeer:(MCPeerID *)peerID {
    for (MCPeerID *peer in self.peers) {
        if ((uint32_t)peer.hash == (uint32_t)peerID.hash) {
            NSInteger index = [self.peers indexOfObject:peer];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            
            self.peers = [CNVConnectivityManager sharedManager].peers;
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            
            return;
        }
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [CNVConnectivityManager sharedManager].peers.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPeerCellIdentifier forIndexPath:indexPath];
    
    MCPeerID *peer = [CNVConnectivityManager sharedManager].peers[indexPath.row];
    cell.textLabel.text = peer.displayName;
    
    if ([peer.displayName isEqualToString:self.selectedPeer.displayName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.selectedPeer = [CNVConnectivityManager sharedManager].peers[indexPath.row];
}


- (void)addActivityIndicatorToTitle {
    UIView *titleView = [[UIView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] init];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    titleLabel.text = self.navigationItem.title;
    [titleLabel sizeToFit];
    
    activityIndicator.color = [UIColor coolGrayColor];
    
    float width = CGRectGetWidth(titleLabel.frame) + CGRectGetWidth(activityIndicator.frame) + 2; // 2 - indent between activity indicator and title
    float height = CGRectGetHeight(titleLabel.frame);
    
    titleView.frame = CGRectMake(0, 0, width, height);
    [titleView addSubview:activityIndicator];
    [titleView addSubview:titleLabel];
    
    activityIndicator.center = CGPointMake(CGRectGetMidX(activityIndicator.frame), height/2);
    titleLabel.center = CGPointMake(width - CGRectGetMidX(titleLabel.frame) + 2, height/2);
    
    [activityIndicator startAnimating];
    self.navigationItem.titleView = titleView;
}


- (void)donePressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(hostList:didSelectPeerToConnect:)]) {
        [self.delegate hostList:self didSelectPeerToConnect:self.selectedPeer];
    }
    [self.navigationController popViewControllerAnimated:true];
}


@end
