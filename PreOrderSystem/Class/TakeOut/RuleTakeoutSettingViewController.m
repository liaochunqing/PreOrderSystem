//
//  RuleTakeoutSettingViewController.m
//  PreOrderSystem
//
//  Created by AaronKwok on 12-8-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RuleTakeoutSettingViewController.h"
#import "JsonPicker.h"
#import "Constants.h"
#import "PSAlertView.h"
#import "NumPicker.h"
#import "NsstringAddOn.h"
#import "NSData+Base64.h"
#import "MainViewController.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "DetailTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomTimePicker.h"
#import "UIDevice+platform.h"
#import "UIImageAddOn.h"
#import "UIImagePickerController+InterfaceOrientations.h"
#import "WeekdayPicker.h"
#import "PSPopoverBckgroundView.h"
#import "UIImage+LittleImg.h"
#import "DisplayHelper.h"
#import "PhotoReviewView.h"
#import "WEPopoverController.h"
#import "MainViewController.h"

typedef enum
{
    kTakeOutNoticeCellType,
    kBusinessTimeCellType
}CustomCellType;

#define kDeliveryfeeCellSection 0
#define kFeeCellSection 1
#define kBusinessTimeCellSection 2
#define kTakeOutNoticeCellSection 3
#define kDiscountCellSection 4
#define kPictureCellSection 5

#define kPictureMaxNum 5
#define kAddPhotoUIActionSheetTag 4000
#define kPictureIndicatorViewTag 4100
#define kDeliveryfeeTextFieldTag 4200
#define kCarryfeeTextFieldTag 4300
#define kCarryRangeTextFieldTag 4400
#define kNeedDateTextFieldTag 4500
#define kDiscountTextFieldTag 5000
#define kDiscountStartTimeTextFieldTag 6000
#define kDiscountEndTimeTextFieldTag 7000
#define kDiscountStartTimeDatePickerTag 6500
#define kDiscountEndTimeDatePickerTag 7500
#define kTableViewWidth self.ruleSettingTableview.frame.size.width
#define kDiscountSwitch [[ruleSettingDict objectForKey:@"discountSwitch"]integerValue]
#define kHeadViewTitleColor [UIColor colorWithRed:104.0/255.0 green:145.0/255.0 blue:49.0/255.0 alpha:1.0]

#define kTakeOutTimeCellSection 2

#define kCarryfeeUserLowerTextFieldTag 10000
#define kCarryfeeUserUpperTextFieldTag 13000
#define kCarryfeeUserCashTextFieldTag 16000

#define kCarryfeeLowerTextFieldTag 3001
#define kCarryfeeUpperTextFieldTag 3000
#define kCarryfeeCashLowerTextFieldTag 3003
#define kCarryfeeCashUpperTextFieldTag 3002

#define kCarryfeeCashDefaultTextFieldTag 3004

#define kStartWeekdayTextFieldTag 1000

@interface RuleTakeoutSettingViewController (Private)

//将图片转化成字符串
- (void)transformatePictureToString:(NSMutableArray *)imageArray;
- (IBAction)ruleSwitchClicked:(id)sender;

@end

@implementation RuleTakeoutSettingViewController
@synthesize delegate;
@synthesize ruleSettingTableview;
@synthesize quitButton;
@synthesize trueButton;
@synthesize tableBgImageView;
@synthesize popoverController;
@synthesize isShowing;


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
    
    [self addNotifications];
    [self addPictureToView];
    
    /* 模拟看内存警告时是否有问题 
     [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(didReceiveMemoryWarning) userInfo:nil repeats:YES];
     */
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self addLocalizedString];
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:kLoc(@"takeout_setting") forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationLandscapeRight;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    popoverController = nil;
    ruleSettingDict = nil;
    jsonPicker = nil;
    selectdTimePicker = nil;
    photoViewArray = nil;
#ifdef DEBUG
    NSLog(@"===RuleTakeoutSettingViewController,viewDidUnload===");
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    /*
    if ((kSystemVersionOfCurrentDevice >= 6.0) && [self isViewLoaded] && ![self.view window])
    {
        [self viewDidUnload];
        [self setView:nil];
    }
     */
    
    NSLog(@"takeout ----------didReceiveMemoryWarning");
}

-(void)dealloc
{
#ifdef DEBUG
    NSLog(@"===RuleTakeoutSettingViewController,dealloc===");
#endif
    [self removeNotification];
}

#pragma mark PUBLIC METHODS
// 当服务器返回自定义配餐费设置天目为0时， 添加一个条自定义配餐费设置
- (void)addFeeUserSetting
{
    // 默认至少一个条自定义配餐费设置
    NSArray *array = nil;
    if (ruleSettingDict && [ruleSettingDict objectForKey:@"carryfee"] != nil)
    {
        array = [[ruleSettingDict objectForKey:@"carryfee"] objectForKey:@"closedInterval"];
    }
    
    if (array.count == 0)
    {
        [self addFeeCell];
        isEdited = NO;
    }
}

-(void)showInView:(UIView*)aView
{
    self.view.alpha = 0.0f;
    
    [aView addSubview:self.view];
    
    [UIView beginAnimations:@"animationID" context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationRepeatAutoreverses:NO];
    
    self.view.alpha = 1.0f;
    
    CGRect aFrame = self.view.frame;
    aFrame.origin.x = 0;
    aFrame.origin.y = kSystemVersionIsIOS7?15:0;
    self.view.frame = aFrame;
	[UIView commitAnimations];
    
    [ruleSettingDict removeAllObjects];
    [self.ruleSettingTableview reloadData];
    [self getRuleSettingData];
    
    isModifyPic = NO;
    isShowing = YES;
    tableViewContentOffset = CGPointZero;
    self.settingBtnDict = nil;
}

//跳出本页面
-(void)dismissView
{
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:kLoc(@"takeout") forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
    
    [self.view removeFromSuperview];
    
    if ([delegate respondsToSelector:@selector(RuleTakeoutSettingViewController:didDismissView:)])
    {
        [delegate RuleTakeoutSettingViewController:self didDismissView:YES];
    }
    isShowing = NO;
}

#pragma mark PRIVATE METHODS
//weekday的index转换为文字（如：，1对应于周一，6对应于周六,7对应于周日...）
-(NSString*)weekdayText:(NSArray*)week
{
    if (0 == [week count])
    {
        return kLoc(@"required_to_fill");
    }
    NSArray *array = [NSArray arrayWithObjects:kLoc(@"one"), kLoc(@"two"), kLoc(@"three"), kLoc(@"four"), kLoc(@"five"), kLoc(@"six"), kLoc(@"seven"), nil];
    NSMutableString *text = [[NSMutableString alloc] init];
    for (int i=0; i<[week count]; i++)
    {
        int week1 = [[week objectAtIndex:i] intValue]-1;
        [text appendString:[array objectAtIndex:week1]];
        if (i<[week count]-1)
        {
            [text appendString:@"、"];
        }
    }
    return text;
}

//- (void)setCarryFeeUploadData:(NSString*)keyWord text:(NSString*)text dict(NSDictionary*)dict
//{
//    
//        NSDictionary *lowerDict = [dict objectForKey:keyWord];
//        if (!lowerDict)
//        {
//            lowerDict = [NSDictionary dictionaryWithObject:text forKey:keyWord];
//        }
//        else
//        {
//            [lowerDict setValue:text forKey:@"cost"];
//        }
//        [dict setValue:lowerDict forKey:@"lower"];
//    
//}


- (void)addLocalizedString
{
    self.openLabel.text = [NSString stringWithFormat:@"%@%@ ：",kLoc(@"offer"),((0 == self.deliveryType)?kLoc(@"takeout"):kLoc(@"self_pick"))];
    [self.trueButton setTitle:kLoc(@"confirm") forState:UIControlStateNormal];
    [self.quitButton setTitle:kLoc(@"cancel") forState:UIControlStateNormal];
}

- (void)addPictureToView
{
    tableBgImageView.image = [UIImage imageFromMainBundleFile:@"rule_frameBg.png"];
}

//“取消”按钮点击
-(IBAction)cancelButtonPressed:(UIButton*)sender
{
    [self hideKeyboard];
    if (isEdited)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:kLoc(@"data_is_not_saved_confirm_to_leave") delegate:self cancelButtonTitle:kLoc(@"cancel") otherButtonTitles:kLoc(@"confirm"), nil];
        alert.tag = 0;
        [alert show];
    }
    else
    {
        [self dismissView];
    }
}


//“保存”按钮点击
-(IBAction)doneButtonPressed:(UIButton*)sender
{
    [self hideKeyboard];
    if (isEdited)
    {
        [self saveRuleSettingData];
    }
    else
    {
        [self dismissView];
    }
}

//“配送费”包含按钮
- (void)includeBtnClick:(UIButton *)btn
{
    isEdited = YES;
    btn.selected = !btn.selected;
    if (ruleSettingDict)
    {
        NSDictionary *carryfeeDict = [ruleSettingDict objectForKey:@"carryfee"] ;
        if (carryfeeDict)
        {
            NSDictionary *openIntervalDict = [carryfeeDict objectForKey:@"openInterval"];
            if (openIntervalDict)
            {
                if (btn.tag == 1)
                {
                    NSDictionary *lowerDict = [openIntervalDict objectForKey:@"upper"];
                    [lowerDict setValue:[NSString stringWithFormat:@"%i",btn.selected]  forKey:@"equal"];
                    [openIntervalDict setValue:lowerDict forKey:@"upper"];
                }
                else if (btn.tag == 2)
                {
                    NSDictionary *upperDict = [openIntervalDict objectForKey:@"lower"];
                    [upperDict setValue:[NSString stringWithFormat:@"%i",btn.selected] forKey:@"equal"];
                    [openIntervalDict setValue:upperDict forKey:@"lower"];
                }
            }
            [carryfeeDict setValue:openIntervalDict forKey:@"openInterval"];
            [ruleSettingDict setValue:carryfeeDict forKey:@"carryfee"];
        }
    }
}


//”提供外卖“开关
- (IBAction)ruleSwitchClicked:(id)sender
{
    isEdited = YES;
    [ruleSettingDict setObject:[NSNumber numberWithBool:self.ruleSwitch.isOn] forKey:@"isOpen"];
    [ruleSettingTableview reloadData];
}

//折扣开关
- (void)discountSwitchClicked:(UISwitch *)sender
{
    isEdited = YES;
    [ruleSettingDict setObject:[NSNumber numberWithBool:sender.isOn] forKey:@"discountSwitch"];
    [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kDiscountCellSection]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)updateViewAfterGetData
{
    //外卖开关
    [self.ruleSwitch setOn:[[ruleSettingDict objectForKey:@"isOpen"]boolValue]];
    [self addFeeUserSetting];
}

//设置“外卖时间”的weekday
-(void)takeOutTimeStartAtWeekday:(UIButton*)sender
{
    /*键盘在时，只收起键盘，不弹出UIPopoverController*/
    if (selectCell)
    {
        [self hideKeyboard];
        return;
    }
    
     NSMutableArray *businessTimeArray = [[NSMutableArray alloc]initWithArray:[ruleSettingDict objectForKey:@"takeoutTime"]];
    NSInteger index = sender.tag - kStartWeekdayTextFieldTag;
    NSDictionary *general = [businessTimeArray objectAtIndex:index];
    NSArray *week = nil;
    
    if (general)
    {
        week = [general objectForKey:@"week"];
    }
    
    WeekdayPicker *picker = [[WeekdayPicker alloc] init];
    picker.delegate = self;
    picker.tag = sender.tag;
    [picker updateWeekdays:week];
    
    if (nil == popoverController) {
        if (kIsiPhone) {
            popoverController = [[WEPopoverController alloc] initWithContentViewController:picker];
        } else {
            popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
        }
    }
    if (!kIsiPhone) {
        [popoverController setPopoverBackgroundViewClass:nil];
    }
    [popoverController setContentViewController:picker];
    [popoverController setPopoverContentSize:picker.pickerSize];
    UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kTakeOutTimeCellSection]];
    
    if (kIsiPhone) {
        MainViewController *mainCtrl = [MainViewController getMianViewShareInstance];
        CGRect showRect = [cell.contentView convertRect:sender.frame toView:mainCtrl.view];
        [popoverController setParentView:mainCtrl.view];
        [popoverController presentPopoverFromRect:showRect
                                           inView:mainCtrl.view
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    } else {
        [popoverController presentPopoverFromRect:sender.frame
                                           inView:cell.contentView
                         permittedArrowDirections:UIPopoverArrowDirectionLeft
                                         animated:YES];
    }
}

//创建随机文件

//异步加载图片
-(void)imageLoadForIndex:(NSIndexPath *)index
{
    @autoreleasepool
    {
        //创建文件夹
        NSFileManager*fm=[NSFileManager defaultManager];
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        cachesPath=[cachesPath stringByAppendingPathComponent:@"takeOutPicCaches/"];
        
        if (![fm fileExistsAtPath:cachesPath])
        {
            NSError *error=nil;
            BOOL a = [fm createDirectoryAtPath:cachesPath withIntermediateDirectories:YES attributes:nil error:&error];
            if (a)
            {
#ifdef DEBUG
                NSLog(@"缓存文件夹创建成功");
#endif
            }
        }
        
        NSArray *picArray = [ruleSettingDict objectForKey:@"picture"];
        smallPhotoViewArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [picArray count]; i++)
        {
            //网络图片地址
            NSString *imgUrlStr=[picArray objectAtIndex:i];
            NSURL *imgUrl=[NSURL URLWithString:imgUrlStr];
            
            //设置文件存储路径
            NSString *imagPath=[cachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/caches-%u",[[imgUrl description] hash]]];
            
            NSData *imgData=nil;
            if ([fm fileExistsAtPath:imagPath])
            {
                imgData=[NSData dataWithContentsOfFile:imagPath];
            }
            else
            {
                imgData=[NSData dataWithContentsOfURL:imgUrl];
                [imgData writeToFile:imagPath atomically:YES];
            }
            
            
            if (nil != imgData)
            {
                //替换图片
                UIImageView *imageview = [photoViewArray objectAtIndex:i];
                imageview.image = [UIImage imageWithData:imgData];
                [photoViewArray replaceObjectAtIndex:i withObject:imageview];
                UIActivityIndicatorView *tempView = (UIActivityIndicatorView *)[imageview viewWithTag:kPictureIndicatorViewTag + i];
                [tempView removeFromSuperview];
                [tempView stopAnimating];
                

                UIImage *temp = [UIImage imageWithData:imgData];
                UIImage * smallimage = [UIImage thumbnailWithImageWithoutScale:temp size:CGSizeMake(300, 300)];
                UIImageView *smallImageView = [[UIImageView alloc] initWithImage:smallimage];
                smallImageView.image = smallimage;
                [smallPhotoViewArray addObject: smallImageView];
            }
            
            //刷新视图
            [self performSelectorOnMainThread:@selector(updateCellImgviewImage) withObject:nil  waitUntilDone:YES];
        }
    }
}

- (CGSize)accoutLabelWithByfont:(NSString *)text fontofsize:(CGFloat)fontofsize hight:(CGFloat)hight
{
    CGSize actualsize;
//ios7方法，获取文本需要的size，限制宽度
    if (kSystemVersionIsIOS7)
    {
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:fontofsize],NSFontAttributeName,nil];
        actualsize =[text boundingRectWithSize:CGSizeMake( MAXFLOAT,hight) options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    }
    else//ios7以下方法，获取文本需要的size，限制宽度
    {
        actualsize = [text sizeWithFont:[UIFont systemFontOfSize:fontofsize] constrainedToSize:CGSizeMake(MAXFLOAT, hight) lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    return actualsize;
}

-(void)updateCellImgviewImage
{
    [ruleSettingTableview reloadData];
}

//将图片转化成字符串
- (void)transformatePictureToString:(NSMutableArray *)imageArray
{
    NSMutableArray *takeoutPicArray = [[NSMutableArray alloc]initWithArray:[ruleSettingDict objectForKey:@"picture"]];
    [takeoutPicArray removeAllObjects];
    
    for (int i = 0; i < [imageArray count]; i ++)
    {
        UIImageView *imageView = [imageArray objectAtIndex:i];
        UIImage *image = [UIImage modifyImageOrientation:imageView.image];
        NSData *picData = UIImageJPEGRepresentation(image, 0.2);
        NSString *picStr = [picData base64EncodedString];
        
        NSMutableDictionary *takeoutPicDict = [[NSMutableDictionary alloc]initWithCapacity:2];
        [takeoutPicDict setObject:picStr forKey:@"picData"];
        [takeoutPicArray insertObject:takeoutPicDict atIndex:0];
    }
    
    [ruleSettingDict setObject:takeoutPicArray forKey:@"picture"];
}

//将图片加入url字段中
- (void)keepPictureToUrl
{
    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:[ruleSettingDict objectForKey:@"picture"]];
    NSMutableArray *pictureArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [tempArray count]; i ++)
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:tempArray[i] forKey:@"url"];
        [pictureArray addObject:dict];
    }
    
    [ruleSettingDict setObject:pictureArray forKey:@"picture"];
}

