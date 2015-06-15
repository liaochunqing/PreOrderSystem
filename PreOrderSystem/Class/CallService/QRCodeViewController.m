//
//  SettingAnswerViewController.m
//  PreOrderSystem
//
//  Created by sWen on 12-10-29.
//
//

#import "QRCodeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PSAlertView.h"
#import "Constants.h"
#import "ZipArchive.h"
#import "OfflineManager.h"
#import "EditQRCodeInfoViewController.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "NsstringAddOn.h"
#import "StaffManagementSuperDataClass.h"
#import "EGORefreshTableHeaderView.h"

#define kHousingDeskNameLength 12
#define kSaveQRPicActionSheetTag 1000
#define kSynchronousAlertViewTag 1100
#define kSynchronousFailAlertViewTag 1200
#define kGetDataFailAlertViewTag 1300
#define kSendEmailAlertViewTag 1400

@interface QRCodeViewController ()<UIActionSheetDelegate, EGORefreshTableHeaderDelegate>
{
    BOOL _reloading; //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
}
- (void)addNotification;
- (void)synchronousHousingDeskData;
- (void)SaveQRCodeData;
- (void)submitQRCodeToEmail:(NSString *)address;
- (NSString *)zipFilePath;
- (void)unzipFile:(NSString * )path;

@end

@implementation QRCodeViewController

@synthesize codeScrollView;
@synthesize codeTableView;
@synthesize nameTextField;
@synthesize titleLabel;
@synthesize bgImageView;
@synthesize addButton;
@synthesize cancelButton;
@synthesize doneButton;
@synthesize synchronousButton;
@synthesize infoButton;
@synthesize delegate;
@synthesize popoverController;

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
    
    [self addPictureToView];
    [self addNotification];
    [self addLocalizedString];
    
    // 加载房台
    [self addPullDownReFresh];
    [self synchronousHousingDeskData];
    
//    cellArray = [[NSMutableArray alloc]init];
    selectedhousingDeskArray = [[NSMutableArray alloc]init];
    QRCodeImageArray = [[NSMutableArray alloc]initWithCapacity:1];
    housingDeskArray = [[NSMutableArray alloc]initWithCapacity:1];
    
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    NSArray *authorityArray = [offlineMgr getAccountAuthority];
    BOOL diningTableAuthority = NO;
    
    for (NSDictionary *authDict in authorityArray)
    {
        StaffManagementAuthDataClass *authClass = [[StaffManagementAuthDataClass alloc] initWithStaffManagementAuthData:authDict];
        if ([authClass.indexStr isEqualToString:kMainAuthorityOfDiningTableIndexStr])
        {
            diningTableAuthority = authClass.open;
            break;
        }
    }
    
    if (!diningTableAuthority)
    {
        synchronousButton.hidden = YES;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self removeNotification];
    housingDeskArray = nil;
    QRCodeDataDict = nil;
    QRCodeImageArray = nil;
    saveQRCodeImageHUD = nil;
    jsonPicker = nil;
    self.popoverController = nil;
    qrCodeSelectedCell = nil;
    failAlert = nil;
    
#ifdef DEBUG
    NSLog(@"===QRCodeViewController,viewDidUnload===");
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ((kSystemVersionOfCurrentDevice >= 6.0) && [self isViewLoaded] && ![self.view window])
    {
        [self viewDidUnload];
        [self setView:nil];
    }
}

- (void)dealloc
{
    [self removeNotification];
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",[self class]);
#endif
}

- (void)addLocalizedString
{
    titleLabel.text = kLoc(@"customize_table_qrcode");
    nameTextField.placeholder = kLoc(@"please_enter_table_name");
    [self.synchronousButton setTitle:kLoc(@"import_table_name") forState:UIControlStateNormal];
    [self.selectedAllBtn setTitle:kLoc(@"select_all") forState:UIControlStateNormal];
    [self.selectedAllBtn setTitle:kLoc(@"cancel_select_all") forState:UIControlStateSelected];
}

- (void)addPictureToView
{
    bgImageView.image = [UIImage imageFromMainBundleFile:@"queue_editArrageBg.png"];
    
    [self.selectedAllBtn setBackgroundColor:[UIColor colorWithRed:0.578 green:0.727 blue:0.258 alpha:1.0]];
}

