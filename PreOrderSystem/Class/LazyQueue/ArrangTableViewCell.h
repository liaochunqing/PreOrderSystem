//
//  ArrangTableViewCell.h
//  PreOrderSystem
//
//  Created by sWen on 13-3-7.
//
//

#import <UIKit/UIKit.h>

#define kHeightForArrangCell 90

@class ArrangTableViewCell;

@protocol ArrangTableViewCellDelegate <NSObject>

- (void)handleArrang:(int)index;

@end

@interface ArrangTableViewCell : UITableViewCell
{
    NSMutableArray *serialNumLabelArray;
    NSMutableArray *peopleNumLabelArray;
    NSMutableArray *handleArrangBtnArray;
    NSMutableArray *selectArrangBgViewArray;
    NSMutableArray *dishLogoArray;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) IBOutlet UILabel *serialNumber1Label;
@property (nonatomic, weak) IBOutlet UILabel *peopleNumber1Label;
@property (nonatomic, weak) IBOutlet UILabel *serialNumber2Label;
@property (nonatomic, weak) IBOutlet UILabel *peopleNumber2Label;
@property (nonatomic, weak) IBOutlet UILabel *serialNumber3Label;
@property (nonatomic, weak) IBOutlet UILabel *peopleNumber3Label;
@property (nonatomic, weak) IBOutlet UILabel *serialNumber4Label;
@property (nonatomic, weak) IBOutlet UILabel *peopleNumber4Label;
@property (nonatomic, weak) IBOutlet UILabel *serialNumber5Label;
@property (nonatomic, weak) IBOutlet UILabel *peopleNumber5Label;
@property (nonatomic, weak) IBOutlet UIButton *handleArrang1Button;
@property (nonatomic, weak) IBOutlet UIButton *handleArrang2Button;
@property (nonatomic, weak) IBOutlet UIButton *handleArrang3Button;
@property (nonatomic, weak) IBOutlet UIButton *handleArrang4Button;
@property (nonatomic, weak) IBOutlet UIButton *handleArrang5Button;
@property (nonatomic, weak) IBOutlet UIImageView *selectArrang1BgView;
@property (nonatomic, weak) IBOutlet UIImageView *selectArrang2BgView;
@property (nonatomic, weak) IBOutlet UIImageView *selectArrang3BgView;
@property (nonatomic, weak) IBOutlet UIImageView *selectArrang4BgView;
@property (nonatomic, weak) IBOutlet UIImageView *selectArrang5BgView;
@property (nonatomic, weak) IBOutlet UIImageView *dishLogo1View;
@property (nonatomic, weak) IBOutlet UIImageView *dishLogo2View;
@property (nonatomic, weak) IBOutlet UIImageView *dishLogo3View;
@property (nonatomic, weak) IBOutlet UIImageView *dishLogo4View;
@property (nonatomic, weak) IBOutlet UIImageView *dishLogo5View;
@property (nonatomic, weak) IBOutlet UIImageView *lineImageView;
@property (nonatomic, assign) int superCellTag;

- (IBAction)handleArrangButongPressed:(UIButton *)sender;
- (void)updateViewAfterGetData:(NSArray *)arrangListArray withLineFlag:(BOOL)hideFlag;

@end
