//
//  DtMenuRemarkOptionsCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-1-7.
//
//

#import <UIKit/UIKit.h>

@class DtMenuRemarkOptionsCell;
@protocol DtMenuRemarkOptionsCellDelegate <NSObject>

- (void)DtMenuRemarkOptionsCellHavedSelected:(NSString *)remarkStr withAddFlag:(BOOL)flag;

@end

@interface DtMenuRemarkOptionsCell : UIView

@property (nonatomic, weak) id < DtMenuRemarkOptionsCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UILabel *remarkLabel;
@property (nonatomic, weak) IBOutlet UIButton *bigButton;

- (id)initWithRemarkText:(NSString *)remarkStr withSelectedFlag:(BOOL)flag;

@end
