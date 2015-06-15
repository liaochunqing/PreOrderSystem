//
//  QueueLookDishViewController.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-19.
//
//

#import <UIKit/UIKit.h>

@class QueueArrangDataClass;
@class QueueLookDishViewController;
@protocol QueueLookDishViewControllerDelegate <NSObject>

-(void)dismissQueueLookDishViewController;

@end

@interface QueueLookDishViewController : UIViewController

@property (nonatomic, weak) id <QueueLookDishViewControllerDelegate> delegate;
@property (nonatomic, strong) QueueArrangDataClass *arrangClass;
@property (nonatomic, strong) NSString *categoryName;

@end
