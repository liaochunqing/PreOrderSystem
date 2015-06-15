//
//  DishCardNewViewController.m
//  PreOrderSystem
//
//  Created by SWen on 14-7-15.
//
//
#import "Constants.h"
#import "CookbookPath.h"
#import "DishCardNewViewController.h"
#import "DishCardItemPriceTableviewCell.h"
#import "DishCardNewDetailTableViewCell.h"
#import "JsonPicker.h"
#import "DtMenuDataClass.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "OfflineManager.h"
#import "DataDownloader.h"
#import "NsstringAddOn.h"
#import "PSAlertView.h"
#import "PSPopoverBckgroundView.h"
#import "PECropViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DisplayHelper.h"
#import "PhotoReviewView.h"
#import "NSData+Base64.h"
#import "CookbookPath.h"
#import "PromotionDishSelectView.h"
#import "CookbookDataClass.h"
#import "DishCardNewViewClass.h"
#import "PackageDataModel.h"
#import "PackageMemberDataModel.h"
#import "WEPopoverController.h"
#import "WEPopoverController.h"
#import "MainViewController.h"


#define kDishNameLength 255
#define kMinPackfee 0
#define kMaxPackfee 1000
#define kpackfeeTextfieldTag 4000
#define kDCItmePriceArray [self.dishCardDict objectForKey:@"price"]
#define kCumtomDarkGray [UIColor colorWithRed:76.0/255.0 green:76.0/255.0 blue:76.0/255.0 alpha:1.0]

@interface DishCardNewViewController () <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, PECropViewControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate, PromotionDishSelectViewDelegate,DishCardNewDetailTableViewCellDelegate>
{
    UILabel *_optionalLabel;//选填
    UITextView *_itemDishDescripTextview;//简介
    PromotionDishSelectView *_guideTableView;
    DtMenuListDataClass *dtMenuListDataClass;
    JsonPicker *jsonPicker;// 网络请求对象
    NSMutableArray *_detailArray;//菜系明细列表
    id popController;
    CookbookDataClass *_cookbook ;//dishCardDict对应的模型
    int cuisineID;
    int isAllowTakeout;
    int isSoldOut;
    BOOL isEditing;//新建item时，isEditing＝NO，否则为YES
    int _isPackage;//是否套餐
    NSString *imgBaseURL;
}
@property (weak, nonatomic) IBOutlet UILabel *packageLabel;
@property (weak, nonatomic) IBOutlet UILabel *pauseLabel;
@property (weak, nonatomic) IBOutlet UISwitch *isActiveSwitch;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *soldOutLabel;
@property (weak, nonatomic) IBOutlet UILabel *takeOutLabel;
@property (weak, nonatomic) IBOutlet UILabel *yuanLabel;
@property (weak, nonatomic) IBOutlet UIImageView *packfeeImgBg;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *packfeeLabel;
@property (strong, nonatomic) NSMutableDictionary *dishCardDict;
@property (strong, nonatomic) id popover;
@property (assign, nonatomic) BOOL isEditEnable;
@property (weak, nonatomic) IBOutlet UITableView *itemTableView;
@property (weak, nonatomic) IBOutlet UITextField *packfeeTextField;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *comboImageView;
@property (weak, nonatomic) IBOutlet UIImageView *itemPicBgImageview;
@property (weak, nonatomic) IBOutlet UIImageView *itemPicImageview;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UITableView *detailTableView;
@property (weak, nonatomic) IBOutlet UISwitch *comboSwitch;
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UIButton *isSoldOutButton;
@property (weak, nonatomic) IBOutlet UIButton *editPicButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *takeoutAvailableButton;

- (IBAction)editItemPicButtonPressed:(UIButton *)sender;
- (IBAction)takeoutAvailableButtonPressed:(UIButton *)sender;
- (IBAction)isSoldOutButtonPressed:(UIButton *)sender;
- (IBAction)itemPicButtonPressed:(UIButton *)sender;
- (IBAction)cancelBtnClick:(UIButton *)sender;
- (IBAction)okBtnClick:(UIButton *)sender;
@end

