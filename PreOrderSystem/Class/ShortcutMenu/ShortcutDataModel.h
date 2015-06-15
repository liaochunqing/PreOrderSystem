//
//  ShortcutDataModel.h
//  PreOrderSystem
//
//  Created by mac on 14-7-21.
//
//

#import <Foundation/Foundation.h>

@interface ShortcutDataModel : NSObject

//快捷方式名称
@property (nonatomic,strong) NSString *shortcutName;

//快捷方式tag
@property (nonatomic,strong) NSString *shortcutTag;

//该快捷方式是否已选("isActive": 0)
@property (nonatomic,assign) BOOL isSelected;

//快捷方式Key ("key": "b43215a0-1bd5-11e4-8ff3-6cae8b77e39c")
@property (nonatomic,strong) NSString *shortcutID;

//快捷方式图标(白色,显示在黑色快捷列表中)
@property (nonatomic,strong) NSString *shortcutImg;

//快捷方式图标(灰色,显示在快捷方式添加界面)
@property (nonatomic,strong) NSString *shortcutImgGray;

//快捷方式简介
@property (nonatomic,strong) NSString *shortcutInfo;



- (id)initWithData:(NSDictionary *)dic;

@end