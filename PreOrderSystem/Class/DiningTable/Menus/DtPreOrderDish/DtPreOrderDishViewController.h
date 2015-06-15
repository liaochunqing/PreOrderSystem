//
//  DtPreOrderDishViewController.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-19.
//
//

#import <UIKit/UIKit.h>

@class QueueArrangDataClass;
@class DtPreOrderDishViewController;
@protocol DtPreOrderDishViewControllerDelegate <NSObject>

-(void)dismissDtPreOrderDishViewController;

@end

/**
 * @brief   预点菜入台。
 */
@interface DtPreOrderDishViewController : UIViewController

@property (nonatomic, weak) id <DtPreOrderDishViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *queueListArray;
@property (nonatomic, assign) int housingId;//房台id

@end
