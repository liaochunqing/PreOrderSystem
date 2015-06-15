//
//  StaffInfoViewController.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-7.
//
//

#import "StaffInfoViewController.h"
#import "Constants.h"
#import "StaffInfoFunctionTableViewCell.h"
#import "StaffManagementSuperDataClass.h"
#import "JsonPicker.h"
#import "PSAlertView.h"
#import "PostStyleView.h"
#import "CustomPopoverTouchView.h"
#import "MainViewController.h"
#import "NsstringAddOn.h"
#import "NSData+Base64.h"
#import "UIImageAddOn.h"
#import "PECropViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "LoadPicture.h"
#import "WEPopoverController.h"
#import "MainViewController.h"
#import "UITextFieldAddition.h"

#define kAuthorityDataSource ((self.isAddNewStaff)?[self getPostDataClass:postListClass.postListArray].authArray:((0 <= postIndex)?[self getPostDataClass:self.postListArray].authArray:self.staffInfo.authArray))
#define kPostDataSource ((self.isAddNewStaff)?postListClass.postListArray:self.postListArray)
#define kHeadImgUIActionSheetTag 1000
#define kBackAlertViewTag 1100
#define kGenerateAccountAlertViewTag 1200
#define kAccountUpdateAlertViewTag 1300

@interface StaffInfoViewController ()<JsonPickerDelegate, UITableViewDataSource, UITableViewDelegate, PostStyleViewDelegate, CustomPopoverTouchViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PECropViewControllerDelegate, StaffInfoFunctionTableViewCellDelegate>
{
    JsonPicker *jsonPicker;
    StaffManagementPostSuperDataClass *postListClass;
    NSInteger postIndex;
    PostStyleView *stylePickerView;
    CustomPopoverTouchView *customTouchView;
    id browsePicPopover;
    NSDictionary *staffListDict;
}

@property (nonatomic, weak) IBOutlet UIImageView *backBtnBgView;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIImageView *headImgFrameView;
@property (nonatomic, weak) IBOutlet UIImageView *defaultHeadImgView;
@property (nonatomic, weak) IBOutlet UIButton *headImgButton;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *nameBgView;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UILabel *accountLabel;
@property (nonatomic, weak) IBOutlet UILabel *roomAccountLabel;
@property (nonatomic, weak) IBOutlet UIImageView *accountBgView;
@property (nonatomic, weak) IBOutlet UITextField *accountTextField;
@property (nonatomic, weak) IBOutlet UILabel *passwordLabel;
@property (nonatomic, weak) IBOutlet UIImageView *passwordBgView;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UILabel *confirmPasswordLabel;
@property (nonatomic, weak) IBOutlet UIImageView *confirmPasswordBgView;
@property (nonatomic, weak) IBOutlet UITextField *confirmPasswordTextField;
@property (nonatomic, weak) IBOutlet UILabel *postLabel;
@property (nonatomic, weak) IBOutlet UIImageView *postBgView;
@property (nonatomic, weak) IBOutlet UITextField *postTextField;
@property (nonatomic, weak) IBOutlet UIImageView *downArrowBgView;
@property (nonatomic, weak) IBOutlet UIButton *downArrowButton;
@property (nonatomic, weak) IBOutlet UILabel *functionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *functionBgView;
@property (nonatomic, weak) IBOutlet UITableView *functionTableView;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *generateAccountButton;
@property (nonatomic, weak) IBOutlet UIButton *trueButton;

- (IBAction)backBtnClicked:(UIButton*)sender;
- (IBAction)headImgBtnClicked:(UIButton*)sender;
- (IBAction)downArrowBtnClicked:(UIButton*)sender;
- (IBAction)cancelBtnClicked:(UIButton*)sender;
- (IBAction)generateAccountBtnClicked:(UIButton*)sender;
- (IBAction)trueBtnClicked:(UIButton*)sender;

@end

