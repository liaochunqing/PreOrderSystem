//
//  SocketPrinterFunctions.m
//  PreOrderSystem
//
//  Created by sWen on 13-10-22.
//
//

#import "SocketPrinterFunctions.h"
#import "AccountManager.h"
#import "NsstringAddOn.h"
#import "Constants.h"
#import "PrinterDataClass.h"
#import "DtMenuDataClass.h"
#import "QueueAddArrangDataClass.h"
#import "UIImageAddOn.h"
#import "UIDevice+platform.h"


#define kNormalTimeout 10
#define kMaxTimeout -1

@interface SocketPrinterFunctions () {
    
    /// socket对象
    AsyncSocket *asyncSocket;
    
    /// 当前打印机名称
    NSString *currentPrinterName;
    
    /// 当前打印机IP地址
    NSString *currentHostStr;
    
    /// 当前打印机尺寸
    int currentPrinterType;
    
    /// 当前打印机品牌
    int currentPrinterBrand;
    
    /// 是否显示错误提示
    BOOL isShowError;
}
@end

@implementation SocketPrinterFunctions

- (id)initSocketPrinter:(NSString *)printerName
          withPrinterIP:(NSString *)hostStr
        withPrinterType:(int)type
       withPrinterBrand:(int)brand
          withErrorFlag:(BOOL)flag
{
    self = [super init];
    if(self)
    {
        asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
        currentPrinterName = printerName;
        currentHostStr = hostStr;
        currentPrinterType = type;
        currentPrinterBrand = brand;
        isShowError = flag;
    }
    return self;
}

- (void)dealloc
{
    [asyncSocket setDelegate:nil];
    [asyncSocket  disconnect];
}

+ (void)getSocketPrinterObject:(NSMutableArray *)socketObjectArray mode:(NSInteger)mode
{
    NSArray *tempArray = [PrinterDataClass getPrinterData:kForeverPrinterDataKey];
    int tempCount = (int)[tempArray count];
    for (int i = 0; i < tempCount; i++)
    {
        PrinterDataClass *tempClass = [[PrinterDataClass alloc] initWithPrinterData:[tempArray objectAtIndex:i]];
        NSString *nameStr = [NSString getStrWithoutWhitespace:tempClass.printerName];
        NSString *hostStr = [NSString getStrWithoutWhitespace:tempClass.printerIPStr];
        int type = tempClass.printerType;
        BOOL brand = ([tempClass.printerStar length] > 0);
        
        if (nameStr.length > 0
            && hostStr.length > 0
            && (type == kPrinterFirstType || type == kPrinterSecondType))
        {
            if ((mode == kPrinterModeOrderdish && tempClass.isOrderdishBtnCheck)
                || (mode == kPrinterModeKitch && tempClass.isKitchenBtnCheck)
                || (mode == kPrinterModeTakeout && tempClass.isTakeoutBtnCheck)
                || (mode == kPrinterModeQueue && tempClass.isQueueBtnCheck))
            {
                [socketObjectArray addObject:[[SocketPrinterFunctions alloc] initSocketPrinter:nameStr
                                                                                 withPrinterIP:hostStr
                                                                               withPrinterType:type
                                                                              withPrinterBrand:brand
                                                                                 withErrorFlag:NO]];
            }
        }
    }
}

- (void)startPrint:(NSData *)printData withPrinterHost:(NSString *)hostStr wihtPrinterType:(int)type
{
    NSError *err = nil;
    UInt16 port = 9100;
    [asyncSocket disconnect];
    if([asyncSocket connectToHost:hostStr onPort:port withTimeout:kNormalTimeout error:&err])
    {
        [asyncSocket writeData:printData withTimeout:kMaxTimeout tag:0];
    }
#ifdef DEBUG
    NSLog(@"===host:%@,type:%d,Error: %@===",hostStr, type,[err localizedDescription]);
#endif
}

- (const void *)commandNamed:(NSString *)name
{
    name = [name uppercaseString];
    if ([name isEqualToString:@"INIT"]) {
        // 初始化
        if (currentPrinterBrand == 0) {
            return "\x1b\x40";  // {0x1b, 0x40};
        } else {
            return "\x1b\x40";
        }
    } else if ([name isEqualToString:@"AUTORUN"]) {
        // 走纸
        if (currentPrinterBrand == 0) {
            return "\x1b\x64\x04\x0a"; // {27, 100, 4, 10}
        } else {
            // TODO
            return "\x1b\x61\x04\x0a";
        }
    } else if ([name isEqualToString:@"NORMALSIZE"]) {
        // 标准尺寸
        if (currentPrinterBrand == 0) {
            return "\x1c\x21\x02\x1b\x21\x02"; // { 0x1C, 0x21, 2, 0x1B, 0x21, 2 }
        } else {
            return "\x1b\x69\x00\x00";
        }
    } else if ([name isEqualToString:@"ZOOMSCALE"]) {
        // 放大
        if (currentPrinterBrand == 0) {
            return "\x1c\x21\x0c\x1b\x21\x30"; // { 0x1C, 0x21, 12, 0x1B, 0x21, 48 }
        } else {
            return "\x09\x09\x1b\x69\x01\x01";
        }
    } else if ([name isEqualToString:@"ALIGNLEFT"]) {
        // 左对齐
        if (currentPrinterBrand == 0) {
            return "\x1b\x61\x00"; // { 0x1b, 'a', 0x00 }
        } else {
            return "\x1b\x1d\x61\x00";
        }
    } else if ([name isEqualToString:@"ALIGNCENTER"]) {
        // 居中对齐
        if (currentPrinterBrand == 0) {
            return "\x1b\x61\x01"; // { 0x1b, 'a', 0x01 }
        } else {
            return "\x1b\x1d\x61\x01";
        }
    } else if ([name isEqualToString:@"ALIGNRIGHT"]) {
        // 右对齐
        if (currentPrinterBrand == 0) {
            return "\x1b\x61\x02"; // { 0x1b, 'a', 0x02 }
        } else {
            return "\x1b\x1d\x61\x02";
        }
    } else if ([name isEqualToString:@"BOLD"]) {
        // 加粗
        if (currentPrinterBrand == 0) {
            return "\x1b\x45\x01"; // { 0x1B, 0x45, 1 }
        } else {
            return "\x1b\x45";
        }
    } else if ([name isEqualToString:@"UNBOLD"]) {
        // 取消加粗
        if (currentPrinterBrand == 0) {
            return "\x1b\x45\x00"; // { 0x1B, 0x45, 0 }
        } else {
            return "\x1b\x46";
        }
    } else if ([name isEqualToString:@"CUTPAPER"]) {
        // 切纸
        if (currentPrinterBrand == 0) {
            return "\x1b\x69"; // {0x1B, 0x69}
        } else {
            return "\x1b\x64\x02";
        }
    } else {
        return "";
    }
}

