//
//  CNVTicTacToeCollectionViewCell.h
//  Connectivity
//
//  Created by user on 9/14/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TicTacToePlayerType) {
    TicTacToePlayerTypeCross = 1,
    TicTacToePlayerTypeNought = 2
};


@interface CNVTicTacToeCollectionViewCell : UICollectionViewCell

@property (assign, nonatomic, getter=isUsed) BOOL used;
@property (assign, nonatomic) TicTacToePlayerType selectedPlayerType;


- (void)selectWithPlayerType:(TicTacToePlayerType)type character:(NSString *)character;
- (void)prepareForReuse;


@end