@implementation DishCardNewViewController

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
    
    //设置UISwitch的初始化状态，初始为ON的一边
    self.comboSwitch.on = NO;
    
    //UISwitch事件的响应
    [self.comboSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    self.detailTableView.hidden  = _guideTableView.hidden = YES;
    
    //菊花
    self.activityView.hidden = YES;
    
    //暂停
    self.isActiveSwitch.on = NO;
    
    //多语言
    [self addLocalizedString];
    [self addPictureToView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)addLocalizedString
{
    self.numberLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"serial_number")];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"dish_name")];
    self.takeOutLabel.text = [NSString stringWithFormat:@"%@ : ",kLoc(@"support_takeout")];
    self.soldOutLabel.text = [NSString stringWithFormat:@"%@ : ",kLoc(@"whether_out_of_stock")];
    self.packfeeLabel.text = [NSString stringWithFormat:@"%@ : ",kLoc(@"packing_fee")];
    self.yuanLabel.text = kLoc(@"yuan");
    self.packfeeTextField.placeholder = [NSString stringWithFormat:@"(%@)",kLoc(@"required_to_fill")];
	self.numberTextField.placeholder = kLoc(@"optional");
    self.packageLabel.text = [NSString stringWithFormat:@"%@:", kLoc(@"is_package")];
    self.pauseLabel.text = [NSString stringWithFormat:@"%@:", kLoc(@"pause")];
    [self.cancelButton setTitle:kLoc(@"cancel") forState:UIControlStateNormal];
    [self.okButton setTitle:kLoc(@"confirm") forState:UIControlStateNormal];
}

- (void)addPictureToView
{
//    bgImageView.image = [UIImage imageFromMainBundleFile:@"dishCard_background.png"];
    //繁体
    if (![kCurrentLanguageOfDevice isEqualToString:kChineseFamiliarStyle])
    {
        [self.editPicButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_editPicButton_traditional.png"] forState:UIControlStateNormal];
    }
}

//收起键盘
- (void)hideKeyboard
{
    [self.numberTextField resignFirstResponder];
    [self.nameTextField resignFirstResponder];
    [_itemDishDescripTextview resignFirstResponder];
    NSInteger priceNum = [kDCItmePriceArray count];
    
    for (NSInteger counter = 0; counter < priceNum; counter++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:counter inSection:kTableViewSecondSection];
        DishCardItemPriceTableviewCell *cell = (DishCardItemPriceTableviewCell *)[_itemTableView cellForRowAtIndexPath:indexPath];
        if ([cell.itemStyleTextfield isFirstResponder])
        {
            [cell.itemStyleTextfield resignFirstResponder];
            break;
        }
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
}

- (void)addNewItemCell
{
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"style", @"", @"price",[NSNumber numberWithInt:0],  @"",  nil];
    NSMutableArray *priceArray = [[NSMutableArray alloc] initWithArray:[self.dishCardDict objectForKey:@"price"]];
    [priceArray insertObject:info atIndex:0];
    [self.dishCardDict setObject:priceArray forKey:@"price"];
}

