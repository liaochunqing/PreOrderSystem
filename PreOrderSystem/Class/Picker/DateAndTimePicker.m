//
//  DateAndTimePicker.m
//  PreOrderSystem
//
//  Created by AaronKwok on 12-6-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DateAndTimePicker.h"
#import "Constants.h"

@interface DateAndTimePicker (Private)
-(IBAction)doneButtonPressed:(UIButton*)sender;
@end

@implementation DateAndTimePicker
@synthesize delegate;
@synthesize tag;
@synthesize PickerType;
@synthesize date;
@synthesize minimumDate;
@synthesize datePicker;
@synthesize trueButton;

#pragma mark LIFE CYCLE
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addLocalizedString];
    
    if (date) {
        datePicker.date = date;
    }
    if (minimumDate) {
        datePicker.minimumDate = minimumDate;
    }
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    if (date) {
        datePicker.date = date;
    }
    if (minimumDate) {
        datePicker.minimumDate = minimumDate;
    }
    self.view.backgroundColor = kSystemVersionIsIOS7?[UIColor clearColor]:[UIColor darkTextColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ((kSystemVersionOfCurrentDevice >= 6.0) && [self isViewLoaded] && ![self.view window])
    {
        [self setView:nil];
    }
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",[self class]);
#endif
}

- (void)addLocalizedString
{
    [self.trueButton setTitle:kLoc(@"confirm") forState:UIControlStateNormal];
}

-(IBAction)doneButtonPressed:(UIButton*)sender{
    if ([delegate respondsToSelector:@selector(DateAndTimePicker:didPickedDate:)]) {
        [delegate DateAndTimePicker:self didPickedDate:datePicker.date];
    }
}

@end