//图片放大
- (void)pictureImageViewClicked:(UIButton *)sender
{
   //jhh_edit
    self.clickImgIndex = sender.tag;
//    xan = [[XANImageViewController alloc] initWithInitialImageIndex:0 dataSource:self delegate:nil];
//    xan.showsDoneButton = YES;
//    //xan.allowNoSlip = YES;
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:xan];
//    nav.modalPresentationStyle = UIModalPresentationFullScreen;
//    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self.view.window.rootViewController presentViewController:nav animated:YES completion:nil];
    
    [[DisplayHelper shareDisplayHelper] showLoading];
    UIImageView *imageView = [photoViewArray objectAtIndex:self.clickImgIndex];
    UIImage *img = imageView.image;
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW , NSEC_PER_SEC * 0.5);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        // 获取图片数据
        //DishTableViewFirstCell *firstCell = [self getFirstCellFromTableView];
        @autoreleasepool {
            PhotoReviewView *photoView = [[PhotoReviewView alloc] initWithFrame:CGRectZero];
            NSData *imageData = UIImagePNGRepresentation(img);
            photoView.photoData = [UIImage imageWithData:imageData];
            [photoView show];
        }
        
        [[DisplayHelper shareDisplayHelper] hideLoading];
    });
    
}

- (void)deletePictureBtnClicked:(UIButton *)sender
{
    isEdited = YES;
    isModifyPic = YES;
    [photoViewArray removeObjectAtIndex:sender.tag];
    [smallPhotoViewArray removeObjectAtIndex:sender.tag];
    [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kPictureCellSection]] withRowAnimation:UITableViewRowAnimationNone];
}

//优惠开放期限
-(void)deadlineBtnPressed:(UIButton *)sender
{
    /*键盘在时，只收起键盘*/
    if (selectCell)
    {
        [self hideKeyboard];
        return;
    }
    isEdited = YES;
    if (1 == sender.tag)
    {
        [ruleSettingDict setObject:@"0" forKey:@"discountTimeType"];
        NSMutableDictionary *dict =  [ruleSettingDict objectForKey:@"discountTime"];
        [dict setObject:@"" forKey:@"start"];
        [dict setObject:@"" forKey:@"end"];
        _privilegeDeadlineAllTimeButton.selected = YES;
        _privilegeDeadlinelimitTimeButton.selected = NO;
        [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kDiscountCellSection]] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if (2 == sender.tag)
    {
//        [ruleSettingDict setObject:@"1" forKey:@"discountTimeType"];
        _privilegeDeadlineAllTimeButton.selected = NO;
        _privilegeDeadlinelimitTimeButton.selected = YES;
    }
}

//添加图片
-(void)addPhotoButtonPressed:(UIButton *)sender
{
    if (kPictureMaxNum == [smallPhotoViewArray count])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:kLoc(@"sorry_the_picture_has_reached_the_limit") delegate:self cancelButtonTitle:kLoc(@"confirm") otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:kLoc(@"take_photo"), kLoc(@"browse_album"), nil];
    actionSheet.tag = kAddPhotoUIActionSheetTag;
    UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kPictureCellSection]];
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:sender.frame inView:cell.contentView animated:YES];
    }
}

#pragma mark customCell

//"订座须知"、“外卖时间”、“折扣优惠”、“添加图片”的cell
- (UITableViewCell *)getCustomCell:(CustomCellType)type withIndex:(int)index
{
    switch (type)
    {
        case kTakeOutNoticeCellType:
        {
            static NSString *cellIdentifier = kTakeOutNoticeCellTableViewCellReuseIdentifier;
            TakeOutNoticeCell *noticeCell = (TakeOutNoticeCell *)[self.ruleSettingTableview dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (nil == noticeCell)
            {
                noticeCell = [[[NSBundle mainBundle] loadNibNamed:@"TakeOutNoticeCell" owner:self options:nil] lastObject];
                noticeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            noticeCell.delegate = self;
            noticeCell.tag = index;
            
            //更新数据
            NSArray *noticeArray = [ruleSettingDict objectForKey:@"instruction"];
            [noticeCell reloadDataAfterLoadView:[noticeArray objectAtIndex:index]];
            
            return noticeCell;
        }
        default:
            break;
    }
    return nil;
}

//订座须知、“外卖时间”、“添加图片”、“折扣优惠”的横条
- (UIImageView *)barViewOfCell:(CustomCellType)type
{
    NSString *titleStr1 = nil;
    NSString *titleStr2 = nil;
    SEL addBtnClicked = nil;
    switch (type)
    {
        case kTakeOutNoticeCellType:
        {
            titleStr1 = [NSString stringWithFormat:@"%@%@ ：",((0 == self.deliveryType)?kLoc(@"takeout"):kLoc(@"self_pick")),kLoc(@"notice")];
            titleStr2 = @"";
            addBtnClicked = @selector(addTakeOutNoticeCell);
            
            break;
        }
        default:
            return nil;
    }
    
    UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-2, 0, 816, 60)];
    bgImageView.userInteractionEnabled = YES;
    bgImageView.image = [UIImage imageFromMainBundleFile:@"rule_cellHeadBg.png"];
    
    DetailTextView *label = [[DetailTextView alloc]initWithFrame:CGRectMake(10, 15, 300, 30)];
    [label setText:[NSString stringWithFormat:@"%@%@",titleStr1,titleStr2] WithFont:[UIFont boldSystemFontOfSize:20] AndColor:kHeadViewTitleColor];
    [label setKeyWordTextArray:[NSArray arrayWithObjects:titleStr2, nil] WithFont:[UIFont boldSystemFontOfSize:16] AndColor:kHeadViewTitleColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentLeft;
    [bgImageView addSubview:label];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setFrame:CGRectMake(745, 5, 47, 47)];
    [addBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_addButton.png"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:addBtnClicked forControlEvents:UIControlEventTouchUpInside];
    [bgImageView addSubview:addBtn];
    
    return bgImageView;
}

- (void)addTakeOutNoticeCell
{
    NSMutableArray *noticeArray = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"instruction"]];
    //只能添加一个空须知
    for (NSString *instructionStr in noticeArray)
    {
        if ([NSString strIsEmpty:instructionStr])
        {
            return;
        }
    }
    [noticeArray addObject:@""];
    [ruleSettingDict setObject:noticeArray forKey:@"instruction"];
    [self.ruleSettingTableview reloadData];
    [self.ruleSettingTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[noticeArray count] inSection:kTakeOutNoticeCellSection] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

//增加配送费cell
- (void)addFeeCell
{
    // 已经编辑标志
    isEdited = YES;
    
    if (ruleSettingDict == nil)
    {
        return;
    }
    
    NSDictionary *carryfeeDict = [ruleSettingDict objectForKey:@"carryfee"] ;
    NSMutableArray *feeArray = nil;
    if ( carryfeeDict)
    {
        feeArray = [[NSMutableArray alloc]initWithArray:[carryfeeDict objectForKey:@"closedInterval"]];
        
        // 配送费只能有一条为空
        for (NSDictionary *itemData in feeArray) {
            id lowerCost = [itemData objectForKey:@"lowerCost"];
            id upperCost = [itemData objectForKey:@"upperCost"];
            id carryfee = [itemData objectForKey:@"carryfee"];
            
            if ([self isEmptyCarryfee:lowerCost] ||
                [self isEmptyCarryfee:upperCost] ||
                [self isEmptyCarryfee:carryfee]) {
                
                return;
            }
        }
        
        //增加默认项：
        NSMutableDictionary *newCell = [[NSMutableDictionary alloc] init];
        [newCell setObject:@"" forKey:@"carryfee"];
        [newCell setObject:@"" forKey:@"lowerCost"];
        [newCell setObject:@"" forKey:@"upperCost"];
        
        [feeArray addObject:newCell];
        [carryfeeDict setValue:feeArray forKey:@"closedInterval"];
        [ruleSettingDict setObject:carryfeeDict forKey:@"carryfee"];
        [ruleSettingTableview reloadSections:[NSIndexSet indexSetWithIndex:kFeeCellSection] withRowAnimation:UITableViewRowAnimationFade];
    }
}
                
- (BOOL)isEmptyCarryfee:(id)fee
{
    if (fee == nil) {
        return YES;
    }
    
    if ([fee isKindOfClass:[NSString class]]) {
        return [fee length] == 0;
    }
    
    if ([fee isKindOfClass:[NSNumber class]]) {
        return [fee doubleValue] == 0;
    }
    
    return YES;
}

//删除“配餐费”cell
-(void)deleteFeeCell:(UIButton*)sender
{
    // 已经编辑标志
    isEdited = YES;
    if (ruleSettingDict == nil)
    {
        return;
    }
    
    NSDictionary *carryfeeDict = [ruleSettingDict objectForKey:@"carryfee"] ;
    NSMutableArray *feeArray = nil;
    if (carryfeeDict)
    {
        feeArray = [[NSMutableArray alloc]initWithArray:[carryfeeDict objectForKey:@"closedInterval"]];
        
        [feeArray removeObjectAtIndex:sender.tag];
        [carryfeeDict setValue:feeArray forKey:@"closedInterval"];
        [ruleSettingDict setObject:carryfeeDict forKey:@"carryfee"];
        [ruleSettingTableview reloadSections:[NSIndexSet indexSetWithIndex:kFeeCellSection] withRowAnimation:UITableViewRowAnimationFade];
    }

}

//增加营业时间cell
- (void)addBusinessTimeCell
{
    isEdited = YES;
    //增加默认项：
    NSMutableDictionary *newCell = [[NSMutableDictionary alloc] init];
    NSMutableArray *businessTimeArray = [[NSMutableArray alloc]initWithArray:[ruleSettingDict objectForKey:@"takeoutTime"]];
    //只能有一个空的时间条
    for (NSDictionary *timeDict in businessTimeArray)
    {
        NSString *startTime = [timeDict objectForKey:@"startTime"];
        NSString *endTime = [timeDict objectForKey:@"endTime"];
        if ([NSString strIsEmpty:startTime] || [NSString strIsEmpty:endTime])
        {
            return;
        }
    }
    [newCell setObject:@"" forKey:@"startTime"];
    [newCell setObject:@"" forKey:@"endTime"];
    [businessTimeArray insertObject:newCell atIndex:[businessTimeArray count]];
    [ruleSettingDict setObject:businessTimeArray forKey:@"takeoutTime"];
    [ruleSettingTableview reloadData];
}

//删除营业时间cell
- (void)deleteSpecialCloseTimeCell:(UIButton*)sender
{
    isEdited = YES;
    NSMutableArray *businessTimeArray = [[NSMutableArray alloc]initWithArray:[ruleSettingDict objectForKey:@"takeoutTime"]];
    if ([businessTimeArray count] > 1)
    {
        [businessTimeArray removeObjectAtIndex:sender.tag];
        [ruleSettingDict setObject:businessTimeArray forKey:@"takeoutTime"];
        [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kBusinessTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        [PSAlertView showWithMessage:kLoc(@"takeout_time_must_keep_at_least_one")];
    }
}

//删除cell
- (void)deleteCustomCell:(int)index withSection:(int)cellSection withKey:(NSString *)keyStr
{
    isEdited = YES;
    NSMutableArray *contentArray = [[NSMutableArray alloc]initWithArray:[ruleSettingDict objectForKey:keyStr]];
    NSInteger contentCount = [contentArray count];
    if (index < contentCount)
    {
        [contentArray removeObjectAtIndex:index];
        [ruleSettingDict setObject:contentArray forKey:keyStr];
    }
    [self.ruleSettingTableview reloadSections:[NSIndexSet indexSetWithIndex:cellSection] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//修改cell
- (void)modifyCustomCell:(NSInteger)index withContent:(id)contentObject withKey:(NSString *)keyStr
{
    isEdited = YES;
    NSMutableArray *contentArray = [[NSMutableArray alloc]initWithArray:[ruleSettingDict objectForKey:keyStr]];
    if (index < [contentArray count])
    {
        [contentArray replaceObjectAtIndex:index withObject:contentObject];
        [ruleSettingDict setObject:contentArray forKey:keyStr];
    }
}

/*点击"取消"和"完成"时,先收起键盘*/
- (void)hideKeyboard
{
    TakeOutNoticeCell * noticeCell = (TakeOutNoticeCell *)selectCell;
    [noticeCell.noticeTextField resignFirstResponder];
}

#pragma mark Notifications

- (void)addNotifications
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification*)sender
{
    tableViewContentOffset = ruleSettingTableview.contentOffset;
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    selectCell = nil;
    ruleSettingTableview.scrollEnabled = YES;
    [ruleSettingTableview setContentOffset:tableViewContentOffset];
}

#pragma mark photo && UIImagePickerController

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

//拍照
- (void)takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *takePhotoController = [[UIImagePickerController alloc] init];
        takePhotoController.sourceType =  UIImagePickerControllerSourceTypeCamera;
        takePhotoController.delegate = self;
        
        if (!kIsiPhone) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        }
        [[MainViewController getMianViewShareInstance] presentViewController:takePhotoController animated:YES completion:nil];
    }
    else
    {
        [PSAlertView showWithMessage:kLoc(@"sorry_camera_not_support_for_your_device")];
    }
}

//从相册获取图片
- (void)loadPhotoFromAlbum
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
    
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
    [elcPicker setDelegate:self];
    
    elcPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    [[MainViewController getMianViewShareInstance] presentViewController:elcPicker animated:YES completion:nil];
}

- (void)dismissViewFromParentAnimated:(BOOL)flag
{
    [[MainViewController getMianViewShareInstance]  dismissViewControllerAnimated:flag completion:nil];
}

#pragma mark netWork


//获取规则设置信息
-(void)getRuleSettingData
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 0;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"fetching_takeout_setting_info_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [jsonPicker postData:postData withBaseRequest:((0 == self.deliveryType)?@"takeout/getDeliverySetting":@"takeout/getSelfhelpSetting")];
}

