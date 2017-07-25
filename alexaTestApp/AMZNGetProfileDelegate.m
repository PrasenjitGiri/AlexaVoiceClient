//
//  AMZNGetProfileDelegate.m
//  alexaTestApp
//
//  Created by Prasenjit Giri on 17/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import "AMZNGetProfileDelegate.h"


@implementation AMZNGetProfileDelegate

-(instancetype)initWithParentController:(LoginWithAmazonViewController *)aViewController{
    if (self = [super init]) {
        self.parentViewController = aViewController;
    }
    return self;
}

-(void)requestDidSucceed:(APIResult *)apiResult{
    NSDictionary* userDetails = (NSDictionary*)apiResult.result;
    
    NSString* userName = [userDetails objectForKey:@"name"];
    NSString* emailID = [userDetails objectForKey:@"email"];
    
    NSLog(@"\nUsername: %@ \nEmail:%@\n", userName, emailID);
    
}
-(void)requestDidFail:(APIError *)errorResponse{
    if (errorResponse.error.code == kAIApplicationNotAuthorized) {
        NSLog(@"\nERROR: Not authorized");
    }
    else{
        NSLog(@"\nERROR: GetProfile:%@", errorResponse.error.description);
    }
}
@end
