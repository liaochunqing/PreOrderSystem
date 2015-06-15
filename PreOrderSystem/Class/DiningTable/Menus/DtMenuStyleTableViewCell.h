//
//  DtMenuStyleTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-30.
//
//

#import <UIKit/UIKit.h>

#define kDtMenuCookbookMaxStyleLen 2

@interface DtMenuStyleTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *lineImageView;
@property (nonatomic, weak) IBOutlet UILabel *styleLabel;

- (void)uopdateDtMenuStyleCell:(NSString *)styleStr;

/**
 *  设置cell的长度
 *
 *  @param width: new Width.
 */
- (void)setTableViewWidth:(CGFloat)width;

@end
