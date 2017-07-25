//
//  AudioRecorder.h
//  alexaTestApp
//
//  Created by Prasenjit Giri on 20/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecorderProtocol.h"
#import <AVFoundation/AVFoundation.h>

@class AudioRecorderViewController;

@interface AudioRecorder : NSObject <RecorderProtocol>


@property (nonatomic, strong) AVAudioRecorder* audioRecorder;
@property (nonatomic, strong) AVAudioPlayer* audioPlayer;

-(void)playAudioData:(NSData*)audioData;
-(BOOL)isRecording;
-(instancetype)initWithParentController:(AudioRecorderViewController*)aViewController; 
@end
