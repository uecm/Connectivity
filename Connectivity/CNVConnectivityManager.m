//
//  CNVConnectivityManager.m
//  Connectivity
//
//  Created by user on 9/8/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import "CNVConnectivityManager.h"

static NSString * const kServiceType = @"CNV-service";

@implementation CNVConnectivityManager


- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        [self initializeLocalPeerID];
        self.peers = @[];
    }
    return self;
}


+ (instancetype)sharedManager {
    static CNVConnectivityManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initPrivate];
    });
    return instance;
}


#pragma mark - Initializers

- (void)initializeLocalPeerID {
    NSString *UUIDString = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    NSString *deviceIdentifierSubstring = [UUIDString substringWithRange:NSMakeRange(0, 2)];
    NSString *deviceName = [UIDevice currentDevice].name;
    
    NSArray<NSString *> *objs = @[deviceName, deviceIdentifierSubstring];
    NSString *displayName = [objs componentsJoinedByString:@"-"];
    
    self.localPeerID = [[MCPeerID alloc] initWithDisplayName:displayName];
}

- (void)initializeNearbyServiceAdvertizer {
    if (_advertiser) {
        return;
    }
    self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.localPeerID
                                                        discoveryInfo:nil
                                                          serviceType:kServiceType];
    self.advertiser.delegate = self;
}

- (void)initializeNearbyServiceBrowser {
    if (_browser) {
        return;
    }
    self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.localPeerID serviceType:kServiceType];
    self.browser.delegate = self;
}



#pragma mark - Browsing


- (void)startBrowsing {
    if (!self.browser) {
        [self initializeNearbyServiceBrowser];
    }
    [self.browser startBrowsingForPeers];
}

- (void)endBrowsing {
    _browser ? [_browser stopBrowsingForPeers] : 0x0;
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info {
    [self addPeer:peerID];
    if ([self.delegate respondsToSelector:@selector(browserFoundPeer:)]) {
        [self.delegate browserFoundPeer:peerID];
    }
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    NSLog(@"Browser failed browsing peers with error: %@", error);
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    [self removePeer:peerID];
    if ([self.delegate respondsToSelector:@selector(browserLostPeer:)]) {
        [self.delegate browserLostPeer:peerID];
    }
}


- (void)addPeer:(MCPeerID *)peerID {
    NSMutableArray *mutableDataSource = [self.peers mutableCopy];
    [mutableDataSource addObject:peerID];
    self.peers = [mutableDataSource copy];
}

- (void)removePeer:(MCPeerID *)peerID {
    NSMutableArray *mutableDataSource = [self.peers mutableCopy];
    for (MCPeerID *peer in mutableDataSource) {
        if ([peerID isEqual:peer]) {
            [mutableDataSource removeObject:peer];
            self.peers = mutableDataSource.copy;
            break;
        }
    }
}


#pragma mark - Advertising


- (void)startAdvertising {
    if (!self.advertiser) {
        [self initializeNearbyServiceAdvertizer];
    }
    [_advertiser startAdvertisingPeer];
}

- (void)endAdvertising {
    _advertiser ? [_advertiser stopAdvertisingPeer] : 0x0;
    _advertiser = nil;
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
                    didReceiveInvitationFromPeer:(MCPeerID *)peerID
                                     withContext:(NSData *)context
                               invitationHandler:(void (^)(BOOL, MCSession * _Nullable))invitationHandler {
    
    if ([self.delegate respondsToSelector:@selector(advertiserDidReceiveInvintationFromPeer:invintationHandler:)]) {
        [self.delegate advertiserDidReceiveInvintationFromPeer:peerID invintationHandler:invitationHandler];
    }
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    NSLog(@"Unable to start advertising peer. Error: %@", error );
    if ([self.delegate respondsToSelector:@selector(advertiserFailedStart)]) {
        [self.delegate advertiserFailedStart];
    }
}

@end
