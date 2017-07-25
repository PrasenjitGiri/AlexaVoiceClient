//
//  UserAgreementViewController.m
//  alexaTestApp
//
//  Created by Prasenjit Giri on 18/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import "UserAgreementViewController.h"

@interface UserAgreementViewController()

@property (weak, nonatomic) IBOutlet UITextView *licenseInfo;
@property (nonatomic, strong) NSString* licenseTerms;
@property (nonatomic, strong) NSString* applicationTerms;
@property (nonatomic, strong) NSString* thirdPartyTerms;
@property (nonatomic, strong) NSString* userTerms;

@end


@implementation UserAgreementViewController

-(void)generateLicenseString{
    
    self.licenseTerms = [@"You accept and agree to be bound by the terms of this agreement by selecting the ""Accept"" option and using the software product. You must agree to all the terms of this agreement before you will be allowed to use this software product. If you do not agree to all of the terms of this agreement, you must select ""Decline"" and you must not use this software.\n\n" uppercaseString];
     
    self.applicationTerms = @"You agree to this software product to record your voice and transmit it over a data network viz Cellular/Wi-Fi and bore the cost of the data exchange";
    self.thirdPartyTerms = @"You agree to process your voice per Alexa Voice Service License Agreement";
    self.userTerms = @"You agree to only use this software product if you are an active employee of Accenture Services Pvt. Ltd.";
    
    NSArray* licenseItems = [[NSArray alloc] initWithObjects:self.userTerms, self.applicationTerms, self.thirdPartyTerms,nil];
    
    NSMutableString* bulletList = [[NSMutableString alloc] initWithString:self.licenseTerms];
    for (NSString* s in licenseItems) {
        [bulletList appendFormat:@"\u2022 %@\n", s];
    }
    
    NSRange range = [bulletList rangeOfString:@"Alexa Voice Service License Agreement"];
    if (range.location != NSNotFound) {
        
        NSMutableAttributedString* strUserAgreement = [[NSMutableAttributedString alloc] initWithString:bulletList];
        NSString* urlAVS = @"https://developer.amazon.com/edw/avs_agreement.html";
        [strUserAgreement addAttribute:NSLinkAttributeName value:urlAVS range:range];
        [self.licenseInfo setAttributedText:strUserAgreement];
        
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
}
- (IBAction)agreedButton:(UIBarButtonItem *)sender {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"licenseAgreed"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}

-(void)viewWillAppear:(BOOL)animated{
    
    self.navigationItem.hidesBackButton = YES;
    [super viewWillAppear:animated];
    [self generateLicenseString];
}
- (IBAction)disagreedButtonClicked:(UIBarButtonItem *)sender {
    
    if ([UIAlertController class])
    {
        // use UIAlertController
        UIAlertController *alert= [UIAlertController
                                   alertControllerWithTitle:@"Enter Folder Name"
                                   message:@"Keep it short and sweet"
                                   preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action){
                                                       //Do Some action here
                                                       UITextField *textField = alert.textFields[0];
                                                       NSLog(@"text was %@", textField.text);
                                                       
                                                   }];
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           
                                                           NSLog(@"cancel btn");
                                                           
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                           
                                                       }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"folder name";
            textField.keyboardType = UIKeyboardTypeDefault;
        }];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else
    {
        // use UIAlertView
        UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"Enter Folder Name"
                                                         message:@"Keep it short and sweet"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"OK", nil];
        
        dialog.alertViewStyle = UIAlertViewStylePlainTextInput;
        dialog.tag = 400;
        [dialog show];
        
    }
    
}

@end
