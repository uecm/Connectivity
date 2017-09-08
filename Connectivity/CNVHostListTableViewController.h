//
//  CNVHostListTableViewController.h
//  Connectivity
//
//  Created by user on 9/8/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CNVHostListTableViewController;
@class MCPeerID;


@protocol CNVHostListDelegate <NSObject>

- (void)hostList:(CNVHostListTableViewController *)hostList didSelectPeerToConnect:(MCPeerID *)peerID;

@end



@interface CNVHostListTableViewController : UITableViewController

@property (weak, nonatomic) id<CNVHostListDelegate> delegate;
@property (strong, nonatomic) MCPeerID *selectedPeer;



@end
