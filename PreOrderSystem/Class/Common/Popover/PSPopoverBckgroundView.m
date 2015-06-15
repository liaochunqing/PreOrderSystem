//
//  PSPopoverBckgroundView.m
//  PreOrderSystem
//
//  Created by YorkIT on 14-5-9.
//
//

#import "PSPopoverBckgroundView.h"
#import "UIImage+imageWithContentsOfFile.h"

#define CONTENT_INSET 10.0
#define CAP_INSET 25.0
#define ARROW_BASE 20.0
#define ARROW_HEIGHT 12.0

@implementation PSPopoverBckgroundView

#pragma mark - initlization methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // 边框
        UIImage *frameImage = [UIImage imageNamed:@"popover_content_frame.png"];
        frameImage = [frameImage stretchableImageWithLeftCapWidth:floor(frameImage.size.width / 2.0)
                                                     topCapHeight:floor(frameImage.size.height / 2.0)];
        frameImageView_ = [[UIImageView alloc] initWithImage:frameImage];
        [self addSubview:frameImageView_];
        
        // 内容背景视图
//        UIImage *contentImage = [UIImage imageNamed:@"popover_content_bg.png"];
//        contentImage = [contentImage stretchableImageWithLeftCapWidth:floor(contentImage.size.width / 2.0)
//                                                         topCapHeight:floor(contentImage.size.height / 2.0)];
//        contentBgImageView_ = [[UIImageView alloc] initWithImage:contentImage];
//        [self addSubview:contentBgImageView_];
        
        // 箭头视图
        UIImage *arrowImage = [UIImage imageNamed:@"popover_arrow.png"];
        arrowImageView_ = [[UIImageView alloc] initWithImage:arrowImage];
        [self addSubview:arrowImageView_];
    }
    return self;
}

-  (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    CGFloat left = 0.0;
    CGFloat top = 0.0;
    CGFloat coordinate = 0.0;
    CGAffineTransform rotation = CGAffineTransformIdentity;
    
    switch (self.arrowDirection) {
        case UIPopoverArrowDirectionUp:
            top += ARROW_HEIGHT;
            height -= ARROW_HEIGHT;
            coordinate = ((width / 2.0) + self.arrowOffset) - (ARROW_BASE / 2.0);
            arrowImageView_.frame = CGRectMake(coordinate, 1.0, ARROW_BASE, ARROW_HEIGHT);
            break;
            
        case UIPopoverArrowDirectionDown:
            height -= ARROW_HEIGHT;
            coordinate = ((width / 2.0) + self.arrowOffset) - (ARROW_BASE / 2.0);
            arrowImageView_.frame = CGRectMake(coordinate, height - 1.0, ARROW_BASE, ARROW_HEIGHT);
            rotation = CGAffineTransformMakeRotation(M_PI);
            break;
            
        case UIPopoverArrowDirectionLeft:
            left += ARROW_HEIGHT;
            width -= ARROW_HEIGHT;
            coordinate = ((height / 2.0) + self.arrowOffset) - (ARROW_HEIGHT / 2.0);
            arrowImageView_.frame = CGRectMake(1.0 - ARROW_BASE / 2.0 + ARROW_HEIGHT / 2.0,
                                               coordinate - ARROW_HEIGHT / 2.0 + ARROW_BASE / 2.0,
                                               ARROW_BASE,
                                               ARROW_HEIGHT);
            rotation = CGAffineTransformMakeRotation(-M_PI_2);
            break;
            
        case UIPopoverArrowDirectionRight:
            width -= ARROW_HEIGHT;
            coordinate = ((height / 2.0) + self.arrowOffset) - (ARROW_HEIGHT / 2.0);
            arrowImageView_.frame = CGRectMake(width - 1.0 - ARROW_BASE / 2.0 + ARROW_HEIGHT / 2.0,
                                               coordinate - ARROW_HEIGHT / 2.0 + ARROW_BASE / 2.0,
                                               ARROW_BASE,
                                               ARROW_HEIGHT);
            rotation = CGAffineTransformMakeRotation(M_PI_2);
            
            break;
        default:
            break;
            
    }
    
    if (self.arrowDirection == UIPopoverArrowDirectionLeft || self.arrowDirection == UIPopoverArrowDirectionRight) {
        // 调换宽度和高度
        width += height;
        height = width - height;
        width -= height;
        // 计算位置
        CGFloat tempLeft = left - (width - height) / 2.0;
        CGFloat tempTop = top - (height - width) / 2.0;
        left = tempLeft;
        top = tempTop;
    }
    
    frameImageView_.frame =  CGRectMake(left, top, width, height);
//    contentBgImageView_.frame = CGRectInset(frameImageView_.frame, 10.0, 10.0);
    
    arrowImageView_.transform = rotation;
    frameImageView_.transform = rotation;
//    contentBgImageView_.transform = rotation;
}

+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(CONTENT_INSET, CONTENT_INSET, CONTENT_INSET, CONTENT_INSET);
}

- (CGFloat)arrowOffset
{
    return arrowOffset_;
}

- (void)setArrowOffset:(CGFloat)arrowOffset
{
    arrowOffset_ = arrowOffset;
}

- (UIPopoverArrowDirection)arrowDirection
{
    return arrowDirection_;
}

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    arrowDirection_ = arrowDirection;
}

+ (CGFloat)arrowHeight
{
    return ARROW_HEIGHT;
}

+ (CGFloat)arrowBase
{
    return ARROW_BASE;
}

@end
