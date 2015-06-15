//
//  PostAuthorityTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-12.
//
//

#import <UIKit/UIKit.h>

@class StaffManagementAuthDataClass;
@class PostAuthorityTableViewCell;
@protocol PostAuthorityTableViewCellDelegate <NSObject>

- (void)postAuthorityTableViewCell:(PostAuthorityTableViewCell *)cell withAuthStateHavedChange:(StaffManagementAuthDataClass *)authInfo;

@end

@interface PostAuthorityTableViewCell : UITableViewCell

@property (nonatomic, weak) id <PostAuthorityTableViewCellDelegate> delegate;
- (void)updatePostAuthorityCell:(StaffManagementAuthDataClass *)authInfo;
- (CGFloat)getPostAuthorityCellHeight:(StaffManagementAuthDataClass *)authInfo;

@end