@implementation StaffInfoViewController

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
    
    // 添加关闭按钮
    [self.accountTextField bindCloseButton];
    
    self.isTakePhoto = NO;
    [self addPictureToView];
    [self addLocalizedString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    if (self.isAddNewStaff) {
        [info setObject:kLoc(@"more_staff_management_permissions") forKey:@"title"];
    } else {
        [info setObject:kLoc(@"more_staff_management_edit_data") forKey:@"title"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
    
    [self updateStaffInfoView];
}

- (void)addPictureToView
{
    self.backBtnBgView.image = LoadImageWithPNGType(@"more_staffInfoBackBtn");
    self.nameBgView.image = LoadImageWithPNGType(@"more_bigTextFieldBg");
    self.accountBgView.image = LoadImageWithPNGType(@"more_smallTextFieldBg");
    self.passwordBgView.image = LoadImageWithPNGType(@"more_bigTextFieldBg");
    self.confirmPasswordBgView.image = LoadImageWithPNGType(@"more_middleTextFieldBg");
    self.postBgView.image = LoadImageWithPNGType(@"more_bigTextFieldBg");
    self.downArrowBgView.image = LoadImageWithPNGType(@"more_staffInfoDownArrow");
    self.functionBgView.image = LoadImageWithPNGType(@"more_staffInfoFunctionBg");
    [self.cancelButton setBackgroundImage:LoadImageWithPNGType(@"more_shortButton") forState:UIControlStateNormal];
    [self.generateAccountButton setBackgroundImage:LoadImageWithPNGType(@"more_staffInfoAccountBtn") forState:UIControlStateNormal];
    [self.trueButton setBackgroundImage:LoadImageWithPNGType(@"more_shortButton") forState:UIControlStateNormal];
    
    self.headImgFrameView.layer.masksToBounds = YES;
    self.headImgFrameView.layer.cornerRadius = 8.0;
    self.headImgFrameView.layer.borderWidth = 1.5;
    self.headImgFrameView.layer.borderColor = [[UIColor colorWithRed:115.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0] CGColor];
}

- (void)addLocalizedString
{
//    self.nameLabel.text = kLoc(@"姓名 :", nil);
//    self.accountLabel.text = kLoc(@"帐号 :", nil);
//    self.passwordLabel.text = kLoc(@"密码 :", nil);
//    self.confirmPasswordLabel.text = kLoc(@"确认密码 :", nil);
//    self.postLabel.text = kLoc(@"职位 :", nil);
    
    
    self.nameLabel.text =[NSString stringWithFormat:@"%@ :",kLoc(@"compellation")];
    self.accountLabel.text = [NSString stringWithFormat:@"%@ :",kLoc(@"account")];
    self.passwordLabel.text = [NSString stringWithFormat:@"%@ :",kLoc(@"password")];
    self.confirmPasswordLabel.text = [NSString stringWithFormat:@"%@ :",kLoc(@"confirm_password")];
    self.postLabel.text = [NSString stringWithFormat:@"%@ :",kLoc(@"positiion")];
    
    self.functionLabel.text = kLoc(@"function");
    [self.cancelButton setTitle:kLoc(@"cancel") forState:UIControlStateNormal];
    [self.generateAccountButton setTitle:kLoc(@"generate_account") forState:UIControlStateNormal];
    [self.trueButton setTitle:kLoc(@"confirm") forState:UIControlStateNormal];
}

- (void)updateStaffInfoView
{
    if (!self.isTakePhoto)
    {
        staffListDict = nil;
        if (self.isAddNewStaff)
        {
            self.generateAccountButton.hidden = self.backButton.hidden = self.backBtnBgView.hidden = NO;
            self.cancelButton.hidden = self.trueButton.hidden = YES;
            self.headImgFrameView.image = nil;
            self.nameTextField.text = @"";
            self.roomAccountLabel.text = @"";
            self.accountTextField.text = @"";
            self.passwordTextField.text = @"";
            self.confirmPasswordTextField.text = @"";
            self.postTextField.text = @"";
            
            postIndex = 0;
            [self getPostInfoData:YES];
        }
        else
        {
            postIndex = -1;
            self.generateAccountButton.hidden = self.backButton.hidden = self.backBtnBgView.hidden = YES;
            self.cancelButton.hidden = self.trueButton.hidden = NO;
            
            self.nameTextField.text = self.staffInfo.name;
            self.roomAccountLabel.text = self.staffInfo.roomNumberStr;
            self.accountTextField.text = self.staffInfo.numberStr;
            self.passwordTextField.text = self.staffInfo.passwordStr;
            self.confirmPasswordTextField.text = self.staffInfo.passwordStr;
            self.postTextField.text = self.staffInfo.postName;
            
            //加载头像
            NSString *picURL = self.staffInfo.pictureURL;
            if (![NSString strIsEmpty:picURL])
            {
                NSURL *imageURL = [NSURL URLWithString:picURL];
//                [LoadPicture loadPicFromNetword:imageURL withImageView:self.headImgFrameView];
                NSData *data = [NSData dataWithContentsOfURL:imageURL];
                UIImage *image = [UIImage imageWithData:data];
                self.headImgFrameView.image = image;
            }
            else
            {
                self.headImgFrameView.image = nil;
            }
        }
        self.defaultHeadImgView.image = self.headImgFrameView.image ?nil:LoadImageWithPNGType(@"more_staffHeadImg");
        [self.functionTableView reloadData];
    }
}

- (StaffManagementPostDataClass *)getPostDataClass:(NSArray *)tempPostListArray
{
    StaffManagementPostDataClass *postClass = nil;
    if (kZeroNumber <= postIndex && postIndex < [tempPostListArray count])
    {
        postClass = [tempPostListArray objectAtIndex:postIndex];
    }
    return postClass;
}

- (void)dismissStaffInfoView:(NSDictionary *)lastestStaffListData
{
    if ([self.delegate respondsToSelector:@selector(staffInfoViewController:didDismissView:)])
    {
        [self.delegate staffInfoViewController:self didDismissView:lastestStaffListData];
    }
}

- (void)hideKeyboard
{
    [self.nameTextField resignFirstResponder];
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
    [self.postTextField resignFirstResponder];
}

#pragma mark - network

-(void)getPostInfoData:(BOOL)animated
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [jsonPicker postData:postData withBaseRequest:@"group/getlist"];
}

-(void)addStaffInfoData:(BOOL)animated
{
    NSDictionary *postDict = [self getSubmitArguments];
    if (!postDict)
    {
        return;
    }
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerSecondTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:postDict withBaseRequest:@"user/add"];
}

