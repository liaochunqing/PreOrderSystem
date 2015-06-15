    //
//  OfflineManager.m
//  Ordering
//
//  Created by USER on 11-6-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OfflineManager.h"


#include <sys/xattr.h>

#include <sys/stat.h>
#include <sys/mount.h>
#import "Constants.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "StaffManagementSuperDataClass.h"

#define kCurrencysymbol @"currencySymbol"
#define kBranchShopData @"branchShop"

@implementation OfflineManager


-(float)getFreeDiskspace {
    float totalSpace = 0.0f;
    float totalFreeSpace = 0.0f;
    NSError *error = nil;  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];  
    
    if (dictionary) {  
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];  
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = ([fileSystemSizeInBytes floatValue]/1024.0f)/1024.0f;
        totalFreeSpace = ([freeFileSystemSizeInBytes floatValue]/1024.0f)/1024.0f;
#ifdef DEBUG
        
        NSLog(@"Memory Capacity of %f MiB with %f MiB Free memory available.", totalSpace, totalFreeSpace);
#endif
    }
    else
    {
        //NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %d", [error domain], [error code]);  
    }
    return totalFreeSpace;
}
       

//不保存到iCloud
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL{
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}


-(NSString *)photosDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"/Photos"];
    [self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:filePath]];
	return filePath;
}

//附件录音的目录
-(NSString *)attachRecordsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"/attachRecords"];
    [self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:filePath]];
	return filePath;
}


//提醒录音的目录
-(NSString *)remindRecordsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"/remindRecords"];
    [self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:filePath]];
	return filePath;
}


//存储己下载的录音文件的目录
-(NSString *)downloadedRecordsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"/downloadedRecords"];
    [self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:filePath]];
	return filePath;
}


+ (OfflineManager *)sharedOfflineManager
{
    static OfflineManager *sharedOfflineManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedOfflineManager){
            sharedOfflineManager = [[OfflineManager alloc] init];
        }
    });
    return sharedOfflineManager;
}


-(id)init{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //创建保存离线图片的文件夹
    NSString *photosDirectory = [self photosDirectory];
    if (![fileMgr fileExistsAtPath:photosDirectory]) {
        [fileMgr createDirectoryAtPath:photosDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }
	return self;
}



#pragma mark PUBLIC METHODS
//保存用于离线的图片
-(BOOL)saveOfflinePhoto:(UIImage *)image andPhotoFileName:(NSString *)filename{
	NSString *photosDirectory = [self photosDirectory];
	NSString *filepath = [photosDirectory stringByAppendingPathComponent:filename];
    
	if (![[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
		NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
		if ([imageData writeToFile:filepath atomically:YES]) {
			return YES;
		}
	}
	return NO;
}


//判断某图片是否己存在或己下载
-(BOOL)isOfflinePhotoExistWithFileName:(NSString *)filename{
    NSString *photosDirectory = [self photosDirectory];
	NSString *filePath = [photosDirectory stringByAppendingPathComponent:filename];
    
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return YES;
	}
	return NO;
}


//读取离线的图片
- (UIImage *)offlinePhotoWithFileName:(NSString *)filename{
	NSString *photosDirectory = [self photosDirectory];
	NSString *filePath = [photosDirectory stringByAppendingPathComponent:filename];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [UIImage imageWithContentsOfFile:filePath];
	}
	return nil;
}



- (UIImage *)offlinePhotoWithFileName:(NSString *)filename toSize:(CGSize)size{
	NSString *photosDirectory = [self photosDirectory];
	NSString *filePath = [photosDirectory stringByAppendingPathComponent:filename];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		UIImage *originalImage = [UIImage imageWithContentsOfFile:filePath];
		return [originalImage scaleToSize:size];
	}
	return nil;
}


//默认图片
-(UIImage *)offlinePhotoDefaultImage{
	UIImage *photoImage = [UIImage imageFromMainBundleFile:@"search_failure.png"];
	return photoImage;
}



//保存用于离线的录音
-(BOOL)saveOfflineRecord:(NSData *)audio andFileName:(NSString *)filename{
    NSString *downloadedRecordsDirectory = [self downloadedRecordsDirectory];
	NSString *filepath = [downloadedRecordsDirectory stringByAppendingPathComponent:filename];
    
	if (![[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
		if ([audio writeToFile:filepath atomically:YES]) {
			return YES;
		}
	}
	return NO;
}

//清空所有离线的图片
-(void)eraseOfflinePhotos
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
    HUD.delegate = self;
    [[[UIApplication sharedApplication] keyWindow] addSubview:HUD];
    HUD.labelText = kLoc(@"clearing_please_wait");
    [HUD show:YES];
	[self performSelector:@selector(eraseOfflinePhotosInBackground:) withObject:HUD afterDelay:3.0];
}

//后台清空图片
-(void)eraseOfflinePhotosInBackground:(MBProgressHUD *)Hud
{
    NSString *photosDirectory = [self photosDirectory];
    if (photosDirectory)
    {
        NSString *tempStr = nil;
        if ([[NSFileManager defaultManager] removeItemAtPath:photosDirectory error:nil])
        {
            tempStr = kLoc(@"clear_succeed");
        }
        else
        {
            tempStr = kLoc(@"clear_failed");
        }
        Hud.mode = MBProgressHUDModeCustomView;
        Hud.labelText = tempStr;
        [Hud hide:YES afterDelay:2.0];
    }
    //创建Photos文件夹
    [[NSFileManager defaultManager] createDirectoryAtPath:photosDirectory withIntermediateDirectories:YES attributes:nil error:nil];
}

#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[hud removeFromSuperview];
	hud = nil;
}

