//
//  AVSUploader.m
//  alexaTestApp
//
//  Created by Prasenjit Giri on 20/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import "AVSUploader.h"
#import "PartData.h"
#import "NSData+MultipartResponses.h"

@interface AVSUploader()

@property (nonatomic, strong) NSString* urlString;

@end

@implementation AVSUploader

-(instancetype)initWithParentController:(AudioRecorderViewController *)aViewController{
    self =  [self init];
    self.parentController = aViewController;
    return self;
}

-(instancetype)init{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}


-(void)setup{
    self.urlString = @"https://access-alexa-na.amazon.com/v1/avs/speechrecognizer/recognize";
}
-(void)postRecording{
    
    //PG: Multi-part => http://www.w3.org/Protocols/rfc1341/7_2_Multipart.html
    //PG: Read => http://nthn.me/posts/2012/objc-multipart-forms.html
    //PG: AVS Requests => https://developer.amazon.com/public/solutions/alexa/alexa-voice-service/rest/speechrecognizer-requests#message-body-json-object
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    request.HTTPShouldHandleCookies = false;
    request.timeoutInterval = 60;
    request.HTTPMethod = @"POST";
    [request addValue:[NSString stringWithFormat:@"Bearer %@",self.accessToken] forHTTPHeaderField:@"Authorization"];
    
    NSString* boundry = [[NSUUID UUID] UUIDString];
    NSString* contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundry];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"access-alexa-na.amazon.com" forHTTPHeaderField:@"Host"];
    
    //PG: Lookup => http://stackoverflow.com/questions/24250475/post-multipart-form-data-with-objective-c

    NSMutableData* httpBody = [NSMutableData data];
    [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"request\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: application/json; charset=UTF-8\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //PG: JSON multipart body
    [httpBody appendData:[[self createMetaData] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //PG: JSON Audio multipart header
    [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundry] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"audio\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: audio/L16; rate=16000; channels=1\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //PG: Audio multipart body
    [httpBody appendData:self.audioData];
    [httpBody appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //PG: Terminating boundary term
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //PG: AMZN REST API Response codes => https://developer.amazon.com/public/apis/experience/cloud-drive/content/restful-api-response-codes
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                               fromData:httpBody completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                   // Handle response here
                                                                   if (!error) {
                                                                       
                                                                       
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           [self.parentController hideActivityIndicator:true];
                                                                       });
                                                                       
#pragma  TODO Fix other response code error
                                                                       
                                                                       NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                                                       NSLog(@"\nResponse code: %ld", httpResponse.statusCode);
                                                                       
                                                                       if (httpResponse.statusCode >=200 && httpResponse.statusCode <=299) {
                                                                           NSData* responseData = data;
                                                                           NSString* contentTypeHeader = [httpResponse.allHeaderFields objectForKey:@"Content-Type"];
                                                                           NSString* boundary;
                                                                           //PG: Regex => http://regexr.com/
                                                                           NSRange contentTypeBoundary = [contentTypeHeader rangeOfString:@"boundary=.*?;" options:NSRegularExpressionSearch];
                                                                          //PG: Step 1: Fetch the boundary
                                                                           if (contentTypeBoundary.location != NSNotFound) {
                                                                               NSString* boundaryNSS = [contentTypeHeader substringWithRange:contentTypeBoundary];
                                                                               boundary = [boundaryNSS substringWithRange: NSMakeRange(9, [boundaryNSS length]-10)];
                                                                            }
                                                                           
                                                                           //PG: Parse data if boundary is present
                                                                           if ([boundary length] !=0) {
//                                                                               PartData* partData = [self parseResponseWith:responseData withBoundry:boundry];
//                                                                               NSArray* responseArray = [self multipartArrayWithBoundary:boundry withData:responseData];
                                                                               
                                                                               NSDictionary* resultDictionary = [responseData multipartDictionary];
                                                                               NSLog(@"\nDictionary:%@", resultDictionary);
                                                                               NSData* voiceResult = [[resultDictionary objectForKey:@"2"] objectForKey:@"data"];
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   [self.parentController playAudioResponseData:voiceResult];
                                                                               });
                                                                               
                                                                           }
                                                                           else{
                                                                               NSLog(@"\nERROR: Boundary not found in AVS response");
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   [self.parentController hideRecordButton:false];
                                                                               });
    
                                                                           }
                                                                           
                                                                        }
                                                                   }
                                                                   else{
                                                                   //PG: Connection Error
                                                                       NSLog(@"\nUpload Error:%@", [error localizedDescription]);
                                                                   }
                                                               }];
    [uploadTask resume];

}