-(void)saveStaffInfoData:(BOOL)animated
{
    NSDictionary *postDict = [self getSubmitArguments];
    if (!postDict)
    {
        return;
    }
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerThirdTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:postDict withBaseRequest:@"user/save"];
}

- (NSMutableDictionary *)getSubmitArguments
{
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    NSString *staffName = self.nameTextField.text;
    if ([NSString strIsEmpty:staffName])
    {
        return [self showWarnWhenCommitData];
    }
    NSString *staffNum = self.accountTextField.text;
    if ([NSString strIsEmpty:staffNum])
    {
        return [self showWarnWhenCommitData];
    }
    NSString *password = self.passwordTextField.text;
    if ([NSString strIsEmpty:password])
    {
        return [self showWarnWhenCommitData];
    }
    NSString *confirmPassword = self.confirmPasswordTextField.text;
    if ([NSString strIsEmpty:confirmPassword])
    {
        return [self showWarnWhenCommitData];
    }
    const NSInteger minLen = 6;
    if ([password length] < minLen)
    {
        [PSAlertView showWithMessage:kLoc(@"password_cannot_be_less_6")];
        return nil;
    }
    if ((![password isEqualToString:confirmPassword]) || ([confirmPassword length] < minLen))
    {
        [PSAlertView showWithMessage:kLoc(@"password_comfirm_password_different")];
        return nil;
    }
    NSString *picStr = @"";
    if (self.headImgFrameView.image)
    {
        UIImage *image = [UIImage modifyImageOrientation:self.headImgFrameView.image];
        NSData *picData = UIImageJPEGRepresentation(image, 0.5);
        picStr = [picData base64EncodedString];
    }
    NSString *postIdStr = nil;
    NSArray *authArray = nil;
    if (self.isAddNewStaff)
    {
        postIdStr = [self getPostDataClass:postListClass.postListArray].postIdStr;
        authArray = [self getOpenSubAuthIdArray:[self getPostDataClass:postListClass.postListArray].authArray];
    }
    else
    {
        [postData setObject:self.staffInfo.staffIdStr forKey:@"id"];
        
        if (kZeroNumber <= postIndex)
        {
            postIdStr = [self getPostDataClass:self.postListArray].postIdStr;
            authArray = [self getOpenSubAuthIdArray:[self getPostDataClass:self.postListArray].authArray];
        }
        else
        {
            postIdStr = self.staffInfo.postIdStr;
            authArray = [self getOpenSubAuthIdArray:self.staffInfo.authArray];
        }
    }
    if (![authArray count])
    {
//        [PSAlertView showWithMessage:kLoc(@"至少勾选一项权限", nil)];
//        return nil;
    }
    [postData setObject:postIdStr forKey:@"gid"];
    [postData setObject:authArray forKey:@"auth"];
    [postData setObject:staffNum forKey:@"number"];
    [postData setObject:staffName forKey:@"name"];
    [postData setObject:confirmPassword forKey:@"pwd"];
    [postData setObject:picStr forKey:@"picture"];
    
#ifdef DEBUG
    NSLog(@"===%s,%@===", __FUNCTION__, postData);
#endif
    
    return postData;
}

