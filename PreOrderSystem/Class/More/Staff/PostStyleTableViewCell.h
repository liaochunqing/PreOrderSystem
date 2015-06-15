//
//  PostStyleTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-30.
//
//

#import <UIKit/UIKit.h>

#define kPostStyleTableViewCellIdentifier @"PostStyleTableViewCellIdentifier"

@interface PostStyleTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *lineImageView;
@property (nonatomic, weak) IBOutlet UILabel *styleLabel;

- (void)uopdatePostStyleCell:(NSString *)styleStr withShowLineFlag:(BOOL)lineFlag;

@end
