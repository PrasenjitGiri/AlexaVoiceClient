//
//  AMZNGetAccessTokenDelegate.m
//  alexaTestApp
//
//  Created by Prasenjit Giri on 20/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import "AMZNGetAccessTokenDelegate.h"
#import "ApplicationManager.h"
#import "LoginWithAmazonViewController.h"

@implementation AMZNGetAccessTokenDelegate

-(instancetype)initWithParentController:(LoginWithAmazonViewController *)aViewController{
    if (self = [super init]) {
        self.parentController  = aViewController;
    }
    return  self;
}

-(void)requestDidSucceed:(APIResult *)apiResult{

    NSString* accessToken = apiResult.result;
    NSLog(@"\nAccessToken: %@", accessToken);
    
    //PG: Store the access token for future use
    //TODO: Token expiration?
    [[ApplicationManager sharedManager] setAccessToken:accessToken];
    
    //PG: Notify for transition
    [self.parentController startRecording];
    
    
}

-(void)requestDidFail:(APIError *)errorResponse{
    NSLog(@"\nAccessToken ERROR:%@", errorResponse.error.description);
}
@end
