//
//  CallServiceViewControllerCell.h
//  PreOrderSystem
//
//  Created by sWen on 12-10-29.
//
//

#import <UIKit/UIKit.h>

@interface CallServiceViewControllerCell : UITableViewCell
{
    __weak UILabel *seatLabel;
    __weak UIImageView *contentImageView;
    __weak UILabel *timeLabel;
    __weak UIImageView *handleImageView;
    __weak UIImageView *bgImageView;
    NSMutableArray *pictureNameArray;
}

@property (nonatomic, weak) IBOutlet UILabel *seatLabel;
@property (nonatomic, weak) IBOutlet UIImageView *contentImageView;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *handleImageView;
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;

- (UIView *)updateWithData:(NSDictionary *)dict;

@end
