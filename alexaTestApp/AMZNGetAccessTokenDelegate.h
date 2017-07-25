//
//  AMZNGetAccessTokenDelegate.h
//  alexaTestApp
//
//  Created by Prasenjit Giri on 20/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LoginWithAmazon/LoginWithAmazon.h>

@class LoginWithAmazonViewController;

@interface AMZNGetAccessTokenDelegate : NSObject <AIAuthenticationDelegate>

@property (nonatomic, strong) LoginWithAmazonViewController* parentController;

-(instancetype)initWithParentController:(LoginWithAmazonViewController*)aViewController;

@end