- (NSUInteger)commandSizeNamed:(NSString *)name
{
    name = [name uppercaseString];
    if ([name isEqualToString:@"INIT"]) {
        // 初始化
        return 2;
    } else if ([name isEqualToString:@"AUTORUN"]) {
        // 走纸
        if (currentPrinterBrand == 0) {
            return 4; // {27, 100, 4, 10}
        } else {
            // TODO
            return 4;
        }
    } else if ([name isEqualToString:@"NORMALSIZE"]) {
        // 标准尺寸
        if (currentPrinterBrand == 0) {
            return 6; // { 0x1C, 0x21, 2, 0x1B, 0x21, 2 }
        } else {
            // TODO
            return 4;
        }
    } else if ([name isEqualToString:@"ZOOMSCALE"]) {
        // 放大
        if (currentPrinterBrand == 0) {
            return 6; // { 0x1C, 0x21, 12, 0x1B, 0x21, 48 }
        } else {
            return 6;
        }
    } else if ([name isEqualToString:@"ALIGNLEFT"]) {
        // 左对齐
        if (currentPrinterBrand == 0) {
            return 3;; // { 0x1b, 'a', 0x00 }
        } else {
            return 4;
        }
    } else if ([name isEqualToString:@"ALIGNCENTER"]) {
        // 居中对齐
        if (currentPrinterBrand == 0) {
            return 3; // { 0x1b, 'a', 0x01 }
        } else {
            return 4;
        }
    } else if ([name isEqualToString:@"ALIGNRIGHT"]) {
        // 右对齐
        if (currentPrinterBrand == 0) {
            return 3; // { 0x1b, 'a', 0x02 }
        } else {
            return 4;
        }
    } else if ([name isEqualToString:@"BOLD"]) {
        // 加粗
        if (currentPrinterBrand == 0) {
            return 3; // { 0x1B, 0x45, 1 }
        } else {
            return 2;
        }
    } else if ([name isEqualToString:@"UNBOLD"]) {
        // 取消加粗
        if (currentPrinterBrand == 0) {
            return 3; // { 0x1B, 0x45, 0 }
        } else {
            return 2;
        }
    } else if ([name isEqualToString:@"CUTPAPER"]) {
        // 切纸
        if (currentPrinterBrand == 0) {
            return 2; // {0x1B, 0x69}
        } else {
            return 3;
        }
    } else {
        return 0;
    }
}

#pragma mark - printTest

- (NSInteger)paperWidthInPixels
{
    CGFloat scale = 1;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [[UIScreen mainScreen] scale];
    }
    
    CGFloat dpi = [UIDevice dpiForDevice];
    CGFloat widthInMillimeter = 0.0;
    if (currentPrinterType == 1000) {
        widthInMillimeter = 58;
    } else {
        widthInMillimeter = 80;
    }
    //    象素数 / DPI = 英寸数
    //    英寸数 * 25.4 = 毫米数
    return floor((widthInMillimeter / 24.5) * dpi);
}

// 打印测试
- (void)printTestReceipt
{
    [self printTestFormat:currentHostStr wihtPrinterType:currentPrinterType];
}

