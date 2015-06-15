//
//  JsonPicker.h
//  AllOfCarParts
//
//  Created by AaronKwok on 12-4-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "AccountManager.h"
#import "SuperDataClass.h"

@class Reachability;

typedef enum
{
    kJsonPickerFirstTag = 1000,
    kJsonPickerSecondTag,
    kJsonPickerThirdTag,
    kJsonPickerFourthTag,
    kJsonPickerFifthTag,
    kJsonPickerSixthTag,
    kJsonPickerSevenTag,
    kJsonPickerEighthTag
}JsonPickerTag;

typedef enum
{
    kFirstResponseStatus = 200,
    kSecondResponseStatus,
    kThirdResponseStatus,
    kFourthResponseStatus,
    kFifthResponseStatus,
    kSixthResponseStatus
}kNetworkResponseStatus;

#define kSuccessfulShowTime 1.5

@class JsonPicker;
@protocol JsonPickerDelegate <NSObject>

-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict;
// JSON解释错误时返回
-(void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error;
// 网络连接失败时返回（无网络的情况）
-(void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error;

@end

@interface JsonPicker : NSObject<NSURLConnectionDataDelegate, MBProgressHUDDelegate>
{
    __weak id <JsonPickerDelegate> delegate;
    float _showSuccessfulMessageInterval;
    NSMutableData *receivedData;
    NSURLConnection *jsonConnection;
    NSTimer *timeoutTimer;
    
    MBProgressHUD *HUD;
    NSDictionary *updateDictionary;
    BOOL isUpdatedAppVersion;//是否更新过app的版本
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign, readwrite) NSInteger debug;
@property (nonatomic, assign, readwrite) NSInteger showActivityIndicator;
@property (nonatomic, strong) NSString *loadingMessage;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, assign) BOOL isShowLoginAlertView;/*在登陆页面不显示修改密码后要重新登陆的UIAlertView */
@property (nonatomic, assign) BOOL isAlwaysShowUpdateAlert;/*在关于页面点击检测更新按钮时，总是显示更新对话框*/
@property (nonatomic, assign) BOOL isShowUpdateAlert;/*订餐易版本有更新时，是否显示更新对话框*/
@property(nonatomic, strong) NSString *loadedSuccessfulMessage;
@property(nonatomic, strong) NSString *loadedFailedMessage;

//Public Methods
-(id)init;
-(void)postData:(NSDictionary *)data withBaseRequest:(NSString *)baseURL;
-(void)postData:(NSDictionary *)data withMainURL:(NSString *)mainURL withBaseRequest:(NSString *)baseURL;
-(void)postDataForError:(NSString *)errorInfo withBaseRequest:(NSString *)baseURL;
@end
