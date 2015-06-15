//
//  XANThumbCell.h
//  XANPhotoBrowser
//
//  Created by Chen Xian'an on 12/17/10.
//  Copyright 2010 lazyapps.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XANThumbsCell;

@protocol XANThumbsCellDelegate <NSObject>
- (void)cell:(XANThumbsCell *)cell didSelectThumbAtColumn:(NSUInteger)column inRow:(NSUInteger)rowIndex;
@end

@interface XANThumbsCell : UITableViewCell {
  NSUInteger numberOfThumbs;
  NSUInteger capacityOfThumbs;
  NSUInteger rowIndex;
  id <XANThumbsCellDelegate> thumbDelegate;
}

@property (nonatomic) NSUInteger numberOfThumbs;
@property (nonatomic) NSUInteger capacityOfThumbs;
@property (nonatomic) NSUInteger rowIndex;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier thumbDelegate:(id <XANThumbsCellDelegate>)thumbDelegate;
- (void)updateImage:(UIImage *)image forColumn:(NSUInteger)column;

@end