- (NSMutableDictionary *)showWarnWhenCommitData
{
    [PSAlertView showWithMessage:kLoc(@"please_enter_the_complete_info")];
    return nil;
}

- (NSMutableArray *)getOpenSubAuthIdArray:(NSArray *)authArray
{
    NSMutableArray *subAuthIdArray = [[NSMutableArray alloc] init];
    for (StaffManagementAuthDataClass *auth in authArray)
    {
        for (StaffManagementSubAuthDataClass *subAuth in auth.childrenArray)
        {
            if (subAuth.open)
            {
                [subAuthIdArray addObject:subAuth.idStr];
            }
        }
    }
    return subAuthIdArray;
}

#pragma mark - UIButton Clicked

- (IBAction)backBtnClicked:(UIButton*)sender
{
    [self hideKeyboard];
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:kLoc(@"no_finished_edit_error") message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:kLoc(@"cancel"), kLoc(@"confirm"), nil];
    alertView.tag = kBackAlertViewTag;
    alertView.delegate = self;
    [alertView show];
}

- (IBAction)headImgBtnClicked:(UIButton*)sender
{
    [self hideKeyboard];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:kLoc(@"take_photo"), kLoc(@"browse_album"), nil];
    actionSheet.tag = kHeadImgUIActionSheetTag;
    if (kIsiPhone) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showFromRect:self.headImgButton.frame inView:self.view animated:YES];
    }
}

- (IBAction)downArrowBtnClicked:(UIButton*)sender
{
    [self hideKeyboard];
    
    MainViewController *mainVC = [MainViewController getMianViewShareInstance];
    if (!customTouchView)
    {
        customTouchView = [[CustomPopoverTouchView alloc] initWithFrame:mainVC.view.frame];
    }
    customTouchView.delegate = self;
    [mainVC.view addSubview:customTouchView];
    
    if (!stylePickerView)
    {
        stylePickerView = [[PostStyleView alloc] initWithFrame:CGRectZero];
    }
    stylePickerView.delegate = self;
    [stylePickerView showInView:mainVC.view withOriginPoint:kPostStyleViewOrigin withAnimated:YES];
    [stylePickerView updatePostStyleView:kPostDataSource];
}

- (IBAction)cancelBtnClicked:(UIButton*)sender
{
    [self backBtnClicked:nil];
}

- (IBAction)generateAccountBtnClicked:(UIButton*)sender
{
    [self hideKeyboard];
    [self addStaffInfoData:YES];
}

- (IBAction)trueBtnClicked:(UIButton*)sender
{
    [self hideKeyboard];
    [self saveStaffInfoData:YES];
}

#pragma mark - get photo by UIImagePickerController

//拍照
- (void)browseFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.isTakePhoto = YES;
        if (!kIsiPhone) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        }
        
        UIImagePickerController *takePhotoController = [[UIImagePickerController alloc] init];
        takePhotoController.sourceType =  UIImagePickerControllerSourceTypeCamera;
        takePhotoController.delegate = self;
        [[MainViewController getMianViewShareInstance] presentViewController:takePhotoController animated:YES completion:nil];
    }
    else
    {
        [PSAlertView showWithMessage:kLoc(@"sorry_camera_not_support_for_your_device")];
    }
}