//保存外卖设置信息
-(void)saveRuleSettingData
{
    //是否开放外卖
    NSInteger isOpen = [[ruleSettingDict objectForKey:@"isOpen"]integerValue];
    
    if (1 == isOpen)
    {
        if (0 == self.deliveryType)
        {
            //起送费
            NSString *deliveryfeeStr = [[NSString stringWithFormat:@"%@",[ruleSettingDict objectForKey:@"minConsumption"]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (0 == [deliveryfeeStr length])
            {
                [PSAlertView showWithMessage:kLoc(@"delivery_fee_can_not_be_empty")];
                return;
            }
            [ruleSettingDict setObject:deliveryfeeStr forKey:@"minConsumption"];
            
            //配送费 开区间
            if ((_upperCarryfeeTextField.text.length == 0 && _upperCostTextField.text.length != 0)
                || (_upperCarryfeeTextField.text.length != 0 && _upperCostTextField.text.length == 0)
                || (_lowerCarryfeeTextField.text.length == 0 && _lowerCostTextField.text.length != 0)
                || (_lowerCarryfeeTextField.text.length != 0 && _lowerCostTextField.text.length == 0))
            {
                [PSAlertView showWithMessage:kLoc(@"please_input_takeoutfee_full")];
                return;
            }
            
            //配送费 闭区间
            NSDictionary *carryfeeDict = [ruleSettingDict objectForKey:@"carryfee"] ;
            NSMutableArray *closedIntervalArray = [carryfeeDict objectForKey:@"closedInterval"];
            for (int i = 0; i < closedIntervalArray.count; i++)
            {
                NSDictionary *dict = closedIntervalArray[i];
                if (dict)
                {
                    NSInteger lowercost = [[dict objectForKey:@"lowerCost"] integerValue];
                    NSInteger uppercost = [[dict objectForKey:@"upperCost"] integerValue];
                    NSInteger carryfee = [[dict objectForKey:@"carryfee"] integerValue];
                    if (lowercost * uppercost * carryfee == 0 && lowercost + uppercost + carryfee != 0)
                    {
                        [PSAlertView showWithMessage:kLoc(@"please_input_takeoutfee_full")];
                        return;
                    }
                }
            }
        }
        
        //外卖时间
        NSArray *businessTimeArray = [ruleSettingDict objectForKey:@"takeoutTime"];
        for (int i = 0; i < [businessTimeArray count]; i++)
        {
            NSArray *week = [[businessTimeArray objectAtIndex:i] objectForKey:@"week"];
            NSString *starTime = [[businessTimeArray objectAtIndex:i] objectForKey:@"startTime"];
            NSString *endTime = [[businessTimeArray objectAtIndex:i] objectForKey:@"endTime"];
            
            if (week.count * starTime.length * endTime.length  == 0 && week.count + starTime.length + endTime.length  != 0 )
            {
                NSString *string = nil;
                if (0 == self.deliveryType)
                {
                    string = kLoc(@"please_input_takeout_time_full");
                }
                else
                {
                    string = kLoc(@"please_input_self_pick_time_full");
                }
                [PSAlertView showWithMessage:string];
                return;
            }
        }
        //折扣
        if (1 == kDiscountSwitch)
        {
            NSString *discountStr = [[NSString stringWithFormat:@"%@",[ruleSettingDict objectForKey:@"discount"]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (0 == [discountStr length])
            {
                [PSAlertView showWithMessage:kLoc(@"please_complete_the_discount_of_total_bill")];
                return;
            }
            [ruleSettingDict setObject:discountStr forKey:@"discount"];
        }
    }
    
    //图片
    if (isModifyPic == YES)
    {
#if 0
        NSMutableArray *takeoutPicArray = [[NSMutableArray alloc]initWithArray:[ruleSettingDict objectForKey:@"picture"]];
        [takeoutPicArray removeAllObjects];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"test.jpg" ofType:nil];
        UIImage *image = [UIImage modifyImageOrientation:[UIImage imageWithContentsOfFile:path]];
        NSData *picData = UIImageJPEGRepresentation(image, 0.2);
        NSString *picStr = [picData base64EncodedString];
        
        for (int i = 0; i < 5; i++)
        {
            NSMutableDictionary *takeoutPicDict = [[NSMutableDictionary alloc] init];
            
            [takeoutPicDict setObject:picStr forKey:@"picData"];
            [takeoutPicArray insertObject:takeoutPicDict atIndex:0];
        }
        
        [ruleSettingDict setObject:takeoutPicArray forKey:@"picture"];
#else
        //图片转化成字符串
        [self transformatePictureToString:photoViewArray];
#endif
    }
    else
    {
        [self keepPictureToUrl];
    }
    
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 1;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"saving_takeout_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = kLoc(@"setting_success");
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] initWithDictionary:ruleSettingDict];
    [jsonPicker postData:postData withBaseRequest:((0 == self.deliveryType)?@"takeout/saveDeliverySetting":@"takeout/saveSelfhelpSetting")];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    isEdited = YES;
    isModifyPic = YES;
    if (nil == photoViewArray)
    {
        photoViewArray = [[NSMutableArray alloc]initWithCapacity:3];
    }
	
    UIImageView *imageview = [[UIImageView alloc] initWithImage:[info valueForKey:UIImagePickerControllerOriginalImage]];
    [imageview setContentMode:UIViewContentModeScaleAspectFit];
    imageview.backgroundColor = [UIColor blackColor];
    imageview.frame = CGRectZero;
    [photoViewArray addObject:imageview];
    
    if (nil == smallPhotoViewArray)
    {
        smallPhotoViewArray = [[NSMutableArray alloc] init];
    }
    
    // 缩略图
    UIImage * smallimage = [UIImage thumbnailWithImageWithoutScale:imageview.image size:CGSizeMake(300, 300)];
    UIImageView *smallImageView = [[UIImageView alloc] initWithImage:smallimage];
    smallImageView.image = smallimage;
    [smallPhotoViewArray addObject: smallImageView];
    
    [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kPictureCellSection]] withRowAnimation:UITableViewRowAnimationNone];
    
    if (!kIsiPhone) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
    [self dismissViewFromParentAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (!kIsiPhone) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
    [self dismissViewFromParentAnimated:YES];
}

#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
	isEdited = YES;
    isModifyPic = YES;
    if (nil == photoViewArray)
    {
        photoViewArray = [[NSMutableArray alloc]initWithCapacity:3];
    }
    
    if (nil == smallPhotoViewArray)
    {
        smallPhotoViewArray = [[NSMutableArray alloc] init];
    }

    for(int i = 0; i < [info count]; i ++)
    {
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"test.jpg" ofType:nil];
//        UIImage *image = [UIImage modifyImageOrientation:[UIImage imageWithContentsOfFile:path]];
        UIImageView *imageview = [[UIImageView alloc] initWithImage:[[info objectAtIndex:i] objectForKey:UIImagePickerControllerOriginalImage]];
//        UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
		[imageview setContentMode:UIViewContentModeScaleAspectFit];
        imageview.backgroundColor = [UIColor blackColor];
        imageview.frame = CGRectZero;

        NSData *picData = UIImageJPEGRepresentation(imageview.image, 0.2);
        NSUInteger fileSize = picData.length;

        if (fileSize/(1024 * 1024) > 1)//判断图片大小是否大于5M
        {
            [PSAlertView showWithMessage:kLoc(@"deposit_photo_cannot_greater_5M")];
            break;
        }
        [photoViewArray addObject:imageview];
        
        // 缩略图
        UIImage * smallimage = [UIImage thumbnailWithImageWithoutScale:imageview.image size:CGSizeMake(300, 300)];
        UIImageView *smallImageView = [[UIImageView alloc] initWithImage:smallimage];
        smallImageView.image = smallimage;
        [smallPhotoViewArray addObject: smallImageView];
	}
    
    [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kPictureCellSection]] withRowAnimation:UITableViewRowAnimationNone];
    
    [self dismissViewFromParentAnimated:YES];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewFromParentAnimated:YES];
}

#pragma mark XANImageViewControllerDataSource

- (NSUInteger)numberOfImages
{
    //jhh_edit
    return 1;//[photoViewArray count];
}

- (UIImage *)imageForIndex:(NSUInteger)index
{
    UIImageView *iv = (UIImageView *)[photoViewArray objectAtIndex:self.clickImgIndex];
    NSLog(@">>>>iv:%f",iv.image.size.width);
    return iv.image;
}

#pragma mark TakeOutNoticeCellDelegate

- (void)beginEditingTakeOutNoticeCell:(TakeOutNoticeCell *)cell
{
    selectCell = cell;
    ruleSettingTableview.scrollEnabled = NO;
    [ruleSettingTableview setContentOffset:CGPointMake(0, cell.frame.origin.y) animated:YES];
}

- (void)endEditingTakeOutNoticeCell:(TakeOutNoticeCell *)cell
{
    NSString *tempStr = [cell.noticeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *noticeStr = (0 == [tempStr length])?@"":tempStr;
    [self modifyCustomCell:cell.tag withContent:noticeStr withKey:@"instruction"];
}

- (void)deleteTakeOutNoticeCell:(int)index
{
    [self deleteCustomCell:index withSection:kTakeOutNoticeCellSection withKey:@"instruction"];
}

#pragma mark UITableViewController datasource & delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	tableView.backgroundColor = [UIColor clearColor];
	static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    else
    {
        //清楚cell的缓存
        NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
        for (UIView *subview in subviews)
        {
            [subview removeFromSuperview];
        }
    }
	 
	NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    if (ruleSettingDict!=nil)
    {
        // 外卖起送费、配送费、配送范围
        if (0 == row && 0 == section)
        {
            CGFloat originY = 20;
            CGFloat titleLabelOriginX = 10;
            CGFloat titleLabelWidth = 150;
            CGFloat textFieldWidth = 163;
            CGFloat unitLabelWidth = 50;
            
            if (1 == self.deliveryType)//自取外卖
            {
                // 送餐所需日数
                NSString *text = kLoc(@"self_pick_need_date");
                
                CGSize size = [self accoutLabelWithByfont:text fontofsize:20.0 hight:40];
                UILabel *needDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelOriginX, originY, size.width, 40)];
                
                needDateLabel.backgroundColor = [UIColor clearColor];
                needDateLabel.textColor = [UIColor blackColor];
                needDateLabel.textAlignment = UITextAlignmentRight;
                needDateLabel.font = [UIFont systemFontOfSize:20.0];
                needDateLabel.text = text;
                [cell.contentView addSubview:needDateLabel];
                
                CGFloat needDateTextFieldOriginX = CGRectGetMaxX(needDateLabel.frame) + 5;
                UITextField *needDateTextField = [[UITextField alloc] initWithFrame:CGRectMake(needDateTextFieldOriginX, originY, textFieldWidth, 40)];
                needDateTextField.tag = kNeedDateTextFieldTag;
                needDateTextField.delegate = self;
                needDateTextField.textAlignment = UITextAlignmentCenter;
                needDateTextField.borderStyle = UITextBorderStyleNone;
                needDateTextField.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
                needDateTextField.textColor = [UIColor blackColor];
                needDateTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                needDateTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                needDateTextField.font = [UIFont systemFontOfSize:20];
                needDateTextField.placeholder = [NSString stringWithFormat:@"（%@）",kLoc(@"optional")];

                
                
                needDateTextField.text = [NSString stringWithFormat:@"%@",[ruleSettingDict objectForKey:@"carryDays"]];
                
                [cell.contentView addSubview:needDateTextField];
                
                // 天
                CGFloat daysOriginX = needDateTextFieldOriginX + textFieldWidth + 15;
                UILabel *daysLabel = [[UILabel alloc] initWithFrame:CGRectMake(daysOriginX, originY, unitLabelWidth, 40)];
                daysLabel.backgroundColor = [UIColor clearColor];
                daysLabel.textColor = [UIColor blackColor];
                daysLabel.textAlignment = UITextAlignmentLeft;
                daysLabel.font = [UIFont boldSystemFontOfSize:20];
                daysLabel.text = kLoc(@"day");
                [cell.contentView addSubview:daysLabel];
                
                // label 注：填0表示当日送达，1表示次日送达
                text = kLoc(@"self_pick_notes");
                size = [self accoutLabelWithByfont:text fontofsize:20 hight:40];
                
                UILabel *labelNotice = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelOriginX , originY + 45, size.width, 40)];
                labelNotice.backgroundColor = [UIColor clearColor];
                labelNotice.textColor = [UIColor grayColor];
                labelNotice.textAlignment = UITextAlignmentRight;
                labelNotice.font = [UIFont systemFontOfSize:20];
                labelNotice.text = text;
                
                [cell.contentView addSubview:labelNotice];
            }
            else if ( 0 == self.deliveryType)
            {
                /******起送费*******/
                UILabel *deliveryfeeLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelOriginX, originY, titleLabelWidth, 40)];
                deliveryfeeLabel.backgroundColor = [UIColor clearColor];
                deliveryfeeLabel.textColor = [UIColor blackColor];
                deliveryfeeLabel.textAlignment = UITextAlignmentRight;
                deliveryfeeLabel.font = [UIFont systemFontOfSize:20];
                deliveryfeeLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"min_delivery_fee")];

                [cell.contentView addSubview:deliveryfeeLabel];
                
                CGFloat deliveryfeeTextFieldOriginX = titleLabelOriginX + titleLabelWidth + 5;
                UITextField *deliveryfeeTextField = [[UITextField alloc] initWithFrame:CGRectMake(deliveryfeeTextFieldOriginX, originY, textFieldWidth, 40)];
                deliveryfeeTextField.tag = kDeliveryfeeTextFieldTag;
                deliveryfeeTextField.delegate = self;
                deliveryfeeTextField.textAlignment = UITextAlignmentCenter;
                deliveryfeeTextField.borderStyle = UITextBorderStyleNone;
                deliveryfeeTextField.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
                deliveryfeeTextField.textColor = [UIColor blackColor];
                deliveryfeeTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                deliveryfeeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                deliveryfeeTextField.font = [UIFont systemFontOfSize:20];
                deliveryfeeTextField.placeholder = [NSString stringWithFormat:@"（%@）",kLoc(@"required_to_fill")];

                CGFloat minConsum = [[ruleSettingDict objectForKey:@"minConsumption"] floatValue];
                //去掉.00,.50中的0
                NSString *tempString = [NSString stringWithFormat:@"%.2f", minConsum];
                deliveryfeeTextField.text = [NSString stringWithFormat:@"%@", [NSString trimmingZeroInPrice:tempString]];
                [cell.contentView addSubview:deliveryfeeTextField];
                
                //单位,元
                CGFloat deliveryfeeUnitOriginX = deliveryfeeTextFieldOriginX + textFieldWidth + 15;
                UILabel *deliveryfeeUnitLabel = [[UILabel alloc] initWithFrame:CGRectMake(deliveryfeeUnitOriginX, originY, unitLabelWidth, 40)];
                deliveryfeeUnitLabel.backgroundColor = [UIColor clearColor];
                deliveryfeeUnitLabel.textColor = [UIColor blackColor];
                deliveryfeeUnitLabel.textAlignment = UITextAlignmentLeft;
                deliveryfeeUnitLabel.font = [UIFont boldSystemFontOfSize:20];
                deliveryfeeUnitLabel.text = kLoc(@"yuan");
                [cell.contentView addSubview:deliveryfeeUnitLabel];
                
                /******配送范围*******/
//                CGFloat carryRangeOriginY = deliveryfeeUnitLabel.frame.origin.x + deliveryfeeUnitLabel.frame.size.width + 50;
                CGFloat carryRangeOriginY = 80;
                UILabel *carryRangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelOriginX, carryRangeOriginY, titleLabelWidth, 40)];
                carryRangeLabel.backgroundColor = [UIColor clearColor];
                carryRangeLabel.textColor = [UIColor blackColor];
                carryRangeLabel.textAlignment = UITextAlignmentRight;
                carryRangeLabel.font = [UIFont systemFontOfSize:20];
                
                carryRangeLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"carry_range")];

                
                [cell.contentView addSubview:carryRangeLabel];
                
                CGFloat carryTangeTextFieldOriginX = carryRangeLabel.frame.origin.x + carryRangeLabel.frame.size.width + 5;
                UITextField *carryTangeTextField = [[UITextField alloc] initWithFrame:CGRectMake(carryTangeTextFieldOriginX, carryRangeOriginY, textFieldWidth, 40)];
                carryTangeTextField.tag = kCarryRangeTextFieldTag;
                carryTangeTextField.delegate = self;
                carryTangeTextField.textAlignment = UITextAlignmentCenter;
                carryTangeTextField.borderStyle = UITextBorderStyleNone;
                carryTangeTextField.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
                carryTangeTextField.textColor = [UIColor blackColor];
                carryTangeTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                carryTangeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                carryTangeTextField.font = [UIFont systemFontOfSize:20];
                carryTangeTextField.placeholder = [NSString stringWithFormat:@"（%@）",kLoc(@"optional")];

                CGFloat carryRange = [[ruleSettingDict objectForKey:@"carryRange"] floatValue];
                //去掉.00,.50中的0
                NSString *carryRangeStr = [NSString stringWithFormat:@"%.2f", carryRange];
                carryTangeTextField.text = [NSString stringWithFormat:@"%@", [NSString trimmingZeroInPrice:carryRangeStr]];
                [cell.contentView addSubview:carryTangeTextField];
                
                
                //单位,公里
                CGFloat deliveryRangeUnitOriginX = carryTangeTextField.frame.origin.x + carryTangeTextField.frame.size.width + 15;
                UILabel *kilometerLabel = [[UILabel alloc] initWithFrame:CGRectMake(deliveryRangeUnitOriginX, carryRangeOriginY, unitLabelWidth, 40)];
                kilometerLabel.backgroundColor = [UIColor clearColor];
                kilometerLabel.textColor = [UIColor blackColor];
                kilometerLabel.textAlignment = UITextAlignmentLeft;
                kilometerLabel.font = [UIFont boldSystemFontOfSize:20];
                kilometerLabel.text = kLoc(@"kilometer");
                [cell.contentView addSubview:kilometerLabel];
                
                // 送餐所需日数
                NSString *text = kLoc(@"take_time_need_date");
                
