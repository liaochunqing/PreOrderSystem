//
//  DeskTableviewCell.h
//  PreOrderSystem
//
//  Created by AaronKwok on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DeskTableviewCell;
@protocol DeskTableviewCellDelegate <NSObject>
-(void)DeskTableviewCell:(DeskTableviewCell*)cell didSelected:(BOOL)isSelected;

@end
@interface DeskTableviewCell : UITableViewCell{
    __weak id <DeskTableviewCellDelegate> delegate;
    __weak UILabel *dtNameLabel;
    __weak UIImageView *selectedImageview;
    __weak UIImageView *normalImageview;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) IBOutlet UILabel *dtNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *selectedImageview;
@property (nonatomic, weak) IBOutlet UIImageView *normalImageview;
@property (nonatomic, strong) NSDictionary *deskInfo;

-(void)isSelected:(BOOL)selected;
-(void)setDeskTitle:(NSString*)text;
@end
