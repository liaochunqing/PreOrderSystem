//
//  DishDetailTitleView.h
//  PreOrderSystem
//
//  Created by sWen on 13-7-3.
//
//

#import <UIKit/UIKit.h>

#import "NumPicker.h"

@class DishDetailTitleView;

@protocol DishDetailTitleViewDelegate <NSObject>

- (void)modifyCarryfee:(NSString *)carryfeeStr;

@end

@interface DishDetailTitleView : UIView<UITextFieldDelegate, NumPickerDelegate>
{
    NSString *carryfeeStr;//配送费
}

@property (nonatomic, weak) id <DishDetailTitleViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *modiftButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *trueButton;
@property (nonatomic, weak) IBOutlet UIImageView *handleImageViewBg;
@property (nonatomic, weak) IBOutlet UIImageView *textFieldImageViewBg;
@property (nonatomic, weak) IBOutlet UITextField *carryfeeTextField;
@property (nonatomic, strong) id popController;

- (id)initWithCarryfee:(NSString *)feeStr withOrderStatus:(int)orderStatus withDeliveryType:(int)deliveryType;

@end
