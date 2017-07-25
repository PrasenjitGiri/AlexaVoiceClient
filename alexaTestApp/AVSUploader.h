//
//  AVSUploader.h
//  alexaTestApp
//
//  Created by Prasenjit Giri on 20/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioRecorderViewController.h"

@interface AVSUploader : NSObject <NSURLSessionDelegate>

@property (nonatomic, strong) NSString* accessToken;
@property (nonatomic, strong) NSString* jsonData;
@property (nonatomic, strong) NSData* audioData;
@property (nonatomic, strong) AudioRecorderViewController* parentController; 

-(NSString*)createMetaData;
-(void)postRecording;

-(instancetype)initWithParentController:(AudioRecorderViewController*)aViewController;

@end
