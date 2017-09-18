//
//  CNVTicTacToeSessionInteractor.m
//  Connectivity
//
//  Created by user on 9/15/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import "CNVTicTacToeSessionInteractor.h"
#import "CNVConnectivityManager.h"

typedef NS_ENUM(NSInteger, GameSessionMessage) {
    GameSessionMessageCreated = 0,
    GameSessionMessageJoin,
    GameSessionMessageAction,
    GameSessionMessageLeave,
    GameSessionMessagePlayAgain
};

@interface CNVTicTacToeSessionInteractor () <CNVConnectivityDelegate>

@property (weak, nonatomic) CNVConnectivityManager *connectivityManager;

@end


static NSString * const kTicTacToeGameIdentifier = @"ticTacToeGameIdentifier";


@implementation CNVTicTacToeSessionInteractor


- (instancetype)init {
    self = [super init];
    if (self) {
        self.connectivityManager = [CNVConnectivityManager sharedManager];
        self.connectivityManager.delegate = self;
        self.opponent = self.connectivityManager.connectedPeers.firstObject;
    }
    return self;
}

- (instancetype)initWithCurrentPlayerPreferences:(NSDictionary *)currentPlayerPreferences {
    self = [self init];
    if (self) {
        self.currentPlayerPreferences = currentPlayerPreferences;
    }
    return self;
}

- (void)sendCreatedGameMessageWithParameters:(NSDictionary *)parameters {
    NSDictionary *createdGameParameters = @{
                                            @"destination"       : kTicTacToeGameIdentifier,
                                            @"message"           : @(GameSessionMessageCreated),
                                            @"player_parameters" : parameters
                                            };
    
    self.currentPlayerPreferences = parameters;
    self.gameOwner = true;
    [self.connectivityManager sendDictionaty:createdGameParameters toPeer:self.opponent];
    
    [NSTimer scheduledTimerWithTimeInterval:2 repeats:true block:^(NSTimer * _Nonnull timer) {
        if (self.opponentPlayerPreferences) {
            [timer invalidate];
        }
        else {
            [self.connectivityManager sendDictionaty:createdGameParameters toPeer:self.opponent];
        }
    }];
}


- (void)sendJoinGameMessageWithParameters:(NSDictionary *)parameters {
    NSDictionary *gameParameters = @{
                                            @"destination"       : kTicTacToeGameIdentifier,
                                            @"message"           : @(GameSessionMessageJoin),
                                            @"player_parameters" : parameters
                                            };
    
    self.currentPlayerPreferences = parameters;
    self.gameOwner = false;
    [self.connectivityManager sendDictionaty:gameParameters toPeer:self.opponent];
}

- (void)sendPerformedActionMessageWithParameters:(NSDictionary *)parameters {
    NSDictionary *actionParameters = @{
                                       @"destination"       : kTicTacToeGameIdentifier,
                                       @"message"           : @(GameSessionMessageAction),
                                       @"action_parameters" : parameters
                                       };
    [self.connectivityManager sendDictionaty:actionParameters toPeer:self.opponent];
}

- (void)sendLeftGameMessage {

    NSDictionary *leaveParameters = @{
                                      @"destination"       : kTicTacToeGameIdentifier,
                                      @"message"           : @(GameSessionMessageLeave)
                                      };
    
    self.opponentPlayerPreferences = nil;
    self.gameStatistics = nil;
    [self.connectivityManager sendDictionaty:leaveParameters toPeer:self.opponent];
}

- (void)sendPlayAgainMessage {
    NSDictionary *playAgainMessage = @{
                                       @"destination"       : kTicTacToeGameIdentifier,
                                       @"message"           : @(GameSessionMessagePlayAgain)
                                       };
    [self.connectivityManager sendDictionaty:playAgainMessage toPeer:self.opponent];
}





-(void)session:(MCSession *)session didReceiveDictionary:(NSDictionary *)dictionary fromPeer:(MCPeerID *)peer {
    if (![dictionary[@"destination"] isEqualToString:kTicTacToeGameIdentifier]) {
        return;
    }
    
    GameSessionMessage message = [dictionary[@"message"] integerValue];
    
    switch (message) {
            
        case GameSessionMessageCreated:
            self.opponentPlayerPreferences = dictionary[@"player_parameters"];
            self.opponent = peer;
            if ([self.delegate respondsToSelector:@selector(peer:didCreateGameWithParameters:)]) {
                [self.delegate peer:peer didCreateGameWithParameters:dictionary[@"player_parameters"]];
            }
            break;
            
        case GameSessionMessageJoin:    // Sent by Browser
            self.opponentPlayerPreferences = dictionary[@"player_parameters"];
            self.opponent = peer;
            if ([self.delegate respondsToSelector:@selector(peer:didEnterGameSessionWithParameters:)]) {
                [self.delegate peer:peer didEnterGameSessionWithParameters:self.opponentPlayerPreferences];
            }
            break;
            
        case GameSessionMessageLeave:
            
            self.gameStatistics = nil;
            self.opponentPlayerPreferences = nil;
            
            if ([self.delegate respondsToSelector:@selector(peerDidLeftGameSession:)]) {
                [self.delegate peerDidLeftGameSession:peer];
            }
            break;
            
        case GameSessionMessageAction:
            if ([self.delegate respondsToSelector:@selector(peer:didActionWithParameters:)]) {
                [self.delegate peer:peer didActionWithParameters:dictionary[@"action_parameters"]];
            }
            break;
            
        case GameSessionMessagePlayAgain:
            if ([self.delegate respondsToSelector:@selector(peerDidSendPlayAgainMessage:)]) {
                [self.delegate peerDidSendPlayAgainMessage:peer];
            }
            break;
        default:
            break;
    }
}


@end
