//
//  DiningTableGuideView.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-20.
//
//

#import <UIKit/UIKit.h>

#import "CustomUIView.h"

@class DiningTableGuideView;
@protocol DiningTableGuideViewDelegate <NSObject>

- (void)guideViewHavedDismiss:(DiningTableGuideView *)viewClass;

@end

@interface DiningTableGuideView : CustomUIView

@property (nonatomic, weak) id <DiningTableGuideViewDelegate> delegate;


@end