//退出
-(void)dismissView
{
    [nameTextField resignFirstResponder];
    if (self.popoverController)
    {
        [self.popoverController dismissPopoverAnimated:YES];
        //self.popoverController = nil;
    }
    
    if ([delegate respondsToSelector:@selector(QRCodeViewController:didDismissView:)])
    {
        [delegate QRCodeViewController:self didDismissView:YES];
    }
}

- (void)hideKeyBoard
{
    [nameTextField resignFirstResponder];
    [qrCodeSelectedCell.nameTextField1 resignFirstResponder];
    [qrCodeSelectedCell.nameTextField2 resignFirstResponder];
}

//下拉刷新
- (void)addPullDownReFresh
{
    //初始化“下拉刷新”控件
    _reloading = NO;
    
    if (_refreshHeaderView == nil)
    {
		_refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.codeTableView.bounds.size.height, self.codeTableView.frame.size.width, self.codeTableView.bounds.size.height)];
        _refreshHeaderView.backgroundColor = [UIColor clearColor];
		_refreshHeaderView.delegate = self;
		[self.codeTableView addSubview:_refreshHeaderView];
	}
    
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
}
#pragma mark - network

//同步房台名称
- (void)synchronousHousingDeskData
{
    self.selectedAllBtn.selected = NO;
    
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 0;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [jsonPicker postData:postData withBaseRequest:@"callservice/getDiningTable"];
}

- (void)SaveQRCodeData
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 1;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"saving_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
//    [postData setObject:housingDeskArray forKey:@"housingDesk"];
    [postData setObject:selectedhousingDeskArray forKey:@"diningTable"];
    [jsonPicker postData:postData withBaseRequest:@"callservice/saveQRCode"];
}

//通过邮件接收刚生成的二维码
- (void)submitQRCodeToEmail:(NSString *)address
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 2;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"submitting_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = kLoc(@"submit_succeed");
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[QRCodeDataDict objectForKey:@"path"] forKey:@"QRCodePackage"];
    if (0 != [address length])
    {
        [postData setObject:address forKey:@"email"];
    }
    else
    {
       [postData setObject:[QRCodeDataDict objectForKey:@"email"] forKey:@"email"];
    }
    [jsonPicker postData:postData withBaseRequest:@"callservice/emailQRCode"];
}

#pragma mark - UIButton Clicked

- (IBAction)selectedAllBtnClick:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    
    for (NSMutableDictionary *temp in housingDeskArray)
    {
        if (temp)
        {
            [temp setObject:[NSNumber numberWithBool:btn.selected] forKey:@"selected"];
        }
    }
    
    [codeTableView reloadData];
}

-(IBAction)cancelButtonPressed:(UIButton*)sender
{
    [self hideKeyBoard];
    [self dismissView];
}

-(IBAction)doneButtonPressed:(UIButton*)sender
{
    [self hideKeyBoard];
    if (0 == [housingDeskArray count])
    {
        [PSAlertView showWithMessage:kLoc(@"table_name_can_not_be_empty")];
        return;
    }
    else
    {
        for (int i = 0; i < [housingDeskArray count]; i++)
        {
            NSDictionary *dict = housingDeskArray[i];
            if (!dict) {
                continue;
            }
            NSString *tempString = [[dict objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (0 == [tempString length])
            {
                [PSAlertView showWithMessage:kLoc(@"table_name_can_not_be_empty")];
                return;
            }
        }
    }
    
    if (selectedhousingDeskArray) {
        [selectedhousingDeskArray removeAllObjects];
    }
    
    for (NSMutableDictionary *temp in housingDeskArray)
    {
        if (temp && [[temp objectForKey:@"selected"] boolValue] == YES)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:temp];
            [dict removeObjectForKey:@"selected"];
            [selectedhousingDeskArray addObject:dict];
        }
    }
    
    if (0 == [selectedhousingDeskArray count])
    {
        [PSAlertView showWithMessage:kLoc(@"please_select_table_name")];
        return;
    }
    
    [self SaveQRCodeData];
}

