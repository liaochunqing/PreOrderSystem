//
//  PostManagementViewController.m
//  PreOrderSystem
//
//  Created by sWen on 13-5-15.
//
//

#import "PostManagementViewController.h"
#import "PostTableViewCell.h"
#import "PostAuthorityTableViewCell.h"
#import "Constants.h"
#import "PSAlertView.h"
#import "JsonPicker.h"
#import "SuperDataClass.h"
#import "StaffManagementSuperDataClass.h"
#import "NsstringAddOn.h"
#import "StaffManagementAlertView.h"


typedef enum
{
    kModifyAlertViewTag = 1000,
    kDeleteAlertViewTag,
    kAddAlertViewTag
}kAlertViewTag;

@interface PostManagementViewController ()<UITableViewDelegate, UITableViewDataSource, JsonPickerDelegate, PostAuthorityTableViewCellDelegate, PostTableViewCellDelegate, UIAlertViewDelegate>
{
    JsonPicker *jsonPicker;
    StaffManagementPostSuperDataClass *postListClass;
    NSInteger selectIndexOfPost;
    NSMutableArray *deletePostArray;
}

@property (nonatomic, weak) IBOutlet UITableView *postTableView;
@property (nonatomic, weak) IBOutlet UITableView *authorityTableView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UIImageView *postBgImageView;
@property (nonatomic, weak) IBOutlet UIButton *addPostButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;

- (IBAction)cancelBtnClicked:(UIButton*)sender;
- (IBAction)doneBtnClicked:(UIButton*)sender;
- (IBAction)addPostBtnClicked:(UIButton*)sender;

@end

@implementation PostManagementViewController

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
    [self addLocalizedString];
    [self addNotifications];
    selectIndexOfPost = 0;
    
    //避免视图遮住MBProgressHUD
    [self performSelector:@selector(getPostListData) withObject:nil afterDelay:0.5];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self removeNotification];
}

- (void)dealloc
{
    [self removeNotification];
#ifdef DEBUG
    NSLog(@"===%s===", __FUNCTION__);
#endif
}

- (void)addPictureToView
{
    self.bgImageView.image = LoadImageWithPNGType(@"more_posteEditBg");
    self.postBgImageView.image = LoadImageWithPNGType(@"more_postListBg");
    [self.addPostButton setBackgroundImage:LoadImageWithPNGType(@"more_addPostBg") forState:UIControlStateNormal];
}

- (void)addLocalizedString
{
    self.titleLabel.text = kLoc(@"position_management");
    [self.addPostButton setTitle:kLoc(@"add_the_position") forState:UIControlStateNormal];
}

- (void)dismissPostManagementView:(NSNumber *)updateFlag
{
    if ([self.delegate respondsToSelector:@selector(dismissPostManagementViewController:withUpdateStaffListFlag:)])
    {
        [self.delegate dismissPostManagementViewController:self withUpdateStaffListFlag:[updateFlag boolValue]];
    }
}

- (StaffManagementPostDataClass *)getPostDataClass
{
    StaffManagementPostDataClass *postClass = nil;
    if (selectIndexOfPost < [postListClass.postListArray count])
    {
        postClass = [postListClass.postListArray objectAtIndex:selectIndexOfPost];
    }
    return postClass;
}

#pragma mark - UIButton clicked

- (IBAction)cancelBtnClicked:(UIButton*)sender
{
    [self dismissPostManagementView:[NSNumber numberWithBool:NO]];
}

- (IBAction)doneBtnClicked:(UIButton*)sender
{
    [self savePostListData];
}

- (IBAction)addPostBtnClicked:(UIButton*)sender
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:kLoc(@"add_the_position") message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:kLoc(@"confirm"), kLoc(@"cancel"), nil];
    alertView.tag = kAddAlertViewTag;
    alertView.delegate = self;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].text = @"";
    [alertView show];
}

#pragma mark - network

