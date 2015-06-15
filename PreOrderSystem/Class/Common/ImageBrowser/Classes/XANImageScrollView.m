//
//  XANImageScrollView.m
//  XANPhotoBrowser
//
//  Created by Chen Xian'an on 12/18/10.
//  Copyright 2010 lazyapps.com. All rights reserved.
//

#import "XANImageScrollView.h"

@implementation XANImageScrollView
@synthesize imageView, image;
@synthesize index;

- (void)setImage:(UIImage *)theImage
{
  [theImage retain];
  [image release];
  image = theImage;

  if (image == nil){
    imageView.image = nil;
    return;
  }
  
  imageView.image = image;
  [self updateLayout];
}

- (id)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]){
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.autoresizesSubviews = NO;
    imageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:imageView];
    [imageView release];
    self.backgroundColor = [UIColor blackColor];
    self.delegate = self;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    [doubleTap release];
  }                                             
  
  return self;
}

- (void)updateLayout
{
  self.zoomScale = 1.0;
  self.minimumZoomScale = 1.0;
  
  CGSize imageSize = image.size;
  CGSize finalSize = self.bounds.size;
  if (imageSize.width > imageSize.height){
    finalSize.height = imageSize.height * (finalSize.width/imageSize.width);
    if (finalSize.height > self.frame.size.height){
      finalSize.width *= (self.frame.size.height/finalSize.height);
      finalSize.height = self.frame.size.height;
    }
  } else {
    finalSize.width = imageSize.width * (finalSize.height/imageSize.height);
    if (finalSize.width > self.frame.size.width){
      finalSize.height *= (self.frame.size.width/finalSize.width);
      finalSize.width = self.frame.size.width;
    }
  }
  
  imageView.frame = CGRectMake(0, 0, finalSize.width, finalSize.height);
  
  CGFloat maximumZoomScale = imageSize.height / finalSize.height;
  if (maximumZoomScale < 2.0) maximumZoomScale = 2.0;
  self.maximumZoomScale = maximumZoomScale;
  
  [self setNeedsLayout];
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  CGSize boundsSize = self.bounds.size;
  CGRect frameToCenter = imageView.frame;
  
  if (frameToCenter.size.width < boundsSize.width)
    frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
  else
    frameToCenter.origin.x = 0;
  
  if (frameToCenter.size.height < boundsSize.height)
    frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
  else 
    frameToCenter.origin.y = 0;

  imageView.frame = frameToCenter;
}

- (void)dealloc
{
  [super dealloc];
}

#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
  return imageView;
}

#pragma mark -
#pragma mark UIGestureRecognizer actions
- (void)handleDoubleTap:(UITapGestureRecognizer *)tgr
{
  float scale = self.zoomScale > self.minimumZoomScale
    ? self.minimumZoomScale
    : self.maximumZoomScale;
  CGPoint center = [tgr locationInView:self];
  CGRect zoomRect;
  zoomRect.size.height = self.bounds.size.height / scale;
  zoomRect.size.width = self.bounds.size.width  / scale;  
  zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
  zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
  
  [self zoomToRect:zoomRect animated:YES];
}

@end
