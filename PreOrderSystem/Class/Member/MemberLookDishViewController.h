//
//  MemberLookDishViewController.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-19.
//
//

#import <UIKit/UIKit.h>

@class MemberUseCountDataClass;
@class MemberLookDishViewController;
@protocol MemberLookDishViewControllerDelegate <NSObject>

-(void)dismissMemberLookDishViewController;

@end

@interface MemberLookDishViewController : UIViewController

@property (nonatomic, weak) id <MemberLookDishViewControllerDelegate> delegate;
@property (nonatomic, strong) MemberUseCountDataClass *useCountDataClass;

@end