//同步房台名称
-(IBAction)synchronousButtonPressed:(UIButton*)sender
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:kLoc(@"import_table_name_tips") message:@"" delegate:self cancelButtonTitle:kLoc(@"confirm") otherButtonTitles:kLoc(@"cancel"), nil];
    alertView.tag = kSynchronousAlertViewTag;
    [alertView show];
    
}

-(IBAction)addButtonPressed:(UIButton*)sender
{
    NSString *tempString = [nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (0 == [tempString length])
    {
        [self hideKeyBoard];
        [PSAlertView showWithMessage:kLoc(@"please_enter_table_name")];
        nameTextField.text = @"";
        return;
    }
    
    //截取字符串
    NSString *cutString = [NSString cutString:tempString withMaxLengthOfStr:kHousingDeskNameLength];
    nameTextField.text = cutString;
    
    [housingDeskArray insertObject:nameTextField.text atIndex:0];
    [codeTableView reloadData];
    [codeTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    nameTextField.text = @"";
}

- (IBAction)infoButtonPressed:(UIButton*)sender
{
    if ([nameTextField isFirstResponder])
    {
        [nameTextField resignFirstResponder];
        [self performSelector:@selector(popInfoViewController:) withObject:sender afterDelay:0.5];
    }
    else
    {
        [self popInfoViewController:sender];
    }
}

- (void)popInfoViewController:(UIButton *)sender
{
    if (nil == self.popoverController)
    {
        EditQRCodeInfoViewController *contentViewController = [[EditQRCodeInfoViewController alloc] initWithNibName:@"EditQRCodeInfoViewController" bundle:nil];
        
        self.popoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
        
        if ([self.popoverController respondsToSelector:@selector(setContainerViewProperties:)])
        {
            [self.popoverController setContainerViewProperties:[self improvedContainerViewProperties]];
        }
        
        self.popoverController.delegate = self;
        self.popoverController.passthroughViews = [NSArray arrayWithObject:sender];
    }
    CGRect rect = CGRectMake(530, sender.frame.origin.y - 240, 41, 41);
    [self.popoverController dismissPopoverAnimated:YES];
    [self.popoverController presentPopoverFromRect:rect
                                            inView:self.view
                          permittedArrowDirections:UIPopoverArrowDirectionUp
                                          animated:YES];
}

#pragma mark - NSNotification

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification*)sender
{
    codeTableView.scrollEnabled = NO;
    [codeTableView setContentOffset:CGPointMake(0, qrCodeSelectedCell.frame.origin.y) animated:YES];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    codeTableView.scrollEnabled = YES;
    [codeTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    //[codeTableView setContentOffset:tableviewContentOffset animated:YES];
}

#pragma mark QRCodeViewControllerCell delegate
- (void)selectedHousingDesk:(QRCodeViewControllerCell*)ctrl
{
#if 0
    if (ctrl.cellTag < [housingDeskArray count])
    {
        if (ctrl.deleteButton1.selected)
        {
            [selectedhousingDeskArray addObject:ctrl.nameTextField1.text];
        }
        
        if (ctrl.deleteButton2.selected)
        {
            [selectedhousingDeskArray addObject:ctrl.nameTextField2.text];
        }
    }
#endif
}

- (void)deleteHousingDesk:(QRCodeViewControllerCell*)ctrl
{
    NSInteger index = ctrl.tag * 2;
    if (index < housingDeskArray.count)
    {
        NSMutableDictionary *dict = housingDeskArray[index];
        [dict setObject:[NSNumber numberWithBool:ctrl.deleteButton1.selected] forKey:@"selected"];
    }
    
    if (index + 1 < housingDeskArray.count)
    {
        NSMutableDictionary *dict = housingDeskArray[index + 1];
        [dict setObject:[NSNumber numberWithBool:ctrl.deleteButton2.selected] forKey:@"selected"];
    }
    
    for (NSMutableDictionary *temp in housingDeskArray)
    {
        if (temp && [[temp objectForKey:@"selected"] boolValue] == NO)
        {
            self.selectedAllBtn.selected = NO;
            return;
        }
    }
    
    self.selectedAllBtn.selected = YES;
}

- (void)housingDeskContentChange:(QRCodeViewControllerCell*)ctrl withNewName:(NSString *)name
{
    [housingDeskArray replaceObjectAtIndex:ctrl.cellTag withObject:name];
    [codeTableView reloadData];
}

- (void)moveViewUpWhenKeyboardShow:(QRCodeViewControllerCell*)ctrl
{
    qrCodeSelectedCell = ctrl;
    //tableviewContentOffset = codeTableView.contentOffset;
    //codeTableView.scrollEnabled = NO;
    [codeTableView setContentOffset:CGPointMake(0, ctrl.frame.origin.y) animated:YES];
}

- (void)moveViewBackWhenKeyboardHide:(QRCodeViewControllerCell*)ctrl
{
    //codeTableView.scrollEnabled = YES;
    //[codeTableView setContentOffset:tableviewContentOffset animated:YES];
}

#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController
{
	//self.popoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController
{
	return YES;
}

- (WEPopoverContainerViewProperties *)improvedContainerViewProperties {
	
	WEPopoverContainerViewProperties *props = [WEPopoverContainerViewProperties alloc];
	NSString *bgImageName = nil;
	CGFloat bgMargin = 0.0;
	CGFloat bgCapSize = 0.0;
	CGFloat contentMargin = 4.0;
	
	//bgImageName = @"popoverBg.png";
	
	// These constants are determined by the popoverBg.png image file and are image dependent
	bgMargin = 13; // margin width of 13 pixels on all sides popoverBg.png (62 pixels wide - 36 pixel background) / 2 == 26 / 2 == 13
	bgCapSize = 31; // ImageSize/2  == 62 / 2 == 31 pixels
	
	props.leftBgMargin = bgMargin;
	props.rightBgMargin = bgMargin;
	props.topBgMargin = bgMargin;
	props.bottomBgMargin = bgMargin;
	props.leftBgCapSize = bgCapSize;
	props.topBgCapSize = bgCapSize;
	props.bgImageName = bgImageName;
	props.leftContentMargin = contentMargin;
	props.rightContentMargin = contentMargin - 1; // Need to shift one pixel for border to look correct
	props.topContentMargin = contentMargin;
	props.bottomContentMargin = contentMargin;
	
	props.arrowMargin = 4.0;
	/*
     props.upArrowImageName = @"popoverArrowUp.png";
     props.downArrowImageName = @"popoverArrowDown.png";
     props.leftArrowImageName = @"popoverArrowLeft.png";
     props.rightArrowImageName = @"popoverArrowRight.png";
     */
	return props;
}

#pragma mark UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 65;
	return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = 0;
    if ( 0 == [housingDeskArray count] % 2)
    {
        number = [housingDeskArray count]/2;
    }
    else
    {
        number = [housingDeskArray count]/2 + 1;
    }
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    QRCodeViewControllerCell *cell = (QRCodeViewControllerCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"QRCodeViewControllerCell" owner:nil options:nil]lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
	}
    
    int indexForCell = (int)indexPath.row * 2;
    if (indexForCell < [housingDeskArray count])
    {
        NSDictionary *dict1 = housingDeskArray[indexForCell];
        if (indexForCell + 1 < [housingDeskArray count])
        {
            NSDictionary *dict2 = housingDeskArray[indexForCell + 1];
            [cell refreshCellAfterGetData:dict1 withSceond:dict2 ];
        }
        else
        {
            [cell refreshCellAfterGetData:dict1 withSceond:nil];
        }
    }
        
    cell.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        //是否同步房台名称
        case kSynchronousAlertViewTag:
        {
            if (0 == buttonIndex)
            {
                [self synchronousHousingDeskData];
            }
            break;
        }
        //QRCode数据获取失败
        case kGetDataFailAlertViewTag:
        {
            if (0 == buttonIndex)
            {
                [self SaveQRCodeData];
            }
            break;
        }
        //同步房台数据失败
        case kSynchronousFailAlertViewTag:
        {
            if (0 == buttonIndex)
            {
                [self synchronousHousingDeskData];
            }
            break;
        }
        case kSendEmailAlertViewTag:
        {
            if (0 == buttonIndex)
            {
                [self showSaveQRPicActionSheet];
            }
            else
            {
                NSString *newAddress = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [self submitQRCodeToEmail:newAddress];
            }
            break;
        }
    }
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //成功获取QRCode数据
    if (kSaveQRPicActionSheetTag == actionSheet.tag)
    {
        //保存到本地
        if (0 == buttonIndex)
        {
            if (saveQRCodeImageHUD == nil && QRCodeDataDict != nil)
            {
                saveQRCodeImageHUD = [[MBProgressHUD alloc] initWithView:self.view];
                saveQRCodeImageHUD.delegate = self;
                saveQRCodeImageHUD.mode = MBProgressHUDModeIndeterminate;
                saveQRCodeImageHUD.labelText = kLoc(@"saving_pictures_please_wait");
                [self.view addSubview:saveQRCodeImageHUD];
            }
            [saveQRCodeImageHUD show:YES];
            
            //下载zip文件
            DataDownloader *downloader = [[DataDownloader alloc] init];
            downloader.delegate = self;
            [downloader parseWithURL:[QRCodeDataDict objectForKey:@"url"] type:DataDownloaderTypeZipFile];
            
        }
        else if(1 == buttonIndex) //发送到邮箱
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:kLoc(@"cancel") otherButtonTitles:kLoc(@"confirm"), nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField *addTextField = [alertView textFieldAtIndex:0];
            addTextField.text = [QRCodeDataDict objectForKey:@"email"];
            addTextField.clearButtonMode = UITextFieldViewModeAlways;
            alertView.tag = kSendEmailAlertViewTag;
            [alertView show];
            
        }
    }
}

