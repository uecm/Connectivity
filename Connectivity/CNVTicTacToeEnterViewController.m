//
//  CNVTicTacToeEnterViewController.m
//  Connectivity
//
//  Created by user on 9/15/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import "CNVTicTacToeEnterViewController.h"
#import "CNVTicTacToeViewController.h"
#import <Colours.h>


@interface CNVTicTacToeEnterViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CNVTicTacToeGameSessionDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *selectedFighterLabel;

@property (weak, nonatomic) IBOutlet UIButton *createGameButton;
@property (weak, nonatomic) IBOutlet UIButton *joinGameButton;

@property (strong, nonatomic) NSArray *figters;
@property (strong, nonatomic) CNVTicTacToeSessionInteractor *sessionInteractor;

@end

static NSString * const kFighterCellIdentifier = @"fighterCell";


@implementation CNVTicTacToeEnterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initializeView];
    
    self.sessionInteractor = [[CNVTicTacToeSessionInteractor alloc] init];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.sessionInteractor.delegate = self;

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.sessionInteractor.opponentPlayerPreferences == nil) {
        self.joinGameButton.alpha = 0;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Collection View Delegate / Data Source

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
    CGFloat width = (CGRectGetWidth(collectionView.frame) - layout.minimumInteritemSpacing * 2) / 2.5f - layout.sectionInset.left - layout.sectionInset.right;
    CGFloat height = CGRectGetHeight(collectionView.frame) - layout.sectionInset.top - layout.sectionInset.bottom;
    
    return CGSizeMake(width, height);
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.figters.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFighterCellIdentifier forIndexPath:indexPath];
    
    UILabel *label = [cell viewWithTag:100];
    label.text = self.figters[indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedFighterLabel.text = self.figters[indexPath.row];
}


- (IBAction)joinGamePressed:(id)sender {
    
}

- (IBAction)createGamePressed:(id)sender {
    
   
}



#pragma mark - Game Session Delegate

- (void)peer:(MCPeerID *)peerID didCreateGameWithParameters:(NSDictionary *)parameters {

    [UIView animateWithDuration:0.3 animations:^{
        self.joinGameButton.alpha = 1;
    }];

}


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([identifier isEqualToString:@"joinGameSegue"]) {
        
    }
    
    
    
    return true;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"joinGameSegue"]) {
        [self.sessionInteractor sendJoinGameMessageWithParameters:@{@"fighter" : self.selectedFighterLabel.text}];
        
        CNVTicTacToeViewController *gameViewController = segue.destinationViewController;
        gameViewController.sessionInteractor = self.sessionInteractor;
    }
    
    else if ([segue.identifier isEqualToString:@"createGameSegue"]) {
        [self.sessionInteractor sendCreatedGameMessageWithParameters:@{@"fighter" : self.selectedFighterLabel.text}];
        
        CNVTicTacToeViewController *gameViewController = segue.destinationViewController;
        gameViewController.sessionInteractor = self.sessionInteractor;
    }
}



#pragma mark - Misc


- (void)initializeView {
    CALayer *collectionLayer = self.collectionView.layer;
    collectionLayer.cornerRadius = 8;
    collectionLayer.borderWidth = 4;
    collectionLayer.borderColor = [UIColor indigoColor].CGColor;

    self.figters = @[@"😈", @"👹", @"👺", @"💩", @"👻", @"💀", @"👽", @"👾", @"🤖", @"🌚", @"🌝"];
    [self.collectionView reloadData];
    
    NSInteger randomIndex = arc4random_uniform((uint32_t)self.figters.count);
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:randomIndex inSection:0]
                                      animated:false
                                scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    
    self.selectedFighterLabel.text = self.figters[randomIndex];

    self.joinGameButton.alpha = 0;
    
    for (UIButton *button in @[self.joinGameButton, self.createGameButton]) {
        button.layer.cornerRadius = 8;
        button.layer.borderWidth = 0;
        button.layer.borderColor = [UIColor indigoColor].CGColor;
        button.backgroundColor = [UIColor indigoColor];
        [button setTitleColor:[UIColor ghostWhiteColor] forState:UIControlStateNormal];
    }
}


@end
