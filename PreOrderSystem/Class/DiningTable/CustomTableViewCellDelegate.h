//
//  CustomTableViewCellDelegate.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-24.
//
//

#import <Foundation/Foundation.h>

@protocol CustomTableViewCellDelegate <NSObject>

- (void)keyboardShow:(id)cell;
- (void)keyboardHide:(id)cell;

@end
