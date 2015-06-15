//
//  MemoPicker.h
//  PreOrderSystem
//
//  Created by AaronKwok on 12-8-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MemoPicker;
@protocol MemoPickerDelegate <NSObject>
-(void)MemoPicker:(MemoPicker*)picker didPickedMemo:(NSString*)memo;

@end
@interface MemoPicker : UIViewController<UIScrollViewDelegate>{
    __weak id <MemoPickerDelegate> delegate;
    __weak UIImageView *backImageView;
    NSArray *memosListArray;
    
    NSMutableArray *typeBtnsArray;
    NSMutableArray *memosViewArray;
    NSMutableArray *memoPageControlsArray;
    int selectedTypeIndex;
    //判断页面是否在显示
    BOOL isShowing;
}
@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) IBOutlet UIImageView *backImageView;
@property (nonatomic, assign)  BOOL isShowing;

//Public Methods
-(void)showInView:(UIView*)aView atPoint:(CGPoint)point;
-(void)dismissView;


@end
