//
//  DishCardItemDetailPicker.m
//  PreOrderSystem
//
//  Created by AaronKwok on 13-4-15.
//  jhh_菜牌_详情
//

#import "DishCardItemDetailPicker.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "OfflineManager.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "NsstringAddOn.h"
#import "PSAlertView.h"
#import "UIDevice+platform.h"
#import "PSPopoverBckgroundView.h"
#import "WEPopoverController.h"
#import "MainViewController.h"

#define kCumtomDarkGray [UIColor colorWithRed:76.0/255.0 green:76.0/255.0 blue:76.0/255.0 alpha:1.0]
#define kOptionalLabelTag 1000
#define kSerialNumTextfieldTag 2000
#define kDishNameTextfieldTag 3000
#define kpackfeeTextfieldTag 4000
#define kDishNameLength 14
#define kMinPackfee 0
#define kMaxPackfee 1000
#define kDCItmePriceArray [dishCardDict objectForKey:@"price"]

@interface DishCardItemDetailPicker ()

- (IBAction)dismissButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)isSoldOutButtonPressed:(id)sender;
- (IBAction)itemPicButtonPressed:(id)sender;
- (IBAction)editItemPicButtonPressed:(id)sender;
- (IBAction)takeoutAvailableButtonPressed:(id)sender;
- (void)addNotification;
- (void)updateViewAfterGetData;
- (void)addFrameToView;
- (UIView *)addSerialNumView;
- (void)hideKeyboard;

@end

@implementation DishCardItemDetailPicker
@synthesize delegate;
@synthesize itemPicImageview;
@synthesize bgImageView;
@synthesize itemTableview;
@synthesize takeoutAvailableButton;
@synthesize isSoldOutButton;
@synthesize editPicButton;
@synthesize activityView;
@synthesize dishCardDict;

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
    
    self.trueButton.enabled = self.isEditEnable;
    [self addNotification];
    [self addFrameToView];
    [self addPictureToView];
    [self addLocalizedString];
    
    if (![[UIDevice platformString]isEqualToString:@"iPad 1"])
    {
        [self addTapGesture];
#ifdef DEBUG
        NSLog(@"===%@,%@===",[self class],[UIDevice platformString]);
#endif
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self removeNotification];
    itemSerialNumTextfield = nil;
    itemDishNameTextfield = nil;
    itemDishDescripTextview = nil;
    optionalLabel = nil;
    dishCardDict = nil;
    jsonPicker = nil;
    imgBaseURL = nil;
    selectedPriceCell = nil;
    
#ifdef DEBUG
    NSLog(@"===DishCardItemDetailPicker,viewDidUnload===");
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ((kSystemVersionOfCurrentDevice >= 6.0) && [self isViewLoaded] && ![self.view window])
    {
        //[self viewDidUnload];
        //[self setView:nil];
    }
}

- (void)dealloc
{
    [self removeNotification];
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",[self class]);
#endif
}

#pragma mark - PUBLIC METHODS

- (void)updateViewWithCuisineID:(int)cid withImgBaseURL:(NSString *)imageURL
{
    isEditing = NO;
    cuisineID = cid;
    imgBaseURL = imageURL;
    isAllowTakeout = 1;
    isSoldOut = 0;
    self.packfeeTextField.text = @"0";
    self.dishCardDict = [[NSMutableDictionary alloc]initWithCapacity:3];
    [self addNewItemCell];
    [itemTableview reloadData];
}

- (void)updateViewWithDishInfo:(NSDictionary *)info withImgBaseURL:(NSString *)imageURL
{
    isEditing = YES;
    imgBaseURL = imageURL;
    self.dishCardDict = [[NSMutableDictionary alloc]initWithDictionary:info];
    [self addNewItemCell];
    [self updateViewAfterGetData];
}

#pragma mark - PRIVATE METHODS

- (void)addLocalizedString
{
    
    self.takeOutLabel.text = [NSString stringWithFormat:@"%@ : ",kLoc(@"support_takeout")];
    self.soldOutLabel.text = [NSString stringWithFormat:@"%@ : ",kLoc(@"whether_out_of_stock")];
    self.packfeeLabel.text = [NSString stringWithFormat:@"%@ : ",kLoc(@"packing_fee")];
    self.yuanLabel.text = kLoc(@"yuan");
    self.packfeeTextField.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"required_to_fill")];

}

- (void)addTapGesture
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapGestureRecognizer addTarget:self action:@selector(handleTapGestureRecognizer:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)handleTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    [self hideKeyboard];
}

//加边框
- (void)addFrameToView
{
    self.itemPicBgImageview.layer.borderColor = [[UIColor colorWithRed:182.0/255.0 green:182.0/255.0 blue:182.0/255.0 alpha:1.0]CGColor];
    self.itemPicBgImageview.layer.borderWidth = 2;
    
    activityView.hidden = YES;
}

