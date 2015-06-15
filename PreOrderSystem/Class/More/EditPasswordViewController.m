//
//  EditPasswordViewController.m
//  PreOrderSystem
//
//  Created by sWen on 12-10-24.
//
//

#import "EditPasswordViewController.h"
#import "JsonPicker.h"
#import "Constants.h"
#import "OfflineManager.h"

@interface EditPasswordViewController ()<UITextFieldDelegate, JsonPickerDelegate>
{
    JsonPicker *jsonPicker;
}
@property (weak, nonatomic) IBOutlet UILabel *nameTitleLabel;

@property (nonatomic, weak) IBOutlet UILabel *dtNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *oldPasswordLabel;
@property (nonatomic, weak) IBOutlet UILabel *freshPasswordLabel;
@property (nonatomic, weak) IBOutlet UILabel *trueNewPasswordLabel;
@property (nonatomic, weak) IBOutlet UITextField *oldPasswordTextField;
@property (nonatomic, weak) IBOutlet UITextField *freshPasswordTextField;
@property (nonatomic, weak) IBOutlet UITextField *trueNewPasswordTextField;
@property (nonatomic, weak) IBOutlet UIButton *quitButton;
@property (nonatomic, weak) IBOutlet UIButton *trueButton;
@property (nonatomic, weak) IBOutlet UIScrollView *editPassScrollView;

- (IBAction)quitButtonPressed:(id)sender;
- (IBAction)trueButtonPressed:(id)sender;
- (IBAction)nextByTextField:(UITextField*)textField;
- (void)modifyPassword;

@end

@implementation EditPasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addLocalizedString];
    
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    self.dtNameLabel.text = [[[offlineMgr getOfflineAccountInfo] objectForKey:@"data"]objectForKey:@"name"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.oldPasswordTextField.text = @"";
    self.freshPasswordTextField.text = @"";
    self.trueNewPasswordTextField.text = @"";
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.editPassScrollView setContentOffset:CGPointZero animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    jsonPicker = nil;
    
#ifdef DEBUG
    NSLog(@"===EditPasswordViewController,viewDidUnload===");
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationMaskLandscape;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===EditPasswordViewController,dealloc===");
#endif
}

- (void)addLocalizedString
{
    self.nameTitleLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"restaurant_name")];
    self.oldPasswordLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"origin_password")];
    self.freshPasswordLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"new_password")];
    self.trueNewPasswordLabel.text = [NSString stringWithFormat:@"%@ ：",kLoc(@"confirm_password")];
    self.oldPasswordTextField.placeholder = kLoc(@"please_enter");
    self.freshPasswordTextField.placeholder = kLoc(@"at_least_six");
    self.trueNewPasswordTextField.placeholder = kLoc(@"please_enter_password_again");
    [self.quitButton setTitle:kLoc(@"cancel") forState:UIControlStateNormal];
    [self.trueButton setTitle:kLoc(@"confirm") forState:UIControlStateNormal];
}

#pragma mark - UIButton Clicked

- (IBAction)quitButtonPressed:(id)sender
{
    [self.oldPasswordTextField resignFirstResponder];
    [self.freshPasswordTextField resignFirstResponder];
    [self.trueNewPasswordTextField resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(EditPasswordViewController:didDismissView:)])
    {
        [self.delegate EditPasswordViewController:self didDismissView:YES];
    }
}

- (IBAction)trueButtonPressed:(id)sender
{
    [self.oldPasswordTextField resignFirstResponder];
    [self.freshPasswordTextField resignFirstResponder];
    [self.trueNewPasswordTextField resignFirstResponder];
    
    [self modifyPassword];
}

- (IBAction)nextByTextField:(UITextField*)textField
{
    if (textField == self.oldPasswordTextField)
    {
        [self.freshPasswordTextField becomeFirstResponder];
        return;
    }
    if (textField == self.freshPasswordTextField)
    {
        [self.trueNewPasswordTextField becomeFirstResponder];
        return;
    }
    if (textField == self.trueNewPasswordTextField)
    {
        [self.trueNewPasswordTextField resignFirstResponder];
        return;
    }
}

#pragma mark - network

//修改密码
-(void)modifyPassword
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.loadingMessage = kLoc(@"submitting_data_please_wait");
    jsonPicker.loadedSuccessfulMessage =  kLoc(@"modify_password_succeed");
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:self.oldPasswordTextField.text forKey:@"password"];
    [postData setObject:self.freshPasswordTextField.text forKey:@"password1"];
    [postData setObject:self.trueNewPasswordTextField.text forKey:@"password2"];
    [jsonPicker postData:postData withBaseRequest:@"CorpUpdatePassword"];
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
                [self quitButtonPressed:nil];
                break;
            }
            default:
            {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:[dict objectForKey:@"desc"] delegate:nil cancelButtonTitle:kLoc(@"confirm") otherButtonTitles:nil, nil];
                [alertView show];
                
                
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

#pragma mark UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
     
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
     
}

@end