- (void)getPostListData
{
    if (!jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [jsonPicker postData:postData withBaseRequest:@"group/getlist"];
}

- (void)savePostListData
{
    NSArray *listArray = [self getSubmitArguments];
//    if (![listArray count])
//    {
//        return;
//    }
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    
    if (listArray.count > 0)
    {
        [postData setObject:listArray forKey:@"list"];
    }
    
    if (!jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerSecondTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"saving_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:postData withBaseRequest:@"group/save"];
    
#ifdef DEBUG
    NSLog(@"===%s,postData:%@===", __FUNCTION__, postData);
#endif
}

- (NSMutableArray *)getSubmitArguments
{
//    BOOL isEmpty = NO;
    NSMutableArray *listArray = [[NSMutableArray alloc] init];
    for (StaffManagementPostDataClass *postClass in postListClass.postListArray)
    {
        NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
        [postDict setObject:postClass.postIdStr forKey:@"id"];
        [postDict setObject:postClass.postName forKey:@"name"];
        NSArray *authArray = [self getOpenSubAuthIdArray:postClass.authArray];
//        if (![authArray count])
//        {
//            isEmpty = YES;
//            break;
//        }
        [postDict setObject:authArray forKey:@"auth"];
        [listArray addObject:postDict];
    }
//    if (isEmpty)
//    {
//        [PSAlertView showWithMessage:kLoc(@"至少勾选一项权限", nil)];
//        return nil;
//    }
    
    for (StaffManagementPostDataClass *postClass in deletePostArray)
    {
        NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
        [postDict setObject:postClass.postIdStr forKey:@"id"];
        [postDict setObject:postClass.postName forKey:@"name"];
        [postDict setObject:[self getOpenSubAuthIdArray:postClass.authArray] forKey:@"auth"];
        [listArray addObject:postDict];
    }
    return listArray;
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

#pragma mark - Notifications

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

- (void)keyboardWillShow:(NSNotification*)notify
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
    self.authorityTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset  - 120,0.0f);
    self.authorityTableView.scrollEnabled = NO;
    
    [UIView commitAnimations];
    
#ifdef DEBUG
    NSLog(@"===%@,keyboardWillShow:%@",self.class,NSStringFromCGRect(keyboardRect));
#endif
}

- (void)keyboardWillHide:(NSNotification*)notify
{
    NSDictionary *userInfo = [notify userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    self.authorityTableView.scrollEnabled = YES;
    self.authorityTableView.contentInset = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (kZeroNumber == buttonIndex)
    {
        const NSInteger maxLen = 6;
        switch (alertView.tag)
        {
            case kModifyAlertViewTag:
            {
                NSInteger postIndex = ((StaffManagementAlertView *)alertView).postIndex;
                if (postIndex < [postListClass.postListArray count])
                {
                    StaffManagementPostDataClass *postClass = [postListClass.postListArray objectAtIndex:postIndex];
                    NSString *postName = nil;
                    NSString *alertText = [alertView textFieldAtIndex:kZeroNumber].text;
                    if ([alertText length] > maxLen)
                    {
                        postName = [NSString cutString:alertText withMaxLengthOfStr:maxLen];
                        [PSAlertView showWithMessage:kLoc(@"positon_name_up_to_six_words")];
                    }
                    else
                    {
                        postName = alertText;
                    }
                    if ([NSString strIsEmpty:postName])
                    {
                        [PSAlertView showWithMessage:kLoc(@"position_name_cannot_be_empty")];
                    }
                    else
                    {
                        postClass.postName = postName;
                        [self.postTableView reloadData];
                    }
                }
                
                break;
            }
            case kDeleteAlertViewTag:
            {
                NSInteger postIndex = ((StaffManagementAlertView *)alertView).postIndex;
                if (postIndex < [postListClass.postListArray count])
                {
                    if (!deletePostArray)
                    {
                        deletePostArray = [[NSMutableArray alloc] init];
                    }
                    StaffManagementPostDataClass *postClass = [postListClass.postListArray objectAtIndex:postIndex];
                    postClass.postName = @"";
                    [deletePostArray addObject:postClass];
                    [postListClass.postListArray removeObjectAtIndex:postIndex];
                    if (postIndex > kZeroNumber)
                    {
                        selectIndexOfPost = [postListClass.postListArray count] - 1;
                        if (selectIndexOfPost < kZeroNumber)
                        {
                            selectIndexOfPost = kZeroNumber;
                        }
                    }
                    [self.postTableView reloadData];
                    [self.authorityTableView reloadData];
                }
                
                break;
            }
            case kAddAlertViewTag:
            {
                NSString *postName = nil;
                NSString *alertText = [alertView textFieldAtIndex:kZeroNumber].text;
                if ([alertText length] > maxLen)
                {
                    postName = [NSString cutString:alertText withMaxLengthOfStr:maxLen];
                    [PSAlertView showWithMessage:kLoc(@"positon_name_up_to_six_words")];
                }
                else
                {
                    postName = alertText;
                }
                if ([NSString strIsEmpty:postName])
                {
                    [PSAlertView showWithMessage:kLoc(@"position_name_cannot_be_empty")];
                }
                else
                {
                    BOOL isSame = NO;
                    for (StaffManagementPostDataClass *postClass in postListClass.postListArray)
                    {
                        if ([postName isEqualToString:postClass.postName])
                        {
                            isSame = YES;
                            break;
                        }
                    }
                    if (isSame)
                    {
                        [PSAlertView showWithMessage:kLoc(@"duplicate_position")];
                    }
                    else
                    {
                        StaffManagementPostDataClass *newPostClass = [[StaffManagementPostDataClass alloc] initWithPostClass:postListClass.samplePostClass];
                        newPostClass.postName = postName;
                        [postListClass.postListArray addObject:newPostClass];
                        selectIndexOfPost = [postListClass.postListArray count] - 1;
                        if (selectIndexOfPost < kZeroNumber)
                        {
                            selectIndexOfPost = kZeroNumber;
                        }
                        [self.postTableView reloadData];
                        [self.authorityTableView reloadData];
                    }
                }
                
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int indexRow = indexPath.row;
    if (self.postTableView == tableView)
    {
        static NSString *cellIdentifier = kPostTableViewCellIdentifier;
        PostTableViewCell * cell = (PostTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"PostTableViewCell" owner:self options:nil]lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        cell.tag = indexRow;
        
        if (indexRow < [postListClass.postListArray count])
        {
            BOOL flag = NO;
            if (selectIndexOfPost >= 0 && selectIndexOfPost == indexRow)
            {
                flag = YES;
            }
            StaffManagementPostDataClass *postClass = [postListClass.postListArray objectAtIndex:indexRow];
            [cell updatePostTableViewCell:postClass.postName withSelected:flag];
        }
        
        return cell;
    }
    else
    {
        static NSString *cellIdentifier = @"postAuthorityTableViewCell";
        PostAuthorityTableViewCell * cell = [[PostAuthorityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = indexRow;
        cell.delegate = self;
        
        [cell updatePostAuthorityCell:[[self getPostDataClass].authArray objectAtIndex:indexRow]];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 40;
    if (self.postTableView == tableView)
    {
        height = kPostTableViewCellHeight;
    }
    if (self.authorityTableView == tableView)
    {
        static NSString *cellIdentifier = @"postAuthorityTableViewCell";
        PostAuthorityTableViewCell *cell = [[PostAuthorityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        NSInteger indexRow = indexPath.row;
        height = [cell getPostAuthorityCellHeight:[[self getPostDataClass].authArray objectAtIndex:indexRow]];
    }
	return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = 0;
    if (self.postTableView == tableView)
    {
        number = [postListClass.postListArray count];
    }
    if (self.authorityTableView == tableView)
    {
        number = [[self getPostDataClass].authArray count];
    }
    
    return number;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.postTableView == tableView)
    {
        selectIndexOfPost = indexPath.row;
    }
    [self.postTableView reloadData];
    [self.authorityTableView reloadData];
}

#pragma mark - PostTableViewCellDelegate

- (void)postTableViewCell:(PostTableViewCell *)cell withDeleteIndex:(NSInteger)index
{
    StaffManagementAlertView *alertView = [[StaffManagementAlertView alloc]initWithTitle:kLoc(@"are_you_sure_delete_position") message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:kLoc(@"confirm"), kLoc(@"cancel"), nil];
    alertView.tag = kDeleteAlertViewTag;
    alertView.postIndex = index;
    alertView.delegate = self;
    [alertView show];
}

- (void)postTableViewCell:(PostTableViewCell *)cell withModifyPostName:(NSString *)postName
{
    StaffManagementAlertView *alertView = [[StaffManagementAlertView alloc]initWithTitle:kLoc(@"rename_the_position") message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:kLoc(@"confirm"), kLoc(@"cancel"), nil];
    alertView.tag = kModifyAlertViewTag;
    alertView.postIndex = cell.tag;
    alertView.delegate = self;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:kZeroNumber].text = postName;
    [alertView show];
}

#pragma mark - PostAuthorityTableViewCell delegate

- (void)postAuthorityTableViewCell:(PostAuthorityTableViewCell *)cell withAuthStateHavedChange:(StaffManagementAuthDataClass *)authInfo
{
    [self.authorityTableView reloadData];
}


#pragma mark - JsonPickerDelegate

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
#ifdef DEBUG
    NSLog(@"===PostManagementViewController,dict:%@====",dict);
#endif
    SuperDataClass *dataClass = [[SuperDataClass alloc] initWithData:dict];
    NSInteger responseStatus = dataClass.responseStatus;
    
    if (kJsonPickerFirstTag == picker.tag)
    {
        switch (responseStatus)
        {
            case kFirstResponseStatus:
            {
                postListClass = [[StaffManagementPostSuperDataClass alloc] initWithStaffManagementPostSuperData:dataClass.dataDict];
                [self.authorityTableView reloadData];
                [self.postTableView reloadData];
                
                break;
            }
            default:
            {
                [PSAlertView showWithMessage:dataClass.alertMsg];
                break;
            }
        }
    }
    else if (kJsonPickerSecondTag == picker.tag)
    {
        switch (responseStatus)
        {
                //保存成功
            case kFirstResponseStatus:
            {
                [PSAlertView showWithMessage:dataClass.alertMsg];
                [self performSelector:@selector(dismissPostManagementView:)
                           withObject:[NSNumber numberWithBool:YES]
                           afterDelay:2.0];
                
                break;
            }
                //保存失败
            default:
            {
                [PSAlertView showWithMessage:dataClass.alertMsg];
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
