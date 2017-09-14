//
//  CNVMessagePopoverViewController.m
//  Connectivity
//
//  Created by user on 9/13/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import "CNVMessagePopoverViewController.h"

@interface CNVMessagePopoverViewController ()

@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation CNVMessagePopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = [NSString stringWithFormat:@"Message to %@", self.receiverName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMessagePressed:(id)sender {
    //[self dismissViewControllerAnimated:true completion:nil];
    if ([self.delegate respondsToSelector:@selector(messageComposer:DidFinishEditingWithMessage:)]) {
        [self.delegate messageComposer:self DidFinishEditingWithMessage:self.messageTextField.text];
    }
}


@end
