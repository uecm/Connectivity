//
//  CNVTicTacToeViewController.m
//  Connectivity
//
//  Created by user on 9/14/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import "CNVTicTacToeViewController.h"
#import "CNVTicTacToeCollectionViewCell.h"
#import "CNVConnectivityManager.h"

#import <CRToast.h>
#import <Colours.h>

typedef NS_ENUM(NSInteger, GameMessageType) {
    GameMessageTypeEndTurn = 0,
    GameMessageTypeNewGame
};


@interface CNVTicTacToeViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CNVConnectivityDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *playAgainButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (assign, nonatomic) TicTacToePlayerType playerType;

@end


static NSString * const ticTacToeCellIdentifier = @"ticTacToeCell";


@implementation CNVTicTacToeViewController{
    TicTacToePlayerType playField[3][3];
    BOOL                myTurn;
    BOOL                gameOver;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [CNVConnectivityManager sharedManager].delegate = self;
    
    if ([CNVConnectivityManager sharedManager].isAdvertising) {
        self.playerType = TicTacToePlayerTypeCross;
        myTurn = true;
        self.statusLabel.text = @"Your turn";
        }
    else {
        self.playerType = TicTacToePlayerTypeNought;
        myTurn = false;
        NSString *statusLabelText = [NSString stringWithFormat:@"%@'s turn",self.peer.displayName];
        self.statusLabel.text = statusLabelText;
    }
    gameOver = false;
    
    
    CALayer *collectionLayer = self.collectionView.layer;
    collectionLayer.cornerRadius = 8;
    collectionLayer.borderWidth = 4;
    collectionLayer.borderColor = [UIColor indigoColor].CGColor;
    
    
    UIButton *button = self.playAgainButton;
    button.layer.cornerRadius = 8;
    button.layer.borderWidth = 0;
    button.layer.borderColor = [UIColor indigoColor].CGColor;
    button.alpha = 0;
    button.backgroundColor = [UIColor indigoColor];
    [button setTitleColor:[UIColor ghostWhiteColor] forState:UIControlStateNormal];

    self.statusLabel.textColor = [UIColor indigoColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Collection View Delegate / Data Source

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
    CGFloat width = (CGRectGetWidth(collectionView.frame) - layout.minimumInteritemSpacing * 2 - layout.sectionInset.left - layout.sectionInset.right) / 3;
    CGFloat height = (CGRectGetHeight(collectionView.frame) - layout.minimumLineSpacing * 2 - layout.sectionInset.top - layout.sectionInset.bottom) / 3;
    
    return CGSizeMake(width, height);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CNVTicTacToeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ticTacToeCellIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CNVTicTacToeCollectionViewCell *cell = (CNVTicTacToeCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.isUsed || !myTurn || gameOver) {
        return;
    }
    
    myTurn = false;
    
    NSString *statusLabelText = [NSString stringWithFormat:@"%@'s turn",self.peer.displayName];
    self.statusLabel.text = statusLabelText;
    
    [self sendMessageWithIndexPath:indexPath playerType:self.playerType];
    [cell selectWithPlayerType:self.playerType];
    
    playField[indexPath.section][indexPath.item] = self.playerType;
    [self checkForGameEnd];
}






#pragma mark - Connectivity

- (void)sendMessageWithIndexPath:(NSIndexPath *)indexPath playerType:(TicTacToePlayerType)type {
    NSDictionary *message = @{
                              @"message_type" : @(GameMessageTypeEndTurn),
                              @"index_path"   : indexPath,
                              @"player_type"  : @(type)
                              };
    [[CNVConnectivityManager sharedManager] sendDictionaty:message toPeer:self.peer];
}

- (void)sendPlayAgainMessage {
    NSDictionary *message = @{
                              @"message_type" : @(GameMessageTypeNewGame)
                              };
    [[CNVConnectivityManager sharedManager] sendDictionaty:message toPeer:self.peer];
}

- (void)session:(MCSession *)session didReceiveDictionary:(NSDictionary *)dictionary fromPeer:(MCPeerID *)peer {
    
    GameMessageType messageType = [dictionary[@"message_type"] integerValue];
    
    if (messageType == GameMessageTypeEndTurn) {
        myTurn = true;
        self.statusLabel.text = @"Your turn";

        NSIndexPath *indexPath = dictionary[@"index_path"];
        TicTacToePlayerType type = [dictionary[@"player_type"] unsignedIntegerValue];
        
        CNVTicTacToeCollectionViewCell *cell = (CNVTicTacToeCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell selectWithPlayerType:type];
        playField[indexPath.section][indexPath.item] = type;
        
        [self checkForGameEnd];
    }
    else if (messageType == GameMessageTypeNewGame) {
        [self prepareForNewGame];
    }
}



#pragma mark - Buttons


- (IBAction)playAgainPressed:(id)sender {
    [self prepareForNewGame];
    [self sendPlayAgainMessage];
}



#pragma mark - Misc


- (void)prepareForNewGame {
    if ([CNVConnectivityManager sharedManager].isAdvertising) {
        myTurn = true;
        self.statusLabel.text = @"Your turn";
    }
    else {
        myTurn = false;
        NSString *statusLabelText = [NSString stringWithFormat:@"%@'s turn",self.peer.displayName];
        self.statusLabel.text = statusLabelText;
    }
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            playField[i][j] = 0;
        }
    }
    for (CNVTicTacToeCollectionViewCell *cell in self.collectionView.visibleCells) {
        [(CNVTicTacToeCollectionViewCell*)cell prepareForReuse];
    }
    gameOver = false;
    [UIView animateWithDuration:0.3 animations:^{
        self.playAgainButton.alpha = 0;
    }];
}