#pragma mark DataDownloader 下载zip文件并且解压

- (void)DataDownloader:(DataDownloader *)loader didLoadZipFile:(NSData *)fileData
{
    NSString * filePath = [self zipFilePath];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileData attributes:nil];
    [self unzipFile:filePath];
}

//加载失败
- (void)DataDownloader:(DataDownloader *)loader didFailedLoadZipFile:(NSData *)file
{
    [saveQRCodeImageHUD hide:YES];
    [PSAlertView showWithMessage:kLoc(@"save_failed")];
}

// 网络连接失败时返回（无网络的情况）
- (void)DataDownloader:(DataDownloader *)loader didFailWithNetwork:(NSError *)error
{
    [saveQRCodeImageHUD hide:YES];
}

- (NSString *)zipFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentPath,[QRCodeDataDict objectForKey:@"name"]];
    return filePath;
}

//解压
- (void)unzipFile:(NSString * )path
{
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    if ([zipArchive UnzipOpenFile:path])
    {
        BOOL isTure = [zipArchive UnzipFileTo:[[[self zipFilePath] componentsSeparatedByString:@".zip"] objectAtIndex:0] overWrite:YES];
        [zipArchive UnzipCloseFile];
        
        if (isTure)
        {
            [self saveImageToPictureLibrary];
        }
        else
        {
            [PSAlertView showWithMessage:kLoc(@"save_failed")];
        }
    }
    else
    {
        [PSAlertView showWithMessage:kLoc(@"save_failed")];
    }
}

