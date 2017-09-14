//
//  CNVGeneralSettingsTableViewController.m
//  Connectivity
//
//  Created by user on 9/13/17.
//  Copyright © 2017 greg. All rights reserved.
//

#import "CNVGeneralSettingsTableViewController.h"
#import "CNVConnectivityManager.h"


@interface CNVGeneralSettingsTableViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneNameTextField;

@end

static NSString * const kGeneralCellIdentifier = @"phoneNameCell";

@implementation CNVGeneralSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    UITapGestureRecognizer *tapOutsideRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapRecognizerAction:)];
    [self.tableView addGestureRecognizer:tapOutsideRecognizer];
    
    [self prefillFields];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


#pragma mark - Text Field Delegates

- (IBAction)textFieldTouchUpOutside:(id)sender {
    [self.view endEditing:true];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.phoneNameTextField]) {
        NSString *newName = textField.text;
        
        if (newName && newName.length > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:newName forKey:@"userName"];
            [[CNVConnectivityManager sharedManager] setLocalPeerIDWithName:newName];
        }
    }
    [textField endEditing:true];
    return true;
}


#pragma mark - Misc

- (void)viewTapRecognizerAction:(UITapGestureRecognizer *)recognizer {
    [self.tableView endEditing:true];
}


- (void)prefillFields {
    self.phoneNameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
}

@end
