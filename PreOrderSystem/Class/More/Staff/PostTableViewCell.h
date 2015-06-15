//
//  PostTableViewCell.h
//  PreOrderSystem
//
//  Created by sWen on 13-5-15.
//
//

#import <UIKit/UIKit.h>

#define kPostTableViewCellIdentifier @"postTableViewCellIdentifier"
#define kPostTableViewCellHeight 60

@class PostTableViewCell;
@protocol PostTableViewCellDelegate <NSObject>

- (void)postTableViewCell:(PostTableViewCell *)cell withDeleteIndex:(NSInteger)index;
- (void)postTableViewCell:(PostTableViewCell *)cell withModifyPostName:(NSString *)postName;

@end

@interface PostTableViewCell : UITableViewCell

@property (nonatomic, weak) id <PostTableViewCellDelegate> delegate;
- (void)updatePostTableViewCell:(NSString *)postStr withSelected:(BOOL)flag;

@end
