//
//  PartData.h
//  alexaTestApp
//
//  Created by Prasenjit Giri on 20/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PartData : NSObject

@property (nonatomic, strong)  NSMutableDictionary* headers; //PG: Header data
@property (nonatomic, strong)  NSData* data; //PG: Voice data 

@end
