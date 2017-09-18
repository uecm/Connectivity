//
//  CNVMainTableViewController.m
//  Connectivity
//
//  Created by user on 9/8/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import "CNVMainTableViewController.h"
#import "CNVHostListTableViewController.h"
#import "CNVMessagePopoverViewController.h"
#import "CNVConnectivityManager.h"
#import "CNVTicTacToeViewController.h"

#import <SVProgressHUD.h>
#import <Colours.h>
#import <CRToast.h>


@interface CNVMainTableViewController () <CNVHostListDelegate, CNVConnectivityDelegate, CNVMessageComposerDelegate, UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *advertisingButton;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;

@property (strong, nonatomic) MCPeerID *selectedPeer;
@property (strong, nonatomic) NSArray *tableMap;

@end

static NSString * const kNetworkSettingsCellIdentifier   = @"networkSettingsCell";
static NSString * const kGeneralSettingsCellIdentifier   = @"generalSettingsCell";
static NSString * const kCurrentConnectionCellIdentifier = @"currentConnectionCell";
static NSString * const kHostConnectionCellIdentifier    = @"hostConnectionCell";
static NSString * const kJoinConnectionCellIdentifier    = @"joinConnectionCell";
static NSString * const kConnectCellIdentifier           = @"connectCell";
static NSString * const kSendMessageIdentifier           = @"sendMessageCell";
static NSString * const kTicTacToeIdentifier             = @"ticTacToeCell";


@implementation CNVMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self initializeTableView];
    [self setupAdvertisingButton];
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
    NSDictionary *settingsSection = @{
                                      kNetworkSettingsCellIdentifier : [NSIndexPath indexPathForRow:0 inSection:0],
                                      kGeneralSettingsCellIdentifier : [NSIndexPath indexPathForRow:1 inSection:0]
                                      };
    
    
    NSDictionary *connectionSection = @{
                                        kCurrentConnectionCellIdentifier : [NSIndexPath indexPathForRow:0 inSection:1],
                                        kHostConnectionCellIdentifier    : [NSIndexPath indexPathForRow:1 inSection:1],
                                        kJoinConnectionCellIdentifier    : [NSIndexPath indexPathForRow:2 inSection:1],
                                        kConnectCellIdentifier           : [NSIndexPath indexPathForRow:3 inSection:1],
                                        };
    
    NSDictionary *interactionSection = @{
                                         kSendMessageIdentifier : [NSIndexPath indexPathForRow:0 inSection:2],
                                         kTicTacToeIdentifier : [NSIndexPath indexPathForRow:1 inSection:2]
                                         };
    
    self.tableMap = @[settingsSection, connectionSection, interactionSection];
    
    [self setConnectButtonStateConnect];
    [self setRemoveButtonStateRemove];
    
    [self.tableView reloadData];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.tableMap) {
        return 0;
    }
    if ([CNVConnectivityManager sharedManager].isConnected) {
        return self.tableMap.count;
    }
    else {
        return self.tableMap.count - 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.tableMap) {
        return 0;
    }
    return ((NSDictionary *)[self.tableMap objectAtIndex:section]).count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CNVConnectivityManager *connectivityManager = [CNVConnectivityManager sharedManager];
    CGFloat height = tableView.rowHeight;
    
    NSIndexPath *connectIndexPath = self.tableMap[1][kConnectCellIdentifier];
    if ([indexPath isEqual:connectIndexPath] && self.selectedPeer == nil) {
        height = 0;
    }
    
    NSIndexPath *browseRowIndexPath = self.tableMap[1][kJoinConnectionCellIdentifier];
    if ([indexPath isEqual:browseRowIndexPath]) {
        height = connectivityManager.isAdvertising ? 0 : 44;
    }
    
    NSIndexPath *hostRowIndexPath = self.tableMap[1][kHostConnectionCellIdentifier];
    if ([indexPath isEqual:hostRowIndexPath]) {
        height = connectivityManager.isBrowsing && connectivityManager.isConnected ? 0 : 44;
    }
    
    
    return height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath == self.tableMap[2][kTicTacToeIdentifier]) {
        UIStoryboard *ticTacToeStoryboard = [UIStoryboard storyboardWithName:@"TicTacToe" bundle:nil];
        UINavigationController *destination = [ticTacToeStoryboard instantiateInitialViewController];
        
        [self.navigationController showViewController:destination sender:self];
    }
}



