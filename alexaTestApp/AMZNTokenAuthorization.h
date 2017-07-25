//
//  AMZNTokenAuthorization.h
//  alexaTestApp
//
//  Created by Prasenjit Giri on 18/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMZNTokenAuthorization : NSObject

@property (nonatomic, strong) NSString* codeVerifier;
@property (nonatomic, strong) NSString* authorizedToken;
@property (nonatomic, strong) NSNumber* tokenRefreshTime;
@property (nonatomic, strong) NSString* accessToken;
@property (nonatomic, strong) NSString* refreshToken;


-(void)updateAccessTokenWith:(NSString*)accessToken;
-(void)updateRefreshTokenWih:(NSString*)refreshToken;
-(void)updateTokenRefreshTimeInSeconds:(NSNumber*) seconds;

-(void)updateTokenAuthorizationInfo:(NSDictionary*)tokenInfo;

-(BOOL)isTokenValid;

@end
