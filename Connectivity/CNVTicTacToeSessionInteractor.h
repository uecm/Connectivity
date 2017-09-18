//
//  CNVTicTacToeSessionInteractor.h
//  Connectivity
//
//  Created by user on 9/15/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNVConnectivityManager.h"


@protocol CNVTicTacToeGameSessionDelegate <NSObject>
@optional

- (void)peer:(MCPeerID *)peerID didCreateGameWithParameters:(NSDictionary *)parameters;
- (void)peer:(MCPeerID *)peerID didEnterGameSessionWithParameters:(NSDictionary *)parameters;
- (void)peerDidLeftGameSession:(MCPeerID *)peerID;
- (void)peer:(MCPeerID *)peer didActionWithParameters:(NSDictionary *)parameters;
- (void)peerDidSendPlayAgainMessage:(MCPeerID *)peer;

@end




@interface CNVTicTacToeSessionInteractor : NSObject

@property (weak, nonatomic) id<CNVTicTacToeGameSessionDelegate> delegate;


@property (strong, nonatomic) NSDictionary *currentPlayerPreferences;
@property (strong, nonatomic) NSDictionary *opponentPlayerPreferences;

@property (strong, nonatomic) MCPeerID *opponent;
@property (strong, nonatomic) NSMutableDictionary *gameStatistics;
@property (assign, nonatomic, getter=isGameOwner) BOOL gameOwner;


- (void)sendCreatedGameMessageWithParameters:(NSDictionary *)parameters;
- (void)sendJoinGameMessageWithParameters:(NSDictionary *)parameters;
- (void)sendPerformedActionMessageWithParameters:(NSDictionary *)parameters;
- (void)sendLeftGameMessage;
- (void)sendPlayAgainMessage;

@end
 
