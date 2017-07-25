//
//  LoginWithAmazonViewController.h
//  alexaTestApp
//
//  Created by Prasenjit Giri on 17/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginWithAmazonViewController : UIViewController<NSURLSessionDelegate>

-(void)sendHTTPPostWithToken:(NSString*)token;
-(void)startRecording;

@property (nonatomic) BOOL loginStatus;

@end
