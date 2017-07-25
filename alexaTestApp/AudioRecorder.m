//
//  AudioRecorder.m
//  alexaTestApp
//
//  Created by Prasenjit Giri on 20/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import "AudioRecorder.h"
#import "ApplicationManager.h"
#import "AudioRecorderViewController.h"

@interface AudioRecorder() <AVAudioPlayerDelegate, AVAudioRecorderDelegate>

@property (nonatomic, strong) NSString* soundFilePath;
@property (nonatomic, strong) NSURL* soundFileURL;
@property (nonatomic, strong) AVAudioSession* audioSession;
@property (nonatomic) BOOL recordingState;
@property (nonatomic, strong) AudioRecorderViewController* parentViewController;

@end

@implementation AudioRecorder

-(BOOL)isRecording{
    return self.recordingState;
}

-(instancetype)initWithParentController:(AudioRecorderViewController *)aViewController{
    self = [self init];
    self.parentViewController = aViewController;
    return self;
    
}
-(instancetype)init{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

#pragma mark - Private methods 
-(void)setup{
    
    NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docsDir = dirPaths[0];
    
    self.soundFilePath = [docsDir stringByAppendingPathComponent:@"alexaRecordedSample.wav"];
    NSLog(@"\nSoundFilePath:%@", self.soundFilePath);
//    recordPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Sound.m4a"];
    self.soundFileURL = [NSURL fileURLWithPath:self.soundFilePath];
    
    //PG: The audio should be encoded as LPCM16 (16-bit linear PCM) format
    NSDictionary *recordSettings=[NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:AVAudioQualityMin],
                                  AVEncoderAudioQualityKey,
                                  [NSNumber numberWithInt:25600],
                                  AVEncoderBitRateKey,
                                  [NSNumber numberWithInt:1],
                                  AVNumberOfChannelsKey,
                                  [NSNumber numberWithFloat:16000.0],
                                  AVSampleRateKey,
                                  [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                  nil];
    
    NSError* error;
    self.audioSession = [AVAudioSession sharedInstance];
    [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker  error:nil];
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:self.soundFileURL settings:recordSettings error:&error];
    
    if (error) {
        NSLog(@"\nERROR:%@", [error localizedDescription]);
    }
    else{
        [self.audioRecorder prepareToRecord];
    }
    self.recordingState = false;
    
}

-(NSData*)loadVoiceFile{
    
    NSData* voiceData;
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0] ;
    path = [path stringByAppendingPathComponent:@"alexaRecordedSample.wav"];
    NSLog(@"\nVoice path file:%@", path);
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        voiceData = [[NSData alloc] initWithContentsOfFile:path];
    }
    return voiceData;
    
}

-(void)saveVoiceFileWith:(NSData*)audioData{
    //    NSData *file;
    //    file = ...
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0] ;
    path = [path stringByAppendingPathComponent:@"alexaRecordedSample.wav"];
    ///Users/prasenjitgiri/Library/Developer/CoreSimulator/Devices/E1979A87-5858-4974-88A4-940C502F8587/data/Containers/Data/Application/52A9C454-7D73-4BF9-9A60-9273C92A2965/Documents/alexaRecordedSample.wav
    [[NSFileManager defaultManager] createFileAtPath:path
                                            contents:audioData
                                          attributes:nil];

    
}

-(void)saveResponseFileWith:(NSData*)audioData{
    //    NSData *file;
    //    file = ...
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0] ;
    path = [path stringByAppendingPathComponent:@"alexaResponseSample.wav"];
    NSLog(@"\nResponse path:%@", path);
    ///Users/prasenjitgiri/Library/Developer/CoreSimulator/Devices/E1979A87-5858-4974-88A4-940C502F8587/data/Containers/Data/Application/52A9C454-7D73-4BF9-9A60-9273C92A2965/Documents/alexaRecordedSample.wav
    [[NSFileManager defaultManager] createFileAtPath:path
                                            contents:audioData
                                          attributes:nil];
    
    
}

-(void)saveRecordedData{
    
    NSMutableData *audioData=[NSMutableData dataWithContentsOfFile:self.soundFilePath];
    [[ApplicationManager sharedManager] setAudioData:audioData];
}
#pragma mark - Recorder delegates
-(void)record{
    self.recordingState = true;
    [self.audioRecorder record];
}

-(void)play{
    if (!self.audioRecorder.recording) {
        NSError* error;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioRecorder.url error:&error];
        self.audioPlayer.delegate = self;
        if (error) {
            NSLog(@"\nERROR:%@", [error localizedDescription]);
        }
        else{
            [self.audioPlayer play];
        }
    }
    
}
-(void)stop{
    if (self.audioRecorder.recording) {
        [self.audioRecorder stop];
        [self saveRecordedData];
        
    }
    else if(self.audioPlayer.playing){
        [self.audioPlayer stop];
        
    }
    self.recordingState = false;
    
//     [[ApplicationManager sharedManager] setAudioData:[self loadVoiceFile]];
}

-(void)playAudioData:(NSData*)audioData
{
    NSError* error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
    self.audioPlayer.delegate = self;
    NSLog(@"\nAudioResponseError:%@", [error localizedDescription]);
    if (!error) {
//        [self saveResponseFileWith:audioData];
        [self.audioPlayer play];
    }
    
}

#pragma mark  - Audio player delegates
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"\naudioPlayerDidFinishPlaying");
    //PG: Notify controller
    [self.parentViewController hideRecordButton:false];
    
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"\naudioPlayerDecodeErrorDidOccur");
}
#pragma mark - Audio recorder delegates
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"\naudioRecorderDidFinishRecording");
}
-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    NSLog(@"\naudioRecorderEncodeErrorDidOccur");
}
@end