//                CGSize size = [self accoutLabelWithByfont:text fontofsize:20.0 hight:40];
                CGFloat needDateOriginY = 140;
                UILabel *needDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelOriginX, needDateOriginY, titleLabelWidth, 40)];
                
                needDateLabel.backgroundColor = [UIColor clearColor];
                needDateLabel.textColor = [UIColor blackColor];
                needDateLabel.textAlignment = UITextAlignmentRight;
                needDateLabel.font = [UIFont systemFontOfSize:20.0];
                needDateLabel.text = text;
                [cell.contentView addSubview:needDateLabel];
                
                CGFloat needDateTextFieldOriginX = CGRectGetMaxX(needDateLabel.frame) + 5;
                UITextField *needDateTextField = [[UITextField alloc] initWithFrame:CGRectMake(needDateTextFieldOriginX, needDateOriginY, textFieldWidth, 40)];
                needDateTextField.tag = kNeedDateTextFieldTag;
                needDateTextField.delegate = self;
                needDateTextField.textAlignment = UITextAlignmentCenter;
                needDateTextField.borderStyle = UITextBorderStyleNone;
                needDateTextField.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
                needDateTextField.textColor = [UIColor blackColor];
                needDateTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                needDateTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                needDateTextField.font = [UIFont systemFontOfSize:20];
                needDateTextField.placeholder = [NSString stringWithFormat:@"（%@）",kLoc(@"optional")];
                
                needDateTextField.text = [NSString stringWithFormat:@"%@",[ruleSettingDict objectForKey:@"carryDays"]];
                
                [cell.contentView addSubview:needDateTextField];
                
                // 天
                CGFloat daysOriginX = needDateTextFieldOriginX + textFieldWidth + 15;
                UILabel *daysLabel = [[UILabel alloc] initWithFrame:CGRectMake(daysOriginX, needDateOriginY, unitLabelWidth, 40)];
                daysLabel.backgroundColor = [UIColor clearColor];
                daysLabel.textColor = [UIColor blackColor];
                daysLabel.textAlignment = UITextAlignmentLeft;
                daysLabel.font = [UIFont boldSystemFontOfSize:20];
                daysLabel.text = kLoc(@"day");
                [cell.contentView addSubview:daysLabel];
                
                // label 注：填0表示当日送达，1表示次日送达
                text = kLoc(@"delivery_meal_notes");
                CGSize size = [self accoutLabelWithByfont:text fontofsize:20 hight:40];
                
                UILabel *labelNotice = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelOriginX , needDateOriginY + 45, size.width, 40)];
                labelNotice.backgroundColor = [UIColor clearColor];
                labelNotice.textColor = [UIColor grayColor];
                labelNotice.textAlignment = UITextAlignmentRight;
                labelNotice.font = [UIFont systemFontOfSize:20];
                labelNotice.text = text;
                
                [cell.contentView addSubview:labelNotice];
            }
            
        }
        
        //配送费
        if (0 == row && 1 == section && 0 == self.deliveryType)
        {
            CGFloat spaceX = 10;
            CGFloat spaceY = 80;
//            CGFloat oneFontWidth = 18;
            CGFloat oneFontHight = 30;
            CGFloat textFieldWidth = 120;
            CGFloat textFieldHight = 40;
            CGFloat sizeOfFont = 20.0;
            
            UIColor *labelColor = [UIColor colorWithRed:104.0/255.0 green:145.0/255.0 blue:49.0/255.0 alpha:1.0];
            
            // 标题背景
            UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-2, 0, 816, 60)];
            bgImageView.image = [UIImage imageFromMainBundleFile:@"rule_cellHeadBg.png"];
            [cell.contentView addSubview:bgImageView];
            
            // 标题
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10 , 150, 40)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = labelColor;
            label.textAlignment = UITextAlignmentLeft;
            label.font = [UIFont boldSystemFontOfSize:20];
            //label.text = kLoc(@"配送费 ：", nil);
            label.text = [NSString stringWithFormat:@"%@ : ",kLoc(@"carry_fee")];

            [cell.contentView addSubview:label];
            
            // 添加按钮
            UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [addBtn setFrame:CGRectMake(745, 5, 47, 47)];
            [addBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_addButton.png"] forState:UIControlStateNormal];
            [addBtn addTarget:self action:@selector(addFeeCell) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:addBtn];
            
            /* 消费100 ************************************************************/
            // label100
            NSString *text = kLoc(@"consume");
            
            CGSize size = [self accoutLabelWithByfont:text fontofsize:20 hight:oneFontHight];
            
            UILabel *label100 = [[UILabel alloc] initWithFrame:CGRectMake(20, 60 + (spaceY -  oneFontHight)/2 , size.width , oneFontHight)];
            label100.backgroundColor = [UIColor clearColor];
            label100.textColor = [UIColor blackColor];
            label100.textAlignment = UITextAlignmentRight;
            label100.font = [UIFont systemFontOfSize:20];
            label100.text = text;
            [cell.contentView addSubview:label100];
            
            // textfield100
            UITextField *textfield100 = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label100.frame) + spaceX, 60 + (spaceY -  textFieldHight)/2 , textFieldWidth, textFieldHight)];
            textfield100.tag = kCarryfeeUpperTextFieldTag;
            textfield100.delegate = self;
            textfield100.textAlignment = UITextAlignmentCenter;
            textfield100.borderStyle = UITextBorderStyleNone;
            textfield100.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
            textfield100.textColor = [UIColor blackColor];
            textfield100.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            textfield100.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textfield100.font = [UIFont systemFontOfSize:20];
            _upperCostTextField = textfield100;
            
            if ([ruleSettingDict objectForKey:@"carryfee"] != nil)
            {
                NSDictionary *dict = [[ruleSettingDict objectForKey:@"carryfee"] objectForKey:@"openInterval"];
                if (dict != nil && [dict objectForKey:@"upper"] )
                {
                    
                    NSString *string = [NSString stringWithFormat:@"%@" ,[[dict objectForKey:@"upper"] objectForKey:@"cost"]];
                    if (string.length > 0)
                    {
                        textfield100.text = string;
                    }
                }
            }
            [cell.contentView addSubview:textfield100];
            
            // label元（
            text = [NSString stringWithFormat:@"%@（",kLoc(@"yuan")];
            
            size = [self accoutLabelWithByfont:text fontofsize:20 hight:oneFontHight];
            UILabel *labelLeft1 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textfield100.frame) + spaceX, label100.frame.origin.y , size.width + spaceX, oneFontHight)];
            labelLeft1.backgroundColor = [UIColor clearColor];
            labelLeft1.textColor = [UIColor blackColor];
            labelLeft1.textAlignment = UITextAlignmentRight;
            labelLeft1.font = [UIFont systemFontOfSize:20];
            labelLeft1.text = text;
            [cell.contentView addSubview:labelLeft1];
            
            // button1
            UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(labelLeft1.frame) , 60 + (spaceY -  25)/2 , 25, 25)];
            [button1 setBackgroundImage:[UIImage imageNamed:@"order_by_phone_area_unselected.png"] forState:UIControlStateNormal];
            [button1 setBackgroundImage:[UIImage imageNamed:@"order_by_phone_area_selected.png"] forState:UIControlStateSelected];
            button1.tag = 1;
            [button1 addTarget:self action:@selector(includeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            if ([ruleSettingDict objectForKey:@"carryfee"] != nil)
            {
                NSDictionary *dict = [[ruleSettingDict objectForKey:@"carryfee"] objectForKey:@"openInterval"];
                if (dict != nil && [dict objectForKey:@"upper"])
                {
                    button1.selected = [[[dict objectForKey:@"upper"] objectForKey:@"equal"] integerValue];
                }
            }
            [cell.contentView addSubview:button1];
            
            // label含）以上，配送费
            //text = kLoc(@"含）以上，配送费", nil);
            text = [NSString stringWithFormat:@"%@）%@，%@",kLoc(@"contains"),kLoc(@"above"),kLoc(@"carry_fee")];

            size = [self accoutLabelWithByfont:text fontofsize:sizeOfFont hight:oneFontHight];
            UILabel *labelright1 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button1.frame) + spaceX, label100.frame.origin.y , size.width, oneFontHight)];
            labelright1.backgroundColor = [UIColor clearColor];
            labelright1.textColor = [UIColor blackColor];
            labelright1.textAlignment = UITextAlignmentRight;
            labelright1.font = [UIFont systemFontOfSize:20];
            labelright1.text = text;
            [cell.contentView addSubview:labelright1];
            
            // textfield100
            UITextField *textfieldFee = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(labelright1.frame) + spaceX, 60 + (spaceY -  textFieldHight)/2 , textFieldWidth, textFieldHight)];
            textfieldFee.tag = kCarryfeeCashUpperTextFieldTag;
            textfieldFee.delegate = self;
            textfieldFee.textAlignment = UITextAlignmentCenter;
            textfieldFee.borderStyle = UITextBorderStyleNone;
            textfieldFee.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
            textfieldFee.textColor = [UIColor blackColor];
            textfieldFee.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            textfieldFee.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textfieldFee.font = [UIFont systemFontOfSize:20];
            _upperCarryfeeTextField = textfieldFee;
            
            if ([ruleSettingDict objectForKey:@"carryfee"] != nil)
            {
                NSDictionary *dict = [[ruleSettingDict objectForKey:@"carryfee"] objectForKey:@"openInterval"];
                if (dict != nil && [dict objectForKey:@"upper"] )
                {
                    NSString *string = [NSString stringWithFormat:@"%@", [[dict objectForKey:@"upper"] objectForKey:@"carryfee"]];
                    if ([string length] > 0)
                    {
                        textfieldFee.text = string;
                    }
                }
                
            }
            [cell.contentView addSubview:textfieldFee];
            
            // label元
            text = kLoc(@"yuan");
            
            size = [self accoutLabelWithByfont:text fontofsize:sizeOfFont hight:oneFontHight];
            UILabel *labelYuan = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textfieldFee.frame) + spaceX, label100.frame.origin.y , size.width, oneFontHight)];
            labelYuan.backgroundColor = [UIColor clearColor];
            labelYuan.textColor = [UIColor blackColor];
            labelYuan.textAlignment = UITextAlignmentRight;
            labelYuan.font = [UIFont systemFontOfSize:20];
            labelYuan.text = text;
            [cell.contentView addSubview:labelYuan];
            
            // 分割线
//            UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, spaceY + 60, 812, 1)];
//            lineImageView.backgroundColor = [UIColor lightGrayColor];
//            [cell.contentView addSubview:lineImageView];
            
            /* 消费200 ************************************************************/
            // label200
            text = kLoc(@"consume");
            
            size = [self accoutLabelWithByfont:text fontofsize:sizeOfFont hight:oneFontHight];
            UILabel *label200 = [[UILabel alloc] initWithFrame:CGRectMake(20, 60 + spaceY+(spaceY -  oneFontHight)/2 , size.width, oneFontHight)];
            label200.backgroundColor = [UIColor clearColor];
            label200.textColor = [UIColor blackColor];
            label200.textAlignment = UITextAlignmentRight;
            label200.font = [UIFont systemFontOfSize:20];
            label200.text = text;
            [cell.contentView addSubview:label200];
            
            // textfield200
            UITextField *textfield200 = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label200.frame) + spaceX, 60 + spaceY + (spaceY -  textFieldHight)/2 , textFieldWidth, textFieldHight)];
            textfield200.tag = kCarryfeeLowerTextFieldTag;
            textfield200.delegate = self;
            textfield200.textAlignment = UITextAlignmentCenter;
            textfield200.borderStyle = UITextBorderStyleNone;
            textfield200.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
            textfield200.textColor = [UIColor blackColor];
            textfield200.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            textfield200.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textfield200.font = [UIFont systemFontOfSize:20];
            _lowerCostTextField = textfield200;
            
            if ([ruleSettingDict objectForKey:@"carryfee"] != nil)
            {
                NSDictionary *dict = [[ruleSettingDict objectForKey:@"carryfee"] objectForKey:@"openInterval"];
                if (dict != nil && [dict objectForKey:@"lower"])
                {
                    NSString *string = [NSString stringWithFormat:@"%@", [[dict objectForKey:@"lower"] objectForKey:@"cost"]];
                    if ([string length] > 0)
                    {
                        textfield200.text = string;
                    }
                }
                
            }
            [cell.contentView addSubview:textfield200];
            

            // label元（
            text = [NSString stringWithFormat:@"%@（",kLoc(@"yuan")];
            size = [self accoutLabelWithByfont:text fontofsize:20 hight:oneFontHight];
            UILabel *labelLeft2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textfield100.frame) + spaceX, label200.frame.origin.y , size.width + spaceX, oneFontHight)];
            labelLeft2.backgroundColor = [UIColor clearColor];
            labelLeft2.textColor = [UIColor blackColor];
            labelLeft2.textAlignment = UITextAlignmentRight;
            labelLeft2.font = [UIFont systemFontOfSize:20];
            labelLeft2.text = text;
            [cell.contentView addSubview:labelLeft2];
            
            // button2
            UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(labelLeft2.frame) , 60 + spaceY + (spaceY -  25)/2 , 25, 25)];
            [button2 setBackgroundImage:[UIImage imageNamed:@"order_by_phone_area_unselected.png"] forState:UIControlStateNormal];
            [button2 setBackgroundImage:[UIImage imageNamed:@"order_by_phone_area_selected.png"] forState:UIControlStateSelected];
            button2.tag = 2;
            [button2 addTarget:self action:@selector(includeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            if ([ruleSettingDict objectForKey:@"carryfee"] != nil)
            {
                NSDictionary *dict = [[ruleSettingDict objectForKey:@"carryfee"] objectForKey:@"openInterval"];
                if (dict != nil && [dict objectForKey:@"lower"])
                {
                    button2.selected = [[[dict objectForKey:@"lower"] objectForKey:@"equal"] integerValue];
                }
            }
            [cell.contentView addSubview:button2];
            
            // label含）以上，配送费
           // text = kLoc(@"含）以下，配送费", nil);
            
            text = [NSString stringWithFormat:@"%@）%@，%@",kLoc(@"contains"),kLoc(@"below"),kLoc(@"carry_fee")];

            size = [self accoutLabelWithByfont:text fontofsize:sizeOfFont hight:oneFontHight];
            UILabel *labelright2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(button1.frame) + spaceX, label200.frame.origin.y , size.width, oneFontHight)];
            labelright2.backgroundColor = [UIColor clearColor];
            labelright2.textColor = [UIColor blackColor];
            labelright2.textAlignment = UITextAlignmentRight;
            labelright2.font = [UIFont systemFontOfSize:20];
            labelright2.text = text;
            [cell.contentView addSubview:labelright2];
            
            // textfield200
            UITextField *textfieldFee200 = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(labelright2.frame) + spaceX, 60 +spaceY + (spaceY -  textFieldHight)/2 , textFieldWidth, textFieldHight)];
            textfieldFee200.tag = kCarryfeeCashLowerTextFieldTag;
            textfieldFee200.delegate = self;
            textfieldFee200.textAlignment = UITextAlignmentCenter;
            textfieldFee200.borderStyle = UITextBorderStyleNone;
            textfieldFee200.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
            textfieldFee200.textColor = [UIColor blackColor];
            textfieldFee200.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            textfieldFee200.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textfieldFee200.font = [UIFont systemFontOfSize:20];
            _lowerCarryfeeTextField = textfieldFee200;
            
            if ([ruleSettingDict objectForKey:@"carryfee"] != nil)
            {
                NSDictionary *dict = [[ruleSettingDict objectForKey:@"carryfee"] objectForKey:@"openInterval"];
                if (dict != nil && [dict objectForKey:@"lower"])
                {
                    NSString *string = [NSString stringWithFormat:@"%@", [[dict objectForKey:@"lower"] objectForKey:@"carryfee"]];
                    if ([string length] > 0)
                    {
                        textfieldFee200.text = string;
                    }
                }
            }
            
            [cell.contentView addSubview:textfieldFee200];
            
            // label元
            text = kLoc(@"yuan");
            
            size = [self accoutLabelWithByfont:text fontofsize:sizeOfFont hight:oneFontHight];
            UILabel *labelYuan200 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textfieldFee200.frame) + spaceX, label200.frame.origin.y , size.width, oneFontHight)];
            labelYuan200.backgroundColor = [UIColor clearColor];
            labelYuan200.textColor = [UIColor blackColor];
            labelYuan200.textAlignment = UITextAlignmentRight;
            labelYuan200.font = [UIFont systemFontOfSize:20];
            labelYuan200.text = text;
            [cell.contentView addSubview:labelYuan200];
            
            // 分割线
