//
//  ReasonTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 13-11-28.
//
//

#import <UIKit/UIKit.h>

@interface ReasonTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *titleImageView;
@property (nonatomic, weak) IBOutlet UILabel *reasonLabel;

- (void)updateViewAfterGetData:(NSString *)reasonStr;

@end
