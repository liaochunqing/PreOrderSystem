//
//  PostStyleView.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-30.
//
//

#import <UIKit/UIKit.h>
#import "CustomUIView.h"

#define kPostStyleViewOrigin CGPointMake(448, 282)

@class PostStyleView;
@protocol PostStyleViewDelegate <NSObject>

- (void)postStyleHavedSelected:(PostStyleView *)styleView withSelectStyle:(NSString *)styleStr;

@end

@interface PostStyleView : CustomUIView<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <PostStyleViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet UITableView *styleTableView;
@property (nonatomic, assign) NSInteger styleIndex;

- (void)updatePostStyleView:(NSArray *)array;

@end
