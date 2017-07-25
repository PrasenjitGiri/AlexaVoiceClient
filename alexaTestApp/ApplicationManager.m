//
//  ApplicationManager.m
//  alexaTestApp
//
//  Created by Prasenjit Giri on 18/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import "ApplicationManager.h"

@implementation ApplicationManager

+(instancetype)sharedManager{
    static ApplicationManager* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc]init];
        
    });
    return sharedManager;
}

-(void)setAudioData:(NSMutableData *)audioData{
    
    if (_audioData == nil) {
        _audioData = [[NSMutableData alloc] init];
        _audioData = audioData;
    }
    else{
        _audioData = audioData;
    }
}
@end
