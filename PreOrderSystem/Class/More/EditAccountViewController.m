//
//  EditAccountViewController.m
//  PreOrderSystem
//
//  Created by sWen on 12-10-24.
//
//

#import "EditAccountViewController.h"
#import "OfflineManager.h"
#import "Constants.h"
#import "PSAlertView.h"
#import "UITextFieldAddition.h"

@interface EditAccountViewController ()<UITextFieldDelegate, JsonPickerDelegate>
{
    JsonPicker *jsonPicker;
}

@property (nonatomic, weak)IBOutlet UIScrollView *accountScrollView;
@property (nonatomic, weak)IBOutlet UILabel *nameLabel;
@property (nonatomic, weak)IBOutlet UILabel *phoneLabel;
@property (nonatomic, weak)IBOutlet UILabel *contactsLabel;
@property (nonatomic, weak)IBOutlet UILabel *addressLabel;
@property (nonatomic, weak)IBOutlet UILabel *emailLabel;
@property (nonatomic, weak)IBOutlet UILabel *nameDetailLabel;
@property (nonatomic, weak)IBOutlet UITextField *phoneDetailTextField;
@property (nonatomic, weak)IBOutlet UITextField *contactsDetailTextField;
@property (nonatomic, weak)IBOutlet UITextView *addressDetailTextView;
@property (nonatomic, weak)IBOutlet UITextField *emailDetailTextField;
@property (nonatomic, weak)IBOutlet UIButton *quitButton;
@property (nonatomic, weak)IBOutlet UIButton *trueButton;

- (IBAction)quitButtonPressed:(id)sender;
- (IBAction)trueButtonPressed:(id)sender;
- (IBAction)nextByTextField:(UITextField*)textField;
- (void)refreshView:(NSDictionary *)accountDictionary;
- (void)modifyAccountInfomation;

@end

@implementation EditAccountViewController
@synthesize accountScrollView;
@synthesize nameLabel,phoneLabel,contactsLabel,addressLabel,emailLabel,nameDetailLabel;
@synthesize phoneDetailTextField,addressDetailTextView,contactsDetailTextField,emailDetailTextField;
@synthesize quitButton,trueButton;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 添加关闭按钮
    [self.phoneDetailTextField bindCloseButton];
    
    [self addLocalizedString];
    [self addNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    [self refreshView:[offlineMgr getOfflineAccountInfo]];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:kLoc(@"more_account_management") forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [accountScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self removeNotification];
    jsonPicker = nil;
    
#ifdef DEBUG
    NSLog(@"===EditAccountViewController,viewDidUnload===");
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
    NSLog(@"===EditAccountViewController,dealloc===");
#endif
}