- (void)addPictureToView
{
    bgImageView.image = [UIImage imageFromMainBundleFile:@"dishCard_background.png"];
    //繁体
    if (![kCurrentLanguageOfDevice isEqualToString:kChineseFamiliarStyle])
    {
        [self.editPicButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_editPicButton_traditional.png"] forState:UIControlStateNormal];
    }
}

- (void)updateViewAfterGetData
{
    cuisineID = [[dishCardDict objectForKey:@"id"] intValue];
    //是否提供外卖
    isAllowTakeout = [[dishCardDict objectForKey:@"isAllowTakeout"] intValue];
    if (isAllowTakeout == 1)
    {
        [takeoutAvailableButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_check.png"] forState:UIControlStateNormal];
        self.packfeeTextField.hidden = NO;
        self.packfeeImgBg.hidden = NO;
        self.packfeeLabel.hidden = NO;
        self.yuanLabel.hidden = NO;
        //打包费
        CGFloat pacefee = [[dishCardDict objectForKey:@"packfee"]floatValue];
        NSString *tempString = [NSString stringWithFormat:@"%.2f", pacefee];
        self.packfeeTextField.text = [NSString stringWithFormat:@"%@", [NSString trimmingZeroInPrice:tempString]];
    }
    else
    {
        [takeoutAvailableButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_uncheck.png"] forState:UIControlStateNormal];
        self.packfeeTextField.hidden = YES;
        self.packfeeImgBg.hidden = YES;
        self.packfeeLabel.hidden = YES;
        self.yuanLabel.hidden = YES;
    }
    
    //是否沽清
    isSoldOut = [[dishCardDict objectForKey:@"isSoldOut"] intValue];
    if (isSoldOut == 1)
    {
        [isSoldOutButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_check.png"] forState:UIControlStateNormal];
    }
    else
    {
        [isSoldOutButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_uncheck.png"] forState:UIControlStateNormal];
    }
    //菜的图片
    NSString *dishesPicture = [dishCardDict objectForKey:@"picture"];
    if ([dishesPicture length]>0)
    {
        //从本地加载图片
        OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
        if ([offlineMgr isOfflinePhotoExistWithFileName:[dishesPicture lastPathComponent]])
        {
            itemPicImageview.image = [offlineMgr offlinePhotoWithFileName:[dishesPicture lastPathComponent]];
        }
        else
        {
            activityView.hidden = NO;
            [activityView startAnimating];
            //从网络下载图片
            DataDownloader *downloader = [[DataDownloader alloc] init];
            downloader.delegate = self;
            [downloader parseWithURL:[NSString stringWithFormat:@"%@%@",imgBaseURL,dishesPicture] type:DataDownloaderTypePic];
        }
    }
    //编号
    itemSerialNumTextfield.text =  [[dishCardDict objectForKey:@"code"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //菜名
    itemDishNameTextfield.text = [[dishCardDict objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //介绍
    itemDishDescripTextview.text = [[dishCardDict objectForKey:@"introduction"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //价格
    [itemTableview reloadData];
}

- (void)addNewItemCell
{
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"style", @"", @"price",[NSNumber numberWithInt:0],  @"",  nil];
    NSMutableArray *priceArray = [[NSMutableArray alloc] initWithArray:kDCItmePriceArray];
    [priceArray insertObject:info atIndex:0];
    [self.dishCardDict setObject:priceArray forKey:@"price"];
}

- (void)dismissView
{
    if ([delegate respondsToSelector:@selector(dismissDishCardItemDetailPicker:)])
    {
        [delegate dismissDishCardItemDetailPicker:self];
    }
}

//收起键盘
- (void)hideKeyboard
{
    [itemSerialNumTextfield resignFirstResponder];
    [itemDishNameTextfield resignFirstResponder];
    [itemDishDescripTextview resignFirstResponder];
    NSInteger priceNum = [[dishCardDict objectForKey:@"price"] count];
    for (NSInteger counter = 0; counter < priceNum; counter++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:counter inSection:kTableViewFourthSection];
        DishCardItemPriceTableviewCell *cell = (DishCardItemPriceTableviewCell *)[self.itemTableview cellForRowAtIndexPath:indexPath];
        if ([cell.itemStyleTextfield isFirstResponder])
        {
            [cell.itemStyleTextfield resignFirstResponder];
            break;
        }
    }
}

#pragma mark Button Pressed

//取消按钮点击
-(IBAction)dismissButtonPressed:(id)sender
{
    [self hideKeyboard];
    [self dismissView];
}

//确定按钮点击
-(IBAction)doneButtonPressed:(id)sender
{
    [self hideKeyboard];
    [self addItemAnimated:YES];
}

//是否提供外卖
-(IBAction)takeoutAvailableButtonPressed:(id)sender
{
    isAllowTakeout = !isAllowTakeout;
    if (isAllowTakeout == 1)
    {
        [takeoutAvailableButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_check.png"] forState:UIControlStateNormal];
        self.packfeeTextField.hidden = NO;
        self.packfeeImgBg.hidden = NO;
        self.packfeeLabel.hidden = NO;
        self.yuanLabel.hidden = NO;
    }
    else
    {
        [takeoutAvailableButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_uncheck.png"] forState:UIControlStateNormal];
        self.packfeeTextField.hidden = YES;
        self.packfeeImgBg.hidden = YES;
        self.packfeeLabel.hidden = YES;
        self.yuanLabel.hidden = YES;
    }
}

//是否沽清
-(IBAction)isSoldOutButtonPressed:(id)sender
{
    isSoldOut = !isSoldOut;
    if (isSoldOut == 1)
    {
        [isSoldOutButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_check.png"] forState:UIControlStateNormal];
    }
    else
    {
        [isSoldOutButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_uncheck.png"] forState:UIControlStateNormal];
    }
}

//菜品图片点击
-(IBAction)itemPicButtonPressed:(id)sender
{
    //jhh_edit
    [self hideKeyboard];
    if (itemPicImageview.image)
    {
//        XANImageViewController *xan = [[XANImageViewController alloc] initWithInitialImageIndex:0 dataSource:self delegate:nil];
//        xan.showsDoneButton = YES;
//        
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:xan];
//        nav.modalPresentationStyle = UIModalPresentationFullScreen;
//        nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//        
//        UIViewController *rootController = self.view.window.rootViewController;
//        [rootController presentViewController:nav animated:YES completion:nil];
        
        //self.view.hidden = YES;
        [[DisplayHelper shareDisplayHelper] showLoading];
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW , NSEC_PER_SEC * 0.5);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            // 获取图片数据
            UIImage *targetImage = itemPicImageview.image;
            PhotoReviewView *photoView = [[PhotoReviewView alloc] initWithFrame:CGRectZero];
            photoView.photoData = targetImage;
            [[DisplayHelper shareDisplayHelper] hideLoading];
            
            [photoView show];
        });
        
    }
}

//编辑菜品图片按钮点击
-(IBAction)editItemPicButtonPressed:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:kLoc(@"take_photo"), kLoc(@"browse_album"), nil];
    actionSheet.tag = 1;
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:editPicButton.frame inView:self.view animated:YES];
    }
}

#pragma mark get photo by UIImagePickerController

//拍照
- (void)browseFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (!kIsiPhone) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        }
        
        UIImagePickerController *takePhotoController = [[UIImagePickerController alloc] init];
        takePhotoController.sourceType =  UIImagePickerControllerSourceTypeCamera;
        takePhotoController.delegate = self;
        [self presentViewController:takePhotoController animated:YES completion:nil];
    } else {
        [PSAlertView showWithMessage:kLoc(@"sorry_camera_not_support_for_your_device")];
    }
}

-(void)browseFromPhotoAlbum
{
    if (YES == (kSystemVersionOfCurrentDevice >= 6.0))
    {
        if (NO == [self canLoadPhotoAlbum])
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:kLoc(@"etable_dont_have_permission_to_read_your_photos") delegate:nil cancelButtonTitle:kLoc(@"i_know") otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ||
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.delegate = self;
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self.popover dismissPopoverAnimated:NO];
        if (kIsiPhone) {
            self.popover = [[WEPopoverController alloc] initWithContentViewController:controller];
            MainViewController *mainCtrl = [MainViewController getMianViewShareInstance];
            CGRect showRect = [self.view convertRect:self.editPicButton.frame toView:mainCtrl.view];
            [self.popover setParentView:mainCtrl.view];
            [self.popover presentPopoverFromRect:showRect
                                          inView:mainCtrl.view
                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                        animated:YES];
        } else {
            self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
            [self.popover presentPopoverFromRect:self.editPicButton.frame
                                          inView:self.view
                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                        animated:YES];
        }
    }
    else
    {
        [PSAlertView showWithMessage:kLoc(@"sorry_your_device_has_not_album")];
    }
}

/*图片截图*/
- (void)openEditor:(UIImage *)pic
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = pic;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

//是否有相片的访问权限
-(BOOL)canLoadPhotoAlbum
{
    switch ([ALAssetsLibrary authorizationStatus])
    {
        case ALAuthorizationStatusAuthorized:
            return YES;
            break;
        case ALAuthorizationStatusDenied:
            return NO;
            break;
        case ALAuthorizationStatusNotDetermined:
            return YES;
            break;
        case ALAuthorizationStatusRestricted:
            return YES;
            break;
    }
}

#pragma mark cellView

//初始化编号cell
- (UIView *)addSerialNumView
{
    UIView *itemSerialNumView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 45)];
    itemSerialNumView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 75, 55)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = kCumtomDarkGray;
    label.font = [UIFont boldSystemFontOfSize:20];
    //label.text = kLoc(@"编号 ：", nil);
    label.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"serial_number")];

    [itemSerialNumView addSubview:label];
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(67, 5, 255, 35)];
    bg.image =[UIImage imageFromMainBundleFile:@"dishCardItem_SerialNumTextfield.png"];
    [itemSerialNumView addSubview:bg];
    
    if (!itemSerialNumTextfield)
    {
        itemSerialNumTextfield = [[UITextField alloc] initWithFrame:CGRectMake(70+5, 10, 255-20, 30)];
        itemSerialNumTextfield.delegate = self;
        itemSerialNumTextfield.tag = kSerialNumTextfieldTag;
        itemSerialNumTextfield.returnKeyType = UIReturnKeyDone;
        itemSerialNumTextfield.borderStyle = UITextBorderStyleNone;
        itemSerialNumTextfield.textAlignment = UITextAlignmentCenter;
        itemSerialNumTextfield.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"optional")];

        itemSerialNumTextfield.textColor = [UIColor orangeColor];
        itemSerialNumTextfield.font = [UIFont systemFontOfSize:20];
        itemSerialNumTextfield.text = [dishCardDict objectForKey:@"code"];
    }
    [itemSerialNumView addSubview:itemSerialNumTextfield];
    
    return itemSerialNumView;
}

