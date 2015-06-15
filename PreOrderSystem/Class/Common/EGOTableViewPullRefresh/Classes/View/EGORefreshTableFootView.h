//
//  EGORefreshTableFootView.h
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "EGORefreshTableHeaderView.h"


@protocol EGORefreshTableFootDelegate;
@interface EGORefreshTableFootView : UIView {
	
	id _delegate;
	EGOPullRefreshState _state;

	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
}

@property(nonatomic,assign) id <EGORefreshTableFootDelegate> delegate;

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end
@protocol EGORefreshTableFootDelegate
- (void)egoRefreshTableFootDidTriggerRefresh:(EGORefreshTableFootView*)view;
- (BOOL)egoRefreshTableFootDataSourceIsLoading:(EGORefreshTableFootView*)view;
@optional
- (NSDate*)egoRefreshTableFootDataSourceLastUpdated:(EGORefreshTableFootView*)view;
@end
