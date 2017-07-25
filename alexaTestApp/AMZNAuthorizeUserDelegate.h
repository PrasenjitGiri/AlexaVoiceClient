//
//  AMZNAuthorizeUserDelegate.h
//  alexaTestApp
//
//  Created by Prasenjit Giri on 17/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LoginWithAmazon/LoginWithAmazon.h>

@class LoginWithAmazonViewController;

@interface AMZNAuthorizeUserDelegate : NSObject <AIAuthenticationDelegate>

@property (nonatomic, strong) LoginWithAmazonViewController* parentViewController;

-(instancetype)initWithParentController:(LoginWithAmazonViewController*)aViewController;

@end