#pragma mark - Delegates

- (void)hostList:(CNVHostListTableViewController *)hostList didSelectPeerToConnect:(MCPeerID *)peerID {
    self.selectedPeer = peerID;
    
    [self updateJoinConnectionCell];
    [self.tableView reloadData];
}



- (void)messageComposer:(CNVMessagePopoverViewController *)composer DidFinishEditingWithMessage:(NSString *)message {
    if (message.length == 0) {
        return;
    }
    CNVConnectivityManager *manager = [CNVConnectivityManager sharedManager];
    [manager sendMessage:message toPeer:manager.connectedPeers.firstObject];
}


#pragma mark Browser

- (void)browserLostPeer:(MCPeerID *)peerID {
    if ((uint32_t)peerID.hash == (uint32_t)self.selectedPeer.hash) {
        self.selectedPeer = nil;
    
        [self updateCurrentConnectionCell];
        [self updateJoinConnectionCell];
        [[CNVConnectivityManager sharedManager] disconnectFromPeer:peerID];
        
        [self.tableView reloadData];
    }
}

- (void)browserDidStartConnectingToPeer:(MCPeerID *)peer {

}

- (void)browserDidConnectToPeer:(MCPeerID *)peer {
    [SVProgressHUD dismiss];
    
    [self setConnectButtonStateConnected];
    [self updateCurrentConnectionCell];
    [self setRemoveButtonStateDisconnect];
    
    [self.tableView reloadData];
}

- (void)browserDidDisconnectFromPeer:(MCPeerID *)peer {
    self.selectedPeer = nil;
    [self setConnectButtonStateConnect];
    [self updateCurrentConnectionCell];
    [self setRemoveButtonStateRemove];
    
    [self.tableView reloadData];
}


#pragma mark Advertiser

- (void)advertiserFailedStart {
    [self setButtonStateFailed];
}

- (void)advertiserDidStartConnectingToPeer:(MCPeerID *)peer {
    [self showConnectingHUDView];
}

- (void)advertiserDidConnectToPeer:(MCPeerID *)peer {
    [SVProgressHUD dismiss];
    
    [self updateCurrentConnectionCell];
    [self setRemoveButtonStateDisconnect];
    
    [self.tableView reloadData];
}

- (void)advertiserDidDisconnectFromPeer:(MCPeerID *)peer {
    [self updateCurrentConnectionCell];
    [self setRemoveButtonStateRemove];
    
    [self.tableView reloadData];
}


#pragma mark Session

- (void)session:(MCSession *)session didReceiveMessage:(NSString *)message fromPeer:(MCPeerID *)peer {
    [self showToastWithMessage:message fromSender:peer.displayName];
}






#pragma mark - Buttons

- (IBAction)connectPressed:(id)sender {
    if ([CNVConnectivityManager sharedManager].isConnected) {
        return;
    }
    
    [self showConnectingHUDView];
    [[CNVConnectivityManager sharedManager] invitePeerToSession:self.selectedPeer];
}


- (IBAction)removePressed:(id)sender {
    
    if ([CNVConnectivityManager sharedManager].isConnected) {
        [[CNVConnectivityManager sharedManager] disconnectFromPeer:self.selectedPeer];
        [self setRemoveButtonStateRemove];
    }
    else {
        self.selectedPeer = nil;
        
        [self setConnectButtonStateConnect];
        [self updateJoinConnectionCell];
        
        [self.tableView reloadData];
    }
}


- (IBAction)advertisingButtonPressed:(id)sender {
    if ([CNVConnectivityManager sharedManager].isAdvertising == false) {
        [[CNVConnectivityManager sharedManager] startAdvertising];
        
        [self setButtonStateAdvertising];
        self.selectedPeer = nil;
        
        [self.tableView reloadData];
    }
    else {
        [self showEndAdvertisingActionSheet];
    }
}




#pragma mark - Button States

- (void)setButtonStateAdvertising {
    UIButton *button = self.advertisingButton;
    
    button.backgroundColor = [UIColor seafoamColor];
    [button setTitle:@"Advertising" forState:UIControlStateNormal];
}

