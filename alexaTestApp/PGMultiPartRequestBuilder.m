//
//  PGMultiPartRequestBuilder.m
//  alexaTestApp
//
//  Created by Prasenjit Giri on 23/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import "PGMultiPartRequestBuilder.h"

@implementation PGMultiPartRequestBuilder

#pragma mark - Private methods 
-(NSString*)createMetaData{
    
    NSMutableDictionary* rootElement = [[NSMutableDictionary alloc] init];
    NSDictionary* deviceContextPayload = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"streamId", @"0", @"offsetInMilliseconds", @"IDLE", @"playerActivity",nil];
    NSDictionary* deviceContext = [NSDictionary dictionaryWithObjectsAndKeys:@"playbackState",@"name",@"AudioPlayer",@"namespace",deviceContextPayload,@"payload", nil];
    [rootElement setObject:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:deviceContext] forKey:@"deviceContext"] forKey:@"messageHeader" ];
    
    //PG: Message body section
    NSDictionary* messageBodyParameters = [NSDictionary dictionaryWithObjectsAndKeys:@"audio/L16; rate=16000; channels=1", @"format", @"en-us", @"locale", @"alexa-close-talk", @"profile", nil];
    [rootElement setObject:messageBodyParameters forKey:@"messageBody"];
    
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:rootElement options:NSJSONWritingPrettyPrinted error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
