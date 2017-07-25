//
//  AMZNTokenAuthorization.m
//  alexaTestApp
//
//  Created by Prasenjit Giri on 18/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import "AMZNTokenAuthorization.h"


@implementation AMZNTokenAuthorization

-(void)updateAccessTokenWith:(NSString*)accessToken{
    self.accessToken = accessToken;
}
-(void)updateRefreshTokenWih:(NSString*)refreshToken{
    self.refreshToken = refreshToken;
}
-(void)updateTokenRefreshTimeInSeconds:(NSNumber*) seconds{
    self.tokenRefreshTime = seconds;
}

-(void)updateTokenAuthorizationInfo:(NSDictionary *)tokenInfo{
    
    self.accessToken = [tokenInfo objectForKey:@"access_token"];
    self.refreshToken = [tokenInfo objectForKey:@"refresh_token"];
    self.tokenRefreshTime = [tokenInfo objectForKey:@"expires_in"];
    
}

-(BOOL)isTokenValid{
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Method not implemented" userInfo:nil];
}

@end