- (void)addLocalizedString
{
    nameLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"restaurant_name")];
    phoneLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"telephone")];
    contactsLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"contact")];
    emailLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"email")];
    addressLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"restaurant_address")];
    [self.quitButton setTitle:kLoc(@"cancel") forState:UIControlStateNormal];
    [self.trueButton setTitle:kLoc(@"confirm") forState:UIControlStateNormal];
}

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
    if ([addressDetailTextView isFirstResponder])
    {
        [accountScrollView setContentOffset:CGPointMake(0, emailDetailTextField.frame.origin.y) animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    [accountScrollView setContentOffset:CGPointZero animated:YES];
}

- (void)refreshView:(NSDictionary *)accountDictionary
{
    nameDetailLabel.text = [[accountDictionary objectForKey:@"data"]objectForKey:@"name"];
    phoneDetailTextField.text = [[accountDictionary objectForKey:@"data"]objectForKey:@"phone"];
    contactsDetailTextField.text = [[accountDictionary objectForKey:@"data"]objectForKey:@"linkMan"];
    addressDetailTextView.text = [[accountDictionary objectForKey:@"data"]objectForKey:@"address"];
    emailDetailTextField.text = [[accountDictionary objectForKey:@"data"]objectForKey:@"email"];
}

#pragma mark - UIButton Clicked

- (IBAction)quitButtonPressed:(id)sender
{
    [phoneDetailTextField resignFirstResponder];
    [contactsDetailTextField resignFirstResponder];
    [addressDetailTextView resignFirstResponder];
    [emailDetailTextField resignFirstResponder];
    if ([delegate respondsToSelector:@selector(EditAccountViewController:didDismissView:)])
    {
        [delegate EditAccountViewController:self didDismissView:YES];
    }
}

- (IBAction)trueButtonPressed:(id)sender
{
    if ([nameDetailLabel.text length]== 0 ) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:kLoc(@"the_name_of_restaurant_can_not_be_empty") delegate:nil cancelButtonTitle:kLoc(@"confirm") otherButtonTitles:nil, nil];
        [alertView show];
        
        return;
    }
    if ([phoneDetailTextField.text length]== 0 ) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:kLoc(@"phone_number_can_not_be_empty") delegate:nil cancelButtonTitle:kLoc(@"confirm") otherButtonTitles:nil, nil];
        [alertView show];
        
        return;
    }
    if ([contactsDetailTextField.text length]== 0 ) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:kLoc(@"contact_can_not_be_empty") delegate:nil cancelButtonTitle:kLoc(@"confirm") otherButtonTitles:nil, nil];
        [alertView show];
        
        return;
    }
    if ([addressDetailTextView.text length]== 0 ) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:kLoc(@"the_address_of_restaurant_can_not_be_empty") delegate:nil cancelButtonTitle:kLoc(@"confirm") otherButtonTitles:nil, nil];
        [alertView show];
        
        return;
    }
    if ([emailDetailTextField.text length]== 0 ) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:kLoc(@"email_can_not_be_empty") delegate:nil cancelButtonTitle:kLoc(@"confirm") otherButtonTitles:nil, nil];
        [alertView show];
        
        return;
    }
    
    [phoneDetailTextField resignFirstResponder];
    [contactsDetailTextField resignFirstResponder];
    [addressDetailTextView resignFirstResponder];
    [emailDetailTextField resignFirstResponder];
    
    [self modifyAccountInfomation];
}

- (IBAction)nextByTextField:(UITextField*)textField
{
    if (textField == phoneDetailTextField)
    {
        [accountScrollView setContentOffset:CGPointMake(0, textField.frame.origin.y) animated:YES];
        [contactsDetailTextField becomeFirstResponder];
        return;
    }
    if (textField == contactsDetailTextField)
    {
        [accountScrollView setContentOffset:CGPointMake(0, textField.frame.origin.y) animated:YES];
        [emailDetailTextField becomeFirstResponder];
        return;
    }
    if (textField == emailDetailTextField)
    {
        [accountScrollView setContentOffset:CGPointMake(0, textField.frame.origin.y) animated:YES];
        [addressDetailTextView becomeFirstResponder];
        return;
    }
}

#pragma mark - network

-(void)modifyAccountInfomation
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"submitting_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = kLoc(@"modify_succeed");
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:phoneDetailTextField.text forKey:@"phone"];
    [postData setObject:contactsDetailTextField.text forKey:@"linkMan"];
    [postData setObject:addressDetailTextView.text forKey:@"address"];
    [postData setObject:emailDetailTextField.text forKey:@"email"];
    [jsonPicker postData:postData withBaseRequest:@"CorpUpdateInfo"];
}

#pragma mark JsonPickerDelegate

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    if (kJsonPickerFirstTag == picker.tag)
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        switch (responseStatus)
        {
            case 200:
            {
                NSDictionary *modifyInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:nameDetailLabel.text,@"name", phoneDetailTextField.text,@"phone", contactsDetailTextField.text,@"linkMan", addressDetailTextView.text,@"address",emailDetailTextField.text,@"email", nil];
                NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:modifyInfoDict,@"data", nil];
                
                OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
                [offlineMgr saveOfflineAccountInfo:tempDict];
                
                [self refreshView:tempDict];
                [self quitButtonPressed:nil];
                
                break;
            }
            default:
            {
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

#pragma mark UITextFidld delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //[accountScrollView setContentOffset:CGPointMake(0, textField.frame.origin.y) animated:YES];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //[accountScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    return YES;
}

@end