-(void)browseFromPhotoAlbum
{
    if (YES == (kSystemVersionOfCurrentDevice >= 6.0))
    {
        if (NO == [self canLoadPhotoAlbum])
        {
            [PSAlertView showWithMessage:kLoc(@"etable_dont_have_permission_to_read_your_photos") buttonTitle:kLoc(@"i_know")];
            return;
        }
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ||
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.delegate = self;
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        if ([browsePicPopover isPopoverVisible]) {
            [browsePicPopover dismissPopoverAnimated:NO];
        }
        if (kIsiPhone) {
            browsePicPopover = [[WEPopoverController alloc] initWithContentViewController:controller];
        } else {
            browsePicPopover = [[UIPopoverController alloc] initWithContentViewController:controller];
        }
        
        if (kIsiPhone) {
            MainViewController *mainCtrl = [MainViewController getMianViewShareInstance];
            CGRect showRect = [self.view convertRect:self.headImgButton.frame toView:mainCtrl.view];
            [browsePicPopover setParentView:mainCtrl.view];
            [browsePicPopover presentPopoverFromRect:showRect
                                              inView:mainCtrl.view
                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                            animated:YES];
        } else {
            [browsePicPopover presentPopoverFromRect:self.headImgButton.frame
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
    [[MainViewController getMianViewShareInstance] presentViewController:navigationController animated:YES completion:nil];
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
    if ([browsePicPopover isPopoverVisible])
    {
        /*从相册获取图片*/
        [browsePicPopover dismissPopoverAnimated:NO];
        [self openEditor:image];
    }
    else
    {
        /*拍照*/
        [[MainViewController getMianViewShareInstance] dismissViewControllerAnimated:YES completion:^{
            self.isTakePhoto = NO;
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
    [[MainViewController getMianViewShareInstance] dismissViewControllerAnimated:YES completion:^{
        self.isTakePhoto = NO;
    }];
    if (!kIsiPhone) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
}

#pragma mark PECropViewControllerDelegate

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [[MainViewController getMianViewShareInstance] dismissViewControllerAnimated:YES completion:nil];
    self.headImgFrameView.image = croppedImage;
    self.defaultHeadImgView.image = nil;
    
#ifdef DEBUG
    NSLog(@"===CropedImage:%f,%f===",croppedImage.size.width,croppedImage.size.height);
#endif
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [[MainViewController getMianViewShareInstance] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (kHeadImgUIActionSheetTag == actionSheet.tag)
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

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case kBackAlertViewTag:
        {
            if (1 == buttonIndex)
            {
                [self dismissStaffInfoView:nil];
            }
            break;
        }
        case kGenerateAccountAlertViewTag:
        {
            if (0 == buttonIndex)
            {
                [self dismissStaffInfoView:staffListDict];
            }
            break;
        }
        case kAccountUpdateAlertViewTag:
        {
            if (0 == buttonIndex)
            {
                [self dismissStaffInfoView:staffListDict];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - UITableViewController datasource & delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"staffFunctionCell";
    StaffInfoFunctionTableViewCell *cell = [[StaffInfoFunctionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSInteger indexRow = indexPath.row;
    cell.tag = indexRow;
    cell.delegate = self;

    [cell updateStaffInfoFunctionCell:[kAuthorityDataSource objectAtIndex:indexRow]];
    
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [kAuthorityDataSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"staffFunctionCell";
    StaffInfoFunctionTableViewCell *cell = [[StaffInfoFunctionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    NSInteger indexRow = indexPath.row;
    return [cell getFunctionCellHeight:[kAuthorityDataSource objectAtIndex:indexRow]];
}

#pragma mark - StaffInfoFunctionTableViewCellDelegate

- (void)staffInfoFunctionTableViewCell:(StaffInfoFunctionTableViewCell *)cell withAuthStateHavedChange:(StaffManagementAuthDataClass *)authInfo
{
    [self hideKeyboard];
    [self.functionTableView reloadData];
}

#pragma mark - UITextFidld delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.postTextField == textField)
    {
        [self downArrowBtnClicked:nil];
        return NO;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.accountTextField == textField)
    {
        if (![NSString isValidateNumber:string])
        {
            return NO;
        }
    }
    else if(self.nameTextField == textField)
    {
        if (range.location > 5)
        {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - PostStyleViewDelegate

- (void)postStyleHavedSelected:(PostStyleView *)styleView withSelectStyle:(NSString *)styleStr
{
    self.postTextField.text = styleStr;
    postIndex = styleView.styleIndex;
    [self.functionTableView reloadData];
    [self customPopoverTouchView:nil touchesBegan:nil withEvent:nil];
}

#pragma mark - CustomPopoverTouchViewDelegate

- (void)customPopoverTouchView:(UIView *)view touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:customTouchView];
    CGRect touchRect = CGRectMake(kPostStyleViewOrigin.x, kPostStyleViewOrigin.y, stylePickerView.frame.size.width, stylePickerView.frame.size.height);
    if (!CGRectContainsPoint(touchRect, touchPoint))
    {
        [stylePickerView dismissViewWithAnimated:YES];
        [customTouchView removeFromSuperview];
    }
}

#pragma mark - JsonPickerDelegate

- (void)handleFirstJsonPicker:(NSDictionary *)dict
{
    SuperDataClass *dataClass = [[SuperDataClass alloc] initWithData:dict];
    switch (dataClass.responseStatus)
    {
        case kFirstResponseStatus:
        {
            postListClass = [[StaffManagementPostSuperDataClass alloc] initWithStaffManagementPostSuperData:dataClass.dataDict];
            self.roomAccountLabel.text = postListClass.roomNumberStr;
            if ([postListClass.postListArray count])
            {
                StaffManagementPostDataClass *postClass = [postListClass.postListArray firstObject];
                self.postTextField.text = postClass.postName;
            }
            [self.functionTableView reloadData];
            
            break;
        }
        default:
        {
            [PSAlertView showWithMessage:dataClass.alertMsg];
            break;
        }
    }
}

- (void)handleSecondJsonPicker:(NSDictionary *)dict
{
    SuperDataClass *dataClass = [[SuperDataClass alloc] initWithData:dict];
    switch (dataClass.responseStatus)
    {
        case kFirstResponseStatus:
        {
            staffListDict = dataClass.dataDict;
            [self performSelector:@selector(showGenerateAccountSuccessfulAlertView) withObject:nil afterDelay:1.0];
//            [PSAlertView showWithMessage:@"保存成功"];
//            [self dismissStaffInfoView:staffListDict];
            
            break;
        }
        default:
        {
            [PSAlertView showWithMessage:dataClass.alertMsg];
            break;
        }
    }
}

- (void)handleThirdJsonPicker:(NSDictionary *)dict
{
    SuperDataClass *dataClass = [[SuperDataClass alloc] initWithData:dict];
    switch (dataClass.responseStatus)
    {
        case kFirstResponseStatus:
        {
            staffListDict = dataClass.dataDict;
            [self performSelector:@selector(showAccountUpateSuccessfulAlertView) withObject:nil afterDelay:1.0];
            
            break;
        }
        default:
        {
            [PSAlertView showWithMessage:dataClass.alertMsg];
            break;
        }
    }
}

- (void)showGenerateAccountSuccessfulAlertView
{
    NSString *titleStr = [NSString stringWithFormat:@"%@%@%@\n%@%@", kLoc(@"success_generate_account"), self.roomAccountLabel.text, self.accountTextField.text,  kLoc(@"please_remember"), self.confirmPasswordTextField.text];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:titleStr message:nil delegate:nil cancelButtonTitle:kLoc(@"confirm") otherButtonTitles: nil];
    alertView.tag = kGenerateAccountAlertViewTag;
    alertView.delegate = self;
    [alertView show];
}

- (void)showAccountUpateSuccessfulAlertView
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:kLoc(@"this_account_has_been_updated") message:nil delegate:nil cancelButtonTitle:kLoc(@"confirm") otherButtonTitles: nil];
    alertView.tag = kAccountUpdateAlertViewTag;
    alertView.delegate = self;
    [alertView show];
}

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
#ifdef DEBUG
    NSLog(@"===%s,%@===", __FUNCTION__, dict);
#endif
    switch (picker.tag)
    {
        case kJsonPickerFirstTag:
        {
            [self handleFirstJsonPicker:dict];
            
            break;
        }
        case kJsonPickerSecondTag:
        {
            [self handleSecondJsonPicker:dict];
            
            break;
        }
        case kJsonPickerThirdTag:
        {
            [self handleThirdJsonPicker:dict];
            
            break;
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
