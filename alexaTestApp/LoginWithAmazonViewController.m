//
//  LoginWithAmazonViewController.m
//  alexaTestApp
//
//  Created by Prasenjit Giri on 17/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import "LoginWithAmazonViewController.h"
#import "AMZNAuthorizeUserDelegate.h"
#import <CommonCrypto/CommonCrypto.h>
#import "ApplicationManager.h"
#import "FooterView.h"


@interface LoginWithAmazonViewController() 

@property (weak, nonatomic) IBOutlet FooterView *footerView;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;

@end

@implementation LoginWithAmazonViewController

#pragma mark - Private & Helper methods 
-(void)modifyInfoText
{
    
    NSMutableString* strInfo = [[NSMutableString alloc] initWithString:self.infoTextView.text];
    NSRange range = [strInfo rangeOfString:@"Alexa Voice Service License Agreement"];
    
    if (range.location != NSNotFound) {
        
        NSString* termsAndConditions = @"https://developer.amazon.com/edw/avs_agreement.html";
        NSMutableAttributedString* attrInfo = [[NSMutableAttributedString alloc] initWithString:strInfo];
        [attrInfo addAttribute:NSLinkAttributeName value:termsAndConditions range:range];
        [self.infoTextView setAttributedText:attrInfo];
    }
}

#pragma mark - Views section

-(void)viewWillAppear:(BOOL)animated{
    
    [self modifyInfoText];
    [self.navigationItem setHidesBackButton:true];
    [super viewWillAppear:animated];
   
}


- (IBAction)onLoginButtonClicked:(UIButton *)sender {
    
    //PG: Specify the minimum basis scope
//    
//    NSArray* requestScopes = [NSArray arrayWithObjects:@"profile", nil];
//    AMZNAuthorizeUserDelegate* delegate = [[AMZNAuthorizeUserDelegate alloc] initWithParentController:self];
//    [AIMobileLib authorizeUserForScopes:requestScopes delegate:delegate];
    
//    NSString* codeChallengeString = [self getCodeChallenge];
    NSString* productID = @"alexaTestApp";
    NSString* deviceSerialNumber = @"007";
    
    NSArray *requestScopes = [NSArray arrayWithObjects:@"alexa:all",nil];
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    NSString* scopeData = [NSString stringWithFormat:@"{\"alexa:all\":{\"productID\":\"%@\","
                           "\"productInstanceAttributes\":{\"deviceSerialNumber\":\"%@\"}}}",
                           productID, deviceSerialNumber];
    options[kAIOptionScopeData] = scopeData;
    //PG: These 3 lines are used to get the authorization code from the server
//    options[kAIOptionReturnAuthCode] = @YES;
//    options[kAIOptionCodeChallenge] = codeChallengeString;
//    options[kAIOptionCodeChallengeMethod] = @"S256";
    
    AMZNAuthorizeUserDelegate* delegate = [[AMZNAuthorizeUserDelegate alloc] initWithParentController:self];
    [AIMobileLib authorizeUserForScopes:requestScopes delegate:delegate options:options];
}

-(NSString*)getCodeChallenge{
    NSString* randomString = [self generateRandomStringofLength:[NSNumber numberWithInt:128]];
//    NSLog(@"\nRadom String: %@, of length:%ld", randomString, (unsigned long)[randomString length]);
    NSString* codeChallengeString = [self generateCodeChallengeFromString:randomString];
    return codeChallengeString;
    
}
-(NSString*)generateRandomStringofLength:(NSNumber*)length{
    //PG: Cryptographically random string composed of URL & filename safe set of characters
    //PG: String should be in the range of 43 - 128 character length
    
    int stringLength = [length intValue];
    NSString* characterSet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~";
    NSMutableString* codeVerifier = [NSMutableString stringWithCapacity: stringLength];
    
    //PG: Store the codeVerifier for token authorization
    [ApplicationManager sharedManager].codeVerifier = codeVerifier;
    
    for (int i = 0; i < stringLength; i++) {
        [codeVerifier appendFormat: @"%C", [characterSet characterAtIndex: arc4random() % [characterSet length]]];
    }
    return codeVerifier;
}
-(NSString*)generateCodeChallengeFromString:(NSString*)codeVerifier{
    
    //PG: SHA-256 Hash  code verifier => http://stackoverflow.com/questions/4992109/generate-sha256-string-in-objective-c
    const char* s = [codeVerifier cStringUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"\nCharacters: %s", s);
    NSData* keyData = [NSData dataWithBytes:s length:strlen(s)];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH] =  {0};
    CC_SHA256(keyData.bytes, keyData.length, digest);
    NSData* out = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
//    NSString* hash = [out description];
//    NSLog(@"\nHashed string:%@", hash);
    
    //PG: Base64 Encoding
    NSString* base64EncodedString = [out base64EncodedStringWithOptions:NSUTF8StringEncoding];
//    NSLog(@"\nBase64EncodedString:%@", base64EncodedString);
    
    //PG: Remove characters as per => http://tools.ietf.org/html/draft-ietf-oauth-spop-10#appendix-A
    NSMutableString* codeChallengeString  = [NSMutableString string];;
    
    for (NSInteger i=0; i<base64EncodedString.length; i++)
    {
        unichar c = [base64EncodedString characterAtIndex:i];
        if (c == '=') {
            continue;
        }
        else if (c == '+') {
            [codeChallengeString appendString:@"-"];
        }
        else if (c == '/') {
            [codeChallengeString appendString:@"_"];
        }
        else {
            [codeChallengeString appendFormat:@"%C", c];
        }
    }
//    NSLog(@"\nChallenge String: %@", codeChallengeString);
    
    return codeChallengeString;
}

#pragma mark - Network section 
-(void)sendHTTPPostWithToken:(NSString*)token{
    
    //PG: Request parameters
    NSURLSessionConfiguration* defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURL* url = [NSURL URLWithString:@"https://api.amazon.com/auth/O2/token"];
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    NSString* grant = @"authorization_code";
    NSString* requestBody = [NSString stringWithFormat:@"grant_type=%@&code=%@&redirect_uri=%@&client_id=%@&code_verifier=%@", grant,token,[AIMobileLib getRedirectUri],[AIMobileLib getClientId],[ApplicationManager sharedManager].codeVerifier];
    
    [urlRequest setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        if(error == nil)
                                                           {//PG: Parse the token
                                                               NSMutableDictionary * resultJSON = [NSJSONSerialization
                                                                                                  JSONObjectWithData:data
                                                                                                  options:kNilOptions
                                                                                                  error:nil];
                                                               NSLog(@"\nResponse Dictionary:%@",resultJSON);
                                                           }
                                                           else{
                                                               //PG: Get the result
//                                                               NSError *error1;
//                                                               NSMutableDictionary * innerJson = [NSJSONSerialization
//                                                                                                  JSONObjectWithData:data
//                                                                                                  options:kNilOptions
//                                                                                                  error:&error1];
//                                                               NSLog(@"\nResponse Dictionary:%@", innerJson);
                                                               NSLog(@"\nERROR: Access Token:%@", error.description);
                                                           }
                                                       }];
    [dataTask resume];
}

#pragma mark - Segues Transition 
-(void)startRecording{
    [self performSegueWithIdentifier:@"showAudioRecorder" sender:self];
}

@end
