//
//  StaffSortStyleView.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-30.
//
//

#import <UIKit/UIKit.h>
#import "CustomUIView.h"

#define kStaffSortStyleViewOrigin CGPointMake(478, kSystemVersionIsIOS7 ? 170.0 : 150.0)

@class StaffSortStyleView;
@protocol StaffSortStyleViewDelegate <NSObject>

- (void)sortStyleHavedSelected:(StaffSortStyleView *)styleView withSelectStyle:(NSString *)styleStr;

@end

@interface StaffSortStyleView : CustomUIView<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <StaffSortStyleViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet UITableView *styleTableView;
@property (nonatomic, assign) NSInteger styleIndex;

- (void)updateStaffSortStyleView:(NSArray *)array;

@end
