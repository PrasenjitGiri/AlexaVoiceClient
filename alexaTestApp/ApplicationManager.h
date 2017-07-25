//
//  ApplicationManager.h
//  alexaTestApp
//
//  Created by Prasenjit Giri on 18/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplicationManager : NSObject

@property (nonatomic, strong) NSString* codeVerifier; 
@property (nonatomic, strong) NSString* accessToken;
@property (nonatomic, strong) NSMutableData* audioData;

+(instancetype)sharedManager;

@end
