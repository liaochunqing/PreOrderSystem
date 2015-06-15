//
//  TakeOutShopListView.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-30.
//
//

#import <UIKit/UIKit.h>
#import "CustomUIView.h"

#define kTakeOutShopListViewOrigin CGPointMake(731.0, (kSystemVersionIsIOS7 ? 116.0 : 101.0))
#define kPreOrderShopListViewOrigin CGPointMake(730.0, (kSystemVersionIsIOS7 ? 118.0 : 98.0))

@class TakeOutShopListView;
@protocol TakeOutShopListViewDelegate <NSObject>

- (void)takeOutShopListView:(TakeOutShopListView *)shopListView withSelectedShop:(NSString *)shopName;

@end

@interface TakeOutShopListView : CustomUIView<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <TakeOutShopListViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet UITableView *styleTableView;
@property (nonatomic, assign) NSInteger branchId;

- (void)updateTakeOutShopListView:(NSArray *)array;

@end
