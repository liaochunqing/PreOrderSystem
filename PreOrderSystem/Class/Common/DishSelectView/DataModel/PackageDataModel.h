//
//  PackageDataModel.h
//  PreOrderSystem
//
//  Created by mac on 14-7-24.
//
//

#import <Foundation/Foundation.h>

@interface PackageDataModel : NSObject

//关联的菜系
@property (nonatomic) NSInteger cuisineID;

//栏目名称
@property (nonatomic) NSInteger pID;

//栏目名称
@property (nonatomic,strong) NSString *itemName;

//选择类型，0：不供选择（全选），1：必选，2：任选
@property (nonatomic,assign) int choiceType;

//必选数
@property (nonatomic,assign) int choiceNum;

//栏目成员(数组中存放的是栏目成员数据模型:PackageMemberDataModel*)
@property (nonatomic,strong) NSMutableArray *memberArr;


- (id)initWithPackageDic:(NSDictionary *)packageDic;
@end