//            lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 2 * spaceY + 60, 812, 1)];
//            lineImageView.backgroundColor = [UIColor lightGrayColor];
//            [cell.contentView addSubview:lineImageView];
            
            NSArray *arry = nil;
            if ([ruleSettingDict objectForKey:@"carryfee"] != nil)
            {
                arry = [[ruleSettingDict objectForKey:@"carryfee"] objectForKey:@"closedInterval"];
            }
            
            //NSInteger count = (arry.count == 0) ? 1 : arry.count;
            NSInteger count = arry.count;
            for (int i = 0; i < count; i++)
            {
                // 消费
                CGFloat labelY = 60 + (2 + i)* spaceY+(spaceY -  oneFontHight)/2;
                text = kLoc(@"consume");
                size = [self accoutLabelWithByfont:text fontofsize:sizeOfFont hight:oneFontHight];
                UILabel *labelXiaofei = [[UILabel alloc] initWithFrame:CGRectMake(20, labelY , size.width, oneFontHight)];
                labelXiaofei.backgroundColor = [UIColor clearColor];
                labelXiaofei.textColor = [UIColor blackColor];
                labelXiaofei.textAlignment = UITextAlignmentRight;
                labelXiaofei.font = [UIFont systemFontOfSize:20];
                labelXiaofei.text = text;
                [cell.contentView addSubview:labelXiaofei];

                // textfield1
                CGFloat textfieldY = 60 + (2 + i)* spaceY+(spaceY -  textFieldHight)/2;
                UITextField *textfield1 = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(labelXiaofei.frame) + spaceX, textfieldY , textFieldWidth, textFieldHight)];
                textfield1.tag = kCarryfeeUserLowerTextFieldTag + i;
                textfield1.delegate = self;
                textfield1.textAlignment = UITextAlignmentCenter;
                textfield1.borderStyle = UITextBorderStyleNone;
                textfield1.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
                textfield1.textColor = [UIColor blackColor];
                textfield1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                textfield1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                textfield1.font = [UIFont systemFontOfSize:20];
                if ([ruleSettingDict objectForKey:@"carryfee"] != nil)
                {
                    NSArray *arry = [[ruleSettingDict objectForKey:@"carryfee"] objectForKey:@"closedInterval"];
                    if (arry && arry.count > i)
                    {
                        NSDictionary *dict = arry[i];
                        if (dict && [dict objectForKey:@"lowerCost"] )
                        {
                            NSString *string = [NSString stringWithFormat:@"%@" ,[dict objectForKey:@"lowerCost"]];
                            if ([string length] > 0)
                            {
                                textfield1.text = string;
                            }
                        }
                    }
                    
                }
                [cell.contentView addSubview:textfield1];
                
                // 至
                text = kLoc(@"to");
                
                size = [self accoutLabelWithByfont:text fontofsize:sizeOfFont hight:oneFontHight];
                UILabel *labelZhi = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textfield1.frame) + spaceX, labelY , size.width, oneFontHight)];
                labelZhi.backgroundColor = [UIColor clearColor];
                labelZhi.textColor = [UIColor blackColor];
                labelZhi.textAlignment = UITextAlignmentRight;
                labelZhi.font = [UIFont systemFontOfSize:20];
                labelZhi.text = text;
                [cell.contentView addSubview:labelZhi];
                
                // textfield2
                UITextField *textfield2 = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(labelZhi.frame) + spaceX, textfieldY , textFieldWidth, textFieldHight)];
                textfield2.tag = kCarryfeeUserUpperTextFieldTag + i;
                textfield2.delegate = self;
                textfield2.textAlignment = UITextAlignmentCenter;
                textfield2.borderStyle = UITextBorderStyleNone;
                textfield2.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
                textfield2.textColor = [UIColor blackColor];
                textfield2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                textfield2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                textfield2.font = [UIFont systemFontOfSize:20];
                if ([ruleSettingDict objectForKey:@"carryfee"] != nil)
                {
                    NSArray *arry = [[ruleSettingDict objectForKey:@"carryfee"] objectForKey:@"closedInterval"];
                    if (arry && arry.count > i)
                    {
                        NSDictionary *dict = arry[i];
                        if (dict && [dict objectForKey:@"upperCost"] )
                        {
                            NSString *string = [NSString stringWithFormat:@"%@" ,[dict objectForKey:@"upperCost"]];
                            if ([string length] > 0)
                            {
                                textfield2.text = string;
                            }
                        }
                    }
                    
                }
                [cell.contentView addSubview:textfield2];
                
                // 元，配送费
                text = [NSString stringWithFormat:@"%@，%@",kLoc(@"yuan"),kLoc(@"carry_fee")];

                size = [self accoutLabelWithByfont:text fontofsize:sizeOfFont hight:oneFontHight];
                UILabel *labelFee = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textfield2.frame) + spaceX, labelY , size.width, oneFontHight)];
                labelFee.backgroundColor = [UIColor clearColor];
                labelFee.textColor = [UIColor blackColor];
                labelFee.textAlignment = UITextAlignmentRight;
                labelFee.font = [UIFont systemFontOfSize:20];
                labelFee.text = text;
                [cell.contentView addSubview:labelFee];
                
                // textfield3
                UITextField *textfield3 = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(labelFee.frame) + spaceX, textfieldY , textFieldWidth, textFieldHight)];
                textfield3.tag = kCarryfeeUserCashTextFieldTag + i;
                textfield3.delegate = self;
                textfield3.textAlignment = UITextAlignmentCenter;
                textfield3.borderStyle = UITextBorderStyleNone;
                textfield3.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
                textfield3.textColor = [UIColor blackColor];
                textfield3.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                textfield3.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                textfield3.font = [UIFont systemFontOfSize:20];
                if ([ruleSettingDict objectForKey:@"carryfee"] != nil)
                {
                    NSArray *arry = [[ruleSettingDict objectForKey:@"carryfee"] objectForKey:@"closedInterval"];
                    if (arry && arry.count > i)
                    {
                        NSDictionary *dict = arry[i];
                        if (dict && [dict objectForKey:@"carryfee"] )
                        {
                            NSString *string = [NSString stringWithFormat:@"%@" ,[dict objectForKey:@"carryfee"]];
                            if ([string length] > 0)
                            {
                                textfield3.text = string;
                            }
                        }
                    }
                    
                }
                [cell.contentView addSubview:textfield3];
                
                // 元
                text = kLoc(@"yuan");
                
                size = [self accoutLabelWithByfont:text fontofsize:sizeOfFont hight:oneFontHight];
                UILabel *labelYuan = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textfield3.frame) + spaceX, labelY , size.width, oneFontHight)];
                labelYuan.backgroundColor = [UIColor clearColor];
                labelYuan.textColor = [UIColor blackColor];
                labelYuan.textAlignment = UITextAlignmentRight;
                labelYuan.font = [UIFont systemFontOfSize:20];
                labelYuan.text = text;
                [cell.contentView addSubview:labelYuan];
                
                //删除CELL按钮
                CGFloat buttonY =  60 + (2 + i)* spaceY+(spaceY -  41)/2;
                UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                deleteBtn.tag = i;
                [deleteBtn setFrame:CGRectMake(750, buttonY, 40, 41)];
                [deleteBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_deleteButton.png"] forState:UIControlStateNormal];
                [deleteBtn addTarget:self action:@selector(deleteFeeCell:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:deleteBtn];
                
                // 分割线
//                lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 60 + (2 + i + 1)* spaceY , 812, 1)];
//                lineImageView.backgroundColor = [UIColor lightGrayColor];
//                [cell.contentView addSubview:lineImageView];
            }
            
            /* 注意 ************************************************************/
            CGFloat cellHeight = 60 + 80 * (arry.count + 3);
            CGFloat labelNoticeY = cellHeight - (spaceY - oneFontHight)/2 - oneFontHight;
            CGFloat textFiledNoticeY = cellHeight - (spaceY - textFieldHight)/2 - textFieldHight;
            
            // label *
            text = @""; // kLoc(@"* ", nil);
            size = [self accoutLabelWithByfont:text fontofsize:20 hight:oneFontHight];
            
            UILabel *labelStar = [[UILabel alloc] initWithFrame:CGRectMake(20, labelNoticeY, size.width, oneFontHight)];
            labelStar.backgroundColor = [UIColor clearColor];
            labelStar.textColor = [UIColor redColor];
            labelStar.textAlignment = UITextAlignmentRight;
            labelStar.font = [UIFont systemFontOfSize:20];
            labelStar.text = text;
            
            [cell.contentView addSubview:labelStar];
            
            // label如果消费金额不满足上述条件，默认配送费为
            text = kLoc(@"default_carry_fee_notes");
            size = [self accoutLabelWithByfont:text fontofsize:20 hight:oneFontHight];
            
            UILabel *labelNotice = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(labelStar.frame) , labelNoticeY, size.width, oneFontHight)];
            labelNotice.backgroundColor = [UIColor clearColor];
            labelNotice.textColor = [UIColor grayColor];
            labelNotice.textAlignment = UITextAlignmentRight;
            labelNotice.font = [UIFont systemFontOfSize:20];
            labelNotice.text = text;
            
            [cell.contentView addSubview:labelNotice];
            
            // textfield
            UITextField *textfieldNotice = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(labelNotice.frame) + spaceX, textFiledNoticeY , textFieldWidth, textFieldHight)];
            textfieldNotice.tag = kCarryfeeCashDefaultTextFieldTag;
            textfieldNotice.delegate = self;
            textfieldNotice.textAlignment = UITextAlignmentCenter;
            textfieldNotice.borderStyle = UITextBorderStyleNone;
            textfieldNotice.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
            textfieldNotice.textColor = [UIColor grayColor];
            textfieldNotice.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            textfieldNotice.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textfieldNotice.font = [UIFont systemFontOfSize:20];
            if ([ruleSettingDict objectForKey:@"carryfee"] != nil)
            {
                NSString *defaultCarryfee = [[ruleSettingDict objectForKey:@"carryfee"] objectForKey:@"defaultCarryfee"];
                if (defaultCarryfee )
                {
                    textfieldNotice.text = [NSString stringWithFormat:@"%@" ,defaultCarryfee];
                }
            }
            [cell.contentView addSubview:textfieldNotice];
            
            // label元
            text = kLoc(@"yuan");
            
            size = [self accoutLabelWithByfont:text fontofsize:sizeOfFont hight:oneFontHight];
            UILabel *labelNoticeYuan = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textfieldNotice.frame) + spaceX, labelNoticeY, size.width, oneFontHight)];
            labelNoticeYuan.backgroundColor = [UIColor clearColor];
            labelNoticeYuan.textColor = [UIColor grayColor];
            labelNoticeYuan.textAlignment = UITextAlignmentRight;
            labelNoticeYuan.font = [UIFont systemFontOfSize:20];
            labelNoticeYuan.text = text;
            [cell.contentView addSubview:labelNoticeYuan];
        }
        
        //外卖时间
        if (0 == row && 2 == section)
        {
            NSArray *businessTimeArray = [ruleSettingDict objectForKey:@"takeoutTime"];
            int businessTimeCount = (int)[businessTimeArray count];
            NSString *businessTimeString = [NSString stringWithFormat:@"( %d )",businessTimeCount];
            
            UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-2, 0, 816, 60)];
            bgImageView.image = [UIImage imageFromMainBundleFile:@"rule_cellHeadBg.png"];
            [cell.contentView addSubview:bgImageView];
            
            DetailTextView *label = [[DetailTextView alloc]initWithFrame:CGRectMake(10, 15 , 500, 40)];
            UIColor *labelColor = [UIColor colorWithRed:104.0/255.0 green:145.0/255.0 blue:49.0/255.0 alpha:1.0];
            NSString *titleStr = [NSString stringWithFormat:@"%@%@",((0 == self.deliveryType)?kLoc(@"takeout"):kLoc(@"self_pick")),kLoc(@"time")];
            [label setText:[NSString stringWithFormat:@"%@ ：%@",titleStr,businessTimeString] WithFont:[UIFont boldSystemFontOfSize:20] AndColor:labelColor];
            [label setKeyWordTextArray:[NSArray arrayWithObjects:businessTimeString, nil] WithFont:[UIFont boldSystemFontOfSize:16] AndColor:labelColor];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = UITextAlignmentLeft;
            [cell.contentView addSubview:label];

            //添加按钮
            UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [addBtn setFrame:CGRectMake(745, 5, 47, 47)];
            [addBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_addButton.png"] forState:UIControlStateNormal];
            [addBtn addTarget:self action:@selector(addBusinessTimeCell) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:addBtn];
            
            int spaceY = 80;
            for (int i=0; i< businessTimeCount; i++)
            {
                //开放的weekday，如：一;二;三;四;五
                UIButton *startWeekdayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                startWeekdayBtn.tag = kStartWeekdayTextFieldTag+i;
                [startWeekdayBtn setFrame:CGRectMake(20, spaceY+i*80, 312, 40)];
                [startWeekdayBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_popupButton_long.png"] forState:UIControlStateNormal];
                
                //设置startWeekdayBtn的text
                startWeekdayBtn.titleLabel.font = [UIFont systemFontOfSize:18];
                [startWeekdayBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                [startWeekdayBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
                startWeekdayBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 30);
                
                [startWeekdayBtn setTitle:kLoc(@"required_to_fill")
                                 forState:UIControlStateNormal];
                
                if (businessTimeArray) {
                    NSMutableDictionary *general = [businessTimeArray objectAtIndex:i];
                    
                    if (general)
                    {
                        NSArray *arry = [general objectForKey:@"week"];
                        if (arry)
                        {
                            NSString *text = [self weekdayText:arry];
                            [startWeekdayBtn setTitle:text forState:UIControlStateNormal];
                        }
                    }
                }
                
                [startWeekdayBtn addTarget:self action:@selector(takeOutTimeStartAtWeekday:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:startWeekdayBtn];
                
                if (_weekdayBtnArray == nil)
                {
                    _weekdayBtnArray = [[NSMutableArray alloc] init];
                }
                [_weekdayBtnArray addObject:startWeekdayBtn];
                
                //开始时间
                UITextField *textfield1 = [[UITextField alloc] initWithFrame:CGRectMake(20 + 338, spaceY+i*80, 160, 40)];
                textfield1.tag = 1000+i;
                textfield1.delegate = self;
                textfield1.borderStyle = UITextBorderStyleNone;
                textfield1.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
                textfield1.textColor = [UIColor blackColor];
                textfield1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                textfield1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                textfield1.textAlignment = UITextAlignmentCenter;
                textfield1.placeholder = kLoc(@"required_to_fill");
                textfield1.clearButtonMode = UITextFieldViewModeAlways;
                textfield1.font = [UIFont systemFontOfSize:18];
                textfield1.text = [[businessTimeArray objectAtIndex:i] objectForKey:@"startTime"];
                [cell.contentView addSubview:textfield1];
                
                //“至”
                UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(195 + 338, spaceY +  5 + i*80, 30, 30)];
                label1.backgroundColor = [UIColor clearColor];
                label1.textColor = [UIColor blackColor];
                label1.text = kLoc(@"to");
                [cell.contentView addSubview:label1];
                
                //结束时间
                UITextField *textfield2 = [[UITextField alloc] initWithFrame:CGRectMake(230 + 338, spaceY+i*80, 160, 40)];
                textfield2.tag = 2000+i;
                textfield2.delegate = self;
                textfield2.borderStyle = UITextBorderStyleNone;
                textfield2.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
                textfield2.textColor = [UIColor blackColor];
                textfield2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                textfield2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                textfield2.textAlignment = UITextAlignmentCenter;
                textfield2.placeholder = kLoc(@"required_to_fill");
                textfield2.font = [UIFont systemFontOfSize:18];
                textfield2.clearButtonMode = UITextFieldViewModeAlways;
                textfield2.text = [[businessTimeArray objectAtIndex:i]objectForKey:@"endTime"];
                [cell.contentView addSubview:textfield2];
                
                //删除CELL按钮
                UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                deleteBtn.tag = i;
                [deleteBtn setFrame:CGRectMake(750, spaceY + i*80, 40, 41)];
                [deleteBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_deleteButton.png"] forState:UIControlStateNormal];
                [deleteBtn addTarget:self action:@selector(deleteSpecialCloseTimeCell:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:deleteBtn];
                
                if (businessTimeCount <= 1)
                {
                    deleteBtn.hidden = YES;
                }
                else
                {
                    deleteBtn.hidden = NO;
                }
                
                //加上一条横线
                if (businessTimeCount > 1 && i != businessTimeCount - 1)
                {
                    UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, spaceY + 60 + i * 80, 812, 1)];
                    lineImageView.backgroundColor = [UIColor lightGrayColor];
                    [cell.contentView addSubview:lineImageView];
                }
                
            }
        }
        //外卖须知
        if (3 == section)
        {
            if (0 == indexPath.row)
            {
                [cell.contentView addSubview:[self barViewOfCell:kTakeOutNoticeCellType]];
            }
            else
            {
                //indexPath.row - 1是减去横条
                return [self getCustomCell:kTakeOutNoticeCellType withIndex:indexPath.row - 1];
            }
        }
        //折扣优惠
        if (0 == row && 4 == section)
        {
            int originX = 15, originY = 20, spaceX = 10, spaceY = 20;
            BOOL isOpen = [[ruleSettingDict objectForKey:@"discountSwitch"]boolValue];
            NSDictionary *discountTimeDict = [ruleSettingDict objectForKey:@"discountTime"];
            
            UIColor *labelColor = [UIColor colorWithRed:104.0/255.0 green:145.0/255.0 blue:49.0/255.0 alpha:1.0];
            
            //背景
            UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-2, 0, 816, 60)];
            bgImageView.image = [UIImage imageFromMainBundleFile:@"rule_cellHeadBg.png"];
            [cell.contentView addSubview:bgImageView];
            
            //折扣优惠
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10 , 150, 40)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = labelColor;
            label.textAlignment = UITextAlignmentLeft;
            label.font = [UIFont boldSystemFontOfSize:20];
            label.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"preferential_after_discount")];

            [cell.contentView addSubview:label];
            
            //折扣开关
            UISwitch *switchCtl = [[UISwitch alloc] initWithFrame:CGRectMake(kTableViewWidth - (kSystemVersionIsIOS7?75:90) , 15.0, 94.0, 27.0)];
            switchCtl.backgroundColor = [UIColor clearColor];
            [switchCtl setOn:[[ruleSettingDict objectForKey:@"discountSwitch"]boolValue]];
            [switchCtl addTarget:self action:@selector(discountSwitchClicked:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchCtl];
            
            if (isOpen)
            {
                //全单折扣
                UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY + bgImageView.frame.size.height, 110, 40)];
                label1.backgroundColor = [UIColor clearColor];
                label1.textColor = [UIColor blackColor];
                label1.textAlignment = UITextAlignmentLeft;
                label1.font = [UIFont systemFontOfSize:20];
                label1.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"total_bill_discount")];

                [cell.contentView addSubview:label1];
                
                UITextField *discountTextField = [[UITextField alloc] initWithFrame:CGRectMake(originX + label1.frame.size.width - 5, originY + bgImageView.frame.size.height + 2, 80, 35)];
                discountTextField.tag = kDiscountTextFieldTag;
                discountTextField.delegate = self;
                discountTextField.textAlignment = UITextAlignmentCenter;
                discountTextField.borderStyle = UITextBorderStyleNone;
                discountTextField.background = [UIImage imageFromMainBundleFile:@"rule_discountFieldBg.png"];
                discountTextField.textColor = [UIColor blackColor];
                discountTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                discountTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                discountTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                discountTextField.keyboardType = UIKeyboardTypeNumberPad;
                discountTextField.returnKeyType = UIReturnKeyDone;
                discountTextField.font = [UIFont systemFontOfSize:20];
                
                discountTextField.placeholder = [NSString stringWithFormat:@"（%@）",kLoc(@"required_to_fill")];

                CGFloat minConsum = [[ruleSettingDict objectForKey:@"discount"] floatValue];
                //去掉.00,.50中的0
                NSString *tempString = [NSString stringWithFormat:@"%.2f", minConsum];
                discountTextField.text = [NSString stringWithFormat:@"%@", [NSString trimmingZeroInPrice:tempString]];
                [cell.contentView addSubview:discountTextField];
                
                UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(originX + label1.frame.size.width + spaceX + discountTextField.frame.size.width, originY + bgImageView.frame.size.height, 300, 40)];
                label2.backgroundColor = [UIColor clearColor];
                label2.textColor = labelColor;
                label2.textAlignment = UITextAlignmentLeft;
                label2.font = [UIFont systemFontOfSize:16];
                label2.text = kLoc(@"discount_note");
                [cell.contentView addSubview:label2];
                
                //优惠期限
                UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY + bgImageView.frame.size.height + label1.frame.size.height + spaceY, 110, 40)];
                label3.backgroundColor = [UIColor clearColor];
                label3.textColor = [UIColor blackColor];
                label3.textAlignment = UITextAlignmentLeft;
                label3.font = [UIFont systemFontOfSize:20];
                label3.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"preferential_deadline")];

                [cell.contentView addSubview:label3];
                
                //一直开放
                _privilegeDeadlineAllTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _privilegeDeadlineAllTimeButton.tag = 1;
                [_privilegeDeadlineAllTimeButton setFrame:CGRectMake(originX + label3.frame.size.width, originY + bgImageView.frame.size.height + label1.frame.size.height + spaceY + 10, 28, 28)];

                [_privilegeDeadlineAllTimeButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"order_by_phone_area_unselected.png"] forState:UIControlStateNormal];
                [_privilegeDeadlineAllTimeButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"order_by_phone_area_selected.png"] forState:UIControlStateSelected];
                [_privilegeDeadlineAllTimeButton addTarget:self action:@selector(deadlineBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:_privilegeDeadlineAllTimeButton];
                
                UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(originX + CGRectGetMaxX(_privilegeDeadlineAllTimeButton.frame) + spaceX, originY + bgImageView.frame.size.height + label1.frame.size.height + spaceY + 5, 300, 30)];
                label4.backgroundColor = [UIColor clearColor];
                label4.textColor = [UIColor blackColor];
                label4.textAlignment = UITextAlignmentLeft;
                label4.font = [UIFont systemFontOfSize:20];
                label4.text = kLoc(@"always_open");
                [cell.contentView addSubview:label4];
                
                //期限开放
                _privilegeDeadlinelimitTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _privilegeDeadlinelimitTimeButton.tag = 2;
                [_privilegeDeadlinelimitTimeButton setFrame:CGRectMake(originX + label3.frame.size.width, originY + bgImageView.frame.size.height + label1.frame.size.height + spaceY + _privilegeDeadlineAllTimeButton.frame.size.height + spaceY + 9, 28, 28)];

                [_privilegeDeadlinelimitTimeButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"order_by_phone_area_unselected.png"] forState:UIControlStateNormal];
                [_privilegeDeadlinelimitTimeButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"order_by_phone_area_selected.png"] forState:UIControlStateSelected];
                [_privilegeDeadlinelimitTimeButton addTarget:self action:@selector(deadlineBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:_privilegeDeadlinelimitTimeButton];
                
                NSString *start = [discountTimeDict objectForKey:@"start"];
                NSString *end = [discountTimeDict objectForKey:@"end"];
                
                if (start.length == 0 && end.length == 0)
                {
                    _privilegeDeadlineAllTimeButton.selected = YES;
                    _privilegeDeadlinelimitTimeButton.selected = NO;
                }
                else
                {
                    _privilegeDeadlineAllTimeButton.selected = NO;
                    _privilegeDeadlinelimitTimeButton.selected = YES;
                }
                
                //开始时间
                UITextField *textfield1 = [[UITextField alloc] initWithFrame:CGRectMake(originX + CGRectGetMaxX(_privilegeDeadlinelimitTimeButton.frame) + spaceX, originY + bgImageView.frame.size.height + label1.frame.size.height + spaceY + _privilegeDeadlineAllTimeButton.frame.size.height + spaceY + 5, 190, 40)];
                textfield1.tag = kDiscountStartTimeTextFieldTag;
                textfield1.delegate = self;
                textfield1.borderStyle = UITextBorderStyleNone;
                textfield1.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
                textfield1.textColor = [UIColor blackColor];
                textfield1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                textfield1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                textfield1.textAlignment = UITextAlignmentCenter;
                textfield1.font = [UIFont systemFontOfSize:18];
                textfield1.clearButtonMode = UITextFieldViewModeAlways;

                if (0 != [discountTimeDict count])
                {
                    textfield1.text = [discountTimeDict objectForKey:@"start"];
                }
                [cell.contentView addSubview:textfield1];
                
                //“至”
                UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(originX + CGRectGetMaxX(textfield1.frame) + spaceX, originY + bgImageView.frame.size.height + label1.frame.size.height + spaceY + _privilegeDeadlineAllTimeButton.frame.size.height + spaceY + 10, 30, 30)];
                label5.backgroundColor = [UIColor clearColor];
                label5.textColor = [UIColor blackColor];
                label5.text = kLoc(@"to");
                [cell.contentView addSubview:label5];
                
                //结束时间
                UITextField *textfield2 = [[UITextField alloc] initWithFrame:CGRectMake(originX + CGRectGetMaxX(label5.frame) + spaceX, originY + bgImageView.frame.size.height + label1.frame.size.height + spaceY + _privilegeDeadlineAllTimeButton.frame.size.height + spaceY + 5, 190, 40)];
                textfield2.tag = kDiscountEndTimeTextFieldTag;
                textfield2.delegate = self;
                textfield2.borderStyle = UITextBorderStyleNone;
                textfield2.background = [UIImage imageFromMainBundleFile:@"rule_timeFieldBg.png"];
                textfield2.textColor = [UIColor blackColor];
                textfield2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                textfield2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                textfield2.textAlignment = UITextAlignmentCenter;
                textfield2.font = [UIFont systemFontOfSize:18];
                textfield2.clearButtonMode = UITextFieldViewModeAlways;

                if (0 != [discountTimeDict count])
                {
                    textfield2.text = [discountTimeDict objectForKey:@"end"];
                }
                [cell.contentView addSubview:textfield2];
            }
        }
        //添加图片
        if (0 == row && 5 == section)
        {
            UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-2, 0, 816, 60)];
            bgImageView.image = [UIImage imageFromMainBundleFile:@"rule_cellHeadBg.png"];
            [cell.contentView addSubview:bgImageView];
            
            //可以上传的图片数
            NSInteger num = kPictureMaxNum - [photoViewArray count];
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:(int)num] forKey:kTakeOutPicNum];
            NSString *addTitle = [NSString stringWithFormat:@"( %@%d%@ )",kLoc(@"can_add"),kPictureMaxNum - [photoViewArray count],kLoc(@"piece")];
            if (0 == num)
            {
                addTitle = @"";
            }
            
            DetailTextView *label = [[DetailTextView alloc]initWithFrame:CGRectMake(10, 15 , 500, 40)];
            UIColor *labelColor = [UIColor colorWithRed:104.0/255.0 green:145.0/255.0 blue:49.0/255.0 alpha:1.0];
            [label setText:[NSString stringWithFormat:@"%@ ：%@",kLoc(@"add_pictures"),addTitle] WithFont:[UIFont boldSystemFontOfSize:20] AndColor:labelColor];
            [label setKeyWordTextArray:[NSArray arrayWithObjects:addTitle, nil] WithFont:[UIFont systemFontOfSize:16] AndColor:labelColor];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = UITextAlignmentLeft;
          
            [cell.contentView addSubview:label];
            
            //添加图片按钮
            UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [addBtn setFrame:CGRectMake(745, 5, 47, 47)];
            [addBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"rule_addButton.png"] forState:UIControlStateNormal];
            [addBtn addTarget:self action:@selector(addPhotoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:addBtn];
            
            for (int i = 0; i < [smallPhotoViewArray count]; i++)
            {
                UIImageView *imageView = [smallPhotoViewArray objectAtIndex:i];
                imageView.frame = CGRectMake(20 + i * 155, 80, 125, 125);
                imageView.tag = i;
                imageView.userInteractionEnabled = YES;
                [cell.contentView addSubview:imageView];
                
                //点击图片放大
                UIButton *pictureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                pictureBtn.frame = CGRectMake(20 + i * 155, 80, 125, 125);
                pictureBtn.tag = i;
                [pictureBtn addTarget:self action:(@selector(pictureImageViewClicked:)) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:pictureBtn];
                
                //删除图片按钮
                UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                deleteBtn.tag = i;
                [deleteBtn setFrame:CGRectMake(120 + i * 155, 65, 47, 47)];
                [deleteBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"order_pictureDelete.png"] forState:UIControlStateNormal];
                [deleteBtn addTarget:self action:@selector(deletePictureBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:deleteBtn];
            }
        }
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if ([[ruleSettingDict objectForKey:@"isOpen"] boolValue])
    {
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
                NSArray *NoticeArray = [ruleSettingDict objectForKey:@"instruction"];
                //横条 + 须知设置
                rows = 1 + [NoticeArray count];
                
                break;
            }
            case 4:
            {
                rows = 1;
                
                break;
            }
            case 5:
            {
                rows = 1;
                
                break;
            }
            default:
                break;
        }
    }
	return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 0;
    float headPicHeight = 60;
    
    switch (indexPath.section)
    {
        case 0:
        {
            if (0 == self.deliveryType)
            {
                height = 70 * 3 + 40;
            }
            else
            {
                height = 70 + 40;
            }
            
            break;
        }
        case 1:
        {
            if (0 == self.deliveryType)
            {
                NSMutableArray *feeArray = nil;
                if (ruleSettingDict && [ruleSettingDict objectForKey:@"carryfee"] != nil)
                {
                    feeArray = [[ruleSettingDict objectForKey:@"carryfee"] objectForKey:@"closedInterval"];
                }
                height = headPicHeight +80 * (feeArray.count + 3);
            }
            else
            {
                height = 0;
            }
            
            break;
        }
        case 2:
        {
            NSMutableArray *businessTimeArray = [[NSMutableArray alloc]initWithArray:[ruleSettingDict objectForKey:@"takeoutTime"]];
            height = headPicHeight + 80 * [businessTimeArray count];
            break;
        }
        case 3:
        {
            height = 75;
            break;
        }
        case 4:
        {
            NSInteger discountSwitch = [[ruleSettingDict objectForKey:@"discountSwitch"]integerValue];
            height = 240;
            if (0 == discountSwitch)
            {
                height = 60;
            }
            break;
        }
        case 5:
        {
            height = 230;
            break;
        }
    }
	return height;
}


