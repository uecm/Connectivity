//
//  CNVHostListTableViewController.m
//  Connectivity
//
//  Created by user on 9/8/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import "CNVHostListTableViewController.h"
#import "CNVConnectivityManager.h"

@interface CNVHostListTableViewController () <CNVConnectivityDelegate>

@end


static NSString * const kServiceType = @"CNV-service";
static NSString * const kPeerCellIdentifier = @"peerCell";


@implementation CNVHostListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self startBrowsing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)startBrowsing {
    [CNVConnectivityManager sharedManager].delegate = self;
    [[CNVConnectivityManager sharedManager] startBrowsing];
    
    
//    
//    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    activityIndicator.center = self.navigationItem.titleView.center;
//    //UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
//    
//    [self.navigationItem.titleView addSubview:activityIndicator];
//    
//    //[self.navigationItem setRightBarButtonItem:barButtonItem animated:true]; //navigationController.navigationItem.rightBarButtonItem = barButtonItem;
//    
//    [activityIndicator startAnimating];

}





#pragma mark - Multipeer Connectivity Delegate

- (void)browserFoundPeer:(MCPeerID *)peerID {
    //[self addPeerToDataSource:peerID];
    [self.tableView reloadData];
}

- (void)browserLostPeer:(MCPeerID *)peerID {
    //[self removePeerFromDataSource:peerID];
    [self.tableView reloadData];
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
    
    if ([self.delegate respondsToSelector:@selector(hostList:didSelectPeerToConnect:)]) {
        [self.delegate hostList:self didSelectPeerToConnect:self.selectedPeer];
    }
    
    [self.navigationController popViewControllerAnimated:true];
}




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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
