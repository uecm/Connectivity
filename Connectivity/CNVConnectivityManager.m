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
        self.acceptedPeers = @[].mutableCopy;
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


- (void)invitePeer:(MCPeerID *)peer {
    self.session = [[MCSession alloc] initWithPeer:self.localPeerID];
    [self.browser invitePeer:peer toSession:self.session withContext:nil timeout:20];
}



#pragma mark - Advertising


- (void)startAdvertising {
    if (!self.advertiser) {
        [self initializeNearbyServiceAdvertizer];
    }
    [_advertiser startAdvertisingPeer];
    _advertising = true;
}

- (void)endAdvertising {
    self.isAdvertising ? [_advertiser stopAdvertisingPeer] : 0x0;
    _advertising = false;
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
                    didReceiveInvitationFromPeer:(MCPeerID *)peerID
                                     withContext:(NSData *)context
                               invitationHandler:(void (^)(BOOL, MCSession * _Nullable))invitationHandler {
    
    if ([_acceptedPeers containsObject:peerID]) {
        invitationHandler(false, nil);
    }
    else if ([self.delegate respondsToSelector:@selector(advertiserDidReceiveInvintationFromPeer:invintationHandler:)]) {
        [self.delegate advertiserDidReceiveInvintationFromPeer:peerID invintationHandler:invitationHandler];
    }
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    NSLog(@"Unable to start advertising peer. Error: %@", error );
    if ([self.delegate respondsToSelector:@selector(advertiserFailedStart)]) {
        [self.delegate advertiserFailedStart];
    }
}



#pragma mark - Session


- (void)invitePeerToSession:(MCPeerID *)peer {
    
    BOOL isMe = (uint32_t)self.localPeerID.hash == (uint32_t)peer.hash;
    if (isMe) {
        return;
    }
    
    if (!_session) {
        self.session = [[MCSession alloc] initWithPeer:self.localPeerID];
    }
    [self.browser invitePeer:peer toSession:self.session withContext:nil timeout:15];
}


// Remote peer changed state.
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
}

// Received data from remote peer.
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    
}

// Received a byte stream from remote peer.
- (void)    session:(MCSession *)session
   didReceiveStream:(NSInputStream *)stream
           withName:(NSString *)streamName
           fromPeer:(MCPeerID *)peerID {
    
}

// Start receiving a resource from remote peer.
- (void)                    session:(MCSession *)session
  didStartReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                       withProgress:(NSProgress *)progress {
    
}

// Finished receiving a resource from remote peer and saved the content
// in a temporary location - the app is responsible for moving the file
// to a permanent location within its sandbox.
- (void)                    session:(MCSession *)session
 didFinishReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                              atURL:(NSURL *)localURL
                          withError:(nullable NSError *)error {
    
}

// Made first contact with peer and have identity information about the
// remote peer (certificate may be nil).
- (void)        session:(MCSession *)session
  didReceiveCertificate:(nullable NSArray *)certificate
               fromPeer:(MCPeerID *)peerID
     certificateHandler:(void (^)(BOOL accept))certificateHandler {
    
}





@end
