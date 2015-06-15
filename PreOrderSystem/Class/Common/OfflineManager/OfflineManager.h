//
//  OfflineManager.h
//  Ordering
//
//  Created by USER on 11-6-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageAddOn.h"
#import "MBProgressHUD.h"


@interface OfflineManager : NSObject<MBProgressHUDDelegate>
{
	
}


//Singleton
+ (OfflineManager *)sharedOfflineManager;

//初始化*/
-(id)init;

//获取设备的剩余存储空间(单位为MB)
-(float)getFreeDiskspace;

//判断某图片是否己存在或己下载
-(BOOL)isOfflinePhotoExistWithFileName:(NSString *)filename;
//读取离线的图片
- (UIImage *)offlinePhotoWithFileName:(NSString *)filename;
//保存离线的图片
-(BOOL)saveOfflinePhoto:(UIImage *)image andPhotoFileName:(NSString *)filename;

-(void)saveOfflineDishes:(NSArray*)dishes withUpdatedDate:(NSString*)date;
-(NSArray*)offlineDishes;
//用户基本信息
-(void)saveOfflineAccountInfo:(NSDictionary *)dictionary;
-(NSDictionary *)getOfflineAccountInfo;
-(void)clearOfflineAccountInfo;
// 保存订座，外卖默认查询时间
-(void) saveDefaultOrderFilterDateData:(NSDictionary*) dict;
- (NSDictionary *)fetchDefaultOrderFilterDateData;
//保存营业时间
-(void)saveOfflineBusinessHours:(NSArray*)businessHours;
-(NSArray*)OfflineBusinessHours;

-(void)saveOfflineDinningTable:(NSArray*)dt withUpdatedDate:(NSString*)date;

//最近一次更新数据（房台数据及菜单数据）的时间（格式如：2012-06-08 15:30）
-(NSString*)data_LastUpdatedDate;

-(void)saveRuleLimitTitles:(NSArray*)titles;
-(NSArray*)ruleLimitTitles;

//保存用户权限
- (void)saveAccountAuthority:(NSArray *)array;
- (NSArray *)getAccountAuthority;

/**
 * 货币符号
 */
- (void)saveCurrencySymbol:(NSString *)symbol;
- (NSString *)getCurrencySymbol;

/**
 * 连锁店信息
 */
- (void)saveBranchShopData:(NSArray *)array;
- (NSArray *)fetchBranchShopData;

-(void)saveOfflineMemos:(NSArray*)memo withUpdatedDate:(NSString*)date;
-(NSArray*)offlineMemos;

//读取离线的餐厅图片
//-(UIImage *)offlinePhotoWithFileName:(NSString *)filename;
//读取离线的餐厅图片，以size为大小输出
-(UIImage *)offlinePhotoWithFileName:(NSString *)filename toSize:(CGSize)size;
//默认图片
-(UIImage *)offlinePhotoDefaultImage;

//清空所有离线的图片
-(void)eraseOfflinePhotos;


@end
