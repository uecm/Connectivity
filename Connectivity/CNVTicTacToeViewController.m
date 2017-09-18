//
//  CNVTicTacToeViewController.m
//  Connectivity
//
//  Created by user on 9/14/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import "CNVTicTacToeViewController.h"
#import "CNVTicTacToeCollectionViewCell.h"
#import "CNVTicTacToeSessionInteractor.h"

#import <CRToast.h>
#import <Colours.h>
#import <SVProgressHUD.h>

typedef NS_ENUM(NSInteger, GameMessageType) {
    GameMessageTypeEndTurn = 0,
    GameMessageTypeNewGame
};

typedef NS_ENUM(NSInteger, GameResultType) {
    GameResultTypeWin = 0,
    GameResultTypeLose,
    GameResultTypeDraw
};


@interface CNVTicTacToeViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CNVTicTacToeGameSessionDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *playAgainButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameStatisticsLabel;
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
    
    [self initializeView];
    self.sessionInteractor.delegate = self;
    
    if (self.sessionInteractor.isGameOwner) {
        self.playerType = TicTacToePlayerTypeCross;
        myTurn = true;
        self.statusLabel.text = @"Your turn";
        }
    else {
        self.playerType = TicTacToePlayerTypeNought;
        myTurn = false;
        NSString *statusLabelText = [NSString stringWithFormat:@"%@'s turn",self.sessionInteractor.opponent.displayName];
        self.statusLabel.text = statusLabelText;
    }
    gameOver = false;
    
    [self showWaitingForOpponentHUD];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.sessionInteractor.opponentPlayerPreferences) {
        [self.sessionInteractor sendLeftGameMessage];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
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
    
    [self sendMessageWithIndexPath:indexPath playerType:self.playerType];
    myTurn = false;
    
    NSString *statusLabelText = [NSString stringWithFormat:@"%@'s turn",self.sessionInteractor.opponent.displayName];
    self.statusLabel.text = statusLabelText;
    
    [cell selectWithPlayerType:self.playerType character:self.sessionInteractor.currentPlayerPreferences[@"fighter"]];
    
    playField[indexPath.section][indexPath.item] = self.playerType;
    [self checkForGameEnd];
}






#pragma mark - Connectivity

- (void)sendMessageWithIndexPath:(NSIndexPath *)indexPath playerType:(TicTacToePlayerType)type {
    NSDictionary *message = @{
                              @"index_path"   : indexPath,
                              @"player_type"  : @(type)
                              };
    [self.sessionInteractor sendPerformedActionMessageWithParameters:message];
}


- (void)peer:(MCPeerID *)peerID didEnterGameSessionWithParameters:(NSDictionary *)parameters {
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)peerDidSendPlayAgainMessage:(MCPeerID *)peer {
    [self prepareForNewGame];
}

- (void)peer:(MCPeerID *)peer didActionWithParameters:(NSDictionary *)parameters {
    myTurn = true;
    self.statusLabel.text = @"Your turn";

    NSIndexPath *indexPath = parameters[@"index_path"];
    TicTacToePlayerType type = [parameters[@"player_type"] unsignedIntegerValue];

    CNVTicTacToeCollectionViewCell *cell = (CNVTicTacToeCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell selectWithPlayerType:type character:self.sessionInteractor.opponentPlayerPreferences[@"fighter"]];
    playField[indexPath.section][indexPath.item] = type;


    [self checkForGameEnd];
}


- (void)peerDidLeftGameSession:(MCPeerID *)peerID {
    [CRToastManager showNotificationWithMessage:@"Opponent has left the game💩" completionBlock:^{
        [self.navigationController popViewControllerAnimated:true];
    }];
}

#pragma mark - Buttons


- (IBAction)playAgainPressed:(id)sender {
    [self prepareForNewGame];
    [self.sessionInteractor sendPlayAgainMessage];
}



#pragma mark - Misc


- (void)initializeView {
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


- (void)prepareForNewGame {
    
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
    [self addEntryToGameStatisticsWithResult:GameResultTypeDraw];
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
        [self addEntryToGameStatisticsWithResult:GameResultTypeWin];
    }
    else {
        textString = [NSString stringWithFormat:@"%@ Won!",self.sessionInteractor.opponent.displayName];
        [self addEntryToGameStatisticsWithResult:GameResultTypeLose];
    }
    
    [CRToastManager showNotificationWithMessage:textString completionBlock:^{
        [UIView animateWithDuration:0.3 animations:^{
            self.playAgainButton.alpha = 1;
        }];
    }];
}


- (void)addEntryToGameStatisticsWithResult:(GameResultType)gameResult {
    if (self.sessionInteractor.gameStatistics == nil) {
        self.sessionInteractor.gameStatistics = @{}.mutableCopy;
    }
    NSMutableDictionary *gameStats = self.sessionInteractor.gameStatistics;
    NSNumber *currentValue = [gameStats objectForKey:@(gameResult)];
    
    if (!currentValue) {
        currentValue = [NSNumber numberWithInteger:0];
    }
    
    currentValue = [NSNumber numberWithInteger:currentValue.integerValue + 1];
    
    [gameStats setObject:currentValue forKey:@(gameResult)];
    [self updateGameStatisticsLabel];
}

- (void)updateGameStatisticsLabel {
    NSDictionary *currentStats = self.sessionInteractor.gameStatistics.copy;
    
    int wins = [[currentStats objectForKey:@(GameResultTypeWin)] intValue];
    int loses = [[currentStats objectForKey:@(GameResultTypeLose)] intValue];
    int draws = [[currentStats objectForKey:@(GameResultTypeDraw)] intValue];

    self.gameStatisticsLabel.text = [NSString stringWithFormat:@"Wins:%d Loses:%d Draws:%d",wins, loses, draws];
}


- (void)showWaitingForOpponentHUD {
    
    if (!self.sessionInteractor.opponentPlayerPreferences) {
        [SVProgressHUD showWithStatus:@"Waiting for Opponent"];
    }
    
}

@end
