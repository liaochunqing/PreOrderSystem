//
//  SocketPrinterFunctions.h
//  PreOrderSystem
//
//  Created by sWen on 13-10-22.
//
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@class QueueAddArrangDataClass;

/**
 * @brief   打印机操作类。
 *
 */
@interface SocketPrinterFunctions : NSObject<AsyncSocketDelegate>
{
    
}

/**
 * @brief   初始化打印机。
 *
 * @param   printerName 打印机名称。
 * @param   hostStr 打印机IP地址。
 * @param   type    打印尺寸类型（1000为58mm，2000为80mm）。
 * @param   brand   打印机品牌（0为普通打印机，1为Star打印机）。
 * @param   flag    是否显示错误提示。
 *
 */
- (id)initSocketPrinter:(NSString *)printerName
          withPrinterIP:(NSString *)hostStr
        withPrinterType:(int)type
       withPrinterBrand:(int)brand
          withErrorFlag:(BOOL)flag;

/**
 * @brief   获取所有的打印机。
 *
 * @param   socketObjectArray   打印机数组（获取到的打印机全部存到这里）。
 */
+ (void)getSocketPrinterObject:(NSMutableArray *)socketObjectArray mode:(NSInteger)mode;

/**
 * @brief   打印测试收据。
 *
 */
- (void)printTestReceipt;

/**
 * @brief   打印购物车菜单收据。
 *
 * @param   dishListArray   数据列表。
 * @param   areaName    区域名称。
 * @param   housingName 房间、桌面名称。
 *
 */
- (void)printDtMenuShoppingCarDishReceipt:(NSArray *)dishListArray
                           withDtAreaName:(NSString *)areaName
                        withDtHousingName:(NSString *)housingName 
                              operateType:(int)operateType;

/**
 * @brief   打印普通菜单。
 *
 * @param   dishDetailDict  菜单数据。
 *
 */
- (void)printDishReceipt:(NSDictionary *)dishDetailDict;

/**
 * @brief   打印排队收据。
 *
 * @param   addArrangDataClass  排队信息。
 */
- (void)printQueueReceiptWithName:(QueueAddArrangDataClass *)addArrangDataClass;

@end
