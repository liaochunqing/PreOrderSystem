//
//  DishCardListTableviewCell.h
//  PreOrderSystem
//
//  Created by AaronKwok on 13-4-10.
//
//

#import <UIKit/UIKit.h>

#define kDishCardListTableviewCellReuseIdentifier @"dishCardListTableviewCellIdentifier"

@class DishCardListTableviewCell;
@protocol DishCardListTableviewCellDelegate <NSObject>
- (void)dishCardCellSelectedAtIndex:(int)index;
- (void)deleteDishCardState:(BOOL)flag;//flag用来判断是否正在删除状态
- (void)deleteDishCard:(DishCardListTableviewCell*)cell withItemId:(NSString *)itemId;

@end
@interface DishCardListTableviewCell : UITableViewCell
{
    id <DishCardListTableviewCellDelegate> __weak delegate;
    __weak UIImageView *col1FrameImageview;
    __weak UILabel *col1SerialNumLabel;
    __weak UILabel *col1DishNameLabel;
    __weak UILabel *col1PriceLabel;
    __weak UIImageView *col1SoldOutImageview;
    __weak UIButton *col1FrameBtn;
    __weak UIButton *delete1Btn;
    
    __weak UIImageView *col2FrameImageview;
    __weak UILabel *col2SerialNumLabel;
    __weak UILabel *col2DishNameLabel;
    __weak UILabel *col2PriceLabel;
    __weak UIImageView *col2SoldOutImageview;
    __weak UIButton *col2FrameBtn;
    __weak UIButton *delete2Btn;
    
    NSString *item1IdString;
    NSString *item2IdString;
}
@property(weak, nonatomic) id delegate;
@property(weak, nonatomic) IBOutlet UIImageView *col1FrameImageview;
@property(weak, nonatomic) IBOutlet UILabel *col1SerialNumLabel;
@property(weak, nonatomic) IBOutlet UILabel *col1IsTakeOutLabel;
@property(weak, nonatomic) IBOutlet UILabel *col1DishNameLabel;
@property(weak, nonatomic) IBOutlet UILabel *col1PriceLabel;
@property(weak, nonatomic) IBOutlet UIImageView *col1SoldOutImageview;

@property (strong, nonatomic) IBOutlet UIImageView *col1StopImv;

@property(weak, nonatomic) IBOutlet UIButton *col1FrameBtn;
@property(weak, nonatomic) IBOutlet UIButton *delete1Btn;
@property(weak, nonatomic) IBOutlet UIImageView *col2FrameImageview;
@property(weak, nonatomic) IBOutlet UILabel *col2SerialNumLabel;
@property(weak, nonatomic) IBOutlet UILabel *col2IsTakeOutLabel;
@property(weak, nonatomic) IBOutlet UILabel *col2DishNameLabel;
@property(weak, nonatomic) IBOutlet UILabel *col2PriceLabel;
@property(weak, nonatomic) IBOutlet UIImageView *col2SoldOutImageview;
@property(weak, nonatomic) IBOutlet UIButton *col2FrameBtn;
@property(weak, nonatomic) IBOutlet UIButton *delete2Btn;

@property (strong, nonatomic) IBOutlet UIImageView *col2StopImv;


@property(nonatomic, readwrite) NSInteger tag;

- (IBAction)columnButtonPressed:(UIButton*)sender;
- (IBAction)deleteButtonPressed:(UIButton*)sender;

-(void)updateCellInfoAtColumn1:(NSDictionary*)col1 column2:(NSDictionary*)col2;

@end
