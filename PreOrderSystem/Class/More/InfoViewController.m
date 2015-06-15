//
//  InfoViewController.m
//  PreOrderSystem
//
//  Created by sWen on 12-10-18.
//
//

#import "InfoViewController.h"
#import "Constants.h"
#import "JsonPicker.h"
#import "PSAlertView.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "LocalizeManager.h"

@interface InfoViewController ()<JsonPickerDelegate, UIActionSheetDelegate>
{
    JsonPicker *jsonPicker;
    NSMutableArray *_langArray;
    NSInteger _langIndex;
    NSMutableString * _langVersion;
}

@property (nonatomic, weak)IBOutlet UIImageView *logoImageView;
@property (nonatomic, weak)IBOutlet UIImageView *systemImageView;
@property (nonatomic, weak)IBOutlet UILabel *rightLabel;
@property (nonatomic, weak)IBOutlet UILabel *phoneLabel;
@property (nonatomic, weak)IBOutlet UILabel *versonLabel;
@property (nonatomic, weak)IBOutlet UILabel *customServiceLabel;
@property (nonatomic, weak)IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIButton *langSettingButton;
- (IBAction)langSettingBtnClick:(UIButton *)sender;

- (IBAction)updateButtonPressed:(id)sender;
- (void)checkUpdateSystem;

@end

@implementation InfoViewController

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
    
    [self addLocalizedString];
    [self addPictureToView];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
#if TEST
    NSString *versionString = [NSString stringWithFormat:@"V%@ test",version];
#elif DEMO
    NSString *versionString = [NSString stringWithFormat:@"V%@ demo",version];
#else
    NSString *versionString = [NSString stringWithFormat:@"V%@",version];
#endif
    
    self.versonLabel.text = versionString;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:kLoc(@"more_about_us") forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    jsonPicker = nil;
    
#ifdef DEBUG
    NSLog(@"===InfoViewController,viewDidUnload===");
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

-(void)dealloc
{
#ifdef DEBUG
    NSLog(@"===InfoViewController,dealloc===");
#endif
}

- (void)addLocalizedString
{
    self.customServiceLabel.text = kLoc(@"service_phone");
    self.rightLabel.text = [NSString stringWithFormat:@"%@    %@",kLoc(@"yortit_software"),kLoc(@"all_rights_reserved")];
    
//    [self.updateButton setTitle:kLoc(@"检测更新", nil) forState:UIControlStateNormal];
    [self.updateButton setTitle:kLoc(@"check_version") forState:UIControlStateNormal];
    
    [self.langSettingButton setTitle:kLoc(@"language_set") forState:UIControlStateNormal];
}

- (void)addPictureToView
{
    //繁体
    if (![kCurrentLanguageOfDevice isEqualToString:kChineseFamiliarStyle])
    {
        self.logoImageView.image = [UIImage imageFromMainBundleFile:@"more_logo_traditional.png"];
        
    }
    self.systemImageView.image = kLocImage(@"more_sysTitle.png");
}

#pragma mark -- btnclick
- (IBAction)langSettingBtnClick:(UIButton *)sender
{
    [self getLangType];
}

- (IBAction)updateButtonPressed:(id)sender
{
    [self checkUpdateSystem];
}


#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
        case 1://多语言
        {
            if (buttonIndex >= 0 && buttonIndex < _langArray.count)
            {
                NSDictionary *dict = _langArray[buttonIndex];
                _langIndex = buttonIndex;
                NSString *landCode = [dict objectForKey:@"langCode"];
                [self getLangData:[[dict objectForKey:@"langId"] intValue] langCode:landCode];
            }
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark -network
-(void)getLangType
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 1;
    jsonPicker.showActivityIndicator = NO;
    jsonPicker.isShowUpdateAlert = NO;
    jsonPicker.isAlwaysShowUpdateAlert = NO;
    jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [jsonPicker postData:postData withMainURL:kDomainCommonURL withBaseRequest:@"Auto/lang"];
}

-(void)getLangData:(int) langID langCode:(NSString *)landCode
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 2;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.isShowUpdateAlert = NO;
    jsonPicker.isAlwaysShowUpdateAlert = YES;
    jsonPicker.loadingMessage = kLoc(@"fetching_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[NSNumber numberWithInt:1] forKey:@"projectId"];
    [postData setObject:[NSNumber numberWithInt:langID] forKey:@"langId"];
    //语言类型
    [postData setObject:@"yorkit_ios" forKey:@"device_type"];
    
    //语言版本号
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *langVerson = (landCode != nil) ? [defaults objectForKey:landCode] : nil;
    if (langVerson == nil) langVerson = kLangVersion;
    [postData setObject:langVerson forKey:@"langVersion"];

    //APP版本号
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSDictionary* infoDictionary =  [mainBundle infoDictionary];
    NSString *appVersion =[infoDictionary objectForKey:@"CFBundleVersion"];
    [postData setObject:appVersion forKey:@"appVersion"];

    [jsonPicker postData:postData withMainURL:kDomainCommonURL withBaseRequest:@"Auto/langData"];
    
}


