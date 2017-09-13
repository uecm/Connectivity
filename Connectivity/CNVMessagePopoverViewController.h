//
//  CNVMessagePopoverViewController.h
//  Connectivity
//
//  Created by user on 9/13/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CNVMessagePopoverViewController;


@protocol CNVMessageComposerDelegate <NSObject>

- (void)messageComposer:(CNVMessagePopoverViewController *)composer DidFinishEditingWithMessage:(NSString *)message;

@end

@interface CNVMessagePopoverViewController : UIViewController

@property (strong, nonatomic) NSString *receiverName;
@property (weak, nonatomic) id<CNVMessageComposerDelegate> delegate;

@end
