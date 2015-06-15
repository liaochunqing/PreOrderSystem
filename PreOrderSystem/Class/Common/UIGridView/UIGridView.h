//
//  UIGridView.h
//  foodling2
//
//  Created by Tanin Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
@protocol UIGridViewDelegate;
@class UIGridViewCell;

@interface UIGridView : UITableView<UITableViewDelegate, UITableViewDataSource,EGORefreshTableHeaderDelegate> {
	UIGridViewCell *tempCell;
}

@property (nonatomic, retain) IBOutlet id<UIGridViewDelegate> uiGridViewDelegate;
//styleBoxGridView中的下拉刷新视图
@property (nonatomic,retain)EGORefreshTableHeaderView *styleBoxRefreshHeaderView;

//下拉刷新用到的一个变量,作用未知
@property (nonatomic,assign)BOOL reloading;

- (void) setUp;
- (UIGridViewCell *) dequeueReusableCell;

- (IBAction) cellPressed:(id) sender;

- (void)setEGORefreshView;
@end
