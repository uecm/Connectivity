//
//  CNVTicTacToeViewController.h
//  Connectivity
//
//  Created by user on 9/14/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNVTicTacToeSessionInteractor.h"

@interface CNVTicTacToeViewController : UIViewController


@property (strong, nonatomic) NSDictionary *playerPreferences;
@property (strong, nonatomic) CNVTicTacToeSessionInteractor *sessionInteractor;



@end