//打印测试的格式
- (void)printTestFormat:(NSString *)hostStr wihtPrinterType:(int)type
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSChineseSimplif);
    NSMutableData *commands = [[NSMutableData alloc] init];
    [commands appendBytes:[self commandNamed:@"INIT"] length:[self commandSizeNamed:@"INIT"]];
    
    if (currentPrinterBrand == 1) {
        [commands appendBytes:"\x1b\x20\x00" length:3];
    }
    
    //-----标题，如：(居中显示)
    [commands appendBytes:[self commandNamed:@"ALIGNCENTER"]
                   length:[self commandSizeNamed:@"ALIGNCENTER"]];
    [commands appendBytes:[self commandNamed:@"BOLD"]
                   length:[self commandSizeNamed:@"BOLD"]];
    [commands appendBytes:[self commandNamed:@"ZOOMSCALE"]
                   length:[self commandSizeNamed:@"ZOOMSCALE"]];
    
    AccountManager *accountMgr = [AccountManager sharedAccountManager];
    [commands appendData:[[accountMgr getRestaurantName] dataUsingEncoding:enc]];
    [commands appendData:[@"\r\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    [commands appendData:[kLoc(@"print_test") dataUsingEncoding:enc]];
    [commands appendData:[@"\r\n\r\n\r\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    if (currentPrinterBrand == 0) {
        [commands appendBytes:[self commandNamed:@"AUTORUN"]
                       length:[self commandSizeNamed:@"AUTORUN"]];
    }

    [commands appendBytes:[self commandNamed:@"CUTPAPER"]
                   length:[self commandSizeNamed:@"CUTPAPER"]];
    
    //打印
    [self startPrint:commands withPrinterHost:hostStr wihtPrinterType:type];
    
    /*
    [commands appendBytes:[self commandNamed:@"INIT"] length:[self commandSizeNamed:@"INIT"]];
    // 设置行间距为24dot（如果不设置会出现图片间距）
    [commands appendBytes:"\x1b\x33\x18" length:3];
    
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    NSInteger paperWidth = [self paperWidthInPixels];
    CGSize paperSize = CGSizeMake(paperWidth, paperWidth); // ceil(paperWidth * 200.0 / window.bounds.size.width)
    UIGraphicsBeginImageContext(paperSize);
    
//    AccountManager *accountMgr = [AccountManager sharedAccountManager];
//    NSString *printText = [NSString stringWithFormat:@"%@\r\n%@",
//                           [accountMgr getRestaurantName], kLoc(@"打印测试", nil)];
    
    UIImage *srcImage = [UIImage imageNamed:@"print_test"];
    
    CGContextRef ctr = UIGraphicsGetCurrentContext();
    UIColor *color = [UIColor whiteColor];
    [color set];
    
    CGRect rect = CGRectMake(0, 0, paperSize.width, paperSize.height);
    CGContextFillRect(ctr, rect);
    
    color = [UIColor blackColor];
    [color set];
    
    [srcImage drawInRect:rect];
    
//    [printText drawInRect:rect withFont:[UIFont boldSystemFontOfSize:30.0] lineBreakMode:NSLineBreakByWordWrapping];
    
    UIImage *textImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    const char *bitmapChar = (const char *)[textImage bitmapRGBA8Chars];
    NSString *bitmapString = [NSString stringWithCString:(const char *)bitmapChar
                                                encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", bitmapString);
    
    char bmpBytes[5] = "\x1b\x2a\x21\x00\x00";
    
    NSInteger nL = (int)paperSize.width % 256;
    NSInteger nH = paperSize.width / 256;
    bmpBytes[3] = nL;
    bmpBytes[4] = nH;
    
    int fmtSize = sizeof(bmpBytes) / sizeof(char);
    NSData *bmpFmtData = [NSData dataWithBytes:bmpBytes length:fmtSize];
    
    for (NSInteger i = 0; i < paperSize.height / 24 + 1; i++) {
        [commands appendData:[bmpFmtData copy]];
        
        for (NSInteger j = 0; j < paperSize.width; j++) {
            
            char dataBytes[3] = "\x00\x00\x00";
            
            for (NSInteger k = 0; k < 24; k++) {
                if (((i * 24) + k) < paperSize.height) {
                    // if within the BMP size
                    NSInteger charIndex = (i * 24 + k) * paperSize.width + j;
                    NSString *charString = [bitmapString substringWithRange:NSMakeRange(charIndex, 1)];
                    
                    if ([charString isEqualToString:@"1"]) {
                        dataBytes[k / 8] += (128 >> (k % 8));
                    }
                }
            }
            
            int dataSize = sizeof(dataBytes) / sizeof(char);
            NSData *itemData = [NSData dataWithBytes:dataBytes length:dataSize];
            
            [commands appendData:itemData];
        }
        
        [commands appendData:[@"\r\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    }
    
    // 还原行间距为30dot（如果不设置会出现走纸异常）
    [commands appendBytes:"\x1b\x33\x1e" length:3];
    
    if (currentPrinterBrand == 0) {
        [commands appendBytes:[self commandNamed:@"AUTORUN"]
                       length:[self commandSizeNamed:@"AUTORUN"]];
    }
    
    [commands appendBytes:[self commandNamed:@"CUTPAPER"]
                   length:[self commandSizeNamed:@"CUTPAPER"]];
    
    //打印
    [self startPrint:commands withPrinterHost:hostStr wihtPrinterType:type];
    */
}

#pragma mark - print dtMenu shoppingCar Data

//打印购物车菜单
- (void)printDtMenuShoppingCarDishReceipt:(NSArray *)dishListArray
                           withDtAreaName:(NSString *)areaName
                        withDtHousingName:(NSString *)housingName
                              operateType:(int)operateType
{
    [self printDtMenuShoppingCarDishReceiptFormat:dishListArray withPrinterHost:currentHostStr wihtPrinterType:currentPrinterType withDtAreaName:areaName withDtHousingName:housingName operateType:operateType];
}

//打印购物车的菜单格式
- (void)printDtMenuShoppingCarDishReceiptFormat:(NSArray *)dishArray withPrinterHost:(NSString *)hostStr wihtPrinterType:(int)type withDtAreaName:(NSString *)areaName withDtHousingName:(NSString *)housingName operateType:(int)operateType
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSChineseSimplif);
    AccountManager *accountMgr = [AccountManager sharedAccountManager];
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    if (currentPrinterBrand == 1) {
        [commands appendBytes:"\x1b\x20\x00" length:3];
    }
    
    //-----餐厅名称或其他：(居中显示)
    [commands appendBytes:[self commandNamed:@"ALIGNCENTER"]
                   length:[self commandSizeNamed:@"ALIGNCENTER"]];
    [commands appendBytes:[self commandNamed:@"BOLD"]
                   length:[self commandSizeNamed:@"BOLD"]];
    [commands appendBytes:[self commandNamed:@"ZOOMSCALE"]
                   length:[self commandSizeNamed:@"ZOOMSCALE"]];
    if (operateType == -1) {
        // 不再打印名称
        [commands appendData:[[accountMgr getRestaurantName] dataUsingEncoding:enc]];
        [commands appendData:[@"\r\n" dataUsingEncoding:NSShiftJISStringEncoding]];
        [commands appendData:[[NSString stringWithFormat:@"%@  %@\r\n\r\n", areaName, housingName] dataUsingEncoding:enc]];
    } else {
        switch (operateType) {
            case 0: {
                NSString *reprintStr = [NSString stringWithFormat:@"%@",
                                        kLoc(@"reprint_the_kitchen_order")];
                [commands appendData:[reprintStr dataUsingEncoding:enc]];
                break;
            }
            case 1: {
                [commands appendData:[kLoc(@"kitchen_order") dataUsingEncoding:enc]];
                break;
            }
            case 2: {
                NSString *reprintStr = [NSString stringWithFormat:@"%@（%@）",
                                        kLoc(@"confirm_order2"),
                                        kLoc(@"reprint")];
                [commands appendData:[reprintStr dataUsingEncoding:enc]];
                break;
            }
            case 3: {
                [commands appendData:[kLoc(@"confirm_order2") dataUsingEncoding:enc]];
                break;
            }
            default:
                break;
        }
        
        [commands appendData:[@"\r\n\r\n" dataUsingEncoding:enc]];
    }
    
    [commands appendBytes:[self commandNamed:@"UNBOLD"]
                   length:[self commandSizeNamed:@"UNBOLD"]];
    [commands appendBytes:[self commandNamed:@"ALIGNLEFT"]
                   length:[self commandSizeNamed:@"ALIGNLEFT"]];
    [commands appendBytes:[self commandNamed:@"NORMALSIZE"]
                   length:[self commandSizeNamed:@"NORMALSIZE"]];
    
    housingName = [housingName stringByReplacingOccurrencesOfString:@" " withString:@""];
    areaName = [areaName stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // 房台名称
    [commands appendData:[[NSString stringWithFormat:@"%@: %@ %@ \r\n",
                            kLoc(@"table"), areaName, housingName]
                          dataUsingEncoding:enc]];
    
    // 出票时间，左对齐
    NSString *nowStr = [NSString dateToNSString:[NSDate date] withFormat:@"yyyy-MM-dd HH:mm:ss"];
    [commands appendData:[[NSString stringWithFormat:@"%@: %@\r\n", kLoc(@"out_ticket_time"), nowStr] dataUsingEncoding:enc]];
    //餐厅地址
//    [commands appendData:[[NSString stringWithFormat:@"%@: %@\r\n", kLoc(@"餐厅地址", nil), [accountMgr getRestaurantAddress]] dataUsingEncoding:enc]];
    
    /******************根据打印机类型，对菜单数据设置不同的打印格式****************/
    //------分割线(左对齐)
    NSMutableString *separationStr = [NSMutableString stringWithFormat:@"%@\r\n", [self getSeparationLineByNum:32 withPrinterType:type]];
    [commands appendData:[separationStr dataUsingEncoding:enc]];
    //菜品
    [commands appendData:[kLoc(@"dishes") dataUsingEncoding:enc]];
    //数量
    NSMutableString *numTitleSpace = [self getSpaceByPrice:0 withMaxSpaceNum:11 withShowLeft:NO withPrinterType:type];
    [commands appendData:[numTitleSpace dataUsingEncoding:enc]];
    [commands appendData:[kLoc(@"numbers") dataUsingEncoding:enc]];
    //小计
    NSMutableString *sumTitleSpace = [self getSpaceByPrice:0 withMaxSpaceNum:10 withShowLeft:NO withPrinterType:type];
    [commands appendData:[sumTitleSpace dataUsingEncoding:enc]];
    //[commands appendData:[kLoc(@"小计\r\n", nil) dataUsingEncoding:enc]];
    [commands appendData:[[NSString stringWithFormat:@"%@\r\n",kLoc(@"subtotal")] dataUsingEncoding:enc]];

    //------菜的详细内容(左对齐)
    int totalQty = 0;//总份数
    CGFloat totalSum = 0;//总金额
    int listCount = (int)[dishArray count];
    for (int k = 0; k < listCount; k++)
    {
        DtMenuShoppingCarDataClass *shoppingCarClass = [[DtMenuShoppingCarDataClass alloc] initWithDtMenuShoppingCarData:[dishArray objectAtIndex:k]];
        
        //菜名，左对齐
        NSString *dishesName = shoppingCarClass.name;
        NSString *currentStyle = shoppingCarClass.currentStyle;
        if (shoppingCarClass.isMultiStyle &&
            ![NSString strIsEmpty:[NSString getStrWithoutWhitespace:currentStyle]]) {
            dishesName = [NSString stringWithFormat:@"%@(%@)", shoppingCarClass.name, currentStyle];
        }
        //数量，右对齐
        int quanty = shoppingCarClass.quantity;
        totalQty = totalQty + quanty;
        NSString *quantyStr = [NSString stringWithFormat:@"%d",quanty];
        //价格，右对齐
        CGFloat currentDishSum = [shoppingCarClass.currentPriceStr floatValue] * quanty;
        totalSum += currentDishSum;
        NSMutableString *priceSpace = [self getSpaceByPrice:currentDishSum withMaxSpaceNum:12 withShowLeft:NO withPrinterType:type];
        NSString *priceStr = [NSString stringWithFormat:@"%@%.2f",priceSpace,currentDishSum];
        //是否是套餐
        NSMutableArray *packageArray = shoppingCarClass.packageArray;
        int packageCount = (int)[packageArray count];
        if (0 != packageCount)
        {
            [commands appendBytes:[self commandNamed:@"ALIGNLEFT"]
                           length:[self commandSizeNamed:@"ALIGNLEFT"]];
            [commands appendData:[[NSString stringWithFormat:@"%d.%@\r\n",k+ 1,dishesName] dataUsingEncoding:enc]];
            
            NSString *subTitleSpace = @"  ";
            for (int i = 0; i < packageCount; i++)
            {
                DtMenuCookbookPackageDataClass *packageClass = [[DtMenuCookbookPackageDataClass alloc] initWithDtMenuPackageData:[packageArray objectAtIndex:i]];
                
                //套餐的某个子项
                if ([self whetherShowItemName:packageClass])
                {
                    NSString *subTitle = [NSString getStrWithoutWhitespace:packageClass.itemName];
                    if (![NSString strIsEmpty:subTitle])
                    {
                        [commands appendData:[[NSString stringWithFormat:@"%@%@:\r\n",subTitleSpace,subTitle] dataUsingEncoding:enc]];
                    }
                    else
                    {
                        if (0 != i)
                        {
                            [commands appendData:[@"\r\n" dataUsingEncoding:enc]];
                        }
                    }
                    
                    //某个子项的详细内容
                    int selectedIndex = 0;
                    NSString *subListSpace = @"    ";
                    NSMutableArray *memberArray = packageClass.memberArray;
                    int memberCount = (int)[memberArray count];
                    for (int j = 0; j < memberCount; j++)
                    {
                        DtMenuCookbookPackageMemberDataClass *packageMemberClass = [[DtMenuCookbookPackageMemberDataClass alloc] initWithDtMenuPackageMemberData:[memberArray objectAtIndex:j]];
                        
                        if (1 == packageMemberClass.checked)
                        {
                            selectedIndex ++;
                            [commands appendData:[[NSString stringWithFormat:@"%@\r\n",[NSString stringWithFormat:@"%@%d)%@",subListSpace,selectedIndex, packageMemberClass.name]] dataUsingEncoding:enc]];
                        }
                    }
                }
            }
            //备注
            NSMutableArray *remarkArray = shoppingCarClass.currentRemarkArray;
            int remarkCount = (int)[remarkArray count];
            for (int h = 0; h < remarkCount; h++)
            {
                DtMenuCookbookRemarkDataClass *remarkClass = [[DtMenuCookbookRemarkDataClass alloc] initWithDtMenuRemarkData:[remarkArray objectAtIndex:h]];
                NSString *dishRemarkStr = [NSString getStrWithoutWhitespace:[self getDishRemarkStr:remarkClass.contentArray]];
                if (![NSString strIsEmpty:dishRemarkStr])
                {
                    [commands appendData:[[NSString stringWithFormat:@"  备注(%d份):%@\r\n", remarkClass.quantity, dishRemarkStr] dataUsingEncoding:enc]];
                }
            }
            //数量价格
            [commands appendBytes:[self commandNamed:@"ALIGNRIGHT"]
                           length:[self commandSizeNamed:@"ALIGNRIGHT"]];
            [commands appendData:[[NSString stringWithFormat:@"%@%@\r\n",quantyStr,priceStr] dataUsingEncoding:enc]];
        }
        else
        {
            [commands appendBytes:[self commandNamed:@"ALIGNLEFT"]
                           length:[self commandSizeNamed:@"ALIGNLEFT"]];
            [commands appendData:[[NSString stringWithFormat:@"%d.%@\r\n",k+ 1,dishesName] dataUsingEncoding:enc]];
            //备注
            NSMutableArray *remarkArray = shoppingCarClass.currentRemarkArray;
            int remarkCount = (int)[remarkArray count];
            for (int h = 0; h < remarkCount; h++)
            {
                DtMenuCookbookRemarkDataClass *remarkClass = [[DtMenuCookbookRemarkDataClass alloc] initWithDtMenuRemarkData:[remarkArray objectAtIndex:h]];
                NSString *dishRemarkStr = [NSString getStrWithoutWhitespace:[self getDishRemarkStr:remarkClass.contentArray]];
                if (![NSString strIsEmpty:dishRemarkStr])
                {
                    [commands appendData:[[NSString stringWithFormat:@"  %@(%d%@):%@\r\n",
                                           kLoc(@"remark"),
                                           remarkClass.quantity,
                                           kLoc(@"part"),
                                           dishRemarkStr] dataUsingEncoding:enc]];
                    
                }
            }
            //数量价格
            [commands appendBytes:[self commandNamed:@"ALIGNRIGHT"]
                           length:[self commandSizeNamed:@"ALIGNRIGHT"]];
            [commands appendData:[[NSString stringWithFormat:@"%@%@\r\n",quantyStr,priceStr] dataUsingEncoding:enc]];
        }
    }
    //------分割线(左对齐)
    [commands appendBytes:[self commandNamed:@"ALIGNLEFT"]
                   length:[self commandSizeNamed:@"ALIGNLEFT"]];
    [commands appendData:[separationStr dataUsingEncoding:enc]];
    //总共份数和总价格@"%.2f"
    NSString *totalQtyStr = [NSString stringWithFormat:@"共%d份", totalQty];
    NSString *tempSumStr = [NSString stringWithFormat:@"%.2f",totalSum];
    CGFloat tempSum = [tempSumStr floatValue];
    NSString *totalSumStr = [NSString stringWithFormat:@"%@%.1f0",
                             kLoc(@"total_price"), roundf(tempSum * kOneDecimal) / kOneDecimal];
    NSMutableString *finalSumSpace = [self getSpaceByPrice:tempSum withMaxSpaceNum:5 withShowLeft:NO withPrinterType:type];
    [commands appendBytes:[self commandNamed:@"ALIGNRIGHT"]
                   length:[self commandSizeNamed:@"ALIGNRIGHT"]];
    [commands appendData:[[NSString stringWithFormat:@"%@%@%@",totalQtyStr,finalSumSpace,totalSumStr] dataUsingEncoding:enc]];
    [commands appendData:[@"\r\n\r\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    if (currentPrinterBrand == 0) {
        [commands appendBytes:[self commandNamed:@"AUTORUN"]
                       length:[self commandSizeNamed:@"AUTORUN"]];
    }

    [commands appendBytes:[self commandNamed:@"CUTPAPER"]
                   length:[self commandSizeNamed:@"CUTPAPER"]];
    
    //打印
    [self startPrint:commands withPrinterHost:hostStr wihtPrinterType:type];
}

- (NSString *)getDishRemarkStr:(NSArray *)array
{
    NSMutableString *tempStr = [NSMutableString string];
    int contentCount = (int)[array count];
    for (int j = 0; j < contentCount; j++)
    {
        [tempStr appendString:[array objectAtIndex:j]];
        [tempStr appendString:@";"];
    }
    return tempStr;
}

- (BOOL)whetherShowItemName:(DtMenuCookbookPackageDataClass *)dataClass
{
    BOOL flag = NO;
    int tempMemberCount = (int)[dataClass.memberArray count];
    for (int j = 0; j < tempMemberCount; j++)
    {
        DtMenuCookbookPackageMemberDataClass *tempMemberClass = [DtMenuCookbookPackageMemberDataClass getPackageMemberDataClass:j withPackageDataClass:dataClass];
        if (tempMemberClass.checked)
        {
            flag = YES;
            break;
        }
    }
    return flag;
}

#pragma mark - print takeOutDish

//打印菜单
- (void)printDishReceipt:(NSDictionary *)dishDetailDict
{
    [self printDishReceiptFormat:dishDetailDict withPrinterHost:currentHostStr wihtPrinterType:currentPrinterType];
}

//打印的菜单格式
- (void)printDishReceiptFormat:(NSDictionary *)dishDetailDict withPrinterHost:(NSString *)hostStr wihtPrinterType:(int)type
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSChineseSimplif);
    
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    [commands appendBytes:[self commandNamed:@"INIT"] length:[self commandSizeNamed:@"INIT"]];
    
    if (currentPrinterBrand == 1) {
        [commands appendBytes:"\x1b\x20\x00" length:3];
    }
    
    //-----(居中显示)
    [commands appendBytes:[self commandNamed:@"ALIGNCENTER"]
                   length:[self commandSizeNamed:@"ALIGNCENTER"]];
    [commands appendBytes:[self commandNamed:@"BOLD"]
                   length:[self commandSizeNamed:@"BOLD"]];
    [commands appendBytes:[self commandNamed:@"ZOOMSCALE"]
                   length:[self commandSizeNamed:@"ZOOMSCALE"]];
//    [commands appendData:[kLoc(@"etable_takeout_order") dataUsingEncoding:enc]];
    [commands appendData:[[NSString stringWithFormat:@"%@\r\n",[dishDetailDict objectForKey:@"corpName"]] dataUsingEncoding:enc]];
    [commands appendData:[[NSString stringWithFormat:@"%@\r\n",kLoc(@"takeout_order")] dataUsingEncoding:enc]];
    [commands appendBytes:[self commandNamed:@"UNBOLD"]
                   length:[self commandSizeNamed:@"UNBOLD"]];
    [commands appendBytes:[self commandNamed:@"ALIGNLEFT"]
                   length:[self commandSizeNamed:@"ALIGNLEFT"]];
    [commands appendBytes:[self commandNamed:@"NORMALSIZE"]
                   length:[self commandSizeNamed:@"NORMALSIZE"]];
    //------餐厅名,电话(左对齐)
//    NSString *corpName = [dishDetailDict objectForKey:@"corpName"];
    [commands appendBytes:[self commandNamed:@"ALIGNRIGHT"]
                   length:[self commandSizeNamed:@"ALIGNRIGHT"]];
    [commands appendData:[[NSString stringWithFormat:@"%@:%@\r\n\r\n",NSLocalizedString(@"外卖电话", nil), [dishDetailDict objectForKey:@"corpPhone"]] dataUsingEncoding:enc]];
    //------称呼,手机(左对齐)
    [commands appendBytes:[self commandNamed:@"ALIGNLEFT"]
                   length:[self commandSizeNamed:@"ALIGNLEFT"]];
    NSString *nameStr = [NSString firstNameWithTitle:[dishDetailDict objectForKey:@"guestName"] withSex:[[dishDetailDict objectForKey:@"guestSex"] intValue]];
    [commands appendData:[[NSString stringWithFormat:@"%@ %@\r\n",nameStr,[dishDetailDict objectForKey:@"guestPhone"]] dataUsingEncoding:enc]];
    //------下单时间(左对齐)
    NSString *orderDateStr = [dishDetailDict objectForKey:@"orderTime"];
    NSDate *orderDate = [orderDateStr stringToNSDateWithFormat:@"yyyy-MM-dd HH:mm"];
    orderDateStr = [NSString dateToNSString:orderDate withFormat:@"yyyy-MM-dd HH:mm"];
    NSString *orderTimeStr = kLoc(@"order_time");
    [commands appendData:[[NSString stringWithFormat:@"%@：%@\r\n",orderTimeStr,orderDateStr] dataUsingEncoding:enc]];
    //------自取时间/送达时间(左对齐)
    int deliveryType = [[dishDetailDict objectForKey:@"deliveryType"] intValue];
    int mealDateType = [[dishDetailDict objectForKey:@"carryTimeType"] intValue];
    NSString *keyStr = (0 == mealDateType)?@"carryTime":@"carryTimeTypeDesc";
    NSString *mealTimesStr = [dishDetailDict objectForKey:keyStr];
    
    if (0 == deliveryType)
    {
        NSString *timeStr = kLoc(@"reach_time");
        [commands appendData:[[NSString stringWithFormat:@"%@：%@\r\n",timeStr,mealTimesStr] dataUsingEncoding:enc]];
        
        //------地址(左对齐)
        NSString *addressStr = kLoc(@"address");
        [commands appendData:[[NSString stringWithFormat:@"%@：%@\r\n",addressStr,[dishDetailDict objectForKey:@"address"]] dataUsingEncoding:enc]];
    }
    else
    {
        NSString *timeStr = kLoc(@"self_pick_time");
        [commands appendData:[[NSString stringWithFormat:@"%@：%@\r\n",timeStr,mealTimesStr] dataUsingEncoding:enc]];
    }
    
    /******************根据打印机类型，对菜单数据设置不同的打印格式****************/
    //------分割线(左对齐)
    NSMutableString *separationStr = [NSMutableString stringWithFormat:@"%@\r\n", [self getSeparationLineByNum:32 withPrinterType:type]];
    [commands appendData:[separationStr dataUsingEncoding:enc]];
    //菜品
    [commands appendData:[kLoc(@"dishes") dataUsingEncoding:enc]];
    //数量
    NSMutableString *numTitleSpace = [self getSpaceByPrice:0 withMaxSpaceNum:12 withShowLeft:NO withPrinterType:type];
    [commands appendData:[numTitleSpace dataUsingEncoding:enc]];
    [commands appendData:[kLoc(@"numbers") dataUsingEncoding:enc]];
    //小计
    NSMutableString *sumTitleSpace = [self getSpaceByPrice:0 withMaxSpaceNum:9 withShowLeft:NO withPrinterType:type];
    [commands appendData:[sumTitleSpace dataUsingEncoding:enc]];
    [commands appendData:[[NSString stringWithFormat:@"%@\r\n",kLoc(@"subtotal")] dataUsingEncoding:enc]];

    //------菜的详细内容(左对齐)
    int totalQty = 0;//总份数
    CGFloat totalSum = 0;//总金额
    CGFloat discount = [[NSString stringWithFormat:@"%@",[dishDetailDict objectForKey:@"discount"]]floatValue];//折扣
    CGFloat carryfee = [[NSString stringWithFormat:@"%@",[dishDetailDict objectForKey:@"carryfee"]]floatValue];//配送费
    CGFloat favorableSum = [[NSString stringWithFormat:@"%@",[dishDetailDict objectForKey:@"couponAmount"]]floatValue];//优惠
    NSArray *dishesListArray = [dishDetailDict objectForKey:@"dishesList"];
    for (int k = 0; k < [dishesListArray count]; k++)
    {
        NSDictionary *dishDict = [dishesListArray objectAtIndex:k];
        //是否是套餐
        int isPackage =[[dishDict objectForKey:@"isPackage"] intValue];
        //菜名，左对齐
        NSString *dishesName = nil;
        NSString *currentStyle = [[dishDict objectForKey:@"currentStyle"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        BOOL isMultiStyle = [[dishDict objectForKey:@"isMultiStyle"] boolValue];
        if (isMultiStyle && [currentStyle length] > 0) {
            dishesName = [NSString stringWithFormat:@"%@(%@)", [dishDict objectForKey:@"name"], currentStyle];
        } else {
            dishesName = [NSString stringWithFormat:@"%@",[dishDict objectForKey:@"name"]];
        }
        //数量，右对齐
        int quanty = [[dishDict objectForKey:@"quantity"] intValue];
        totalQty += quanty;
        NSString *quantyStr = [NSString stringWithFormat:@"%d",quanty];
        //价格，右对齐
        CGFloat originalPrice = [[dishDict objectForKey:@"originalPrice"] floatValue];
        CGFloat currentPrice = [[dishDict objectForKey:@"currentPrice"] floatValue];
        CGFloat packfee = [[dishDict objectForKey:@"packfee"] floatValue];
        CGFloat price = currentPrice?currentPrice:originalPrice;
        CGFloat currentDishSum = (price + packfee)* quanty ;
        totalSum += currentDishSum;
        NSMutableString *priceSpace = [self getSpaceByPrice:currentDishSum withMaxSpaceNum:11 withShowLeft:NO withPrinterType:type];
        NSString *priceStr = [NSString stringWithFormat:@"%@%.2f",priceSpace,currentDishSum];
        //备注
        NSString *dishRemarkStr = [dishDict objectForKey:@"remark"];
        int dishRemarkLen = (int)[[dishRemarkStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
        
        if (1 == isPackage)
        {
            [commands appendBytes:[self commandNamed:@"ALIGNLEFT"]
                           length:[self commandSizeNamed:@"ALIGNLEFT"]];
            [commands appendData:[[NSString stringWithFormat:@"%d.%@\r\n",k+ 1,dishesName] dataUsingEncoding:enc]];
            
            NSString *subTitleSpace = @"  ";
            NSArray *packageItem = [dishDict objectForKey:@"packageData"];
            for (int i=0; i<[packageItem count]; i++)
            {
                NSDictionary *package = [packageItem objectAtIndex:i];
                //套餐的某个子项
                NSString *subTitle = [[package objectForKey:@"title"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (0 != [subTitle length])
                {
                    [commands appendData:[[NSString stringWithFormat:@"%@%@:\r\n",subTitleSpace,subTitle] dataUsingEncoding:enc]];
                }
                else
                {
                    if (0 != i)
                    {
                        [commands appendData:[@"\r\n" dataUsingEncoding:enc]];
                    }
                }
                
                //某个子项的详细内容
                int selectedIndex = 0;
                NSString *subListSpace = @"    ";
                NSArray *subList = [package objectForKey:@"list"];
                for (int j=0; j<[subList count]; j++)
                {
                    NSDictionary *sub = [subList objectAtIndex:j];
                    selectedIndex ++;
                    [commands appendData:[[NSString stringWithFormat:@"%@\r\n",[NSString stringWithFormat:@"%@%d)%@",subListSpace,selectedIndex, [sub objectForKey:@"name"]]] dataUsingEncoding:enc]];
                }
            }
            if (0 != dishRemarkLen)
            {
                [commands appendData:[[NSString stringWithFormat:@"  %@ : %@\r\n",kLoc(@"remark"),dishRemarkStr] dataUsingEncoding:enc]];
            }
            [commands appendBytes:[self commandNamed:@"ALIGNRIGHT"]
                           length:[self commandSizeNamed:@"ALIGNRIGHT"]];
            [commands appendData:[[NSString stringWithFormat:@"%@%@\r\n",quantyStr,priceStr] dataUsingEncoding:enc]];
        }
        else
        {
            [commands appendBytes:[self commandNamed:@"ALIGNLEFT"]
                           length:[self commandSizeNamed:@"ALIGNLEFT"]];
            [commands appendData:[[NSString stringWithFormat:@"%d.%@\r\n",k+ 1,dishesName] dataUsingEncoding:enc]];
            if (0 != dishRemarkLen)
            {
                [commands appendData:[[NSString stringWithFormat:@"  %@ : %@\r\n",kLoc(@"remark"),dishRemarkStr] dataUsingEncoding:enc]];
            }
            [commands appendBytes:[self commandNamed:@"ALIGNRIGHT"]
                           length:[self commandSizeNamed:@"ALIGNRIGHT"]];
            [commands appendData:[[NSString stringWithFormat:@"%@%@\r\n",quantyStr,priceStr] dataUsingEncoding:enc]];
        }
        
        //原价
        [commands appendBytes:[self commandNamed:@"ALIGNLEFT"]
                       length:[self commandSizeNamed:@"ALIGNLEFT"]];
        if (currentPrice >0 || packfee > 0)
        {
            [commands appendData:[[NSString stringWithFormat:@"%@:%0.2f\r\n",NSLocalizedString(@"原价", nil),[[dishDict objectForKey:@"originalPrice"] floatValue]] dataUsingEncoding:enc]];
        }
        
        //优惠价
        if (currentPrice > 0)
        {
            [commands appendData:[[NSString stringWithFormat:@"%@:%0.2f\r\n",NSLocalizedString(@"优惠价", nil),[[dishDict objectForKey:@"currentPrice"] floatValue]] dataUsingEncoding:enc]];
        }
        
        //打包费
        if (packfee > 0)
        {
            [commands appendData:[[NSString stringWithFormat:@"%@:%0.2f\r\n",NSLocalizedString(@"打包费", nil),packfee] dataUsingEncoding:enc]];
        }
        
        if (k != [dishesListArray count] - 1)
        {
            [commands appendData:[@"\r\n" dataUsingEncoding:enc]];
        }
    }
    //整条订单的备注(左对齐)
    NSString *orderRemarkStr = [dishDetailDict objectForKey:@"remark"];
    int orderRemarkLen = (int)[[orderRemarkStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
    if (0 != orderRemarkLen)
    {
        //------分割线(左对齐)
        [commands appendBytes:[self commandNamed:@"ALIGNRIGHT"]
                       length:[self commandSizeNamed:@"ALIGNRIGHT"]];
        [commands appendData:[separationStr dataUsingEncoding:enc]];
        [commands appendData:[[NSString stringWithFormat:@"%@ : %@\r\n",kLoc(@"remark"),orderRemarkStr] dataUsingEncoding:enc]];
    }
    //------分割线(右对齐)
    [commands appendBytes:[self commandNamed:@"ALIGNRIGHT"]
                   length:[self commandSizeNamed:@"ALIGNRIGHT"]];
    [commands appendData:[separationStr dataUsingEncoding:enc]];
    //共几份
    [commands appendData:[[NSString stringWithFormat:@"共%d份\r\n",totalQty] dataUsingEncoding:enc]];
    //------预估总价(右对齐)
    NSMutableString *sumSpace = [self getSpaceByPrice:totalSum withMaxSpaceNum:20 withShowLeft:YES withPrinterType:type];
    NSString *sumStr = kLoc(@"estimate_total_price");
    [commands appendData:[[NSString stringWithFormat:@"%@%@%.2f\r\n",sumStr,sumSpace,totalSum] dataUsingEncoding:enc]];
    //------折扣(右对齐)
    if (0 < discount)
    {
        CGFloat discountSum = discount * totalSum;
        NSString *tempStr= [NSString trimmingZeroInPrice:[NSString stringWithFormat:@"%.2f", discount * 10]];
        int discountSpaceNum = 19;
        switch ([tempStr length])
        {
            case 3:
            {
                discountSpaceNum = 19;
                break;
            }
            default:
            {
                discountSpaceNum = 21;
                break;
            }
        }
        NSMutableString *discountSpace = [self getSpaceByPrice:discountSum withMaxSpaceNum:discountSpaceNum withShowLeft:YES withPrinterType:type];
        NSString *tempStr2 = kLoc(@"total_bill");
        NSString *tempStr3 = kLoc(@"discount");
        [commands appendData:[[NSString stringWithFormat:@"%@%@%.2f\r\n",[NSString stringWithFormat:@"%@%@%@",tempStr2, tempStr,tempStr3],discountSpace,discountSum] dataUsingEncoding:enc]];
    }
    //------配送费(右对齐)
    if (0 < carryfee)
    {
        NSMutableString *carryfeeSpace = [self getSpaceByPrice:carryfee withMaxSpaceNum:22 withShowLeft:YES withPrinterType:type];
        NSString *carryfeeStr = kLoc(@"carry_fee");
        [commands appendData:[[NSString stringWithFormat:@"%@%@%.2f\r\n",carryfeeStr, carryfeeSpace,carryfee] dataUsingEncoding:enc]];
    }
    //------优惠(右对齐)
    if (0 < favorableSum)
    {
        NSMutableString *favorableSpace = [self getSpaceByPrice:favorableSum withMaxSpaceNum:24 withShowLeft:YES withPrinterType:type];
        NSString *favorableStr = kLoc(@"preferential");
        [commands appendData:[[NSString stringWithFormat:@"%@%@%.2f\r\n",favorableStr,favorableSpace,favorableSum] dataUsingEncoding:enc]];
    }
    //------分割线(右对齐)
    [commands appendData:[separationStr dataUsingEncoding:enc]];
    //------总价(右对齐) 打折后的总价 + 配送费 - 优惠
    CGFloat finalSum = 0;
    if (0 < discount)
    {
        finalSum = totalSum *discount + carryfee;
    }
    else
    {
        finalSum = totalSum + carryfee;
    }
    if (0 < favorableSum)
    {
        finalSum = finalSum - favorableSum;
        if (0 > finalSum)
        {
            finalSum = 0;
        }
    }
    NSMutableString *finalSumSpace = [self getSpaceByPrice:finalSum withMaxSpaceNum:24 withShowLeft:YES withPrinterType:type];
    NSString *finalSumStr = kLoc(@"total_price");
    finalSum = roundf(finalSum * kTwoDecimal)/kTwoDecimal;
    [commands appendData:[[NSString stringWithFormat:@"%@%@%.2f", finalSumStr, finalSumSpace, finalSum] dataUsingEncoding:enc]];
    
    [commands appendData:[@"\r\n\r\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    if (currentPrinterBrand == 0) {
        [commands appendBytes:[self commandNamed:@"AUTORUN"]
                       length:[self commandSizeNamed:@"AUTORUN"]];
    }

    [commands appendBytes:[self commandNamed:@"CUTPAPER"]
                   length:[self commandSizeNamed:@"CUTPAPER"]];
    
    //打印
    [self startPrint:commands withPrinterHost:hostStr wihtPrinterType:type];
}

//根据价格获取空格
- (NSMutableString *)getSpaceByPrice:(CGFloat)price withMaxSpaceNum:(int)maxNum withShowLeft:(BOOL)isLeft withPrinterType:(int)type
{
    NSMutableString *spaceStr = [[NSMutableString alloc]init];
    int priceLen = (int)[[NSString stringWithFormat:@"%d",(int)(price)] length];
    int spaceNum = maxNum - priceLen;
    if (kPrinterSecondType == type)
    {
        if (isLeft)
        {
            spaceNum = spaceNum + 16;
        }
        else
        {
            spaceNum = spaceNum + 8;
        }
    }
    for (int k = 0; k < spaceNum; k++)
    {
        [spaceStr appendString:@" "];
    }
    return spaceStr;
}

//生成给定数量的分割线
- (NSMutableString *)getSeparationLineByNum:(int)num withPrinterType:(int)type
{
    NSMutableString *spaceStr = [[NSMutableString alloc]init];
    int spaceNum = num;
    if (kPrinterSecondType == type)
    {
        spaceNum = spaceNum + 16;
    }
    for (int k = 0; k < spaceNum; k++)
    {
        [spaceStr appendString:@"-"];
    }
    return spaceStr;
}

#pragma mark - printQueue

//打印排队
- (void)printQueueReceiptWithName:(QueueAddArrangDataClass *)addArrangDataClass
{
    [self printQueueReceiptFormat:addArrangDataClass withPrinterHost:currentHostStr wihtPrinterType:currentPrinterType];
}

- (void)printQueueReceiptFormat:(QueueAddArrangDataClass *)dataClass withPrinterHost:(NSString *)hostStr wihtPrinterType:(int)type
{
    QueueAddArrangInfoDataClass *infoDataClass = [[QueueAddArrangInfoDataClass alloc] initWithQueueAddArrangInfoData:dataClass.addedInfoDict];
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSChineseSimplif);
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    [commands appendBytes:[self commandNamed:@"INIT"] length:[self commandSizeNamed:@"INIT"]];
    
    if (currentPrinterBrand == 1) {
        [commands appendBytes:"\x1b\x20\x00" length:3];
    }
    
    //-----餐厅名称，如：(居中显示)
    [commands appendBytes:[self commandNamed:@"ALIGNCENTER"]
                   length:[self commandSizeNamed:@"ALIGNCENTER"]];
    [commands appendBytes:[self commandNamed:@"BOLD"]
                   length:[self commandSizeNamed:@"BOLD"]];
    [commands appendBytes:[self commandNamed:@"ZOOMSCALE"]
                   length:[self commandSizeNamed:@"ZOOMSCALE"]];
    [commands appendData:[[NSString stringWithFormat:@"%@\r\n\r\n", dataClass.corpName] dataUsingEncoding:enc]];
    
    //------(左对齐)
    [commands appendBytes:[self commandNamed:@"UNBOLD"]
                   length:[self commandSizeNamed:@"UNBOLD"]];
    [commands appendBytes:[self commandNamed:@"ALIGNLEFT"]
                   length:[self commandSizeNamed:@"ALIGNLEFT"]];
    
    //------人数(左对齐)
    [commands appendBytes:[self commandNamed:@"NORMALSIZE"]
                   length:[self commandSizeNamed:@"NORMALSIZE"]];
    [commands appendData:[[NSString stringWithFormat:@"%@: %d%@\r\n",
                           kLoc(@"people_number"), (int)infoDataClass.people,
                           kLoc(@"person")] dataUsingEncoding:enc]];
    
    //------手机号码(左对齐)
    [commands appendBytes:[self commandNamed:@"NORMALSIZE"]
                   length:[self commandSizeNamed:@"NORMALSIZE"]];
    [commands appendData:[[NSString stringWithFormat:@"%@: %@\r\n", kLoc(@"mobile"), infoDataClass.mobileStr] dataUsingEncoding:enc]];
    
    //------地址(左对齐)
    [commands appendBytes:[self commandNamed:@"NORMALSIZE"]
                   length:[self commandSizeNamed:@"NORMALSIZE"]];
    [commands appendData:[[NSString stringWithFormat:@"%@: %@\r\n\r\n", kLoc(@"address"), dataClass.corpAddr] dataUsingEncoding:enc]];
    
    //------分割线(左对齐)
    NSInteger separationLen = 32;
    NSMutableString *separationStr = [NSMutableString stringWithFormat:@"%@\r\n\r\n",
                                      [self getSeparationLineByNum:(int)separationLen withPrinterType:type]];
    [commands appendBytes:[self commandNamed:@"NORMALSIZE"]
                   length:[self commandSizeNamed:@"NORMALSIZE"]];
    [commands appendData:[separationStr dataUsingEncoding:enc]];
    
    //------类别名 + 序列号(居中)
    [commands appendBytes:[self commandNamed:@"ALIGNCENTER"]
                   length:[self commandSizeNamed:@"ALIGNCENTER"]];
    [commands appendBytes:[self commandNamed:@"BOLD"]
                   length:[self commandSizeNamed:@"BOLD"]];
    [commands appendBytes:[self commandNamed:@"ZOOMSCALE"]
                   length:[self commandSizeNamed:@"ZOOMSCALE"]];
    [commands appendData:[[NSString stringWithFormat:@"%@ %.3d\r\n\r\n", infoDataClass.typeNameStr, (int)infoDataClass.number] dataUsingEncoding:enc]];
    
    //------等待人数(居中)
    [commands appendBytes:[self commandNamed:@"ALIGNCENTER"]
                   length:[self commandSizeNamed:@"ALIGNCENTER"]];
    [commands appendBytes:[self commandNamed:@"NORMALSIZE"]
                   length:[self commandSizeNamed:@"NORMALSIZE"]];
    [commands appendData:[[NSString stringWithFormat:@"%@%d%@\r\n\r\n",
                           kLoc(@"ahead_of"), (int)infoDataClass.waiting,
                           kLoc(@"guest_wait")] dataUsingEncoding:enc]];
    
    //------分割线(左对齐)
    [commands appendBytes:[self commandNamed:@"UNBOLD"]
                   length:[self commandSizeNamed:@"UNBOLD"]];
    [commands appendBytes:[self commandNamed:@"ALIGNLEFT"]
                   length:[self commandSizeNamed:@"ALIGNLEFT"]];
    [commands appendBytes:[self commandNamed:@"NORMALSIZE"]
                   length:[self commandSizeNamed:@"NORMALSIZE"]];
    [commands appendData:[separationStr dataUsingEncoding:enc]];
    
    //------出票时间(居中),如:2013-03-24 08:30:20
    [commands appendBytes:[self commandNamed:@"ALIGNCENTER"]
                   length:[self commandSizeNamed:@"ALIGNCENTER"]];
    [commands appendBytes:[self commandNamed:@"NORMALSIZE"]
                   length:[self commandSizeNamed:@"NORMALSIZE"]];
    NSString *nowStr = [NSString dateToNSString:[NSDate date] withFormat:@"yyyy-MM-dd HH:mm:ss"];
    [commands appendData:[[NSString stringWithFormat:@"%@: %@\r\n", kLoc(@"out_ticket_time"), nowStr] dataUsingEncoding:enc]];
    
    //----排队说明(居中)
    [commands appendBytes:[self commandNamed:@"NORMALSIZE"]
                   length:[self commandSizeNamed:@"NORMALSIZE"]];
    NSString *warningStr = [NSString stringWithFormat:@"%@\r\n\r\n",
                            kLoc(@"pay_attention_to_your_turn")];
    [commands appendData:[warningStr dataUsingEncoding:enc]];

    
    if (currentPrinterBrand == 0) {
        [commands appendBytes:[self commandNamed:@"AUTORUN"]
                       length:[self commandSizeNamed:@"AUTORUN"]];
    }
    
    //切纸
    [commands appendBytes:[self commandNamed:@"CUTPAPER"]
                   length:[self commandSizeNamed:@"CUTPAPER"]];
    
    //打印
    [self startPrint:commands withPrinterHost:hostStr wihtPrinterType:type];
}

#pragma mark AsyncSocket delegate

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [sock readDataWithTimeout:kMaxTimeout tag:0];
    
#ifdef DEBUG
    NSLog(@"===onSocket:%p didConnectToHost:%@ port:%hu===", sock, host, port);
#endif
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
#ifdef DEBUG
    NSLog(@"===onSocket:%p willDisconnectWithError:%@===", sock, [err localizedDescription]);
#endif
    if (err.code == 5) {
        NSString *titleStr = [NSString stringWithFormat:@"%@%@",
                              currentPrinterName,
                              kLoc(@"print_paper_use_out")];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleStr
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:kLoc(@"confirm")
                                              otherButtonTitles:nil];
        [alert show];
    } else if (isShowError) {
        NSString *titleStr = [NSString stringWithFormat:@"%@%@",
                              currentPrinterName,
                              kLoc(@"printer_link_error")];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleStr
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:kLoc(@"confirm")
                                              otherButtonTitles:nil];
        [alert show];
    }
}

//断开连接了
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
#ifdef DEBUG
    NSLog(@"===onSocketDidDisconnect:%p ===", sock);
#endif
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    /***打印完成后关闭连接***/
    [asyncSocket disconnect];
}

@end
