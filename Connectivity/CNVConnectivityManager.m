//
//  CNVConnectivityManager.m
//  Connectivity
//
//  Created by user on 9/8/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import "CNVConnectivityManager.h"

static NSString * const kServiceType = @"CNV-game-srvc";


@implementation CNVConnectivityManager
@synthesize session = _session;


- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        [self initializeLocalPeerID];
        self.peers = @[];
        self.connectedPeers = @[].mutableCopy;
        self.broadcastingDeviceName = [UIDevice currentDevice].name;
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


- (void)setLocalPeerIDWithName:(NSString *)name {
    MCPeerID *newPeer = [[MCPeerID alloc] initWithDisplayName:name];
    self.localPeerID = newPeer;
}


#pragma mark - Initializers

- (void)initializeLocalPeerID {
    
    NSString *displayName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    
    if (!displayName) {
        NSString *UUIDString = [[UIDevice currentDevice] identifierForVendor].UUIDString;
        NSString *deviceIdentifierSubstring = [UUIDString substringWithRange:NSMakeRange(0, 2)];
        NSString *deviceName = [UIDevice currentDevice].name;
        
        NSArray<NSString *> *objs = @[deviceName, deviceIdentifierSubstring];
        displayName = [objs componentsJoinedByString:@"-"];
    }
    
    self.localPeerID = [[MCPeerID alloc] initWithDisplayName:displayName];
}


- (void)initializeAdvertizerAssistant {
    if (_advertiserAssistant) {
        return;
    }
    NSDictionary *discoveryInfo = @{
                                    @"id" : [UIDevice currentDevice].identifierForVendor.UUIDString,
                                    @"creationDate" : [NSString stringWithFormat:@"%f", [NSDate date].timeIntervalSince1970],
                                    @"device" : _broadcastingDeviceName
                                    };
    
    _advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:kServiceType discoveryInfo:discoveryInfo session:self.session];
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
    self.browsing = true;
}

- (void)endBrowsing {
    _browser ? [_browser stopBrowsingForPeers] : 0x0;
    self.browsing = false;
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
    if (!_advertiserAssistant) {
        [self initializeAdvertizerAssistant];
    }
    _advertiserAssistant.delegate = self;
    [_advertiserAssistant start];
    self.advertising = true;
}

- (void)endAdvertising {
    [_advertiserAssistant stop];
    self.advertising = false;
}

- (void)advertiserAssistantWillPresentInvitation:(MCAdvertiserAssistant *)advertiserAssistant {
    
}

- (void)advertiserAssistantDidDismissInvitation:(MCAdvertiserAssistant *)advertiserAssistant {
    
}








#pragma mark - Session

- (MCSession *)session {
    if (!_session) {
        _session = [[MCSession alloc] initWithPeer:self.localPeerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
        _session.delegate = self;
    }
    return _session;
}

-(void)setSession:(MCSession *)session {
    _session = session;
}


- (void)invitePeerToSession:(MCPeerID *)peer {
    
    BOOL isMe = (uint32_t)self.localPeerID.hash == (uint32_t)peer.hash;
    if (isMe) {
        return;
    }
    [self.browser invitePeer:peer toSession:self.session withContext:nil timeout:30];
}


- (BOOL)sendMessage:(NSString *)message toPeer:(MCPeerID *)peer {
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    NSError *error = nil;
    
    BOOL result = [self.session sendData:data toPeers:@[peer] withMode:MCSessionSendDataReliable error:&error];
    if (!result) {
        NSLog(@"An error occurred while trying to send message to peer:%@", error);
    }
    return result;
}


- (BOOL)sendDictionaty:(NSDictionary *)dictionary toPeer:(MCPeerID *)peer {
    NSData *dictData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    NSError *error = nil;
    
    BOOL result = [self.session sendData:dictData toPeers:@[peer] withMode:MCSessionSendDataReliable error:&error];
    if (!result) {
        NSLog(@"An error occurred while trying to send dictionary to peer:%@", error);
    }
    return result;
}



// Remote peer changed state.
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (state) {
            case MCSessionStateConnected:
                _connected = true;
                [self.connectedPeers addObject:peerID];
                
                if (self.isBrowsing && [self.delegate respondsToSelector:@selector(browserDidConnectToPeer:)]) {
                    [self.delegate browserDidConnectToPeer:peerID];
                }
                else if (self.isAdvertising && [self.delegate respondsToSelector:@selector(advertiserDidConnectToPeer:)]) {
                    [self.delegate advertiserDidConnectToPeer:peerID];
                }
                break;
                
            case MCSessionStateConnecting:
                break;
                
                
            case MCSessionStateNotConnected:
                _connected = false;
                [self removePeerFromconnectedPeers:peerID];
                if (self.isBrowsing && [self.delegate respondsToSelector:@selector(browserDidDisconnectFromPeer:)]) {
                    [self.delegate browserDidDisconnectFromPeer:peerID];
                }
                else if (self.isAdvertising && [self.delegate respondsToSelector:@selector(advertiserDidDisconnectFromPeer:)]) {
                    [self.delegate advertiserDidDisconnectFromPeer:peerID];
                }
                break;
            default:
                break;
        }
    });
    
}

// Received data from remote peer.
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    
    id unarchivedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if ([unarchivedData isKindOfClass:[NSString class]]) {
        NSString *message = (NSString *)unarchivedData;
        if ([self.delegate respondsToSelector:@selector(session:didReceiveMessage:fromPeer:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate session:session didReceiveMessage:message fromPeer:peerID];
            });
        }
    }
    else if ([unarchivedData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionaty = (NSDictionary *)unarchivedData;
        if ([self.delegate respondsToSelector:@selector(session:didReceiveDictionary:fromPeer:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate session:session didReceiveDictionary:dictionaty fromPeer:peerID];
            });
        }
    }
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

- (void)removePeerFromconnectedPeers:(MCPeerID *)peer {
    for (MCPeerID *acceptedPeer in self.connectedPeers) {
        if ((uint32_t)acceptedPeer.hash == (uint32_t)peer.hash) {
            [self.connectedPeers removeObject:acceptedPeer];
            return;
        }
    }
}


@end
