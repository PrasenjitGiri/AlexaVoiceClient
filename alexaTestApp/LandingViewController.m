//
//  LandingViewController.m
//  alexaTestApp
//
//  Created by Prasenjit Giri on 28/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import "LandingViewController.h"

@interface LandingViewController ()

@end

@implementation LandingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationItem setHidesBackButton:true];
}
- (IBAction)continueButton:(UIBarButtonItem *)sender {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"licenseAgreed"]) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    else{
        [self performSegueWithIdentifier:@"showAgreement" sender:self];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
