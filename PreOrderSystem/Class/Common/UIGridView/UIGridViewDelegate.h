//
//  UIGridViewDelegate.h
//  foodling2
//
//  Created by Tanin Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIGridViewDelegate


@optional
- (void) gridView:(UIGridView *)grid didSelectRowAt:(int)rowIndex AndColumnAt:(int)columnIndex;

- (UIView *)gridView:(UIGridView *)grid viewForHeaderInSection:(NSInteger)section;

- (CGFloat) gridView:(UIGridView *)grid heightForHeaderInSection:(NSInteger)section;

/**
 *  下拉刷新,通知父视图重新获取数据.
 *
 *  @param disSelectView self
 *  @param view          下拉刷新界面
 */
- (void)gridView:(UIGridView *)grid didTriggerRefresh:(EGORefreshTableHeaderView*)view;

@required
- (CGFloat) gridView:(UIGridView *)grid widthForColumnAt:(int)columnIndex;
- (CGFloat) gridView:(UIGridView *)grid heightForRowAt:(int)rowIndex;

- (NSInteger) numberOfColumnsOfGridView:(UIGridView *) grid;
- (NSInteger) numberOfCellsOfGridView:(UIGridView *) grid;

- (UIGridViewCell *) gridView:(UIGridView *)grid cellForRowAt:(int)rowIndex AndColumnAt:(int)columnIndex;

@end

