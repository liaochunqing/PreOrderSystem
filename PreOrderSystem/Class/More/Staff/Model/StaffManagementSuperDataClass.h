//
//  StaffManagementSuperDataClass.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-7.
//
//

#import <Foundation/Foundation.h>

#define kMainAuthorityOfDiningTableIndexStr @"diningTable"
#define kMainAuthorityOfTakeoutIndexStr @"takeout"
#define kMainAuthorityOfBookingIndexStr @"booking"
#define kMainAuthorityOfCookbookIndexStr @"cookbook"
#define kMainAuthorityOfQueueIndexStr @"queue"
#define kMainAuthorityOfCallServiceIndexStr @"callService"
#define kMainAuthorityOfMemberIndexStr @"member"
#define kMainAuthorityOfMoreIndexStr @"more"

@interface StaffManagementSuperDataClass : NSObject

@property (nonatomic, strong) NSMutableArray *postArray;//职位列表
@property (nonatomic, strong) NSMutableArray *staffListArray;//员工列表
@property (nonatomic, strong) NSArray *sortArray;//排序

- (id)initWithStaffManagementSuperData:(NSDictionary *)dict;

@end

#pragma mark - StaffManagementSortDataClass

@class StaffManagementSortDataClass;
@interface StaffManagementSortDataClass : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *valueStr;

- (id)initWithStaffManagementSortData:(NSDictionary *)dict;

@end

#pragma mark - StaffManagementPostSuperDataClass

@class StaffManagementPostDataClass;
@interface StaffManagementPostSuperDataClass : NSObject

@property (nonatomic, strong) NSMutableArray *postListArray;
@property (nonatomic, strong) StaffManagementPostDataClass *samplePostClass;
@property (nonatomic, strong) NSString *roomNumberStr;//餐厅帐号

- (id)initWithStaffManagementPostSuperData:(NSDictionary *)dict;

@end

#pragma mark - StaffManagementPostDataClass

@interface StaffManagementPostDataClass : NSObject

@property (nonatomic, strong) NSString *postIdStr;//职位id
@property (nonatomic, strong) NSString *postName;//职位id
@property (nonatomic, strong) NSMutableArray *authArray;//权限

- (id)initWithStaffManagementPostData:(NSDictionary *)dict;
- (id)initWithPostClass:(StaffManagementPostDataClass *)postClass;

@end

#pragma mark - StaffManagementStaffInfoDataClass

@interface StaffManagementStaffInfoDataClass : NSObject

@property (nonatomic, strong) NSString *staffIdStr;//员工id
@property (nonatomic, strong) NSString *numberStr;//员工帐号
@property (nonatomic, strong) NSString *postIdStr;//职位id
@property (nonatomic, strong) NSString *postName;//职位id
@property (nonatomic, strong) NSString *roomNumberStr;//餐厅帐号
@property (nonatomic, strong) NSString *name;//员工名
@property (nonatomic, strong) NSString *pictureURL;//图片
@property (nonatomic, strong) NSString *passwordStr;//密码
@property (nonatomic, strong) NSMutableArray *authArray;//权限

- (id)initWithStaffManagementStaffInfoData:(NSDictionary *)dict;
- (id)initWithStaffInfoClass:(StaffManagementStaffInfoDataClass *)staffClass;

@end

#pragma mark - StaffManagementAuthDataClass

@interface StaffManagementAuthDataClass : NSObject

@property (nonatomic, strong) NSString *indexStr;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *childrenArray;
@property (nonatomic, assign) BOOL open;
@property (nonatomic, strong) NSArray *pageArray;

- (id)initWithStaffManagementAuthData:(NSDictionary *)dict;
- (id)initWithStaffAuthData:(StaffManagementAuthDataClass *)authClass;

@end

#pragma mark - StaffManagementSubAuthDataClass

@interface StaffManagementSubAuthDataClass : NSObject

@property (nonatomic, strong) NSString *indexStr;
@property (nonatomic, strong) NSString *idStr;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *checkedArray;/*此项选中时需选中哪些权限（index）*/
@property (nonatomic, strong) NSArray *uncheckedArray;/*此项取消时需取消哪些权限（index）*/
@property (nonatomic, assign) BOOL open;

- (id)initWithStaffManagementSubAuthData:(NSDictionary *)dict;
- (id)initWithStaffSubAuthData:(StaffManagementSubAuthDataClass *)subAuthClass;

@end


