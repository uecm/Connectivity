//
//  CNVTicTacToeEnterViewController.m
//  Connectivity
//
//  Created by user on 9/15/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import "CNVTicTacToeEnterViewController.h"
#import "CNVTicTacToeViewController.h"

@interface CNVTicTacToeEnterViewController () <UICollectionViewDelegate, UICollectionViewDataSource, CNVTicTacToeGameSessionDelegate>

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
    
    self.figters = @[@"😈", @"👹", @"👺", @"💩", @"👻", @"💀", @"👽", @"👾", @"🤖", @"🌚", @"🌝"];
    [self.collectionView reloadData];
    NSInteger randomIndex = arc4random_uniform((uint32_t)self.figters.count);
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:randomIndex inSection:0] animated:false scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    self.selectedFighterLabel.text = self.figters[randomIndex];
    
    self.sessionInteractor = [[CNVTicTacToeSessionInteractor alloc] init];
    self.joinGameButton.alpha = 0;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.sessionInteractor.delegate = self;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Collection View Delegate / Data Source

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
//    if ([self.selectedFighterLabel.text isEqualToString:@""]) {
//        self.selectedFighterLabel.text = self.figters[arc4random_uniform((uint32_t)self.figters.count)];
//    }
    
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


@end