- (void)checkForGameEnd {
    
    TicTacToePlayerType wonPlayerType;
    
    // Rows
    for (int i = 0; i < 3; i++) {
        if ((playField[i][0] == playField[i][1]) && (playField[i][1] == playField[i][2]) && playField[i][0] != 0) {
            wonPlayerType = playField[i][0];
            gameOver = true;
            [self showGameOverWithWonPlayerType:wonPlayerType];
            return;
        }
    }
    
    // Columns
    for (int i = 0; i < 3; i++) {
        if ((playField[0][i] == playField[1][i]) && (playField[1][i] == playField[2][i]) && playField[0][i] != 0) {
            wonPlayerType = playField[0][i];
            gameOver = true;
            [self showGameOverWithWonPlayerType:wonPlayerType];
            return;
        }
    }
    
    // Main diagonal
    if ((playField[0][0] == playField[1][1]) && (playField[1][1] == playField[2][2]) && playField[0][0] != 0) {
        wonPlayerType = playField[0][0];
        gameOver = true;
        [self showGameOverWithWonPlayerType:wonPlayerType];
        return;
    }
    
    // Antidiagonal
    
    if ((playField[0][2] == playField[1][1]) && (playField[1][1] == playField[2][0]) && playField[1][1] != 0) {
        wonPlayerType = playField[1][1];
        gameOver = true;
        [self showGameOverWithWonPlayerType:wonPlayerType];
        return;
    }
    
    BOOL allUsed = true;
   // Draw
    for (CNVTicTacToeCollectionViewCell *cell in self.collectionView.visibleCells) {
        if (!cell.isUsed) {
            allUsed = false;
        }
    }
    if (allUsed) {
        [self showGameDraw];
    }
}

- (void)showGameDraw {
    [CRToastManager showNotificationWithMessage:@"Draw!" completionBlock:^{
        [UIView animateWithDuration:0.3 animations:^{
            self.playAgainButton.alpha = 1;
        }];
    }];
}



- (void)showGameOverWithWonPlayerType:(TicTacToePlayerType)wonPlayerType {
    
    NSString *textString;
    if (wonPlayerType == self.playerType) {
        textString = @"You Won!";
    }
    else {
        textString = [NSString stringWithFormat:@"%@ Won!",self.peer.displayName];
    }
    
    [CRToastManager showNotificationWithMessage:textString completionBlock:^{
        [UIView animateWithDuration:0.3 animations:^{
            self.playAgainButton.alpha = 1;
        }];
    }];
}

@end
