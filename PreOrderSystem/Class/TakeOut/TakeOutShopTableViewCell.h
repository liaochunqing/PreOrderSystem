//
//  TakeOutShopTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-30.
//
//

#import <UIKit/UIKit.h>

#define kTakeOutShopTableViewCellIdentifier @"takeOutShopTableViewCellIdentifier"

@interface TakeOutShopTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *lineImageView;
@property (nonatomic, weak) IBOutlet UILabel *styleLabel;

- (void)uopdateTakeOutShopListCell:(NSString *)shopName withShowLineFlag:(BOOL)lineFlag;

@end
