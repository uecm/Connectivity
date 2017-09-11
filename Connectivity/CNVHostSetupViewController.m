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
    
    if ([CNVConnectivityManager sharedManager].isAdvertising) {
        [self setButtonStateAdvertising];
    }
    else {
        [self setButtonStateDefault];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startAdvertisingButtonPressed:(id)sender {
    [self setButtonStateAdvertising];
    
    if ([CNVConnectivityManager sharedManager].isAdvertising == false) {
        [[CNVConnectivityManager sharedManager] startAdvertising];
        [self setButtonStateAdvertising];
    }
    else {
        [self showEndAdvertisingActionSheet];
    }
}

-(void)advertiserDidReceiveInvintationFromPeer:(MCPeerID *)peerID invintationHandler:(void (^)(BOOL, MCSession *))invitationHandler {
    
}

- (void)advertiserFailedStart {
    [self setButtonStateFailed];
}



#pragma mark - Button States

- (void)setButtonStateAdvertising {
    UIButton *button = self.startAdvertisingButton;
    
    button.backgroundColor = [UIColor seafoamColor];
    [button setTitle:@"Advertising" forState:UIControlStateNormal];
}

- (void)setButtonStateFailed {
    UIButton *button = self.startAdvertisingButton;
    
    button.backgroundColor = [UIColor tomatoColor];
    [button setTitle:@"Failed" forState:UIControlStateNormal];
}

- (void)setButtonStateDefault {
    UIButton *button = self.startAdvertisingButton;
    
    button.backgroundColor = [UIColor pastelBlueColor];
    [button setTitle:@"Start advertising" forState:UIControlStateNormal];
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
                                                          [alertController dismissViewControllerAnimated:true completion:nil];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [alertController dismissViewControllerAnimated:true completion:nil];
                                                      }]];
    
    [self presentViewController:alertController animated:true completion:nil];
}

@end
