//
//  PrinterDataClass.m
//  PreOrderSystem
//
//  Created by SWen on 14-1-6.
//
//

#import "PrinterDataClass.h"
#import "NsstringAddOn.h"



@implementation PrinterDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithPrinterData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        if ([dict objectForKey:kPrinterMac] != nil)
        {
            self.printerMac = [dict objectForKey:kPrinterMac];
        } else
        {
            self.printerMac = @"";
        }
        
        self.printerName = [dict objectForKey:kPrinterName];
        self.printerIPStr = [dict objectForKey:kPrinterIP];
        self.printerType = [[dict objectForKey:kPrinterType] integerValue];
        self.isOrderdishBtnCheck = [[dict objectForKey:kisOrderdishBtnCheck] boolValue];
        self.isKitchenBtnCheck = [[dict objectForKey:kisKitchenBtnCheck] boolValue];
        self.isTakeoutBtnCheck = [[dict objectForKey:kisTakeoutBtnCheck] boolValue];
        self.isQueueBtnCheck = [[dict objectForKey:kisQueueBtnCheck] boolValue];
        
        
        if ([dict objectForKey:kPrinterStar] != nil)
        {
            self.printerStar = [dict objectForKey:kPrinterStar];
        }
        else
        {
            self.printerStar = @"";
        }
    }
    return self;
}

+ (void)addNewPrinterData
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[self getPrinterData:kTemporaryPrinterDataKey]];
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:[NSNumber numberWithBool:NO] forKey:kisOrderdishBtnCheck];
    [tempDict setObject:[NSNumber numberWithBool:NO] forKey:kisKitchenBtnCheck];
    [tempDict setObject:[NSNumber numberWithBool:NO] forKey:kisTakeoutBtnCheck];
    [tempDict setObject:[NSNumber numberWithBool:NO] forKey:kisQueueBtnCheck];
    [tempDict setObject:@"" forKey:kPrinterName];
    [tempDict setObject:@"" forKey:kPrinterIP];
    [tempDict setObject:[NSNumber numberWithInt:kPrinterFirstType] forKey:kPrinterType];
    [tempArray addObject:tempDict];
    [self saveTemporaryPrinterData:tempArray];
}

+ (BOOL)allowAddNewPrinter
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[self getPrinterData:kTemporaryPrinterDataKey]];
    
    for (NSDictionary *tempDict in tempArray) {
        NSString *ip = [tempDict objectForKey:@"printerIP"];
        NSString *name =[tempDict objectForKey:@"printerName"];
        
        if ([ip length] == 0 || [name length] == 0) {
            return NO;
        }
    }
    
    return YES;
}

+ (void)addNewStrPrinterData:(PortInfo *)info
{
    if (info)
    {
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[self getPrinterData:kTemporaryPrinterDataKey]];
        NSString *ip = @"";
        if ([info.portName length] > 5)
        {
            ip = [info.portName substringFromIndex:4];
        }
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        [tempDict setObject:[NSNumber numberWithBool:NO] forKey:kisOrderdishBtnCheck];
        [tempDict setObject:[NSNumber numberWithBool:NO] forKey:kisKitchenBtnCheck];
        [tempDict setObject:[NSNumber numberWithBool:NO] forKey:kisTakeoutBtnCheck];
        [tempDict setObject:[NSNumber numberWithBool:NO] forKey:kisQueueBtnCheck];
        [tempDict setObject:@"starPrinter" forKey:kPrinterStar];
        [tempDict setObject:info.modelName forKey:kPrinterName];
        [tempDict setObject:ip forKey:kPrinterIP];
        [tempDict setObject:info.macAddress forKey:kPrinterMac];
        [tempDict setObject:[NSNumber numberWithInt:kPrinterSecondType] forKey:kPrinterType];
        [tempArray addObject:tempDict];
        [self saveTemporaryPrinterData:tempArray];
    }
}

