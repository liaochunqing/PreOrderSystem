//
//  TaskListLoadMoreCell.h
//  EasyWork2
//
//  Created by AaronKwok on 12-2-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderListLoadMoreCell : UITableViewCell
{
    __weak UILabel *messageLabel;
    __weak UIActivityIndicatorView *spinner;
}
@property (nonatomic, weak)IBOutlet UILabel *messageLabel;
@property (nonatomic, weak)IBOutlet UIActivityIndicatorView *spinner;

-(void)loadText:(NSString *)message;
-(void)loadTextWithOutData:(NSString *)message;
-(void)startLoading:(NSString *)message;
-(void)stopLoading:(NSString *)message;

@end