-(void)checkUpdateSystem
{
    //检测更新
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 0;
    jsonPicker.showActivityIndicator = YES;
    jsonPicker.isShowUpdateAlert = YES;
    jsonPicker.isAlwaysShowUpdateAlert = YES;
    jsonPicker.loadingMessage = kLoc(@"checking_version_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [jsonPicker postData:postData withBaseRequest:@"Update"];
}

#pragma mark JsonPickerDelegate
-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    
    //检测更新
    if (picker.tag==0)
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        switch (responseStatus)
        {
            case 200:
            {
                break;
            }
            default:
            {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                break;
            }
        }
    }
    else if (picker.tag == 1)//获取语言列表
    {
        int responseStatus = [[dict objectForKey:@"responseStatus"] intValue];
        switch (responseStatus)
        {
            case 200:
            {
                _langArray = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"data"]];
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                
                for (int i = 0; i < _langArray.count; i++)
                {
                    NSString *string = [NSString stringWithFormat:@"%@" ,kLoc([_langArray[i] objectForKey:@"title"])];
                    [actionSheet addButtonWithTitle:string];
                }
                
                actionSheet.tag = 1;
                [actionSheet showFromRect:self.langSettingButton.frame inView:self.view animated:YES];
                break;
            }
            default:
            {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                break;
            }
        }
    }
    else if (picker.tag == 2)
    {
        int responseStatus = [[dict objectForKey:@"responseStatus"] intValue];
        switch (responseStatus)
        {
            case 200://更新语言包
            {
                //保存语言包
                NSDictionary *data = dict[@"data"];
                
                if (data)
                {
                    NSMutableString *allStr = [[NSMutableString alloc] init];
                    
                    NSDictionary *langDict = [data objectForKey:@"langData"];
                    for (NSString *key in langDict)
                    {
                        NSString *value = langDict[key];
                        NSString *str = [NSString stringWithFormat:@"\"%@\" = \"%@\";\n",key,value];
                        [allStr appendString:str];
                    }
                    
                    NSData *langStrData = [allStr dataUsingEncoding:NSUTF8StringEncoding];
                    NSString *langCode = [_langArray[_langIndex] objectForKey:@"langCode"];
                    NSString *langVerson = [data objectForKey:@"langVersion"];
                    
                    
                    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
                    int langNum = [[userdefault objectForKey:@"langNum"] intValue];
                    if (langNum > 0)
                    {
                        langNum++;
                    }
                    else
                    {
                        langNum = 1;
                    }
                    [userdefault setObject:[NSNumber numberWithInt:langNum] forKey:@"langNum"];
                    
                    langCode = [NSString stringWithFormat:@"%@%d",langCode,langNum];
                    [LocalizeManager saveLocalizedData:langStrData bundleName:langCode];
                    
                    [userdefault setObject:langCode forKey:kApplicationLanguageKey];
                    [userdefault setObject:langVerson forKey:langCode];
                    [userdefault synchronize];
                    
                    //通知界面更新语言
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateForLangChangedNotify object:nil userInfo:nil];
                    
                    NSArray *imageUrlArray = [data objectForKey:@"staticImageUrl"];
                    if (imageUrlArray.count > 0)
                    {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                        ^{
                            for (NSString *str in imageUrlArray)
                            {
                                NSURL *url = [NSURL URLWithString:str];
                                NSData *data = [NSData dataWithContentsOfURL:url];
                                NSArray *result = [str componentsSeparatedByString:@"/"];
                                NSString *imageName = [result lastObject];
                                [LocalizeManager saveLocalizedImageData:data bundleName:langCode andImageName:imageName];
                            }
                        });
                    }
                }
                
                break;
            }
                
            case 201://没有更新的语言包
            {
                //将选择的语言记录到本地
                NSString *langCode = [_langArray[_langIndex] objectForKey:@"langCode"];
                NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
                [userdefault setObject:langCode forKey:kApplicationLanguageKey];
                [userdefault synchronize];
                
                //通知界面更新语言
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateForLangChangedNotify object:nil userInfo:nil];
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

@end
