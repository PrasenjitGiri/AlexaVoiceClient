//
//  LaunchViewController.m
//  alexaTestApp
//
//  Created by Prasenjit Giri on 21/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import "LaunchViewController.h"

@interface LaunchViewController()

@property (nonatomic, strong) NSTimer* timer;

@end

@implementation LaunchViewController

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:true animated:animated];
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(targetMethod:)
                                   userInfo:nil
                                    repeats:NO];
}

-(void)targetMethod:(NSTimer*)timer{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"licenseAgreed"]) {
        [self performSegueWithIdentifier:@"showLanding" sender:self];
    }
    else{
        [self performSegueWithIdentifier:@"showUserAgreement" sender:self];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewDidDisappear:animated];
}
@end
