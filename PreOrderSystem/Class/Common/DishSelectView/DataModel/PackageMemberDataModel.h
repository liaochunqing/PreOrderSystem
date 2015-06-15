//
//  PackageMemberDataModel.h
//  PreOrderSystem
//
//  Created by mac on 14-7-24.
//
//套餐中的栏目成员

#import <Foundation/Foundation.h>

@interface PackageMemberDataModel : NSObject

//栏目成员名称
@property (nonatomic, strong) NSString *memberName;

//栏目成员价格
@property (nonatomic, assign) int memberPrice;

//是否已选
@property (nonatomic, assign) BOOL isChecked;

//份数
@property (nonatomic, assign) NSInteger quantity;

//关联菜品的ID
@property (nonatomic, assign) NSInteger cbID;

- (id)initWithMemberDic:(NSDictionary *)memDic;

@end
