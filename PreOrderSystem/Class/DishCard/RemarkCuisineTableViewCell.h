//
//  RemarkCuisineTableViewCell.h
//  PreOrderSystem
//
//  Created by sWen on 13-5-15.
//
//

#import <UIKit/UIKit.h>

#define kRemarkCuisineTableViewCellReuseIdentifier @"remarkCuisineTableViewCellIdentifier"

@interface RemarkCuisineTableViewCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet  UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UILabel *cuisineLabel;

- (void)updateViewAfterGetData:(NSString *)cuisineStr withSelected:(BOOL)flag;

@end