- (void)updateViewWithCuisineID:(int)cid withImgBaseURL:(NSString *)imageURL
{
    isEditing = NO;
    cuisineID = cid;
    imgBaseURL = imageURL;
    isAllowTakeout = 1;
    isSoldOut = 0;
    //是否沽清
    if (isSoldOut == 1)
    {
        [self.isSoldOutButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_check.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.isSoldOutButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_uncheck.png"] forState:UIControlStateNormal];
    }
    
    //提供外卖
    if (isAllowTakeout == 1)
    {
        [self.takeoutAvailableButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_check.png"] forState:UIControlStateNormal];
        self.packfeeTextField.hidden = NO;
        self.packfeeImgBg.hidden = NO;
        self.packfeeLabel.hidden = NO;
        self.yuanLabel.hidden = NO;
    }
    else
    {
        [self.takeoutAvailableButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_uncheck.png"] forState:UIControlStateNormal];
        self.packfeeTextField.hidden = YES;
        self.packfeeImgBg.hidden = YES;
        self.packfeeLabel.hidden = YES;
        self.yuanLabel.hidden = YES;
    }
    
    self.packfeeTextField.text = @"0";
    self.dishCardDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    [self addNewItemCell];
    [self.itemTableView reloadData];
}

- (void)updateViewWithDishInfo:(NSDictionary *)info withImgBaseURL:(NSString *)imageURL
{
    isEditing = YES;
    imgBaseURL = imageURL;
    self.dishCardDict = [[NSMutableDictionary alloc] initWithDictionary:info];
    [self addNewItemCell];
    [self updateViewAfterGetData];

}

//重新组织套餐数据，以便详细列表detailTableView数据加载（接口给得太繁琐，没办法，这样做情非得已，泪奔啊）
- (void)organizePackageData
{
    _cookbook = [[CookbookDataClass alloc] initWithCookbookDic:self.dishCardDict];
    
    for (PackageDataModel *package in _cookbook.packageDataArr)
    {
        DishCardNewViewClass *dishClass = [[DishCardNewViewClass alloc] init];
        
        //菜系名
        dishClass.groupName = [[NSMutableString alloc] initWithString:package.itemName];
        //菜系ID
        dishClass.cuisineID = package.cuisineID;
        
        //规则
        dishClass.choose = package.choiceType;
        
        //份数
        dishClass.chooseNum = package.choiceNum;
        
        //菜名（数组）
        dishClass.cookArray = [[NSMutableArray alloc] initWithArray:package.memberArr];
        
        [_detailArray addObject:dishClass];
    }
}

- (void)updateViewAfterGetData
{
    cuisineID = [[self.dishCardDict objectForKey:@"id"] intValue];
    //是否提供外卖
    isAllowTakeout = [[self.dishCardDict objectForKey:@"isAllowTakeout"] intValue];
    
    //是否套餐
    _isPackage = [[self.dishCardDict objectForKey:@"isPackage"] intValue];
    
    if (_isPackage)
    {
        // 打开开关
        self.comboSwitch.on = YES;
        [self switchAction:self.comboSwitch];
        
        //获得套餐数据，刷新列表
        [self organizePackageData];
        [self.detailTableView reloadData];
    }
    
    if (isAllowTakeout == 1)
    {
        [self.takeoutAvailableButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_check.png"] forState:UIControlStateNormal];
        self.packfeeTextField.hidden = NO;
        self.packfeeImgBg.hidden = NO;
        self.packfeeLabel.hidden = NO;
        self.yuanLabel.hidden = NO;
        //打包费
        CGFloat pacefee = [[self.dishCardDict objectForKey:@"packfee"]floatValue];
        NSString *tempString = [NSString stringWithFormat:@"%.2f", pacefee];
        self.packfeeTextField.text = [NSString stringWithFormat:@"%@", [NSString trimmingZeroInPrice:tempString]];
    }
    else
    {
        [self.takeoutAvailableButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_uncheck.png"] forState:UIControlStateNormal];
        self.packfeeTextField.hidden = YES;
        self.packfeeImgBg.hidden = YES;
        self.packfeeLabel.hidden = YES;
        self.yuanLabel.hidden = YES;
    }
    
    //是否沽清
    isSoldOut = [[self.dishCardDict objectForKey:@"isSoldOut"] intValue];
    if (isSoldOut == 1)
    {
        [self.isSoldOutButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_check.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.isSoldOutButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_uncheck.png"] forState:UIControlStateNormal];
    }
    //菜的图片
    NSString *dishesPicture = [self.dishCardDict objectForKey:@"picture"];
    if ([dishesPicture length]>0)
    {
        //从本地加载图片
        OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
        if ([offlineMgr isOfflinePhotoExistWithFileName:[dishesPicture lastPathComponent]])
        {
            self.itemPicImageview.image = [offlineMgr offlinePhotoWithFileName:[dishesPicture lastPathComponent]];
        }
        else
        {
            self.activityView.hidden = NO;
            [self.activityView startAnimating];
            //从网络下载图片
            DataDownloader *downloader = [[DataDownloader alloc] init];
            downloader.delegate = self;
            [downloader parseWithURL:[NSString stringWithFormat:@"%@%@",imgBaseURL,dishesPicture] type:DataDownloaderTypePic];
        }
    }
    //编号
    self.numberTextField.text =  [[self.dishCardDict objectForKey:@"code"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //菜名
    self.nameTextField.text = [[self.dishCardDict objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //是否暂停
    self.isActiveSwitch.on = ![[self.dishCardDict objectForKey:@"isActive"] intValue];
    
    //介绍
    _itemDishDescripTextview.text = [[self.dishCardDict objectForKey:@"introduction"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //价格
    [self.itemTableView reloadData];
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
    
    if (!_optionalLabel)
    {
        _optionalLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 10, 255, 60)];
    }
    _optionalLabel.tag= 1;
    _optionalLabel.backgroundColor = [UIColor clearColor];
    _optionalLabel.textAlignment = UITextAlignmentCenter;
    _optionalLabel.textColor = [UIColor lightGrayColor];
    _optionalLabel.font = [UIFont systemFontOfSize:20];
    _optionalLabel.text = [NSString stringWithFormat:@"(%@)",kLoc(@"optional")];
    _optionalLabel.hidden = NO;
    [itemDishDescripView addSubview:_optionalLabel];
    
    if (!_itemDishDescripTextview)
    {
        _itemDishDescripTextview = [[UITextView alloc] initWithFrame:CGRectMake(65, 5, 255, 60)];
        _itemDishDescripTextview.delegate = self;
        _itemDishDescripTextview.backgroundColor = [UIColor clearColor];
        _itemDishDescripTextview.font = [UIFont systemFontOfSize:20];
        _itemDishDescripTextview.textColor = [UIColor orangeColor];
        _itemDishDescripTextview.textAlignment = UITextAlignmentCenter;
        NSString *introductionStr = [[self.dishCardDict objectForKey:@"introduction"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (0 != [introductionStr length])
        {
            _itemDishDescripTextview.text = introductionStr;
        }
    }
    if (0 != [[_itemDishDescripTextview.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length])
    {
        _optionalLabel.hidden = YES;
    }
    [itemDishDescripView addSubview:_itemDishDescripTextview];
    
    return itemDishDescripView;
}

#pragma mark --button click
//是否提供外卖
-(IBAction)takeoutAvailableButtonPressed:(id)sender
{
    [self hideKeyboard];
    isAllowTakeout = !isAllowTakeout;
    if (isAllowTakeout == 1)
    {
        [self.takeoutAvailableButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_check.png"] forState:UIControlStateNormal];
        self.packfeeTextField.hidden = NO;
        self.packfeeImgBg.hidden = NO;
        self.packfeeLabel.hidden = NO;
        self.yuanLabel.hidden = NO;
    }
    else
    {
        [self.takeoutAvailableButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_uncheck.png"] forState:UIControlStateNormal];
        self.packfeeTextField.hidden = YES;
        self.packfeeImgBg.hidden = YES;
        self.packfeeLabel.hidden = YES;
        self.yuanLabel.hidden = YES;
    }
}

//是否沽清
-(IBAction)isSoldOutButtonPressed:(id)sender
{
    [self hideKeyboard];
    isSoldOut = !isSoldOut;
    if (isSoldOut == 1)
    {
        [self.isSoldOutButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_check.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.isSoldOutButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishCardItem_uncheck.png"] forState:UIControlStateNormal];
    }
}

//菜品图片点击
-(IBAction)itemPicButtonPressed:(id)sender
{
    //jhh_edit
    [self hideKeyboard];
    if (self.itemPicImageview.image)
    {
        //self.view.hidden = YES;
        [[DisplayHelper shareDisplayHelper] showLoading];
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW , NSEC_PER_SEC * 0.5);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            // 获取图片数据
            UIImage *targetImage = self.itemPicImageview.image;
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
    [self hideKeyboard];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:kLoc(@"take_photo"), kLoc(@"browse_album"), nil];
    actionSheet.tag = 1;
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:self.editPicButton.frame inView:self.view animated:YES];
    }
}

//取消
- (IBAction)cancelBtnClick:(UIButton *)sender
{
    [self hideKeyboard];
    if (self.delegate && [self.delegate respondsToSelector:@selector(DishCardNewViewController:didDismissView:)])
    {
        [self.delegate DishCardNewViewController:self didDismissView:NO];
    }
    
}

//确定
- (IBAction)okBtnClick:(UIButton *)sender
{
    [self hideKeyboard];
    [self uploadData];
}

-(void)switchAction:(id)sender
{
    [self hideKeyboard];
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = switchButton.isOn;
    
    if (isButtonOn)
    {
        if (_detailArray == nil)
        {
            _detailArray = [[NSMutableArray alloc] init];
        }
        
        //菜系明细列表创建
        self.detailTableView.layer.borderWidth = 1;
        self.detailTableView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        
        //菜系选择列表创建
        if (_guideTableView == nil)
        {
            _guideTableView = [[PromotionDishSelectView alloc] initWithFrame:CGRectMake(self.comboImageView.frame.origin.x, CGRectGetMaxY(self.comboImageView.frame) + 5, self.comboImageView.frame.size.width/2, self.view.frame.size.height - CGRectGetMaxY(self.comboImageView.frame) - 35)];
            _guideTableView.delegate = self;
            _guideTableView.detailArray = _detailArray;
            [self.view addSubview:_guideTableView];
            [_guideTableView setSelectDataModel:self.allDishCardListArray selectedDishCardDict:self.dishCardDict];
            [_guideTableView reloadData];
        }
        
        self.detailTableView.hidden = _guideTableView.hidden = NO;
    }
    else
    {
        self.detailTableView.hidden = _guideTableView.hidden = YES;
    }
}

- (void)deleteBtnClick:(UIButton *)btn
{
    if (btn.tag < _detailArray.count)
    {
        [_detailArray removeObjectAtIndex:btn.tag];
        [_detailTableView reloadData];
    }
}

- (void)editBtnClick:(UIButton *)btn
{
    if (btn.tag < _detailArray.count)
    {
        DishCardNewViewClass *tempClass = _detailArray[btn.tag];
        [[NSNotificationCenter defaultCenter] postNotificationName:kEditDishFromDishCardNotification object:tempClass];
        
        [_detailTableView reloadData];
    }
}

- (void)spreadAndFoldBtnClick:(UIButton *)btn
{
    if (btn.tag < _detailArray.count)
    {
        DishCardNewViewClass *dishClass = _detailArray[btn.tag];
        dishClass.isSpread = !dishClass.isSpread;
        [_detailTableView reloadData];
    }
}


#pragma mark - UITableView delegate && datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    int section = indexPath.section;
    NSInteger indexRow = indexPath.row;
    
    if (tableView == self.itemTableView)
    {
        //介绍
        if (section == 0)
        {
            [cell.contentView addSubview:[self addDishDescripView]];
            return cell;
        }
        
        //价格
        if (section == 1)
        {
            static NSString *cellIdentifier = @"DishCardItemPriceTableviewCell";
            DishCardItemPriceTableviewCell *cell = (DishCardItemPriceTableviewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell)
            {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"DishCardItemPriceTableviewCell" owner:self options:nil] lastObject];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.tag = indexRow;
            cell.delegate = self;
            
            [cell updateCellInfo:kDCItmePriceArray[indexRow]];
            
            return cell;
        }
    }
    else if(tableView == self.detailTableView)
    {
        static NSString *cellIdentifier = @"DishCardNewDetailTableViewCell";
        DishCardNewDetailTableViewCell *cell = (DishCardNewDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DishCardNewDetailTableViewCell" owner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.tag = indexPath.section;
        cell.delegate = self;
        DishCardNewViewClass *dishClass = _detailArray[indexPath.section];
        [cell updateCellInfo:dishClass.cookArray[indexPath.row]];

        
        return cell;
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 0;
    if (tableView == self.itemTableView)
    {
        int section = indexPath.section;
        
        switch (section)
        {
            case 0:
            {
                height = 85;
                break;
            }
                
            case 1:
            {
                height = 50;
                break;
            }
        }
    }
    else if(tableView == self.detailTableView)
    {
        height = 50;
    }
    
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    if (tableView == self.itemTableView)
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
                rows = [kDCItmePriceArray count];
                break;
            }
        }
    }
    else if(tableView == self.detailTableView)
    {
        DishCardNewViewClass *dishClass = _detailArray[section];
        
        if (dishClass.isSpread)//展开
        {
            NSArray *array = dishClass.cookArray;
            rows = array.count;
        }
        else//折叠
        {
            return 0;
        }
        
        
    }
    
    return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger num = 1;
    if (tableView == self.itemTableView)
    {
        num = 2;
    }
    else if (tableView == self.detailTableView)
    {
        num = _detailArray.count;
    }
    
    return num;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.detailTableView)
    {
        DishCardNewViewClass *dishClass = _detailArray[section];
        
        float headViewHight = 50;
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.detailTableView.frame.size.width, headViewHight)];
        
        float space = 5;
        
        //菜系名
        UILabel *groupNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.detailTableView.frame.size.width/2 , 30)];
        groupNameLabel.font = [UIFont boldSystemFontOfSize:20];
        groupNameLabel.textColor = [UIColor blackColor];
        groupNameLabel.text = kLoc(dishClass.groupName);
        
        // 规则 + 数 + 项
        UILabel *ruleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, self.detailTableView.frame.size.width/2 + 55, 20)];
        ruleLabel.font = [UIFont boldSystemFontOfSize:15];
        ruleLabel.textColor = [UIColor grayColor];
        
        if (dishClass.chooseStringArray.count == 0)
        {
            dishClass.chooseStringArray = [[NSMutableArray alloc] initWithObjects:kLoc(@"select_all"),kLoc(@"required"),kLoc(@"optional_choose"), nil];
        }
        
        if (dishClass.choose == 0)
        {
            ruleLabel.text = kLoc(dishClass.chooseStringArray[dishClass.choose]);
        }
        else
        {
            ruleLabel.text = [NSString stringWithFormat:@"%@%d%@", kLoc(dishClass.chooseStringArray[dishClass.choose]),dishClass.chooseNum, kLoc(@"item")];
        }
        
        //删除按钮
        UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(groupNameLabel.frame) + space, (headViewHight - 40)/2, 60, 40)];
        [deleteButton setTitle:kLoc(@"delete") forState:UIControlStateNormal];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"more_shortButton.png"] forState:UIControlStateNormal];
        deleteButton.tag = section;
        [deleteButton addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //编辑按钮
        UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(deleteButton.frame) + space, (headViewHight - 40)/2, 60, 40)];
        [editButton setTitle:kLoc(@"edit") forState:UIControlStateNormal];
        [editButton setBackgroundImage:[UIImage imageNamed:@"more_shortButton.png"] forState:UIControlStateNormal];
        editButton.tag = section;
        [editButton addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        //展开折叠按钮
        UIButton *spreadAndFoldButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(editButton.frame) + space, (headViewHight - 40)/2, 60, 40)];
        NSString *string = dishClass.isSpread ? kLoc(@"fold") : kLoc(@"unfold");
        [spreadAndFoldButton setTitle:string forState:UIControlStateNormal];
        [spreadAndFoldButton setBackgroundImage:[UIImage imageNamed:@"more_shortButton.png"] forState:UIControlStateNormal];
        [spreadAndFoldButton addTarget:self action:@selector(spreadAndFoldBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        spreadAndFoldButton.tag = section;

        //背景图
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:headView.frame];
        imageView.image = [UIImage imageNamed:@"rule_cellHeadBg.png"];
        imageView.userInteractionEnabled = YES;
        
        [headView addSubview:imageView];
        [headView addSubview:deleteButton];
        [headView addSubview:editButton];
        [headView addSubview:ruleLabel];
        [headView addSubview:spreadAndFoldButton];
        [headView addSubview:groupNameLabel];
        return headView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.detailTableView)
    {
        return 50;
    }
    
    return 0;
}