#pragma mark UITextFieldDelegate

- (void)showNumPicker:(UITextField *)textField
{
    UITableViewCell *showView = nil;
    NSString *sumStr = nil;
    int cellSection = 0;
    int cellRow = 0;
    NSInteger tag = textField.tag;
    switch (tag)
    {
            // 系统配送费
        case kCarryfeeLowerTextFieldTag:
        case kCarryfeeCashLowerTextFieldTag:
        case kCarryfeeCashUpperTextFieldTag:
        case kCarryfeeCashDefaultTextFieldTag:
        case kCarryfeeUpperTextFieldTag:
        {
            cellSection = kFeeCellSection;
            cellRow = kTableViewFirstRow;
            UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cellRow inSection:cellSection]];
            NSArray *array = [cell.contentView subviews];
            for (int i = 0; i < array.count; i++)
            {
                UIView *view = array[i];
                if (view.tag == tag)
                {
                    UITextField *textfield = (UITextField *)view;
                    sumStr = textfield.text;
                }
            }
            
            break;
        }
        case kNeedDateTextFieldTag:
        {
            sumStr = [NSString stringWithFormat:@"%@", [ruleSettingDict objectForKey:@"carryDays"]];
            cellSection = kDeliveryfeeCellSection;
            cellRow = kTableViewFirstRow;
            
            break;
        }
        case kDeliveryfeeTextFieldTag:
        {
            sumStr = [NSString stringWithFormat:@"%@", [ruleSettingDict objectForKey:@"minConsumption"]];
            cellSection = kDeliveryfeeCellSection;
            cellRow = kTableViewFirstRow;
            
            break;
        }
        case kCarryfeeTextFieldTag:
        {
            sumStr = [NSString stringWithFormat:@"%@",[ruleSettingDict objectForKey:@"carryfee"]];
            cellSection = kDeliveryfeeCellSection;
            cellRow = kTableViewFirstRow;
            
            break;
        }
        case kCarryRangeTextFieldTag:
        {
            sumStr = [NSString stringWithFormat:@"%@",[ruleSettingDict objectForKey:@"carryRange"]];
            cellSection = kDeliveryfeeCellSection;
            cellRow = kTableViewFirstRow;
            
            break;
        }
        case kDiscountTextFieldTag:
        {
            sumStr = [NSString stringWithFormat:@"%@",[ruleSettingDict objectForKey:@"discount"]];
            cellSection = kDiscountCellSection;
            cellRow = kTableViewFirstRow;
            
            break;
        }
        default:
            // 自定义配送费
            if (tag >= 10000)
            {
                cellSection = kFeeCellSection;
                cellRow = kTableViewFirstRow;
                UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cellRow inSection:cellSection]];
                NSArray *array = [cell.contentView subviews];
                for (int i = 0; i < array.count; i++)
                {
                    UIView *view = array[i];
                    if (view.tag == tag)
                    {
                        UITextField *textfield = (UITextField *)view;
                        sumStr = textfield.text;
                    }
                }
            }
            else
            {
                return;
            }
            break;
    }
    
    
   
    NumPicker *picker = [[NumPicker alloc] init];
    picker.delegate = self;
    picker.tag = tag;
    picker.pickerType = NumPickerTypeWithDishPrice;
    if (tag == kNeedDateTextFieldTag)
    {
        picker.pickerType = NumPickerTypeNormal;
    }
    picker.numberText = sumStr;
    
    if (nil == popoverController) {
        if (kIsiPhone) {
            popoverController = [[WEPopoverController alloc] initWithContentViewController:picker];
        } else {
            popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
        }
    }
    
    if (!kIsiPhone) {
        if (kSystemVersionOfCurrentDevice >= 7.0) {
            // 更改iOS7默认样式
            [(UIPopoverController *)popoverController setPopoverBackgroundViewClass:[PSPopoverBckgroundView class]];
        } else {
            [(UIPopoverController *)popoverController setPopoverBackgroundViewClass:nil];
        }
    }
    
    [popoverController setContentViewController:picker];
    [popoverController setPopoverContentSize:picker.pickerSize];
    showView = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cellRow inSection:cellSection]];
    
    if (kIsiPhone) {
        MainViewController *mainCtrl = [MainViewController getMianViewShareInstance];
        CGRect showRect = [showView convertRect:textField.frame toView:mainCtrl.view];
        [popoverController setParentView:mainCtrl.view];
        [popoverController presentPopoverFromRect:showRect
                                           inView:mainCtrl.view
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    } else {
        [popoverController presentPopoverFromRect:textField.frame
                                           inView:showView
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    }
}

- (void)showDatePicker:(UITextField *)textField
{
    /*键盘在时，只收起键盘，不弹出UIActionSheet*/
    if (selectCell)
    {
        [self hideKeyboard];
        return;
    }
    
    UITableViewCell *showView = nil;
    NSString *timeStr = nil;
    NSDictionary *discountTimeDict = [ruleSettingDict objectForKey:@"discountTime"];
    int cellSection = 0;
    int cellRow = 0;
    int pickerTag = -1;
    NSInteger tag = textField.tag;
    switch (tag)
    {
        case kDiscountStartTimeTextFieldTag:
        {
            if (0 != [discountTimeDict count])
            {
                timeStr = [discountTimeDict objectForKey:@"start"];
            }
            cellSection = kDiscountCellSection;
            cellRow = kTableViewFirstRow;
            pickerTag = kDiscountStartTimeDatePickerTag;
            
            break;
        }
        case kDiscountEndTimeTextFieldTag:
        {
            if (0 != [discountTimeDict count])
            {
                timeStr = [discountTimeDict objectForKey:@"end"];
            }
            cellSection = kDiscountCellSection;
            cellRow = kTableViewFirstRow;
            pickerTag = kDiscountEndTimeDatePickerTag;
            
            break;
        }
 
        default:
            return;
    }
    
    NSString *title = @"";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                  delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
    actionSheet.tag = tag;
    
    UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 0.0, 270.0, 216.0)];
    if (kIsiPhone) {
        picker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
    }
    picker.backgroundColor = [UIColor clearColor];
    picker.tag = pickerTag;
    picker.datePickerMode = UIDatePickerModeDateAndTime;
    picker.date = (0 == [timeStr length])?[NSDate date]:[timeStr stringToNSDateWithFormat:@"yyyy-MM-dd HH:mm"];
    [actionSheet addSubview:picker];
    
    showView = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cellRow inSection:cellSection]];
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:textField.frame inView:showView animated:YES];
    }
}