- (void)setButtonStateFailed {
    UIButton *button = self.advertisingButton;
    
    button.backgroundColor = [UIColor tomatoColor];
    [button setTitle:@"Failed" forState:UIControlStateNormal];
}

- (void)setButtonStateDefault {
    UIButton *button = self.advertisingButton;
    
    button.backgroundColor = [UIColor pastelBlueColor];
    [button setTitle:@"Start advertising" forState:UIControlStateNormal];
}


- (void)setConnectButtonStateConnect {
    [self.connectButton setTitleColor:[UIColor pastelBlueColor] forState:UIControlStateNormal];
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
}

- (void)setConnectButtonStateConnected {
    [self.connectButton setTitleColor:[UIColor seafoamColor] forState:UIControlStateNormal];
    [self.connectButton setTitle:@"Connected" forState:UIControlStateNormal];
}

- (void)setRemoveButtonStateRemove {
    [self.removeButton setTitleColor:[UIColor tomatoColor] forState:UIControlStateNormal];
    [self.removeButton setTitle:@"Remove" forState:UIControlStateNormal];
}

- (void)setRemoveButtonStateDisconnect {
    [self.removeButton setTitleColor:[UIColor tomatoColor] forState:UIControlStateNormal];
    [self.removeButton setTitle:@"Disconnect" forState:UIControlStateNormal];
}


#pragma mark - Misc


- (void)showConnectingHUDView {
    [SVProgressHUD showWithStatus:@"Connecting"];
}


- (void)showToastWithMessage:(NSString *)message fromSender:(NSString *)sender {
    
    NSString *text = [NSString stringWithFormat:@"%@: %@", sender, message];
    
    [CRToastManager showNotificationWithOptions:@{kCRToastTextKey : text} completionBlock:nil];
}


- (void)setupAdvertisingButton {
    self.advertisingButton.layer.cornerRadius = 8.f;
    self.advertisingButton.clipsToBounds = true;
    
    if ([CNVConnectivityManager sharedManager].isAdvertising) {
        [self setButtonStateAdvertising];
    }
    else {
        [self setButtonStateDefault];
    }
}


- (void)updateCurrentConnectionCell {
    UITableViewCell *currentConnectionCell = [self.tableView cellForRowAtIndexPath:self.tableMap[1][kCurrentConnectionCellIdentifier]];
    if (!currentConnectionCell) {
        return;
    }
    
    MCPeerID *currentPeer = [CNVConnectivityManager sharedManager].connectedPeers.firstObject;
    NSString *currerntConnectionText = currentPeer ? currentPeer.displayName : @"No connection";
    currentConnectionCell.detailTextLabel.text = currerntConnectionText;
}


- (void)updateJoinConnectionCell {
    UITableViewCell *joinConnectionCell = [self.tableView cellForRowAtIndexPath:self.tableMap[1][kJoinConnectionCellIdentifier]];
    if (!joinConnectionCell) {
        return;
    }
    joinConnectionCell.textLabel.text = self.selectedPeer ? self.selectedPeer.displayName : @"Search for others";
}



- (void)showEndAdvertisingActionSheet {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:@"Are you sure you want to stop advertising?"
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Stop"
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [[CNVConnectivityManager sharedManager] endAdvertising];
                                                          [self setButtonStateDefault];
                                                        
                                                          
                                                          [self.tableView reloadData];
                                                          
                                                          [alertController dismissViewControllerAnimated:true completion:nil];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [alertController dismissViewControllerAnimated:true completion:nil];
                                                      }]];
    
    [self presentViewController:alertController animated:true completion:nil];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"hostListSegue"]) {
        CNVHostListTableViewController *destination = segue.destinationViewController;
        destination.selectedPeer = self.selectedPeer;
        destination.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"messagePopover"]) {
        CNVMessagePopoverViewController *destination = segue.destinationViewController;
        destination.popoverPresentationController.delegate = self;
        destination.popoverPresentationController.sourceView = sender;
        destination.preferredContentSize = CGSizeMake(300, 400);
        destination.delegate = self;
        destination.receiverName = [CNVConnectivityManager sharedManager].connectedPeers.firstObject.displayName;
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}


@end