//初始化菜名的view
- (UIView *)addDishNameView
{
    UIView *itemDishNameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 45)];
    itemDishNameView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 75, 45)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = kCumtomDarkGray;
    label.font = [UIFont boldSystemFontOfSize:20];
    //label.text = kLoc(@"菜名 ：", nil);
    label.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"dish_name")];

    [itemDishNameView addSubview:label];
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(67, 5, 255, 35)];
    bg.image =[UIImage imageFromMainBundleFile:@"dishCardItem_SerialNumTextfield.png"];
    [itemDishNameView addSubview:bg];
    
    if (!itemDishNameTextfield)
    {
        itemDishNameTextfield = [[UITextField alloc] initWithFrame:CGRectMake(70+5, 10, 255-20, 30)];
        itemDishNameTextfield.delegate = self;
        itemDishNameTextfield.tag = kDishNameTextfieldTag;
        itemDishNameTextfield.returnKeyType = UIReturnKeyDone;
        itemDishNameTextfield.borderStyle = UITextBorderStyleNone;
        itemDishNameTextfield.textAlignment = UITextAlignmentCenter;
        //itemDishNameTextfield.placeholder = kLoc(@"(必填)", nil);
        
        itemDishNameTextfield.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"required_to_fill")];

        itemDishNameTextfield.textColor = [UIColor orangeColor];
        itemDishNameTextfield.font = [UIFont systemFontOfSize:20];
        itemDishNameTextfield.text = [dishCardDict objectForKey:@"name"];
    }
    [itemDishNameView addSubview:itemDishNameTextfield];
    
    return itemDishNameView;
}

