//
//  DeskPicker.h
//  PreOrderSystem
//
//  Created by AaronKwok on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
//"选台"拾取器(包含详细信息：该台的人数上限，最低消费)
#import <UIKit/UIKit.h>
typedef enum {
    //单选
	DeskPickerWithSummaryTypeSingle = 0,
    //多选
	DeskPickerWithSummaryMultiple
}DeskPickerWithSummaryType;

#import "JsonPicker.h"

@class MBProgressHUD;
@class DeskPickerWithSummary;
@protocol DeskPickerWithSummaryDelegate <NSObject>
-(void)DeskPickerWithSummary:(DeskPickerWithSummary*)picker didPressedCancelButton:(BOOL)flag;
//该函数只返回ID
-(void)DeskPickerWithSummary:(DeskPickerWithSummary*)picker didPickedDesks:(NSArray*)desks;
//该函数返回房台的详细（包括：餐厅所在区域的ID、房台名称（如: 1号台）、房台ID、）
//若选择了某房台，则返回结构如下的数组
-(void)DeskPickerWithSummary:(DeskPickerWithSummary*)picker didPickedDesksDetail:(NSArray*)desks;
@end
@interface DeskPickerWithSummary : UIViewController<JsonPickerDelegate>{
    __weak id <DeskPickerWithSummaryDelegate> delegate;
    __weak UITableView *deskTableview;
    __weak UIButton *quitButton;
    __weak UIButton *clearButton;
    __weak UIButton *trueButton;
    __weak UILabel *headLabel;
    __weak UIImageView *headImageView;
    
    NSMutableArray *diningTableListArray;
    NSMutableArray *selectedArray;
    NSMutableArray *isZipped;
    
    int selectedSection;
    int selectedRow;
    JsonPicker *jsonPicker;
}

@property(nonatomic, weak) id delegate;
@property(weak, nonatomic) IBOutlet UITableView *deskTableview;
@property(weak, nonatomic) IBOutlet UIButton *quitButton;
@property(weak, nonatomic) IBOutlet UIButton *clearButton;
@property(weak, nonatomic) IBOutlet UIButton *trueButton;
@property(weak, nonatomic) IBOutlet UILabel *headLabel;
@property(weak, nonatomic) IBOutlet UIImageView *headImageView;
@property(nonatomic, assign, readwrite) NSInteger tag;
//设置Picker的类型：单选/多选
@property(nonatomic, assign, readwrite) NSInteger deskPickerType;
//仅纯粹通过seatsId来初始化
-(id)initWithSelectedList:(NSArray*)selectedList;
-(void)updateWithSelectedList:(NSArray*)selectedList;

//房台ID转换为对应的文字(如：)
+(NSString *)seatsIdsToSummary:(NSArray*)diningTable;

//房台ID转换为对应的文字(如：)
+(NSString *)seatsIdsToSeatName:(NSArray*)diningTable;

-(CGSize)pickerSize;
//获取即时的房台信息
-(void)getDingTableData;

@end
