//
//  WeekdayPicker.h
//  PreOrderSystem
//
//  Created by AaronKwok on 12-8-30.
//
//

#import <UIKit/UIKit.h>
@class WeekdayPicker;
@protocol WeekdayPickerDelegate <NSObject>
-(void)WeekdayPicker:(WeekdayPicker*)picker didPickedWeekdays:(NSArray*)weekdays;
-(void)WeekdayPicker:(WeekdayPicker*)picker didPressedCancelButton:(BOOL)flag;
@end
@interface WeekdayPicker : UIViewController{
    __weak id <WeekdayPickerDelegate> delegate;
    __weak UITableView *weekdayTableview;
    __weak UIButton *quitButton;
    __weak UIButton *trueButton;
    __weak UIButton *clearButton;
    __weak UIImageView *headImageView;
    __weak UILabel *headLabel;
    NSArray *weekdaysArray;
    NSMutableArray *selectedArray;
}

@property(nonatomic, weak) id delegate;
@property(weak, nonatomic) IBOutlet UITableView *weekdayTableview;
@property(weak, nonatomic) IBOutlet UIButton *quitButton;
@property(weak, nonatomic) IBOutlet UIButton *trueButton;
@property(weak, nonatomic) IBOutlet UIButton *clearButton;
@property(weak, nonatomic) IBOutlet UIImageView *headImageView;
@property(weak, nonatomic) IBOutlet UILabel *headLabel;
@property(nonatomic, assign, readwrite) NSInteger tag;

-(void)updateWeekdays:(NSArray*)week;

//返回该页面的size
-(CGSize)pickerSize;
@end
