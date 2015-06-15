//
//  PrintSearchingViewController.h
//  PreOrderSystem
//
//  Created by SWen on 14-4-24.
//
//

#import <UIKit/UIKit.h>
@class PrintSearchingViewController;
@class PrintSearchingTableViewCell;

@protocol PrintSearchingViewControllerDelegate <NSObject>

- (void)PrintSearchingViewController:(PrintSearchingViewController*)ctrl withConnectedCell:(NSMutableArray *) cellArray;

@end

@interface PrintSearchingViewController : UIViewController
@property (nonatomic,weak) id<PrintSearchingViewControllerDelegate> delegate;
@property (nonatomic,strong) NSArray* defaultSearchingPrinterArray;
//@property (nonatomic,strong) NSString* customName;
@end
