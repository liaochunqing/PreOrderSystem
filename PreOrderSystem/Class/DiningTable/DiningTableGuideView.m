//
//  DiningTableGuideView.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-20.
//
//

#import "DiningTableGuideView.h"
#import "Constants.h"

@interface DiningTableGuideView ()

@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UIImageView *arrowImageView;
@property (nonatomic, weak) IBOutlet UIImageView *circleImageView;
@property (nonatomic, weak) IBOutlet UIImageView *wordsImageView;
@property (nonatomic, weak) IBOutlet UIButton *guideButton;
- (IBAction)guideBtnClicked:(id)sender;

@end

@implementation DiningTableGuideView

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DiningTableGuideView" owner:self options:nil]lastObject];
    if (self)
    {
        self.bgImageView.image = LoadImageWithPNGType(@"dt_guideBg");
        self.arrowImageView.image = LoadImageWithPNGType(@"dt_guideArrows");
        self.circleImageView.image = LoadImageWithPNGType(@"dt_guideCircle");
        self.wordsImageView.image = LoadImageWithPNGType(@"dt_guideWords");
    }
    return self;
}

- (IBAction)guideBtnClicked:(id)sender
{
    [self dismissViewWithAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(guideViewHavedDismiss:)])
    {
        [self.delegate guideViewHavedDismiss:self];
    }
}

@end
