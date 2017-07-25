//
//  AMZNAuthorizeUserDelegate.m
//  alexaTestApp
//
//  Created by Prasenjit Giri on 17/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import "AMZNAuthorizeUserDelegate.h"
#import "AMZNGetProfileDelegate.h"
#import "ApplicationManager.h"
#import "LoginWithAmazonViewController.h"
#import "AMZNGetAccessTokenDelegate.h"

@implementation AMZNAuthorizeUserDelegate

-(void)sendHTTPPostWithToken:(NSString*)token{
    
    //PG: Request parameters
//    NSString* grantType = @"grant_type=authorization_code";
//    NSString* code = [NSString stringWithFormat:@"code=%@",token];
//    NSString* redirectURL = [NSString stringWithFormat:@"redirect_uri=%@",[AIMobileLib getRedirectUri] ];
//    NSString* clientID = [NSString stringWithFormat:@"client_id=%@",[AIMobileLib getClientId]];
//    NSString* codeVerifier = [NSString stringWithFormat:@"code_verifier=%@",[ApplicationManager sharedManager].codeVerifier];
//    NSMutableDictionary* paramDictionary = [[NSMutableDictionary alloc] init];
//    [paramDictionary setObject:grantType forKey:@"grant_type"];
//    [paramDictionary setObject:token forKey:@"code"];
//    [paramDictionary setObject:redirectURL forKey:@"redirect_uri"];
//    [paramDictionary setObject:clientID forKey:@"client_id"];
//    [paramDictionary setObject:codeVerifier forKey:@"code_verifier"];
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paramDictionary
//                                                       options:NSJSONWritingPrettyPrinted
//                                                         error:&error];
//    NSString* jsonString;
//    if (! jsonData) {
//        NSLog(@"Got an error: %@", error);
//    } else {
//         jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    }
    NSURLSessionConfiguration* defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURL* url = [NSURL URLWithString:@"https://api.amazon.com/auth/O2/token"];
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
//    [urlRequest ]
    
//    [urlRequest setHTTPBody:jsonData];
    
    NSString* grant = @"authorization_code";
    NSString* requestBody = [NSString stringWithFormat:@"grant_type=%@&code=%@&redirect_uri=%@&client_id=%@&code_verifier=%@", grant,token,[AIMobileLib getRedirectUri],[AIMobileLib getClientId],[ApplicationManager sharedManager].codeVerifier];
    
//    [urlRequest setHTTPBody:[grantType dataUsingEncoding:NSUTF8StringEncoding]];
//    [urlRequest setHTTPBody:[code dataUsingEncoding:NSUTF8StringEncoding]];
//    [urlRequest setHTTPBody:[redirectURL dataUsingEncoding:NSUTF8StringEncoding]];
//    [urlRequest setHTTPBody:[clientID dataUsingEncoding:NSUTF8StringEncoding]];
//    [urlRequest setHTTPBody:[codeVerifier dataUsingEncoding:NSUTF8StringEncoding]];
    
    [urlRequest setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    
//    NSLog(@"\nJSON:%@", jsonString);
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           NSLog(@"Response:%@ %@\n", response, error);
                                                           if(error == nil)
                                                           {
                                                               NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                               NSLog(@"Data = %@",text);
                                                           }
                                                           else{
                                                               //PG: Get the result
                                                               NSLog(@"dataAsString %@", [NSString stringWithUTF8String:[data bytes]]);
                                                               
                                                               NSError *error1;
                                                               NSMutableDictionary * innerJson = [NSJSONSerialization
                                                                                                  JSONObjectWithData:data
                                                                                                  options:kNilOptions
                                                                                                  error:&error1];
                                                               NSLog(@"\nResponse Dictionary:%@", innerJson);
                                                           }
                                                           
                                                       }];
    [dataTask resume];
    
}
-(void)requestDidSucceed:(APIResult *)apiResult{
//    AMZNGetProfileDelegate* delegate = [[AMZNGetProfileDelegate alloc] initWithParentController:self.parentViewController];
//    [AIMobileLib getProfile:delegate];
    //PG: Save the token
    NSString* authorizedToken = apiResult.result;
    NSLog(@"\nToken: %@", authorizedToken);
    
    //PG: Call AMZN to exchange authorization code for access & refresh tokens
    //PG: URL=> https://api.amazon.com/auth/O2/token
    
//    [self sendHTTPPostWithToken:authorizedToken];
//    [self.parentViewController sendHTTPPostWithToken:authorizedToken];
    
    //PG: Call to get the access token
    AMZNGetAccessTokenDelegate* tokenDelegate = [[AMZNGetAccessTokenDelegate alloc] initWithParentController:self.parentViewController];
    [AIMobileLib getAccessTokenForScopes:[NSArray arrayWithObjects:@"alexa:all", nil] withOverrideParams:nil delegate:tokenDelegate];
}

-(void)requestDidFail:(APIError *)errorResponse{
    NSString* errorMessage = errorResponse.error.description;
    
    NSLog(@"\nERROR: Authorize %@", errorMessage);
    
}

-(instancetype)initWithParentController:(LoginWithAmazonViewController *)aViewController{
    if (self = [super init]) {
        self.parentViewController = aViewController;
    }
    return self;
}
@end
