//
//  NoticeViewController.h
//  PreOrderSystem
//
//  Created by sWen on 13-1-29.
//
//

#import <UIKit/UIKit.h>

@interface NoticeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *infoArray;//简介数据
}

@property (nonatomic, weak) IBOutlet UITableView *infoTableView;
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, assign) int rightTag;

@end