+ (void)modifyPrinterDataWithName:(NSString *)nameStr withPrinterIPStr:(NSString *)ipStr withPrinterType:(int)type withIndex:(int)index
{
    NSString *printerName = ([NSString strIsEmpty:nameStr])?@"":nameStr;
    NSString *printerIp = ([NSString strIsEmpty:ipStr])?@"":ipStr;
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[self getPrinterData:kTemporaryPrinterDataKey]];
    int tempCount = [tempArray count];
    if (index < tempCount)
    {
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:[tempArray objectAtIndex:index]];
        [tempDict setObject:printerName forKey:kPrinterName];
        [tempDict setObject:printerIp forKey:kPrinterIP];
        [tempDict setObject:[NSNumber numberWithInt:type] forKey:kPrinterType];
        [tempArray replaceObjectAtIndex:index withObject:tempDict];
        [self saveTemporaryPrinterData:tempArray];
    }
}

+ (void)modifyPrinterDataWithName:(NSString *)nameStr withIndex:(int)index
{
    NSString *printerName = ([NSString strIsEmpty:nameStr])?@"":nameStr;
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[self getPrinterData:kTemporaryPrinterDataKey]];
    int tempCount = [tempArray count];
    if (index < tempCount)
    {
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:[tempArray objectAtIndex:index]];
        [tempDict setObject:printerName forKey:kPrinterName];
        [tempArray replaceObjectAtIndex:index withObject:tempDict];
        [self saveTemporaryPrinterData:tempArray];
    }
}

+ (void)modifyPrinterDataWithPrinterIPStr:(NSString *)ipStr withIndex:(int)index
{
    NSString *printerIp = ([NSString strIsEmpty:ipStr])?@"":ipStr;
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[self getPrinterData:kTemporaryPrinterDataKey]];
    int tempCount = [tempArray count];
    if (index < tempCount)
    {
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:[tempArray objectAtIndex:index]];
        [tempDict setObject:printerIp forKey:kPrinterIP];
        [tempArray replaceObjectAtIndex:index withObject:tempDict];
        [self saveTemporaryPrinterData:tempArray];
    }
}

+ (void)modifyPrinterDataWithPrinterType:(int)type withIndex:(int)index
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[self getPrinterData:kTemporaryPrinterDataKey]];
    int tempCount = [tempArray count];
    if (index < tempCount)
    {
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:[tempArray objectAtIndex:index]];
        [tempDict setObject:[NSNumber numberWithInt:type] forKey:kPrinterType];
        [tempArray replaceObjectAtIndex:index withObject:tempDict];
        [self saveTemporaryPrinterData:tempArray];
    }
}

+ (void)modifyPrinterDataWithCell:(PrintManagementTableViewCell *)cell  withIndex:(int)index
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[self getPrinterData:kTemporaryPrinterDataKey]];
    int tempCount = [tempArray count];
    
    if (index < tempCount)
    {
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:[tempArray objectAtIndex:index]];
        [tempDict setObject:[NSNumber numberWithInt:cell.orderDishesBtn.selected] forKey:kisOrderdishBtnCheck];
        [tempDict setObject:[NSNumber numberWithInt:cell.kitchenBtn.selected] forKey:kisKitchenBtnCheck];
        [tempDict setObject:[NSNumber numberWithInt:cell.takeoutBtn.selected] forKey:kisTakeoutBtnCheck];
        [tempDict setObject:[NSNumber numberWithInt:cell.queueBtn.selected] forKey:kisQueueBtnCheck];
        [tempArray replaceObjectAtIndex:index withObject:tempDict];
        [self saveTemporaryPrinterData:tempArray];
    }
}

+ (void)saveForeverPrinterData:(NSArray *)tempArray
{
    NSUserDefaults *temp = [NSUserDefaults standardUserDefaults];
    [temp setObject:tempArray forKey:kForeverPrinterDataKey];
    [temp synchronize];
}

+ (void)saveTemporaryPrinterData:(NSArray *)tempArray
{
    NSUserDefaults *temp = [NSUserDefaults standardUserDefaults];
    [temp setObject:tempArray forKey:kTemporaryPrinterDataKey];
    [temp synchronize];
}

+ (NSMutableArray *)getPrinterData:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)deletePrinterData:(int)index
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[self getPrinterData:kTemporaryPrinterDataKey]];
    int tempCount = [tempArray count];
    if (index < tempCount)
    {
        [tempArray removeObjectAtIndex:index];
        [self saveTemporaryPrinterData:tempArray];
    }
}

@end
