//
//  DtMenuRemarkOptionsCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-1-7.
//
//

#import "DtMenuRemarkOptionsCell.h"
#import "UIImage+imageWithContentsOfFile.h"


@interface DtMenuRemarkOptionsCell ()
{
    BOOL selectedFlag;
}

- (IBAction)bigBtnClicked:(id)sender;

@end

@implementation DtMenuRemarkOptionsCell

- (id)initWithRemarkText:(NSString *)remarkStr withSelectedFlag:(BOOL)flag
{
    self = [[[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@",self.class] owner:self options:nil]lastObject];
    if (self)
    {
        selectedFlag = flag;
        [self addPictureToView];
        self.remarkLabel.center = self.center;
        self.remarkLabel.text = remarkStr;
    }
    return self;
}

- (void)addPictureToView
{
    NSString *imgName = (selectedFlag)?@"dt_menuRemarkSecondOptionSelectedBg.png":@"dt_menuRemarkSecondOptionNormalBg.png";
    self.bgImageView.image = [UIImage imageFromMainBundleFile:imgName];
    
}

- (IBAction)bigBtnClicked:(id)sender
{
    selectedFlag = !selectedFlag;
    [self addPictureToView];
    if ([self.delegate respondsToSelector:@selector(DtMenuRemarkOptionsCellHavedSelected: withAddFlag:)])
    {
        [self.delegate DtMenuRemarkOptionsCellHavedSelected:self.remarkLabel.text withAddFlag:selectedFlag];
    }
}

@end
