//
//  DeskPicker.h
//  PreOrderSystem
//
//  Created by AaronKwok on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//"选台"拾取器
#import <UIKit/UIKit.h>


@class DeskPicker;
@protocol DeskPickerDelegate <NSObject>
-(void)DeskPicker:(DeskPicker*)picker didPressedCancelButton:(BOOL)flag;
-(void)DeskPicker:(DeskPicker*)picker didPickedDesks:(NSArray*)desks;
-(void)DeskPicker:(DeskPicker*)picker didPickedDesks2:(NSArray*)desks;
@end
@interface DeskPicker : UIViewController{
    __weak id <DeskPickerDelegate> delegate;
    __weak UITableView *deskTableview;
    __weak UIButton *quitButton;
    __weak UIButton *clearButton;
    __weak UIButton *trueButton;
    __weak UILabel *headLabel;
    __weak UIImageView *headImageView;
    
    NSArray *diningTableListArray;
    NSMutableArray *selectedArray;
    NSMutableArray *isZipped;
}
@property (nonatomic, weak) id delegate;
@property (weak, nonatomic) IBOutlet UITableView *deskTableview;
@property (weak, nonatomic) IBOutlet UIButton *quitButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *trueButton;
@property (weak, nonatomic) IBOutlet UILabel *headLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (nonatomic, assign, readwrite) NSInteger tag;

//仅纯粹通过seatsId来初始化
-(id)initWithSelectedList:(NSArray*)selectedList;

//通过{seatsId, name}结构的数组来初始化
-(id)initWithSelectedList2:(NSArray*)selectedList;

//房台ID转换为对应的文字(用于：指定的开放台号)
+(NSString *)seatsIdsToText:(NSArray*)diningTable;

//返回该页面的size
-(CGSize)pickerSize;
@end