//保存QRCode到图片库
- (void)saveImageToPictureLibrary
{
    [QRCodeImageArray removeAllObjects];
    NSString *path = [[[self zipFilePath] componentsSeparatedByString:@".zip"] objectAtIndex:0];
    NSArray *picArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    for (int k = 0; k < [picArray count]; k++)
    {
        //添加图片到数组
        UIImage *tempImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",path,[picArray objectAtIndex:k]]];
        if (nil != tempImage)
        {
            [QRCodeImageArray addObject:tempImage];
        }
    }
    if (0 != [QRCodeImageArray count])
    {
        [self saveNextImage];
    }
    else
    {
        [saveQRCodeImageHUD hide:YES];
        [PSAlertView showWithMessage:kLoc(@"save_failed")];
    }
}

- (void)saveNextImage
{
    if (QRCodeImageArray && QRCodeImageArray.count > 0)
    {
        UIImage *image = [QRCodeImageArray lastObject];
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:),
                                       nil);
        [QRCodeImageArray removeLastObject];
    }
}

- (void)savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo
{
    if (QRCodeImageArray)
    {
        if (error)
        {
            if (nil == failAlert)
            {
                failAlert = [[UIAlertView alloc] initWithTitle:nil message:kLoc(@"open_photo_library_tips") delegate:nil cancelButtonTitle:kLoc(@"i_know") otherButtonTitles:nil];
            }
            [failAlert show];
        }
        
        if (QRCodeImageArray.count == 0)
        {
            [saveQRCodeImageHUD hide:YES];
            [PSAlertView showWithMessage:kLoc(@"save_succeed")];
            [self performSelector:@selector(dismissView) withObject:nil afterDelay:2.0];
            return;
        }
        
        [self saveNextImage];
    }
}

