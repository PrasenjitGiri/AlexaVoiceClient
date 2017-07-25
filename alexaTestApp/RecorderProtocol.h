//
//  RecorderProtocol.h
//  alexaTestApp
//
//  Created by Prasenjit Giri on 20/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RecorderProtocol <NSObject>

-(void)record;
-(void)stop;
-(void)play;

@end
