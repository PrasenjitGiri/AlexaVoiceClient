//
//  FooterView.m
//  alexaTestApp
//
//  Created by Prasenjit Giri on 24/12/15.
//  Copyright © 2015 PrasenjitGiri. All rights reserved.
//

#import "FooterView.h"

@interface FooterView()

@property (strong, nonatomic) IBOutlet UIView *view;

@end

@implementation FooterView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super initWithCoder:aDecoder]) {
        
        [self xibSetup];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
    
        [self xibSetup];
    }
    return self;
}

#pragma mark - Private methods 
-(void)xibSetup{
    
    self.view = [self loadViewFromNib];
    self.bounds = self.view.bounds;
//    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth ];
//    [self.view setTranslatesAutoresizingMaskIntoConstraints:false];
    [self addSubview:self.view];
}

-(UIView*)loadViewFromNib{
    //PG: Load the interface file from .xib
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString *className = NSStringFromClass([self class]);
    UINib* nib = [UINib nibWithNibName:className bundle:bundle];
    
    UIView* view = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
    
    return view;
}

- (void)layoutSubviews{
    
}

@end