-(NSArray*)cycleRemindTimesList{
    NSArray *array = [[NSArray alloc] initWithObjects:
                      [NSDictionary dictionaryWithObjectsAndKeys:kLoc(@"10 minutes"), @"name", [NSNumber numberWithInt:600], @"seconds", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:kLoc(@"15 minutes"), @"name", [NSNumber numberWithInt:900], @"seconds", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:kLoc(@"30 minutes"), @"name",  [NSNumber numberWithInt:1800], @"seconds", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:kLoc(@"1 hour"), @"name", [NSNumber numberWithInt:3600], @"seconds", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:kLoc(@"3 hours"), @"name", [NSNumber numberWithInt:10800], @"seconds", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:kLoc(@"6 hours"), @"name",  [NSNumber numberWithInt:21600], @"seconds", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:kLoc(@"1 day"), @"name",  [NSNumber numberWithInt:86400], @"seconds", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:kLoc(@"1 week"), @"name",  [NSNumber numberWithInt:604800], @"seconds", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:kLoc(@"1 month"), @"name",  [NSNumber numberWithInt:18144000],@"seconds", nil], nil];
    return array;
}


-(void)saveOfflineDishes:(NSArray*)dishes withUpdatedDate:(NSString*)date{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:dishes forKey:kDishesList];
    [pref setObject:date forKey:kDiningTableAndDishesLastUpdatedDate];
    [pref synchronize];
}

-(void)saveOfflineAccountInfo:(NSDictionary *)dictionary {
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:dictionary forKey:kAccountInfo];
    [pref synchronize];
}

-(NSDictionary *)getOfflineAccountInfo
{
    NSUserDefaults *info = [NSUserDefaults standardUserDefaults];
    return [info objectForKey:kAccountInfo];
}

-(void)clearOfflineAccountInfo
{
    NSDictionary *dict = [[NSDictionary alloc]init];
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:dict forKey:kAccountInfo];
    [pref synchronize];
}

-(void)saveOfflineBusinessHours:(NSArray*)businessHours {
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:businessHours forKey:kBusinessHours];
    [pref synchronize];
}

-(NSArray*)OfflineBusinessHours {
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    return [pref objectForKey:kBusinessHours];
}

-(void)saveOfflineDinningTable:(NSArray*)dt withUpdatedDate:(NSDate*)date{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:dt forKey:kDiningTableList];
    [pref synchronize];
}

-(NSArray*)offlineDishes{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSArray *dishes = [pref objectForKey:kDishesList];
    if (dishes==nil || [dishes count]==0) {
        return nil;
    }
    return dishes;
}


-(void)saveOfflineMemos:(NSArray*)memo withUpdatedDate:(NSString*)date{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:memo forKey:kMemosList];
    //[pref setObject:date forKey:kDiningTableAndDishesLastUpdatedDate];
    [pref synchronize];
}


-(NSArray*)offlineMemos{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSArray *memos = [pref objectForKey:kMemosList];
    if (memos==nil || [memos count]==0) {
        return nil;
    }
    return memos;
}

-(NSString*)data_LastUpdatedDate{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString *date = [pref objectForKey:kDiningTableAndDishesLastUpdatedDate];
    if (date==nil || [date length]==0) {
        return nil;
    }
    return date;
}

-(void)saveRuleLimitTitles:(NSArray*)titles{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:titles forKey:kRuleLimitTitleList];
    [pref synchronize];
}


-(NSArray*)ruleLimitTitles{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSArray *titles = [pref objectForKey:kRuleLimitTitleList];
    if (titles==nil || [titles count]==0) {
        return nil;
    }
    return titles;
}

- (void)saveAccountAuthority:(NSArray *)array{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:array forKey:kAccountAuthority];
    [pref synchronize];
}


- (NSArray *)getAccountAuthority{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSArray *dict = [pref objectForKey:kAccountAuthority];
    if (dict==nil || [dict count]==0) {
        return nil;
    }
    return dict;
}

- (void)saveCurrencySymbol:(NSString *)symbol{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:symbol forKey:kCurrencysymbol];
    [pref synchronize];
}

- (NSString *)getCurrencySymbol{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString *symbol = [pref objectForKey:kCurrencysymbol];
    if (!symbol){
        return @"";
    }
    return symbol;
}

- (void)saveBranchShopData:(NSArray *)array{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:array forKey:kBranchShopData];
    [pref synchronize];
}

- (NSArray *)fetchBranchShopData{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSArray *array = [pref objectForKey:kBranchShopData];
    return array;
}

- (void)saveDefaultOrderFilterDateData:(NSArray *)array
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:array forKey:@"defaultOrderFilterDate"];
    [pref synchronize];
}

- (NSDictionary *)fetchDefaultOrderFilterDateData
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [pref objectForKey:@"defaultOrderFilterDate"];
    return dict;
}

@end