#pragma mark -- UITextFieldDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    
    _isTextFieldClearButtonClick = YES;
    isEdited = YES;
    
    if (textField.tag >= 1000 && textField.tag < 2000)
    {
        NSMutableArray *generalTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"takeoutTime"]];
        NSInteger index = textField.tag - 1000;
        //修改该值
        NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[generalTimeSet objectAtIndex:index]];
        [newCell setObject:@"" forKey:@"startTime"];
        [generalTimeSet replaceObjectAtIndex:index withObject:newCell];
        [ruleSettingDict setObject:generalTimeSet forKey:@"takeoutTime"];

    }
    else if(textField.tag >= 2000 && textField.tag < 3000)
    {
        NSMutableArray *generalTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"takeoutTime"]];
        NSInteger index = textField.tag - 2000;
        //修改该值
        NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[generalTimeSet objectAtIndex:index]];
        [newCell setObject:@"" forKey:@"endTime"];
        [generalTimeSet replaceObjectAtIndex:index withObject:newCell];
        [ruleSettingDict setObject:generalTimeSet forKey:@"takeoutTime"];

    }
    else if(kDiscountStartTimeTextFieldTag == textField.tag)
    {
        NSMutableDictionary *discountTimeDict = [[NSMutableDictionary alloc] initWithDictionary:[ruleSettingDict objectForKey:@"discountTime"]];
        [discountTimeDict setObject:@"" forKey:@"start"];
        [ruleSettingDict setObject:discountTimeDict forKey:@"discountTime"];
    }
    else if(kDiscountEndTimeTextFieldTag == textField.tag)
    {
        NSMutableDictionary *discountTimeDict = [[NSMutableDictionary alloc] initWithDictionary:[ruleSettingDict objectForKey:@"discountTime"]];
        [discountTimeDict setObject:@"" forKey:@"end"];
        [ruleSettingDict setObject:discountTimeDict forKey:@"discountTime"];
    }
    
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    int tag = (int)textField.tag;
    switch (tag)
    {
        case kNeedDateTextFieldTag:
        {
            [self showNumPicker:textField];
            break;
        }
        case kDeliveryfeeTextFieldTag:
        {
            [self showNumPicker:textField];
            break;
        }
        case kCarryfeeTextFieldTag:
        {
            [self showNumPicker:textField];
            break;
        }
        case kCarryRangeTextFieldTag:
        {
            [self showNumPicker:textField];
            break;
        }
        case kDiscountTextFieldTag:
        {
            /*键盘在时，只收起键盘，不弹出UIActionSheet*/
            if (selectCell)
            {
                [self hideKeyboard];
                return NO;
            }
            [self showNumPicker:textField];
            break;
        }
        case kDiscountStartTimeTextFieldTag:
        {
            if (_isTextFieldClearButtonClick)
            {
                _isTextFieldClearButtonClick = NO;
                return NO;
            }
            [self showDatePicker:textField];
            
            break;
        }
        case kDiscountEndTimeTextFieldTag:
        {
            if (_isTextFieldClearButtonClick)
            {
                _isTextFieldClearButtonClick = NO;
                return NO;
            }
            [self showDatePicker:textField];
            
            break;
        }
        
            // 系统配餐费
        case kCarryfeeLowerTextFieldTag:
        case kCarryfeeCashLowerTextFieldTag:
        case kCarryfeeCashUpperTextFieldTag:
        case kCarryfeeCashDefaultTextFieldTag:
        case kCarryfeeUpperTextFieldTag:
        {
            [self showNumPicker:textField];
            break;
        }
        default:
            break;
    }
    
    // 自定义配餐费
    if (tag >= 10000 )
    {
        [self showNumPicker:textField];
        return NO;
    }
      
    if (tag >= 1000 && tag < 2000)
    {
        if (_isTextFieldClearButtonClick)
        {
            _isTextFieldClearButtonClick = NO;
            return NO;
        }
        NSString *title = @"";
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                      delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
        actionSheet.tag = tag;
        
        
        int index = tag - 1000;
        NSString *startTimeStr = [[[ruleSettingDict objectForKey:@"takeoutTime"] objectAtIndex:index] objectForKey:@"startTime"];
        if (0 == [startTimeStr length])
        {
            startTimeStr = [NSString dateToNSString:[NSDate date] withFormat:@"HH:mm"];
        }
       
        //时间选择器
        CustomTimePicker *timePicker = [[CustomTimePicker alloc]initWithLastTimeString:startTimeStr];
        if (kIsiPhone) {
            timePicker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
        } else {
            timePicker.frame = CGRectMake(-25.0, 0.0, 320.0, 216.0);
        }
        timePicker.backgroundColor = [UIColor clearColor];
        selectdTimePicker = timePicker;
        [actionSheet addSubview:timePicker];
        
        UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kBusinessTimeCellSection]];
        if (kIsiPhone) {
            [actionSheet showInView:self.view.window];
        } else {
            [actionSheet showFromRect:textField.frame inView:cell.contentView animated:YES];
        }
    }
    else if (tag >= 2000 && tag < 3000)
    {
        if (_isTextFieldClearButtonClick)
        {
            _isTextFieldClearButtonClick = NO;
            return NO;
        }
        NSString *title = @"";
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n\n\n\n", title]
                                      delegate:self cancelButtonTitle:nil destructiveButtonTitle:kLoc(@"confirm") otherButtonTitles:nil];
        actionSheet.tag = tag;
        
        
        int index = tag - 2000;
        NSString *endTimeStr = [[[ruleSettingDict objectForKey:@"takeoutTime"] objectAtIndex:index] objectForKey:@"endTime"];
        if (0 == [endTimeStr length])
        {
            endTimeStr = [NSString dateToNSString:[NSDate date] withFormat:@"HH:mm"];
        }
        
        //时间选择器
        CustomTimePicker *timePicker = [[CustomTimePicker alloc]initWithLastTimeString:endTimeStr];
        if (kIsiPhone) {
            timePicker.frame = CGRectMake(10.0, 0.0, 460.0, 216.0);
        } else {
            timePicker.frame = CGRectMake(-25.0, 0.0, 320.0, 216.0);
        }
        timePicker.backgroundColor = [UIColor clearColor];
        selectdTimePicker = timePicker;
        [actionSheet addSubview:timePicker];
        
        UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kBusinessTimeCellSection]];
        if (kIsiPhone) {
            [actionSheet showInView:self.view.window];
        } else {
            [actionSheet showFromRect:textField.frame inView:cell.contentView animated:YES];
        }
    }
    return NO;
}

#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    isEdited = YES;
 
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    tableViewContentOffset = ruleSettingTableview.contentOffset;
    UITableViewCell *cell = [ruleSettingTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kBusinessTimeCellSection]];
    [ruleSettingTableview setContentOffset:CGPointMake(0, cell.frame.origin.y) animated:YES];
    ruleSettingTableview.scrollEnabled = NO;
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [ruleSettingTableview setContentOffset:tableViewContentOffset];
    ruleSettingTableview.scrollEnabled = YES;
    
    return YES;
}

#pragma mark UIActionSheetDelegate

- (void)updateDiscountTime:(UIActionSheet *)actionSheet
{
    NSMutableDictionary *discountTimeDict = [[NSMutableDictionary alloc] initWithDictionary:[ruleSettingDict objectForKey:@"discountTime"]];
    int pickerTag = actionSheet.tag;
    switch (pickerTag)
    {
        case kDiscountStartTimeTextFieldTag:
        {
            UIDatePicker *selectedDatePicker = (UIDatePicker *)[actionSheet viewWithTag:kDiscountStartTimeDatePickerTag];
            NSString *startDate = [NSString dateToNSString:selectedDatePicker.date withFormat:@"yyyy-MM-dd HH:mm"];
            NSString *endDate = [discountTimeDict objectForKey:@"end"];
            NSComparisonResult result = [startDate compare:endDate];
            if (result >= NSOrderedSame && ![NSString strIsEmpty:endDate])
            {
                [PSAlertView showWithMessage:kLoc(@"illegal_input")];
                
                return;
            }
            [discountTimeDict setObject:startDate forKey:@"start"];
            
            break;
        }
        case kDiscountEndTimeTextFieldTag:
        {
            UIDatePicker *selectedDatePicker = (UIDatePicker *)[actionSheet viewWithTag:kDiscountEndTimeDatePickerTag];
            NSString *endDate = [NSString dateToNSString:selectedDatePicker.date withFormat:@"yyyy-MM-dd HH:mm"];
            NSString *startDate = [discountTimeDict objectForKey:@"start"];
            NSComparisonResult result = [startDate compare:endDate];
            if (result >= NSOrderedSame && ![NSString strIsEmpty:startDate])
            {
                [PSAlertView showWithMessage:kLoc(@"illegal_input")];
                
                return;
            }
            [discountTimeDict setObject:endDate forKey:@"end"];
            break;
        }
        default:
            return;
    }
    [ruleSettingDict setObject:discountTimeDict forKey:@"discountTime"];
    
    isEdited = YES;
    //更新
    
    [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kDiscountCellSection]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger tag = actionSheet.tag;
    switch (tag)
    {
        case kDiscountStartTimeTextFieldTag:
        {
            if (0 == buttonIndex)
            {
                [self updateDiscountTime:actionSheet];
            }
            
            break;
        }
        case kDiscountEndTimeTextFieldTag:
        {
            if (0 == buttonIndex)
            {
                [self updateDiscountTime:actionSheet];
            }
            
            break;
        }
        case kAddPhotoUIActionSheetTag:
        {
            switch (buttonIndex)
            {
                case 0:
                {
                    [self takePhoto];
                    
                    break;
                }
                case 1:
                {
                    [self loadPhotoFromAlbum];
                    
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        default:
            break;
    }
    
    //设置的开始时间
    if (tag>=1000 && tag<2000)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                NSInteger index = actionSheet.tag-1000;
                //修改该值
                NSMutableArray *generalTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"takeoutTime"]];
                NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[generalTimeSet objectAtIndex:index]];
                [newCell setObject:selectdTimePicker.selectedTimeStr forKey:@"startTime"];
                NSString *endTime = [newCell objectForKey:@"endTime"];
                NSComparisonResult result = [selectdTimePicker.selectedTimeStr compare:endTime];
                if (result >= NSOrderedSame && ![NSString strIsEmpty:endTime])
                {
                    [PSAlertView showWithMessage:kLoc(@"illegal_input")];
                    
                    return;
                }
                [generalTimeSet replaceObjectAtIndex:index withObject:newCell];
                [ruleSettingDict setObject:generalTimeSet forKey:@"takeoutTime"];
                
                //更新Textfield
                [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kBusinessTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
                
                isEdited = YES;
                break;
            }
        }
    }
    
    //设置结束时间
    if (tag>=2000 && tag<3000) {
        switch (buttonIndex) {
            case 0:{
                NSInteger index = actionSheet.tag-2000;
                //修改该值
                NSMutableArray *generalTimeSet = [[NSMutableArray alloc] initWithArray:[ruleSettingDict objectForKey:@"takeoutTime"]];
                NSMutableDictionary *newCell = [[NSMutableDictionary alloc] initWithDictionary:[generalTimeSet objectAtIndex:index]];
                NSString *startTime = [newCell objectForKey:@"startTime"];
                NSComparisonResult result = [startTime compare:selectdTimePicker.selectedTimeStr];
                if (result >= NSOrderedSame && ![NSString strIsEmpty:startTime])
                {
                    [PSAlertView showWithMessage:kLoc(@"illegal_input")];
                    
                    return;
                }
                [newCell setObject:selectdTimePicker.selectedTimeStr forKey:@"endTime"];
                [generalTimeSet replaceObjectAtIndex:index withObject:newCell];
                [ruleSettingDict setObject:generalTimeSet forKey:@"takeoutTime"];
                
                //更新Textfield
                [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kBusinessTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
                
                isEdited = YES;
                break;
            }
        }
    }
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int tag = alertView.tag;
    //提示用户是否退出
    if (tag==0) {
        if (buttonIndex==1) {
            [self.view removeFromSuperview];
            
            [self dismissView];
            return;
        }
    }
}