#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[saveQRCodeImageHUD removeFromSuperview];
	saveQRCodeImageHUD = nil;
}

#pragma mark UITextFidld delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    codeTableView.scrollEnabled = NO;
    [codeScrollView setContentOffset:CGPointMake(0, 320) animated:YES];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //截取字符串
    NSString *tempString = [NSString cutString:textField.text withMaxLengthOfStr:kHousingDeskNameLength];
    textField.text = tempString;
    
    codeTableView.scrollEnabled = YES;
    [codeScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    return YES;
}

/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location >= kHousingDeskNameLength)
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
    [self hideKeyBoard];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self synchronousHousingDeskData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; // should return date data source was last changed
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
};

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark JsonPickerDelegate

- (void)showSaveQRPicActionSheet
{
    UIActionSheet *saveQRPicActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:kLoc(@"save_to_local"),kLoc(@"send_to_email"), nil];
    saveQRPicActionSheet.tag = kSaveQRPicActionSheetTag;
    [saveQRPicActionSheet showInView:self.view.window];
}

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    int responseStatus = [[dict objectForKey:@"status"] intValue];
    if (picker.tag==0)
    {
        switch (responseStatus)
        {
            case 200:
            {
                [housingDeskArray removeAllObjects];
                [housingDeskArray addObjectsFromArray:[[dict objectForKey:@"data"] objectForKey:@"diningTable"]];
                
                for (NSMutableDictionary *temp in housingDeskArray)
                {
                    if (temp)
                    {
                        [temp setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
                    }
                }
                
                _reloading = NO;
                [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.codeTableView];
                
                //刷新页面
                [codeTableView reloadData];
                break;
            }
            default:
            {
                [housingDeskArray removeAllObjects];
                //刷新页面
                [codeTableView reloadData];
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:kLoc(@"synchronization_fail") message:nil delegate:self cancelButtonTitle:kLoc(@"retry") otherButtonTitles:kLoc(@"cancel"), nil];
                alertView.tag = kSynchronousFailAlertViewTag;
                [alertView show];
                
                break;
            }
        }
    }
    
    if (picker.tag==1)
    {
        switch (responseStatus)
        {
            //保存成功
            case 200:
            {
                if (nil == QRCodeDataDict)
                {
                    QRCodeDataDict  = [[NSMutableDictionary alloc] init];
                }
                [QRCodeDataDict removeAllObjects];
                [QRCodeDataDict addEntriesFromDictionary:[dict objectForKey:@"data"]];
                
                [self performSelector:@selector(showSaveQRPicActionSheet) withObject:nil afterDelay:1.0];
                
                break;
            }
            //保存失败
            default:
            {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:kLoc(@"fetch_failed") message:@"" delegate:self cancelButtonTitle:kLoc(@"retry") otherButtonTitles:kLoc(@"cancel"), nil];
                alertView.tag = kGetDataFailAlertViewTag;
                [alertView show];
                
                break;
            }
        }
    }
    
    if (picker.tag==2)
    {
        switch (responseStatus)
        {
            //成功
            case 200:
            {
                [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.5];
                break;
            }
            //
            default:
            {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                
                break;
            }
        }
    }
    
}


// JSON解释错误时返回
-(void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error
{
    
}


// 网络连接失败时返回（无网络的情况）
-(void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error
{
    
}



@end
