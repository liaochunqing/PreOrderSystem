//
//  DtMenuCookbookStyleView.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-30.
//
//

#import <UIKit/UIKit.h>
#import "CustomUIView.h"
#import "DtMenuStyleTableViewCell.h"

#define kDtMenuCookbookStyleViewOrigin CGPointMake(724, 208)

@class DtMenuCookbookStyleView;
@protocol DtMenuCookbookStyleViewDelegate <NSObject>

- (void)DtMenuCookbookStyleHavedSelected:(DtMenuCookbookStyleView *)styleView withSelectStyle:(NSString *)styleStr;

- (void)DtMenuCookbookStyleHavedSelected:(DtMenuCookbookStyleView *)styleView withSelectIndex:(NSIndexPath *)indexPath;

@end

@interface DtMenuCookbookStyleView : CustomUIView<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <DtMenuCookbookStyleViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UITableView *styleTableView;
@property (nonatomic, assign) NSInteger styleIndex;
@property (nonatomic, assign) CGFloat width;

- (void)setTableViewWidth:(CGFloat)width;
- (void)updateDtMenuCookbookStyleView:(NSArray *)array;

@end
