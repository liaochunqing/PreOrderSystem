//
//  PrinterDataClass.h
//  PreOrderSystem
//
//  Created by SWen on 14-1-6.
//
//

#import <Foundation/Foundation.h>
#import "StarIO/SMPort.h"
#import "PrintManagementTableViewCell.h"

#define kTemporaryPrinterDataKey @"temporaryprinterDataKey"
#define kForeverPrinterDataKey @"foreverPrinterDataKey"
#define kPrinterFirstType 1000
#define kPrinterSecondType 2000
#define kPrinterStar @"printerStar"
#define kPrinterName @"printerName"
#define kPrinterIP @"printerIP"
#define kPrinterMac @"printerMac"
#define kPrinterType @"printerType"
#define kisOrderdishBtnCheck @"isOrderdishBtnCheck"
#define kisKitchenBtnCheck @"isKitchenBtnCheck"
#define kisTakeoutBtnCheck @"isTakeoutBtnCheck"
#define kisQueueBtnCheck @"isQueueBtnCheck"

@interface PrinterDataClass : NSObject

@property (nonatomic) BOOL isOrderdishBtnCheck;
@property (nonatomic) BOOL isKitchenBtnCheck;
@property (nonatomic) BOOL isTakeoutBtnCheck;
@property (nonatomic) BOOL isQueueBtnCheck;

@property (nonatomic, strong) NSString *printerMac;
@property (nonatomic, strong) NSString *printerName;
@property (nonatomic, strong) NSString *printerIPStr;
@property (nonatomic, assign) int printerType;
@property (nonatomic, strong) NSString *printerStar;

- (id)initWithPrinterData:(NSDictionary *)dict;
+ (void)addNewPrinterData;
+ (void)addNewStrPrinterData:(PortInfo *)info;
+ (void)modifyPrinterDataWithName:(NSString *)nameStr withPrinterIPStr:(NSString *)ipStr withPrinterType:(int)type withIndex:(int)index;
+ (void)modifyPrinterDataWithName:(NSString *)nameStr withIndex:(int)index;
+ (void)modifyPrinterDataWithPrinterIPStr:(NSString *)ipStr withIndex:(int)index;
+ (void)modifyPrinterDataWithPrinterType:(int)type withIndex:(int)index;
+ (void)modifyPrinterDataWithCell:(PrintManagementTableViewCell *)cell  withIndex:(int)index;
+ (NSArray *)getPrinterData:(NSString *)key;
+ (void)saveTemporaryPrinterData:(NSArray *)tempArray;
+ (void)saveForeverPrinterData:(NSArray *)tempArray;
+ (void)deletePrinterData:(int)index;
+ (BOOL)allowAddNewPrinter;
@end
