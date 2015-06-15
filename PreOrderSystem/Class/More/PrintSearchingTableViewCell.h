//
//  PrintSearchingTableViewCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-4-24.
//
//


#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class PortInfo;

@interface PrintSearchingTableViewCell : UITableViewCell <MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UIButton *connectStatus;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *ipLabel;

@property (nonatomic, strong) PortInfo *printerInfo;//打印机信息

@property (nonatomic) NSInteger connectedStatus;//连接状态
- (void)updatePrinterInfo:(PortInfo *)info defaultSearchingPrinterArray:(NSArray*)array;
// 默认主动连接外面已有的打印机，根据mac地址匹配
- (void)defaultConnected:(PortInfo *)info defaultSearchingPrinterArray:(NSArray*)array;
@end
