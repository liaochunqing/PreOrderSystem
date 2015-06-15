//
//  XANImageViewController.h
//  XANImageBrowser
//
//  Created by Chen Xian'an on 12/18/10.
//  Copyright 2010 lazyapps.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XANImageViewController;

@protocol XANImageViewControllerDataSource <NSObject>
@required
- (NSUInteger)numberOfImages;
- (UIImage *)imageForIndex:(NSUInteger)index;
@optional
- (NSString *)titleForIndex:(NSUInteger)index;
@end

@protocol XANImageViewControllerDelegate <NSObject>
@optional
- (void)doneWithImageViewController:(XANImageViewController *)imageViewController;
@end



@interface XANImageViewController : UIViewController<UIScrollViewDelegate> {
  NSInteger currentImageIndex;
  UIScrollView *pagingScrollView;

  NSMutableSet *visiblePages;
  NSMutableSet *recycledPages;

  UIInterfaceOrientation fromInterfaceOrientation;

  UIBarButtonItem *prevItem;
  UIBarButtonItem *nextItem;
  
  UIStatusBarStyle fromStatusBarStyle;
  
  BOOL showsDoneButton;
  id <XANImageViewControllerDataSource> dataSource;
  id <XANImageViewControllerDelegate> delegate;
    
    BOOL barHidden;
}

//@property (nonatomic, assign) BOOL allowNoSlip;
@property (nonatomic, assign) BOOL showsDoneButton;
@property (nonatomic, assign) id <XANImageViewControllerDataSource> dataSource;
@property (nonatomic, assign) id <XANImageViewControllerDelegate> delegate;
@property (nonatomic, retain, readonly) UIImage *currentImage;

- (id)initWithInitialImageIndex:(NSUInteger)initialImageIndex dataSource:(id <XANImageViewControllerDataSource>)dataSource delegate:(id <XANImageViewControllerDelegate>)delegate;
- (void)prevImage:(UIBarButtonItem *)sender;
- (void)nextImage:(UIBarButtonItem *)sender;
- (void)handleSingleTap:(UITapGestureRecognizer *)tgr;
- (void)done;

@end
