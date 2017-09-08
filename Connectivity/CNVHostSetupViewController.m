//
//  CNVHostSetupViewController.m
//  Connectivity
//
//  Created by user on 9/8/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import "CNVHostSetupViewController.h"
#import "CNVConnectivityManager.h"
#import <Colours.h>

@interface CNVHostSetupViewController () <CNVConnectivityDelegate>

@property (weak, nonatomic) IBOutlet UIButton *startAdvertisingButton;


@end


static NSString * const kServiceType = @"CNV-service";
static NSString * const kPeerCellIdentifier = @"peerCell";


@implementation CNVHostSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [CNVConnectivityManager sharedManager].delegate = self;
    
    self.startAdvertisingButton.layer.cornerRadius = 8.f;
    self.startAdvertisingButton.clipsToBounds = true;
    
    if ([CNVConnectivityManager sharedManager].advertiser) {
        [self setButtonStateAdvertising];
    }
    else {
        self.startAdvertisingButton.backgroundColor = [UIColor pastelBlueColor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startAdvertisingButtonPressed:(id)sender {
    [self setButtonStateAdvertising];
    [[CNVConnectivityManager sharedManager] startAdvertising];
}

-(void)advertiserDidReceiveInvintationFromPeer:(MCPeerID *)peerID invintationHandler:(void (^)(BOOL, MCSession *))invitationHandler {
    
}

- (void)advertiserFailedStart {
    [self setButtonStateFailed];
}



#pragma mark - Button States

- (void)setButtonStateAdvertising {
    UIButton *button = self.startAdvertisingButton;
    button.enabled = false;
    
    button.backgroundColor = [UIColor seafoamColor];
    [button setTitle:@"Advertising" forState:UIControlStateNormal];
}

- (void)setButtonStateFailed {
    UIButton *button = self.startAdvertisingButton;
    button.enabled = true;
    
    button.backgroundColor = [UIColor tomatoColor];
    [button setTitle:@"Failed" forState:UIControlStateNormal];
}

@end
