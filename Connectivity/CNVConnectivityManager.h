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

- (void)browserDidConnectToPeer:(MCPeerID *)peer;
- (void)browserDidDisconnectFromPeer:(MCPeerID *)peer;

- (void)advertiserDidConnectToPeer:(MCPeerID *)peer;
- (void)advertiserDidDisconnectFromPeer:(MCPeerID *)peer;

- (void)session:(MCSession *)session didReceiveMessage:(NSString *)message fromPeer:(MCPeerID *)peer;

@end



@interface CNVConnectivityManager : NSObject <MCNearbyServiceBrowserDelegate, MCSessionDelegate, MCAdvertiserAssistantDelegate>

@property (strong, nonatomic) MCPeerID *localPeerID;
@property (strong, nonatomic) MCSession *session;

@property (strong, nonatomic) MCNearbyServiceBrowser *browser;
@property (strong, nonatomic) MCAdvertiserAssistant *advertiserAssistant;

@property (weak, nonatomic)   id<CNVConnectivityDelegate> delegate;



@property (strong, nonatomic) NSArray<MCPeerID *> *peers;
@property (strong, nonatomic) NSMutableArray<MCPeerID *> *acceptedPeers;
@property (copy, nonatomic)   NSString *broadcastingDeviceName;

@property (assign, nonatomic, getter=isAdvertising) BOOL advertising;
@property (assign, nonatomic, getter=isBrowsing)    BOOL browsing;
@property (assign, nonatomic, getter=isConnected)   BOOL connected;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)sharedManager;
- (void)setLocalPeerIDWithName:(NSString *)name;


- (void)startBrowsing;
- (void)endBrowsing;

- (void)startAdvertising;
- (void)endAdvertising;

- (void)invitePeerToSession:(MCPeerID *)peer;

- (BOOL)sendMessage:(NSString *)message toPeer:(MCPeerID *)peer;

@end
