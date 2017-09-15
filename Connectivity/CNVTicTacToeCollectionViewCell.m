//
//  CNVTicTacToeCollectionViewCell.m
//  Connectivity
//
//  Created by user on 9/14/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import "CNVTicTacToeCollectionViewCell.h"

@interface CNVTicTacToeCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation CNVTicTacToeCollectionViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    self.label.text = @"";
    self.used = false;
}

- (void)selectWithPlayerType:(TicTacToePlayerType)type character:(NSString *)character{
    self.used = true;
    self.selectedPlayerType = type;
    self.label.text = character;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.label.text = @"";
    self.used = false;
}


@end
