//
//  EditArrangInfoViewController.m
//  PreOrderSystem
//
//  Created by sWen on 13-3-20.
//
//

#import "EditQRCodeInfoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "UIImage+imageWithContentsOfFile.h"

@interface EditQRCodeInfoViewController ()

@end

@implementation EditQRCodeInfoViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.contentSizeForViewInPopover = CGSizeMake(635, 200);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addPictureToView];
    
    self.infoTextView.layer.cornerRadius = 20;
    self.infoTextView.layer.masksToBounds = YES;
    self.infoTextView.text = kLoc(@"edit_qrcode_message");
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

- (void)addPictureToView
{
    self.bgImageView.image = [UIImage imageFromMainBundleFile:@"callService_infoBg.png"];
}

@end
