//
//  XANThumbCell.m
//  XANPhotoBrowser
//
//  Created by Chen Xian'an on 12/17/10.
//  Copyright 2010 lazyapps.com. All rights reserved.
//

#import "XANThumbsCell.h"
#import <QuartzCore/QuartzCore.h>
#import "config.h"

#define TAG_BASE 1000

@interface XANThumbsCell()
- (CGRect)buttonFrameAtColumn:(NSUInteger)column;
- (UIButton *)createButtonForColumn:(NSUInteger)column;
@end

@implementation XANThumbsCell
@synthesize numberOfThumbs, capacityOfThumbs, rowIndex;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier 
                thumbDelegate:(NSObject <XANThumbsCellDelegate> *)theThumbDelegate

{
  if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]){
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    thumbDelegate = theThumbDelegate;
  }
  
  return self;
}

- (void)dealloc
{
  thumbDelegate = nil;

  [super dealloc];
}

- (void)layoutSubviews
{
  [super layoutSubviews];

  CGRect r = self.contentView.frame;
  r.size.width = self.bounds.size.width;
  self.contentView.frame = r;

  NSUInteger numberOfButtons = [self.contentView.subviews count];
  if (numberOfButtons == 0) numberOfButtons = numberOfThumbs;

  for (NSUInteger i=0; i<numberOfButtons; i++){
    UIButton *button = (UIButton *)[self.contentView viewWithTag:TAG_BASE+i];
    if (i < numberOfThumbs){
      if (!button) [self createButtonForColumn:i];
      
      button.frame = [self buttonFrameAtColumn:i];
    } else {
      [button removeFromSuperview];
    }
  }
}

#pragma mark methods
- (void)updateImage:(UIImage *)image 
          forColumn:(NSUInteger)column
{
  UIButton *button = (UIButton *)[self.contentView viewWithTag:TAG_BASE+column];
  if (!button){
    button = [self createButtonForColumn:column];
    button.frame = [self buttonFrameAtColumn:column];
  }
  
  [button setImage:image forState:UIControlStateNormal];
}

#pragma mark button action
- (void)didTouchButton:(UIButton *)button
{
  if ([thumbDelegate conformsToProtocol:@protocol(XANThumbsCellDelegate)]){
    [thumbDelegate cell:self didSelectThumbAtColumn:(button.tag-TAG_BASE) inRow:rowIndex];
  }
}

#pragma mark privates
- (CGRect)buttonFrameAtColumn:(NSUInteger)column
{
  CGFloat x = (self.bounds.size.width - kThumbSize.width * capacityOfThumbs - kSpacing * (capacityOfThumbs-1)) / 2;
  if (column > 0)
    x += (kThumbSize.width + kSpacing) * column;
  
  return CGRectMake(x, 0, kThumbSize.width, kThumbSize.height);
}

- (UIButton *)createButtonForColumn:(NSUInteger)column
{
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.tag = TAG_BASE + column;
  button.layer.borderWidth = 1.0;
  button.layer.borderColor = [UIColor darkGrayColor].CGColor;
  [button addTarget:self action:@selector(didTouchButton:) forControlEvents:UIControlEventTouchUpInside];
  [self.contentView addSubview:button];

  return button;
}

@end