#pragma mark JsonPickerDelegate

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    int responseStatus = [[dict objectForKey:@"status"] intValue];
    NSDictionary *dataDict = [dict objectForKey:@"data"];
    
    if (!dataDict)
    {
        return;
    }
    
    //获取规则设置信息
    if (picker.tag==0)
    {
        
        switch (responseStatus)
        {
            case 200:
            {
                //刷新数据
                ruleSettingDict = [[NSMutableDictionary alloc] initWithDictionary:dataDict];
                //暂停外卖的数据
                self.settingBtnDict = [ruleSettingDict objectForKey:@"settingButtons"];
                //确保discountTime是字典
                if ([[ruleSettingDict objectForKey:@"discountTime"] isKindOfClass:[NSArray class]])
                {
                     NSMutableDictionary *discountTimeDict = [[NSMutableDictionary alloc] initWithCapacity:3];
                    [ruleSettingDict setObject:discountTimeDict forKey:@"discountTime"];
                }
                //营业时间
                NSArray *businessTimeArray = [ruleSettingDict objectForKey:@"takeoutTime"];
                if ([businessTimeArray count] == 0)
                {
                    //增加默认项：
                    NSMutableDictionary *newCell = [[NSMutableDictionary alloc] init];
                    NSMutableArray *businessTimeArray = [[NSMutableArray alloc]initWithCapacity:3];
                    
                    [newCell setObject:@"" forKey:@"startTime"];
                    [newCell setObject:@"" forKey:@"endTime"];
                    
                    [businessTimeArray insertObject:newCell atIndex:0];
                    [ruleSettingDict setObject:businessTimeArray forKey:@"takeoutTime"];
                }
                
                //下载网络图片
                if (nil == photoViewArray)
                {
                    photoViewArray = [[NSMutableArray alloc]initWithCapacity:3];
                }
                [photoViewArray removeAllObjects];
                
                smallPhotoViewArray = [[NSMutableArray alloc] init];
                
                for (int i = 0; i < [[ruleSettingDict objectForKey:@"picture"] count]; i ++)
                {
                    UIImageView *imageview = [[UIImageView alloc]init];
                    [imageview setContentMode:UIViewContentModeScaleAspectFit];
                    imageview.backgroundColor = [UIColor blackColor];
                    imageview.userInteractionEnabled = YES;
                    imageview.layer.borderColor = [[UIColor colorWithRed:226.0/255.0 green:226.0/255.0 blue:226.0/255.0 alpha:1.0]CGColor];
                    imageview.layer.borderWidth = 2;
                    NSString *path = [[NSBundle mainBundle]pathForResource:@"dt_defaultMenuTypeCellPhoto" ofType:@"png"];
                    imageview.image = [UIImage imageWithContentsOfFile:path];
                    [photoViewArray addObject:imageview];
                    
                    //缩略图
                    UIImage * smallimage = [UIImage thumbnailWithImageWithoutScale:imageview.image size:CGSizeMake(300, 300)];
                    UIImageView *smallImageView = [[UIImageView alloc] initWithImage:smallimage];
                    smallImageView.image = smallimage;
                    [smallPhotoViewArray addObject: smallImageView];
                    
                    //加载提示
                    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                    activityView.tag = kPictureIndicatorViewTag + i;
                    activityView.frame = CGRectMake(50, 40, activityView.frame.size.width, activityView.frame.size.height);
                    [imageview addSubview:activityView];
                    [activityView startAnimating];
                }
                
                
                if (0 !=[[ruleSettingDict objectForKey:@"picture"] count])
                {
                    [NSThread detachNewThreadSelector:@selector(imageLoadForIndex:) toTarget:self withObject:nil];
                }
                
                //刷新tableview
                isEdited = NO;
                [ruleSettingTableview setContentOffset:CGPointZero];
                [ruleSettingTableview reloadData];
                [self updateViewAfterGetData];
                
                break;
            }
            case 201:
            {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                self.settingBtnDict = [dataDict objectForKey:@"settingButtons"];
                [self performSelector:@selector(dismissView) withObject:nil afterDelay:0];
                
                break;
            }
            default:
            {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                
                break;
            }
        }
    }
    
    //保存规则设置信息
    if (picker.tag==1)
    {
        switch (responseStatus)
        {
                //保存成功
            case 200:
            {
                //刷新数据
//                ruleSettingDict = [[NSMutableDictionary alloc] initWithDictionary:[dict objectForKey:@"data"]];
//                self.settingBtnDict = [ruleSettingDict objectForKey:@"settingButtons"];
//                [ruleSettingTableview setContentOffset:CGPointZero];
//                [ruleSettingTableview reloadData];
                
                [self dismissView];
                
                //
//                isEdited = NO;
                break;
            }
            case 201:
            {
                [self dismissView];
                break;
            }
            default:
            {
//                sleep(1);
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
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


#pragma mark NumPickerDelegate

-(void)NumPicker:(NumPicker*)picker didPickedNumber:(NSString*)number
{
    [popoverController dismissPopoverAnimated:YES];
    isEdited = YES;
    NSString *keyStr = nil;
    int cellSection = 0;
    int cellRow = 0;
    NSInteger tag = picker.tag;
    switch (tag)
    {
        case kNeedDateTextFieldTag:
        {
            keyStr = @"carryDays";
            cellSection = kDeliveryfeeCellSection;
            cellRow = kTableViewFirstRow;
            
            break;
        }
        case kDeliveryfeeTextFieldTag:
        {
            keyStr = @"minConsumption";
            cellSection = kDeliveryfeeCellSection;
            cellRow = kTableViewFirstRow;
            
            break;
        }
        case kCarryfeeTextFieldTag:
        {
            keyStr = @"carryfee";
            cellSection = kDeliveryfeeCellSection;
            cellRow = kTableViewFirstRow;
            
            break;
        }
        case kCarryRangeTextFieldTag:
        {
            keyStr = @"carryRange";
            cellSection = kDeliveryfeeCellSection;
            cellRow = kTableViewFirstRow;
            
            break;
        }
        case kDiscountTextFieldTag:
        {
            keyStr = @"discount";
            cellSection = kDiscountCellSection;
            cellRow = kTableViewFirstRow;
            
            break;
        }
            // 系统配送费
        case kCarryfeeLowerTextFieldTag:
        case kCarryfeeCashLowerTextFieldTag:
        case kCarryfeeCashUpperTextFieldTag:
        case kCarryfeeCashDefaultTextFieldTag:
        case kCarryfeeUpperTextFieldTag:
        {
            cellSection = kFeeCellSection;
            cellRow = kTableViewFirstRow;

            if (ruleSettingDict)
            {
                NSDictionary *carryfeeDict = [ruleSettingDict objectForKey:@"carryfee"] ;
                if (carryfeeDict)
                {
                    NSMutableDictionary *openIntervalDict = [carryfeeDict objectForKey:@"openInterval"];
//                    [openIntervalDict removeAllObjects];
                    if (openIntervalDict)
                    {
                            if (tag == kCarryfeeLowerTextFieldTag)
                            {
                                NSMutableDictionary *lowerDict = [openIntervalDict objectForKey:@"lower"];
                                if (!lowerDict)
                                {
                                    lowerDict = [NSMutableDictionary dictionaryWithObject:number forKey:@"cost"];
                                    [lowerDict setValue:@"" forKey:@"carryfee"];
                                    [lowerDict setValue:[NSNumber numberWithInt:0] forKey:@"equal"];
                                }
                                else
                                {
                                    [lowerDict setValue:number forKey:@"cost"];
                                }
                                [openIntervalDict setValue:lowerDict forKey:@"lower"];
                            }
                            else if (tag == kCarryfeeCashLowerTextFieldTag)
                            {
                                NSMutableDictionary *lowerDict = [openIntervalDict objectForKey:@"lower"];
                                
                                if (!lowerDict)
                                {
                                    lowerDict = [NSMutableDictionary dictionaryWithObject:number forKey:@"carryfee"];
                                    [lowerDict setValue:@"" forKey:@"cost"];
                                    [lowerDict setValue:[NSNumber numberWithInt:0] forKey:@"equal"];
                                }
                                else
                                {
                                    [lowerDict setValue:number forKey:@"carryfee"];
                                }
                                [openIntervalDict setValue:lowerDict forKey:@"lower"];
                            }
                            else if (tag == kCarryfeeUpperTextFieldTag)
                            {
                                NSMutableDictionary *upperDict = [openIntervalDict objectForKey:@"upper"];
                                
                                if (!upperDict)
                                {
                                    upperDict = [NSMutableDictionary dictionaryWithObject:number forKey:@"cost"];
                                    [upperDict setValue:@"" forKey:@"carryfee"];
                                    [upperDict setValue:[NSNumber numberWithInt:0] forKey:@"equal"];
                                }
                                else
                                {
                                    [upperDict setValue:number forKey:@"cost"];
                                }
                                [openIntervalDict setValue:upperDict forKey:@"upper"];
                            }
                            else if (tag == kCarryfeeCashUpperTextFieldTag)
                            {
                                NSMutableDictionary *upperDict = [openIntervalDict objectForKey:@"upper"];
                                
                                if (!upperDict)
                                {
                                    upperDict = [NSMutableDictionary dictionaryWithObject:number forKey:@"cost"];
                                    [upperDict setValue:@"" forKey:@"carryfee"];
                                    [upperDict setValue:[NSNumber numberWithInt:0] forKey:@"equal"];
                                }
                                else
                                {
                                    [upperDict setValue:number forKey:@"carryfee"];
                                }
                                [openIntervalDict setValue:upperDict forKey:@"upper"];
                            }
                    }
                    
                    [carryfeeDict setValue:openIntervalDict forKey:@"openInterval"];
                    if (tag == kCarryfeeCashDefaultTextFieldTag)
                    {
                        [carryfeeDict setValue:number forKey:@"defaultCarryfee"];
                    }
                    
                }
                [ruleSettingDict setValue:carryfeeDict forKey:@"carryfee"];
                [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:cellRow inSection:cellSection]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }

            return;
        }
        default:
        {
            // 自定义配送费
            if (tag >= 10000)
            {
                cellSection = kFeeCellSection;
                cellRow = kTableViewFirstRow;
                NSInteger index = tag%100;
                
                if (ruleSettingDict)
                {
                    NSDictionary *carryfeeDict = [ruleSettingDict objectForKey:@"carryfee"] ;
                    NSMutableArray *closedIntervalArray = [carryfeeDict objectForKey:@"closedInterval"];
                    if (closedIntervalArray && closedIntervalArray.count > index )
                    {
                        NSDictionary *dict = closedIntervalArray[index];
                        if (dict)
                        {
                            if (tag == kCarryfeeUserLowerTextFieldTag + index)
                                [dict setValue:number forKey:@"lowerCost"];
                            if (tag == kCarryfeeUserUpperTextFieldTag + index)
                                [dict setValue:number forKey:@"upperCost"];
                            if (tag == kCarryfeeUserCashTextFieldTag + index)
                                [dict setValue:number forKey:@"carryfee"];
                        }
                        [closedIntervalArray replaceObjectAtIndex:index withObject:dict];
                        [carryfeeDict setValue:closedIntervalArray forKey:@"closedInterval"];
                    }
                    [ruleSettingDict setValue:carryfeeDict forKey:@"carryfee"];
                    [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:cellRow inSection:cellSection]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
            return;
        }
            
    }
    
    if (keyStr)
    {
        float num = [number doubleValue];
        [ruleSettingDict setObject:[NSNumber numberWithFloat:num] forKey:keyStr];
        [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:cellRow inSection:cellSection]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


#pragma mark WeekdayPickerDelegate
-(void)WeekdayPicker:(WeekdayPicker*)picker didPickedWeekdays:(NSArray*)weekdays
{
    //是否要添加到数组的标记
//    BOOL shouldAdd = YES;
//    if ([WeekdayBtnArray count] == 0)
//    {
//        [WeekdayBtnArray addObject:[NSNumber numberWithInt:(int)picker.tag]];
//    }
//    else
//    {
//        for (int i = 0; i < [WeekdayBtnArray count]; i++)
//        {
//            if ([[WeekdayBtnArray objectAtIndex:i]integerValue] == picker.tag)
//            {
//                shouldAdd = NO;
//                break;
//            }
//        }
//        if (shouldAdd == YES)
//        {
//            [WeekdayBtnArray addObject:[NSNumber numberWithInt:(int)picker.tag]];
//        }
//    }
    
    
    isEdited = YES;
    [popoverController dismissPopoverAnimated:YES];
    
    int tag = (int)picker.tag;
    
    //设置外卖时间的“开放星期”
    if (tag>=1000 && tag<1100)
    {
        int index = tag - 1000;
        
//        if (_weekdayBtnArray)
//        {
//            NSMutableString *text = [[NSMutableString alloc] init];
//            
//            for (int i = 0; i < weekdays.count; i++)
//            {
//                if (i != weekdays.count)
//                {
//                    [text appendString:[NSString stringWithFormat:@"%@，",weekdays[i]]];
//                }
//                else
//                {
//                    [text appendString:weekdays[i]];
//                }
//                
//            }
//            
//            UIButton *weekBtn = _weekdayBtnArray[index];
//            [weekBtn setTitle:text forState:UIControlStateNormal];
//            [weekBtn setTitle:text forState:UIControlStateHighlighted];
//            [weekBtn setTitle:text forState:UIControlStateSelected];
//        }
        
        NSMutableArray *businessTimeArray = [[NSMutableArray alloc]initWithArray:[ruleSettingDict objectForKey:@"takeoutTime"]];

        if (businessTimeArray)
        {
            NSMutableDictionary *general = [businessTimeArray objectAtIndex:index];
            
            if (general)
            {
                [general setObject:weekdays forKey:@"week"];
                [businessTimeArray replaceObjectAtIndex:index withObject:general];
                [ruleSettingDict setObject:businessTimeArray forKey:@"takeoutTime"];
                
                [ruleSettingTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kTableViewFirstRow inSection:kTakeOutTimeCellSection]] withRowAnimation:UITableViewRowAnimationFade];
            }
        }

    }
}


-(void)WeekdayPicker:(WeekdayPicker*)picker didPressedCancelButton:(BOOL)flag
{
    [popoverController dismissPopoverAnimated:YES];
    
}
@end