#pragma mark DataDownloaderDelegate

- (void)hideActivityView
{
    self.activityView.hidden = YES;
    [self.activityView stopAnimating];
}


-(void)DataDownloader:(DataDownloader *)loader didLoadPhoto:(UIImage *)image
{
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    [offlineMgr saveOfflinePhoto:image andPhotoFileName:[loader url]];
    
    self.itemPicImageview.image = image;
    [self hideActivityView];
}

//加载失败，返回默认图像
-(void)DataDownloader:(DataDownloader *)loader didFailedLoadPhoto:(UIImage *)image
{
    [self hideActivityView];
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
#pragma mark - DishCardNewDetailTableViewCellDelegate
- (void)DishCardNewDetailTableViewCell:(DishCardNewDetailTableViewCell*)cell hideKeyboard:(BOOL)flag
{
    [self hideKeyboard];
}

- (void)DishCardNewDetailTableViewCell:(DishCardNewDetailTableViewCell*)cell changeChooseNumber:(NSInteger)chooseNumber
{
    DishCardNewViewClass *dishClass = _detailArray[cell.tag];
    dishClass.chooseNum = chooseNumber;
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
    [_itemTableView reloadData];
//    [_itemTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[kDCItmePriceArray count] -1 inSection:kTableViewSecondSection] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
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
                [_itemTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
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
        [_itemTableView reloadData];
//        [_itemTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
//        [_itemTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[kDCItmePriceArray count] -1 inSection:kTableViewSecondSection] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
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
        [_itemTableView reloadData];
//        [_itemTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[kDCItmePriceArray count] -1 inSection:kTableViewSecondSection] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
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
        [_itemTableView reloadData];
//        [_itemTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[kDCItmePriceArray count] -1 inSection:kTableViewSecondSection] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

-(void)DishCardItemPriceTableviewCellDidBeginEditingPrice:(DishCardItemPriceTableviewCell*)cell
{
    [self hideKeyboard];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _itemTableView.scrollEnabled = NO;
    
    if (kpackfeeTextfieldTag == textField.tag)
    {
        [self hideKeyboard];
        NumPicker *picker = [[NumPicker alloc] init];
        picker.delegate = self;
        picker.tag = kpackfeeTextfieldTag;
        picker.pickerType = NumPickerTypeWithDishPrice;
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
            [self.popover setParentView:mainCtrl.view];
            [self.popover presentPopoverFromRect:showRect
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
    if (textField == self.nameTextField)
    {
        //截取字符串
        NSString *tempString = [NSString cutString:textField.text withMaxLengthOfStr:kDishNameLength];
        textField.text = tempString;
    }
    
    _itemTableView.scrollEnabled = YES;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.nameTextField == textField && range.location >= kDishNameLength)
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - UITextviewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    _optionalLabel.hidden = YES;
    _itemTableView.scrollEnabled = NO;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    _optionalLabel.hidden = [_itemDishDescripTextview hasText];
    _itemTableView.scrollEnabled = YES;
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _optionalLabel.hidden = [_itemDishDescripTextview hasText];
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
        if ([self.popover isPopoverVisible]) {
            [self.popover dismissPopoverAnimated:NO];
        }
        
        if (kIsiPhone) {
            self.popover = [[WEPopoverController alloc] initWithContentViewController:controller];
        } else {
            self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        }
        
        
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
        [self.popover presentPopoverFromRect:self.editPicButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    self.itemPicImageview.image = croppedImage;
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
    return self.itemPicImageview.image;
}

#pragma mark - PromotionDishSelectViewDelegate
// uitableview滚动到最后一行
- (void)scrollTableToFoot:(UITableView *)tableView
{
    NSInteger s = [tableView numberOfSections];
    if (s<1) return;
    NSInteger r = [tableView numberOfRowsInSection:s-1];
    if (r<1) return;
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];
    
    [tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)PromotionDishSelectView:(PromotionDishSelectView *)dishSelectView pressSureButtonWithClass:(DishCardNewViewClass *)dishClass
{
    int i = 0;
    BOOL isReplace = NO;
    for (DishCardNewViewClass *temp in _detailArray)
    {
        NSString *tempGroupName = temp.groupName;
        NSString *groupName = dishClass.groupName;
        if ((dishClass.cuisineID == temp.cuisineID && temp.cuisineID != 0) || ([groupName isEqualToString:tempGroupName] && temp.cuisineID == 0))
        {
            [_detailArray replaceObjectAtIndex:i withObject:dishClass];
            isReplace = YES;
            break;
        }
        i++;
    }
    
    if (isReplace == NO)
    {
        [_detailArray addObject:dishClass];
    }
    
    [self.detailTableView reloadData];
//    [self scrollTableToFoot:self.detailTableView];
}

- (void)PromotionDishSelectView:(PromotionDishSelectView *)disSelectView didSelectedCookbookPathArr:(NSMutableArray *)indexArr
{
//    for (CookbookPath *cpath in indexArr)
//    {
//        if (cpath.cuisineIndex < self.allDishCardListArray.count)
//        {
//            NSMutableDictionary *addDict = [[NSMutableDictionary alloc] init];
//            // 菜系名
//            NSDictionary *dict = self.allDishCardListArray[cpath.cuisineIndex];
//            NSString *groupName = [dict objectForKey:@"name"];
//            [addDict setObject:groupName forKey:@"groupName"];
//            
//            // 菜名
//            NSArray *cookbookArr = [dict objectForKey:@"cookbook"];
//            if (cpath.cookbookIndex < cookbookArr.count)
//            {
//                NSDictionary *cookbookDict = cookbookArr[cpath.cookbookIndex];
//                NSString *name = [cookbookDict objectForKey:@"name"];
//                [addDict setObject:name forKey:@"name"];
//            }
//            
//            //添加到详情列表数组
//            [_detailArray addObject:addDict];
//        }
//        
//    }
//    
//    [_detailTableView reloadData];
}
- (void)PromotionDishSelectView:(PromotionDishSelectView *)disSelectView didRemovedCookbookPathArr:(NSMutableArray *)indexArr
{
//    for (CookbookPath *cpath in indexArr)
//    {
//        if (cpath.cuisineIndex < self.allDishCardListArray.count)
//        {
//            // 获得菜名
//            NSDictionary *dict = self.allDishCardListArray[cpath.cuisineIndex];
//            NSString *name ;
//            NSArray *cookbookArr = [dict objectForKey:@"cookbook"];
//            if (cpath.cookbookIndex < cookbookArr.count)
//            {
//                NSDictionary *cookbookDict = cookbookArr[cpath.cookbookIndex];
//                name = [cookbookDict objectForKey:@"name"];
//            }
//            
//            int i = 0;
//            
//            for (NSDictionary *tempDict in _detailArray)
//            {
//                NSString *tempString = [tempDict objectForKey:@"name"];
//                if ([tempString compare:name] == NSOrderedSame)
//                {
//                    // 删除被选中的
//                    [_detailArray removeObjectAtIndex:i];
//                    break;
//                }
//                i++;
//            }
//        }
//        
//    }
//    
//    [_detailTableView reloadData];
}
#pragma mark - network

/*  特别需要注意设置这个属性 jsonPicker.isShowUpdateAlert   */

- (void)uploadData
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
    
    NSString *itemDishName = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
                if (0 != i)
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
    
    //套餐价格只能有一个
    if (self.comboSwitch.on && prices.count > 1)
    {
        [PSAlertView showWithMessage:NSLocalizedString(@"套餐价格只能有一个", nil)];
        return;
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
    NSString *itemSN = [self.numberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([itemSN length]>0)
    {
        [postData setObject:itemSN forKey:@"code"];
    }
    else
    {
        [postData setObject:@"" forKey:@"code"];
    }
    
    //介绍
    NSString *itemDescrip = [_itemDishDescripTextview.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
    //是否暂停
    [postData setObject:[NSNumber numberWithInt:self.isActiveSwitch.on?0:1] forKey:@"isActive"];
    //价格
    [postData setObject:prices forKey:@"price"];
    
    //图片，转换image为Base64数据（大小为640×470）
    if (self.itemPicImageview.image)
    {
        NSData *picData = UIImageJPEGRepresentation(self.itemPicImageview.image,0.5);
        NSString *picStr = [picData base64EncodedString];
        [postData setObject:picStr forKey:@"picture"];
    }
    
    //是否套餐
    int i = self.comboSwitch.on?1:0;
    [postData setObject:[NSNumber numberWithInt:i] forKey:@"isPackage"];
    
    //套餐
    NSMutableArray *packageArray = [[NSMutableArray alloc] init];
    for (DishCardNewViewClass *dishCardClass in _detailArray)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
   
        [dict setObject:dishCardClass.groupName forKey:@"pName"];
        [dict setObject:[NSNumber numberWithInt:dishCardClass.choose] forKey:@"choose"];
        [dict setObject:[NSNumber numberWithInteger:dishCardClass.chooseNum] forKey:@"chooseNum"];
        [dict setObject:[NSNumber numberWithInteger:dishCardClass.cuisineID] forKey:@"cb_cuisineID"];
        
        // item数据
        NSMutableArray *itemArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < dishCardClass.cookArray.count; i++)
        {
            if ([dishCardClass.cookArray[i] isKindOfClass:[CookbookDataClass class]])
            {
                CookbookDataClass *cookbook = (CookbookDataClass *)dishCardClass.cookArray[i];
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:cookbook.cookbookName forKey:@"pName"];
                [dict setObject:[NSNumber numberWithInteger:cookbook.cookbookID] forKey:@"cb_cbID"];
                [dict setObject:[NSNumber numberWithInteger:cookbook.quantity] forKey:@"quantity"];
                [itemArray addObject:dict];
            }
            else if ([dishCardClass.cookArray[i] isKindOfClass:[PackageMemberDataModel class]])
            {
                PackageMemberDataModel *packageMember = (PackageMemberDataModel *)dishCardClass.cookArray[i];
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:packageMember.memberName forKey:@"pName"];
                [dict setObject:[NSNumber numberWithInteger:packageMember.cbID] forKey:@"cb_cbID"];
                [dict setObject:[NSNumber numberWithInteger:packageMember.quantity] forKey:@"quantity"];
                [itemArray addObject:dict];
            }
        }
        [dict setObject:itemArray forKey:@"item"];
        
        [packageArray addObject:dict];
    }
    [postData setObject:packageArray forKey:@"packages"];
    
    
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerSecondTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.isShowUpdateAlert = YES;
    jsonPicker.loadingMessage = kLoc(@"submitting_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    
    if (isEditing)
    {
        //编辑菜品
        [jsonPicker postData:postData withBaseRequest:@"cookbook/edit"];
    }
    else
    {
        //增加菜品
        [jsonPicker postData:postData withBaseRequest:@"cookbook/add"];
    }
    
}
#pragma mark - JsonPickerDelegate methods

- (void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    int responseStatus = [[dict objectForKey:@"status"] intValue];

    if (picker.tag == kJsonPickerSecondTag)
    {
        switch (responseStatus)
        {
            case 200:
            {
                if (self.delegate && [self.delegate respondsToSelector:@selector(DishCardNewViewController:didDismissView:)])
                {
                    [self.delegate DishCardNewViewController:self didDismissView:YES];
                }
                
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
- (void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error
{
}
// 网络连接失败时返回（无网络的情况）
- (void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error
{
}
@end
