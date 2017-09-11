//
//  CNVConnectivityManager.h
//  Connectivity
//
//  Created by user on 9/8/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol CNVConnectivityDelegate <NSObject>
@optional

- (void)browserFoundPeer:(MCPeerID *)peerID;
- (void)browserLostPeer:(MCPeerID *)peerID;

- (void)advertiserDidReceiveInvintationFromPeer:(MCPeerID *)peerID invintationHandler:(void (^)(BOOL, MCSession *))invitationHandler;
- (void)advertiserFailedStart;
@end



@interface CNVConnectivityManager : NSObject <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate, MCAdvertiserAssistantDelegate>

@property (strong, nonatomic) MCPeerID *localPeerID;
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (strong, nonatomic) MCNearbyServiceBrowser *browser;

@property (weak, nonatomic) id<CNVConnectivityDelegate> delegate;
@property (strong, nonatomic) NSArray<MCPeerID *> *peers;

@property (assign, nonatomic, getter=isAdvertising) BOOL advertising;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)sharedManager;



- (void)startBrowsing;
- (void)endBrowsing;

- (void)startAdvertising;
- (void)endAdvertising;

@end