//初始化菜品介绍view
- (UIView *)addDishDescripView
{
    UIView *itemDishDescripView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 77)];
    itemDishDescripView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 75, 77)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = kCumtomDarkGray;
    label.font = [UIFont boldSystemFontOfSize:20];
    //label.text = kLoc(@"介绍 ：", nil);
    
    label.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"introduction")];

    [itemDishDescripView addSubview:label];
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(67, 5, 255, 67)];
    bg.image =[UIImage imageFromMainBundleFile:@"dishCardItem_descriptionTextfield.png"];
    [itemDishDescripView addSubview:bg];
    
    if (!optionalLabel)
    {
        optionalLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 10, 255, 60)];
    }
    optionalLabel.tag= kOptionalLabelTag;
    optionalLabel.backgroundColor = [UIColor clearColor];
    optionalLabel.textAlignment = UITextAlignmentCenter;
    optionalLabel.textColor = [UIColor lightGrayColor];
    optionalLabel.font = [UIFont systemFontOfSize:20];
    //optionalLabel.text = kLoc(@"(选填)", nil);
    optionalLabel.text = [NSString stringWithFormat:@"(%@)",kLoc(@"optional")];
    optionalLabel.hidden = NO;
    [itemDishDescripView addSubview:optionalLabel];
    
    if (!itemDishDescripTextview)
    {
        itemDishDescripTextview = [[UITextView alloc] initWithFrame:CGRectMake(65, 5, 255, 60)];
        itemDishDescripTextview.delegate = self;
        itemDishDescripTextview.backgroundColor = [UIColor clearColor];
        itemDishDescripTextview.font = [UIFont systemFontOfSize:20];
        itemDishDescripTextview.textColor = [UIColor orangeColor];
        itemDishDescripTextview.textAlignment = UITextAlignmentCenter;
        NSString *introductionStr = [[dishCardDict objectForKey:@"introduction"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (0 != [introductionStr length])
        {
            itemDishDescripTextview.text = introductionStr;
        }
    }
    if (0 != [[itemDishDescripTextview.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length])
    {
        optionalLabel.hidden = YES;
    }
    [itemDishDescripView addSubview:itemDishDescripTextview];
    
    return itemDishDescripView;
}

#pragma mark network

//添加或修改item
- (void)addItemAnimated:(BOOL)animated
{
    //postData
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    
    if (isAllowTakeout)
    {
        NSString *packfeeStr = [self.packfeeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (0 == [packfeeStr length])
        {
            packfeeStr = @"0";
//            [PSAlertView showWithMessage:kLoc(@"打包费不能为空!", nil)];
//            return;
        }
        //打包费
        [postData setObject:packfeeStr forKey:@"packfee"];
    }
    
    NSString *itemDishName = [itemDishNameTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([itemDishName length]==0)
    {
        [PSAlertView showWithMessage:[NSString stringWithFormat:@"%@!",kLoc(@"dish_name_can_not_be_empty")]];
        return;
    }
    
    //整理价格
    NSMutableArray *prices = [[NSMutableArray alloc] init];
    NSInteger priceCount = [kDCItmePriceArray count];
    if (1 >= priceCount)
    {
        NSDictionary *priceDict = [kDCItmePriceArray firstObject];
        NSString *styleStr = [ [NSString stringWithFormat:@"%@", [priceDict objectForKey:@"style"]]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *priceStr = [[NSString stringWithFormat:@"%@", [priceDict objectForKey:@"price"]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (![styleStr isEqualToString:@""] && ![priceStr isEqualToString:@""])
        {
            NSMutableDictionary *priceInfo = [[NSMutableDictionary alloc] init];
            [priceInfo setObject:styleStr forKey:@"style"];
            [priceInfo setObject:priceStr forKey:@"price"];
            [priceInfo setObject:[NSNumber numberWithInt:0] forKey:@"priceType"];
            [prices addObject:priceInfo];
        }
        else
        {
            [PSAlertView showWithMessage:kLoc(@"please_add_cuisine_price")];
            return;
        }
    }
    else
    {
        //判断规格是否重复了
        BOOL isRepeat = NO;
        NSInteger tempIndex = 0;
        NSString *firstStyleName = [[kDCItmePriceArray firstObject] objectForKey:@"style"];
        for (NSDictionary *priceDict in kDCItmePriceArray)
        {
            if (kZeroNumber != tempIndex)
            {
                NSString *styleName = [priceDict objectForKey:@"style"];
                if ([styleName isEqualToString:firstStyleName])
                {
                    isRepeat = YES;
                    break;
                }
                
//                for (NSDictionary *tempDict in kDCItmePriceArray)
//                {
//                    NSString *tempName = [tempDict objectForKey:@"style"];
//                    if (tempDict != priceDict && [styleName isEqualToString:tempName])
//                    {
//                        isRepeat = YES;
//                        break;
//                    }
//                }
                
            }
            tempIndex++;
        }
        if (isRepeat)
        {
            [self showWarnWhenAreaNameRepeat];
            return;
        }
        for (int i = 0; i<[kDCItmePriceArray count]; i++)
        {
            NSDictionary *priceDict = [kDCItmePriceArray objectAtIndex:i];
            NSString *styleStr = [ [NSString stringWithFormat:@"%@", [priceDict objectForKey:@"style"]]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *priceStr = [[NSString stringWithFormat:@"%@", [priceDict objectForKey:@"price"]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if (![styleStr isEqualToString:@""] && ![priceStr isEqualToString:@""])
            {
                NSMutableDictionary *priceInfo = [[NSMutableDictionary alloc] init];
                [priceInfo setObject:styleStr forKey:@"style"];
                [priceInfo setObject:priceStr forKey:@"price"];
                [priceInfo setObject:[NSNumber numberWithInt:0] forKey:@"priceType"];
                [prices addObject:priceInfo];
            }
            else
            {
                if (kZeroNumber != i)
                {
                    if ([styleStr isEqualToString:@""])
                    {
//                        [PSAlertView showWithMessage:kLoc(@"规格不能为空！", nil)];
//                        return;
                    }
                    if ([priceStr isEqualToString:@""])
                    {
//                        [PSAlertView showWithMessage:kLoc(@"请添加价格", nil)];
//                        return;
                    }
                }
            }
        }
    }
    
    //菜系ID
    if (isEditing)
    {
        [postData setObject:[NSNumber numberWithInt:cuisineID] forKey:@"id"];
    }
    else
    {
        [postData setObject:[NSNumber numberWithInt:cuisineID] forKey:@"cuisineId"];
    }
    
    //菜名
    [postData setObject:itemDishName forKey:@"name"];
    //编号
    NSString *itemSN = [itemSerialNumTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([itemSN length]>0)
    {
        [postData setObject:itemSN forKey:@"code"];
    }
    else
    {
        [postData setObject:@"" forKey:@"code"];
    }
    //介绍
    NSString *itemDescrip = [itemDishDescripTextview.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([itemDescrip length]>0)
    {
        [postData setObject:itemDescrip forKey:@"introduction"];
    }
    else
    {
        [postData setObject:@"" forKey:@"introduction"];
    }
    //是否提供外卖
    [postData setObject:[NSNumber numberWithInt:isAllowTakeout] forKey:@"isAllowTakeout"];
    //是否沽清
    [postData setObject:[NSNumber numberWithInt:isSoldOut] forKey:@"isSoldOut"];
    //价格
    [postData setObject:prices forKey:@"price"];
    
    //图片，转换image为Base64数据（大小为640×470）
    if (itemPicImageview.image)
    {
        NSData *picData = UIImageJPEGRepresentation(itemPicImageview.image,0.5);
        NSString *picStr = [picData base64EncodedString];
        [postData setObject:picStr forKey:@"picture"];
    }
    
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 1;
    jsonPicker.showActivityIndicator = animated;
    if (animated)
    {
        jsonPicker.loadingMessage = kLoc(@"submitting_data_please_wait");
        jsonPicker.loadedSuccessfulMessage = kLoc(@"submit_succeed");
    }
    else
    {
        jsonPicker.loadingMessage = nil;
        jsonPicker.loadedSuccessfulMessage = nil;
    }
    if (isEditing)
    {
        ///jhh_changed_编辑菜品
        [jsonPicker postData:postData withBaseRequest:@"cookbook/edit"];
//        [jsonPicker postData:postData withBaseRequest:@"DishCard/editItem"];
    }
    else
    {
        ///jhh_changed_增加菜品
        [jsonPicker postData:postData withBaseRequest:@"cookbook/add"];
//        [jsonPicker postData:postData withBaseRequest:@"DishCard/addItem"];
    }
}

#pragma mark Notification

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notify
{
    NSDictionary *userInfo = [notify userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    keyboardRect = [self.view convertRect:keyboardRect fromView:window];
    CGRect intersectionOfKeyboardRectAndWindowRect = CGRectIntersection(window.frame, keyboardRect);
    CGFloat bottomInset = intersectionOfKeyboardRectAndWindowRect.size.height;
    self.itemTableview.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset,0.0f);
    self.itemTableview.scrollEnabled = NO;
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notify
{
    NSDictionary *userInfo = [notify userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    self.itemTableview.scrollEnabled = YES;
    self.itemTableview.contentInset = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
}

#pragma mark - UITableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    int section = indexPath.section;
    NSInteger indexRow = indexPath.row;
    
    //编号
    if (section==0)
    {
        [cell.contentView addSubview:[self addSerialNumView]];
        return cell;
    }
    
    //菜名
    if (section==1)
    {
        [cell.contentView addSubview:[self addDishNameView]];
        return cell;
    }
    //介绍
    if (section==2)
    {
        [cell.contentView addSubview:[self addDishDescripView]];
        return cell;
    }
    
    //价格
    if (section==3)
    {
        static NSString *cellIdentifier = kDishCardItemPriceTableviewCellReuseIdentifier;
        DishCardItemPriceTableviewCell *cell = (DishCardItemPriceTableviewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DishCardItemPriceTableviewCell" owner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.tag = indexRow;
        cell.delegate = self;
        [cell updateCellInfo:[kDCItmePriceArray objectAtIndex:indexRow]];

        return cell;
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int section = indexPath.section;
    float height = 0;
    switch (section) {
        case 0:
            height = 55;
            break;
        case 1:
            height = 55;
            break;
        case 2:{
            height = 85;
            break;
        }
        case 3:
            height = 50;
            break;
    }
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    switch (section)
    {
        case 0:
        {
            rows = 1;
            break;
        }
        case 1:
        {
            rows = 1;
            break;
        }
        case 2:
        {
            rows = 1;
            break;
        }
        case 3:
        {
            rows = [kDCItmePriceArray count];
            break;
        }
    }
    return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    itemTableview.scrollEnabled = NO;
    
    if (kpackfeeTextfieldTag == textField.tag)
    {
        NumPicker *picker = [[NumPicker alloc] init];
        picker.delegate = self;
        picker.tag = kpackfeeTextfieldTag;
        picker.pickerType = NumPickerTypeWithDecimal;
        picker.minimumNum = kMinPackfee;
        picker.maximumNum = kMaxPackfee;
        picker.numberText = textField.text;
        
        if (!popController) {
            if (kIsiPhone) {
                popController = [[WEPopoverController alloc] initWithContentViewController:picker];
            } else {
                popController = [[UIPopoverController alloc] initWithContentViewController:picker];
            }
        }
        
        if (!kIsiPhone) {
            if (kSystemVersionOfCurrentDevice >= 7.0) {
                // 更改iOS7默认样式
                [(UIPopoverController *)popController setPopoverBackgroundViewClass:[PSPopoverBckgroundView class]];
            } else {
                [(UIPopoverController *)popController setPopoverBackgroundViewClass:nil];
            }
        }
        
        [popController setContentViewController:picker];
        [popController setPopoverContentSize:picker.pickerSize];
        
        if (kIsiPhone) {
            MainViewController *mainCtrl = [MainViewController getMianViewShareInstance];
            CGRect showRect = [self.view convertRect:textField.frame toView:mainCtrl.view];
            [popController setParentView:mainCtrl.view];
            [popController presentPopoverFromRect:showRect
                                           inView:mainCtrl.view
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
        } else {
            [popController presentPopoverFromRect:textField.frame
                                           inView:self.view
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag == kDishNameTextfieldTag)
    {
        //截取字符串
        NSString *tempString = [NSString cutString:textField.text withMaxLengthOfStr:kDishNameLength];
        textField.text = tempString;
    }
    itemTableview.scrollEnabled = YES;
    return YES;
}

/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location >= kDishNameLength && textField.tag == kDishNameTextfieldTag)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
 */

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextviewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    optionalLabel.hidden = YES;
    itemTableview.scrollEnabled = NO;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    optionalLabel.hidden = [itemDishDescripTextview hasText];
    itemTableview.scrollEnabled = YES;
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    optionalLabel.hidden = [itemDishDescripTextview hasText];
    [textView resignFirstResponder];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag==1)
    {
        switch (buttonIndex)
        {
            //拍照
            case 0:
            {
                [self browseFromCamera];
                break;
            }
            //浏览相册
            case 1:
            {
                [self browseFromPhotoAlbum];
                break;
            }
        }
    }
}

#pragma mark DataDownloaderDelegate

- (void)hideActivityView
{
    activityView.hidden = YES;
    [activityView stopAnimating];
}


-(void)DataDownloader:(DataDownloader *)loader didLoadPhoto:(UIImage *)image
{
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    [offlineMgr saveOfflinePhoto:image andPhotoFileName:[loader url]];
    
    itemPicImageview.image = image;
    [self hideActivityView];
}

//加载失败，返回默认图像
-(void)DataDownloader:(DataDownloader *)loader didFailedLoadPhoto:(UIImage *)image
{
    [self hideActivityView];
    
//    [PSAlertView showWithMessage:kLoc(@"图片加载失败", nil)];
}

-(void)DataDownloader:(DataDownloader *)loader didFailWithNetwork:(NSError *)error
{
    [self hideActivityView];
}

#pragma mark NumPickerDelegate

-(void)NumPicker:(NumPicker*)picker didPickedNumber:(NSString*)number
{
    [popController dismissPopoverAnimated:YES];
    if (kpackfeeTextfieldTag == picker.tag)
    {
        if (number.length > 0)
        {
            CGFloat tempNumber = [number floatValue];
            NSString *tempStr = [NSString stringWithFormat:@"%.2f",tempNumber];
            self.packfeeTextField.text = [NSString stringWithFormat:@"%@",[NSString trimmingZeroInPrice:tempStr]];
        }
        else
        {
            self.packfeeTextField.text = @"";
        }
    }
}

- (void)NumPicker:(NumPicker*)picker didPickedOverflowNumber:(NSString*)number
{
    [PSAlertView showWithMessage:kLoc(@"please_enter_from_0_to_1000")];
}

#pragma mark - DishCardItemPriceTableviewCellDelegate

/**
 * 显示提示语，当规格名重复时
 */
- (void)showWarnWhenAreaNameRepeat
{
    [self hideKeyboard];
    [PSAlertView showWithMessage:kLoc(@"duplicated_cuisine_specification")];
}

- (void)dishCardItemPriceTableviewCell:(DishCardItemPriceTableviewCell *)cell withAddStyle:(NSString *)styleStr withAddPriceStr:(NSString *)priceStr
{
    //判断规格是否重复了
    BOOL isRepeat = NO;
    NSInteger priceIndex = cell.tag;
    NSInteger tempIndex = 0;
    for (NSDictionary *priceDict in kDCItmePriceArray)
    {
        if (tempIndex != priceIndex)
        {
            NSString *styleName = [priceDict objectForKey:@"style"];
            if ([styleName isEqualToString:styleStr])
            {
                isRepeat = YES;
                break;
            }
        }
        tempIndex++;
    }
    if (isRepeat)
    {
        [self showWarnWhenAreaNameRepeat];
        return;
    }
    NSMutableArray *priceArray = [[NSMutableArray alloc] initWithArray:kDCItmePriceArray];
    NSMutableDictionary *priceDict = [[NSMutableDictionary alloc] initWithDictionary:[priceArray firstObject]];
    [priceDict setObject:styleStr forKey:@"style"];
    [priceDict setObject:priceStr forKey:@"price"];
    [priceArray replaceObjectAtIndex:0 withObject:priceDict];
    [self.dishCardDict setObject:priceArray forKey:@"price"];
    [self addNewItemCell];
    [itemTableview reloadData];
    [itemTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[kDCItmePriceArray count] -1 inSection:kTableViewFourthSection] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)dishCardItemPriceTableviewCell:(DishCardItemPriceTableviewCell *)cell withStyleChanged:(NSString *)styleStr
{
    NSInteger priceCount = [kDCItmePriceArray count];
    NSInteger priceIndex = cell.tag;
    BOOL whetherSave = NO;
    if (kZeroNumber != priceIndex)
    {
        if (priceIndex < priceCount)
        {
            //判断规格是否重复了
            BOOL isRepeat = NO;
            NSInteger tempIndex = 0;
            for (NSDictionary *priceDict in kDCItmePriceArray)
            {
                if (tempIndex != priceIndex)
                {
                    NSString *styleName = [priceDict objectForKey:@"style"];
                    if ([styleName isEqualToString:styleStr])
                    {
                        isRepeat = YES;
                        break;
                    }
                }
                tempIndex++;
            }
            if (isRepeat)
            {
                [self showWarnWhenAreaNameRepeat];
                [self.itemTableview performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
            }
            else
            {
                whetherSave = YES;
            }
        }
    }
    else
    {
        whetherSave = YES;
    }
    if (whetherSave)
    {
        NSMutableArray *priceArray = [[NSMutableArray alloc] initWithArray:kDCItmePriceArray];
        NSMutableDictionary *priceDict = [[NSMutableDictionary alloc] initWithDictionary:[priceArray objectAtIndex:priceIndex]];
        [priceDict setObject:styleStr forKey:@"style"];
        [priceArray replaceObjectAtIndex:priceIndex withObject:priceDict];
        [self.dishCardDict setObject:priceArray forKey:@"price"];
        [self.itemTableview performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
        [itemTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[kDCItmePriceArray count] -1 inSection:kTableViewFourthSection] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)dishCardItemPriceTableviewCell:(DishCardItemPriceTableviewCell *)cell withPriceStrChanged:(NSString *)priceStr
{
    NSInteger priceCount = [kDCItmePriceArray count];
    NSInteger priceIndex = cell.tag;
    if (priceIndex < priceCount)
    {
        NSMutableArray *priceArray = [[NSMutableArray alloc] initWithArray:kDCItmePriceArray];
        NSMutableDictionary *priceDict = [[NSMutableDictionary alloc] initWithDictionary:[priceArray objectAtIndex:priceIndex]];
        [priceDict setObject:priceStr forKey:@"price"];
        [priceArray replaceObjectAtIndex:priceIndex withObject:priceDict];
        [self.dishCardDict setObject:priceArray forKey:@"price"];
        [itemTableview reloadData];
        [itemTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[kDCItmePriceArray count] -1 inSection:kTableViewFourthSection] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

-(void)DishCardItemPriceTableviewCellDidDeletedItem:(DishCardItemPriceTableviewCell*)cell
{
    NSInteger priceCount = [kDCItmePriceArray count];
    NSInteger priceIndex = cell.tag;
    if (priceIndex < priceCount)
    {
        NSMutableArray *priceArray = [[NSMutableArray alloc] initWithArray:kDCItmePriceArray];
        [priceArray removeObjectAtIndex:priceIndex];
        [self.dishCardDict setObject:priceArray forKey:@"price"];
        [itemTableview reloadData];
        [itemTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[kDCItmePriceArray count] -1 inSection:kTableViewFourthSection] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

-(void)DishCardItemPriceTableviewCellDidBeginEditingPrice:(DishCardItemPriceTableviewCell*)cell
{
    [self hideKeyboard];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    if ([self.popover isPopoverVisible]) {
        /*从相册获取图片*/
        [self.popover dismissPopoverAnimated:NO];
        [self openEditor:image];
    } else {
        /*拍照*/
        [self dismissViewControllerAnimated:YES completion:^{
            [self openEditor:image];
        }];
    }
    
    if (!kIsiPhone) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    /*拍照*/
    [self dismissViewControllerAnimated:YES completion:nil];
    if (!kIsiPhone) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
}

#pragma mark PECropViewControllerDelegate

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [self dismissViewControllerAnimated:YES completion:nil];
    itemPicImageview.image = croppedImage;
    
#ifdef DEBUG
    NSLog(@"===CropedImage:%f,%f===",croppedImage.size.width,croppedImage.size.height);
#endif
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - XANImageViewControllerDataSource

- (NSUInteger)numberOfImages
{
    return 1;
}

- (UIImage *)imageForIndex:(NSUInteger)index
{
    return itemPicImageview.image;
}

#pragma mark - JsonPickerDelegate

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    //add item
    if (picker.tag==1)
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        switch (responseStatus)
        {
            case 200:
            {
                if ([delegate respondsToSelector:@selector(DishCardItemDetailPickerDidAddedNewItem:)])
                {
                    [delegate DishCardItemDetailPickerDidAddedNewItem:dict];
                }
                
                [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.5];
                break;
            }
            default:
            {
                NSString *alertMsg = [dict objectForKey:@"desc"];
                [PSAlertView showWithMessage:alertMsg];
                break;
            }
        }
    }
}


// JSON解释错误时返回
-(void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error{
    
}


// 网络连接失败时返回（无网络的情况）
-(void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error{
    
}
@end
