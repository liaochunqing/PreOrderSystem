//
//  promotionMainViewController.h
//  PreOrderSystem
//
//  Created by SWen on 14-6-30.
//
//

#import <UIKit/UIKit.h>
@class promotionMainViewController;


@protocol promotionMainViewControllerDelegate <NSObject>

- (void)promotionMainViewController:(promotionMainViewController*)ctrl didDismissView:(BOOL)flag;

@end


@interface promotionMainViewController : UIViewController
@property (nonatomic,assign) id <promotionMainViewControllerDelegate> delegate;

//所有菜系菜品原始数据(未解析)
@property (nonatomic,strong)NSArray *allCuisineDataArr;

-(void)showInView:(UIView *)aView;
@end
