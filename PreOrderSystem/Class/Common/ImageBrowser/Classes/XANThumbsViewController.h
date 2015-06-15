//
//  XANThumbsViewController.h
//  XANPhotoBrowser
//
//  Created by Chen Xian'an on 12/17/10.
//  Copyright 2010 lazyapps.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XANThumbsCell.h"

@class XANThumbsViewController;

@protocol XANThumbsViewControllerDataSource <NSObject>
@required
- (UIImage *)thumbImageForIndex:(NSUInteger)index;
- (NSUInteger)numberOfThumbs;
- (NSUInteger)numberOfColumnsForPortrait;
@optional
- (NSUInteger)numberOfColumnsForLandscape;
@end

@protocol XANThumbsViewControllerDelegate <NSObject>
@optional
- (void)thumbsViewController:(XANThumbsViewController *)thumbsViewController didSelectThumbAtIndex:(NSUInteger)index;
- (void)doneWithThumbsViewController:(XANThumbsViewController *)thumbsViewController;
@end

@interface XANThumbsViewController : UITableViewController <XANThumbsCellDelegate>{
  NSUInteger numberOfThumbs;
  NSUInteger numberOfColumns;
  NSUInteger numberOfRows;
  UIStatusBarStyle fromStatusBarStyle;
  
  BOOL showsDoneButton;
  id <XANThumbsViewControllerDataSource> dataSource;
  id <XANThumbsViewControllerDelegate> delegate;
}

@property (nonatomic, assign) BOOL showsDoneButton;
@property (nonatomic, assign) id <XANThumbsViewControllerDataSource> dataSource;
@property (nonatomic, assign) id <XANThumbsViewControllerDelegate> delegate;

- (id)initWithDataSource:(id <XANThumbsViewControllerDataSource>)dataSource delegate:(id <XANThumbsViewControllerDelegate>)delegate;
- (void)reloadData;
- (NSUInteger)thumbIndexForColumn:(NSUInteger)column inRow:(NSUInteger)row;

@end
