//
//  PromotionTimePriceTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-7-19.
//
//

#import <UIKit/UIKit.h>
typedef void(^addBlock) (NSString* sTime, NSString* eTime, NSString *price);
typedef void(^delBlock) ();
typedef void (^hideKeyboardBlock) ();
typedef void (^timeEndEditingBlock)();

@interface PromotionTimePriceTableViewCell : UITableViewCell <UITextFieldDelegate, UIActionSheetDelegate>
@property (nonatomic, copy)delBlock deleteBlock;
@property (nonatomic, copy)addBlock addBlock;
@property (nonatomic, copy)hideKeyboardBlock hideKeyboardBlock;
@property (nonatomic, copy)timeEndEditingBlock timeEndEditingBlock;
@property (nonatomic)BOOL isFirstCell;

-(void)updateCellInfo:(NSDictionary*)info;
@end