-(PartData*)parseResponseWith:(NSData*) data withBoundry:(NSString*)boundry {
    
    //PG: Working with binary data => https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/BinaryData/Tasks/WorkingBinaryData.html
    //PG: AVS Response=> https://developer.amazon.com/public/solutions/alexa/alexa-voice-service/rest/speechrecognizer-responses
    //PG: Stackoverflow => http://stackoverflow.com/questions/27808830/nsdata-multi-part-response-from-nsurlconnection
    
    NSData* innerBoundry = [[NSString stringWithFormat:@"--%@\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding];
//    NSData* endBoundry = [[NSString stringWithFormat:@"--\r\n%@--\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableArray* innerRanges = [[NSMutableArray alloc] init]; //PG: Array collection to hold NSRanges
    unsigned long lastStartingLocation = 0;
    
    NSRange boundryRange = [data rangeOfData:innerBoundry options:NSDataSearchAnchored range:NSMakeRange(lastStartingLocation, [data length])];
    
    while (boundryRange.location != NSNotFound) {
        
        lastStartingLocation = boundryRange.location + boundryRange.length;
        boundryRange = [data rangeOfData:innerBoundry options:NSDataSearchAnchored range:NSMakeRange(lastStartingLocation, [data length] - lastStartingLocation)];
        
        if (boundryRange.location != NSNotFound) {
            
             //PG: NOTE=> Swap NSRange with NSValue as NSMutableArray can only store objects; so unwrap to NSRange from function-> rangeValue
            [innerRanges addObject:[NSValue valueWithRange: NSMakeRange(lastStartingLocation, boundryRange.location - [innerBoundry length])]];
         }
        else{
            [innerRanges addObject:[NSValue valueWithRange:NSMakeRange(lastStartingLocation, [data length] - lastStartingLocation)]];
        }
    }
    
    PartData* partData = [[PartData alloc] init];
//    for (int i =0; i < [innerRanges count]; i++) {
//        NSRange innerRange = [[innerRanges objectAtIndex:i] rangeValue];
//        NSData* innerData = [data subdataWithRange:innerRange];
//        NSRange headerRange = [innerData rangeOfData:[[NSString stringWithFormat:@"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding] options:NSDataSearchAnchored range:NSMakeRange(0, innerRange.length)];
//        
//        NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];
//        NSString* headerData = [[NSString alloc] initWithData:[innerData subdataWithRange:NSMakeRange(0, headerRange.location)] encoding:NSUTF8StringEncoding];
//        if (headerData) {
//            NSString* headerLine =
//        }
//        
//    }
//        
//    }

return partData;
    
}

- (NSArray *)multipartArrayWithBoundary:(NSString *)boundary withData:(NSData*)resonseData
{
    NSString *data = [[NSString alloc] initWithData:resonseData encoding:NSUTF8StringEncoding];
    
    NSArray *multiparts = [data componentsSeparatedByString:[@"--" stringByAppendingString:boundary]]; // remove boundaries
    multiparts = [multiparts subarrayWithRange:NSMakeRange(1, [multiparts count]-2)]; // continued removing of boundaries
    
    NSMutableArray *toReturn = [NSMutableArray arrayWithCapacity:2];
    for(NSString __strong *part in multiparts)
    {
        part = [part stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *separated = [part componentsSeparatedByString:@"\n\n"];
        
        NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithCapacity:3];
        for(NSString *headerLine in [[separated objectAtIndex:0] componentsSeparatedByString:@"\n"])
        {
            NSArray *keyVal = [headerLine componentsSeparatedByString:@":"];
            
            [headers setObject:[[keyVal objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:[[keyVal objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
        
        [toReturn addObject:[NSDictionary dictionaryWithObjectsAndKeys:[[separated objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding], @"body", headers, @"headers", nil]];
    }
    
    return toReturn;
}



-(NSString*)createMetaData{
    
    NSMutableDictionary* rootElement = [[NSMutableDictionary alloc] init];
    //PG: Message Header section
    NSDictionary* deviceContextPayload = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"streamId", @"0", @"offsetInMilliseconds", @"IDLE", @"playerActivity",nil];
//    NSLog(@"\nPayload:%@", deviceContextPayload);
    NSDictionary* deviceContext = [NSDictionary dictionaryWithObjectsAndKeys:@"playbackState",@"name",@"AudioPlayer",@"namespace",deviceContextPayload,@"payload", nil];
//    NSLog(@"\nDeviceContext: %@", deviceContext);
    [rootElement setObject:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:deviceContext] forKey:@"deviceContext"] forKey:@"messageHeader" ];
//    NSLog(@"\nMessageHeader: %@", rootElement);
    
    //PG: Message body section
    NSDictionary* messageBodyParameters = [NSDictionary dictionaryWithObjectsAndKeys:@"audio/L16; rate=16000; channels=1", @"format", @"en-us", @"locale", @"alexa-close-talk", @"profile", nil];
//    NSLog(@"\nMessageBody:%@", messageBodyParameters);
    [rootElement setObject:messageBodyParameters forKey:@"messageBody"];
    
//    NSLog(@"\nRoot element: %@", rootElement);
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:rootElement options:NSJSONWritingPrettyPrinted error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSLog(@"\nJSON String: %@", jsonString);
    return jsonString;
}
@end
