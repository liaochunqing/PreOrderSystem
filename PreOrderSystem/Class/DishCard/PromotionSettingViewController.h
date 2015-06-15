//
//  PromotionSettingViewController.h
//  PreOrderSystem
//
//  Created by SWen on 14-7-1.
//
//

#import <UIKit/UIKit.h>

typedef void(^sureBlock) (NSMutableDictionary *dict);

@interface PromotionSettingViewController : UIViewController <UIActionSheetDelegate>

@property (nonatomic, copy)sureBlock sureBlock;
@property (nonatomic, strong) NSMutableArray *promoteCookbookGroupArray;//未解析的优惠组合
@property (nonatomic, strong) NSMutableArray *promoteCookbookGroupParsedArray;//未解析的优惠组合
@property (nonatomic, strong) NSMutableDictionary *promoteActivity;//优惠活动详情
@property (nonatomic)BOOL selected;

@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UITextField *identifieTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *endDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *startDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *weekTextField;
@property (weak, nonatomic) IBOutlet UILabel *packageLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *packageImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *basicScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *timePriceScrollView;
@property (weak, nonatomic) IBOutlet UITableView *timePriceTabelView;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UIImageView *weekImageVIew;
@property (weak, nonatomic) IBOutlet UILabel *promotionActivityLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

//所有菜系菜品原始数据(未解析)
@property (nonatomic,strong)NSArray *allCuisineDataArr;

@end
