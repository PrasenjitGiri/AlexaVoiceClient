//
//  NSData+MultipartResponses.h
//  alexaTestApp
//
//  Created by Prasenjit Giri on 24/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import <Foundation/Foundation.h>

//PG: http://stackoverflow.com/questions/22095186/parse-multipart-response-for-image-download-in-ios
@interface NSData (MultipartResponses)

- (NSArray *)multipartArray;
- (NSDictionary *)multipartDictionary;

@end
