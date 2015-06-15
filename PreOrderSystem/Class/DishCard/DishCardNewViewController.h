//
//  DishCardNewViewController.h
//  PreOrderSystem
//
//  Created by SWen on 14-7-15.
//
//

#import <UIKit/UIKit.h>
typedef void (^quitBlock) ();

@class DishCardNewViewController;
@protocol DishCardNewViewControllerDelegate <NSObject>
- (void)DishCardNewViewControllerDidAddedNewItem:(NSDictionary*)item;
- (void)DishCardNewViewController:(DishCardNewViewController*)ctrl didDismissView:(BOOL)flag;

@end

@interface DishCardNewViewController : UIViewController

@property (weak, nonatomic) id <DishCardNewViewControllerDelegate> delegate;
@property (nonatomic, copy) quitBlock qBlock;

// 原始菜系列表
@property (nonatomic, strong) NSMutableArray *allDishCardListArray;
//Public Methods
-(void)showInView:(UIView*)aView;
- (void)updateViewWithCuisineID:(int)cid withImgBaseURL:(NSString *)imageURL;
- (void)updateViewWithDishInfo:(NSDictionary *)info withImgBaseURL:(NSString *)imageURL;
@end