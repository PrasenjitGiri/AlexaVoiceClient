//
//  AudioRecorderViewController.h
//  alexaTestApp
//
//  Created by Prasenjit Giri on 20/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioRecorderViewController : UIViewController

@property (nonatomic, strong) NSString* audioFilePath;

-(void)playAudioResponseData:(NSData*)audioData;
-(void)hideRecordButton:(BOOL)flag;
-(void)hideActivityIndicator:(BOOL)flag;

@property (weak, nonatomic) IBOutlet UIButton *buttonRecord;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@end
