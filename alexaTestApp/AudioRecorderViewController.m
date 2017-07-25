//
//  AudioRecorderViewController.m
//  alexaTestApp
//
//  Created by Prasenjit Giri on 20/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import "AudioRecorderViewController.h"
#import "AudioRecorder.h"
#import "AVSUploader.h"
#import "ApplicationManager.h"
#import "SCSiriWaveformView.h"


typedef NS_ENUM(NSUInteger, SCSiriWaveformViewInputType) {
    SCSiriWaveformViewInputTypeRecorder,
    SCSiriWaveformViewInputTypePlayer
};

@interface AudioRecorderViewController()

@property (nonatomic, strong) AudioRecorder* audioRecorder;
@property (nonatomic, strong) AVSUploader* avsUploader;
@property (weak, nonatomic) IBOutlet SCSiriWaveformView *waveformView;
@property (nonatomic, assign) SCSiriWaveformViewInputType selectedInputType;

@end

@implementation AudioRecorderViewController

-(void)hideRecordButton:(BOOL)flag{
    //PG: Gets invoked when playing is finished
    [self.buttonRecord setHidden:flag];
}

-(void)hideActivityIndicator:(BOOL)flag{
    [self.activityIndicator setHidden:flag];

}
-(void)playAudioResponseData:(NSData *)audioData{
    
    [self.buttonRecord setHidden:true];
    [self.audioRecorder playAudioData:audioData];
}

- (IBAction)recordButton:(UIButton *)sender {
    
    if ([self.audioRecorder isRecording]) {
        
        [self.waveformView setHidden:true];
        [self.audioRecorder stop];
        [sender setBackgroundImage:[UIImage imageNamed:@"player_record.png"] forState:UIControlStateNormal];
        [self.avsUploader setAccessToken:[ApplicationManager sharedManager].accessToken];
        [self.avsUploader setAudioData:[ApplicationManager sharedManager].audioData];
        [self.avsUploader postRecording];
        [sender setHidden:true];
        [self.activityIndicator setHidden:false];
    }
    else{
        
        [self.waveformView setHidden:false];
        [self.audioRecorder record];
        [sender setBackgroundImage:[UIImage imageNamed:@"player_stop.png"] forState:UIControlStateNormal];
    }
    
}

- (IBAction)playButton:(UIButton *)sender {
    [self.audioRecorder play];
}
- (IBAction)stopButton:(UIButton *)sender {
    [self.audioRecorder stop];
    [self.avsUploader setAccessToken:[ApplicationManager sharedManager].accessToken];
    [self.avsUploader setAudioData:[ApplicationManager sharedManager].audioData];
    [self.avsUploader postRecording];
//    [[ApplicationManager sharedManager] setAudioData:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationItem setHidesBackButton:true];
    [self setup];
    
}

#pragma mark - Private methods 
-(void)setup{
    self.audioRecorder = [[AudioRecorder alloc]initWithParentController:self];
    self.avsUploader = [[AVSUploader alloc]initWithParentController:self];
    
    //PG: Setup siriWaveForm
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.waveformView setWaveColor:[UIColor blackColor]];
    [self.waveformView setPrimaryWaveLineWidth:3.0f];
    [self.waveformView setSecondaryWaveLineWidth:1.0];
    [self setSelectedInputType:SCSiriWaveformViewInputTypeRecorder];
    
    [self.waveformView setHidden:true];
}

- (void)setSelectedInputType:(SCSiriWaveformViewInputType)selectedInputType
{
    _selectedInputType = selectedInputType;
    
    switch (selectedInputType) {
        case SCSiriWaveformViewInputTypeRecorder: {
            [self.audioRecorder.audioPlayer stop];
            
            [self.audioRecorder.audioRecorder prepareToRecord];
            [self.audioRecorder.audioRecorder setMeteringEnabled:YES];
            [self.audioRecorder.audioRecorder record];
            break;
        }
        case SCSiriWaveformViewInputTypePlayer: {
            [self.audioRecorder.audioRecorder stop];
            
            [self.audioRecorder.audioPlayer prepareToPlay];
            [self.audioRecorder.audioPlayer setMeteringEnabled:YES];
            [self.audioRecorder.audioPlayer play];
            break;
        }
    }
}

- (void)updateMeters
{
    CGFloat normalizedValue;
    switch (self.selectedInputType) {
        case SCSiriWaveformViewInputTypeRecorder: {
            [self.audioRecorder.audioRecorder updateMeters];
            normalizedValue = [self _normalizedPowerLevelFromDecibels:[self.audioRecorder.audioRecorder averagePowerForChannel:0]];
            break;
        }
        case SCSiriWaveformViewInputTypePlayer: {
            [self.audioRecorder.audioPlayer updateMeters];
            normalizedValue = [self _normalizedPowerLevelFromDecibels:[self.audioRecorder.audioPlayer averagePowerForChannel:0]];
            break;
        }
    }
    [self.waveformView updateWithLevel:normalizedValue];
}

- (CGFloat)_normalizedPowerLevelFromDecibels:(CGFloat)decibels
{
    if (decibels < -60.0f || decibels == 0.0f) {
        return 0.0f;
    }
    
    return powf((powf(10.0f, 0.05f * decibels) - powf(10.0f, 0.05f * -60.0f)) * (1.0f / (1.0f - powf(10.0f, 0.05f * -60.0f))), 1.0f / 2.0f);
}


@end
