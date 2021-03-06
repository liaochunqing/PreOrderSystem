﻿//
//  PrinterFunctions.m
//  IOS_SDK
//
//  Created by Tzvi on 8/2/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import "PrinterFunctions.h"
#import "StarIO/SMPort.h"
#import "RasterDocument.h"
#import "StarBitmap.h"
#import <sys/time.h>
#include <unistd.h>
#import "NsstringAddOn.h"
#import "MBProgressHUD.h"

@implementation PrinterFunctions

+ (void)PrintTestWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    unsigned char characterExpansion0[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion0[2] = 0 + '0';
    characterExpansion0[3] = 0 + '0';
    
    unsigned char characterExpansion1[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion1[2] = 1 + '0';
    characterExpansion1[3] = 1 + '0';
    
    unsigned char characterExpansion2[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion2[2] = 2 + '0';
    characterExpansion2[3] = 2 + '0';
    
    unsigned char characterExpansion3[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion3[2] = 3 + '0';
    characterExpansion3[3] = 3 + '0';
    
    unsigned char characterExpansion4[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion4[2] = 4 + '0';
    characterExpansion4[3] = 4 + '0';
    
    unsigned char alignmentLeftCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    alignmentLeftCommand[3] = 48;
    unsigned char alignmentCenterCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    alignmentCenterCommand[3] = 49;
    unsigned char alignmentRightCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    alignmentRightCommand[3] = 50;
    
    //-----标题，如：(居中显示)
    [commands appendBytes:characterExpansion1 length:4];
    [commands appendBytes:alignmentCenterCommand length:4];
    [commands appendData:[kLoc(@"order_to_print_test") dataUsingEncoding:enc]];
    [commands appendData:[@"\n\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    //------内容(左对齐)
    [commands appendBytes:characterExpansion0 length:4];
    [commands appendBytes:alignmentLeftCommand length:4];
    [commands appendData:[kLoc(@"printer_describe") dataUsingEncoding:enc]];
    
    [commands appendData:[@"\n\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    //打印完二维码后己带有切纸功能，所以不需再切一次
    [commands appendBytes:"\x1b\x64\x02" length:sizeof("\x1b\x64\x02") - 1];    // CutPaper
    
    int commandSize = [commands length];
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [commands getBytes:dataToSentToPrinter];
    
    SMPort *starPort = nil;
    @try {
        starPort = [SMPort getPort:portName :portSettings :3000];
        
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLoc(@"no_link_printer")
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:kLoc(@"confirm")
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec){
                break;
            }
        }
        
        usleep(1000 * 1000);
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLoc(@"print_error")
                                                            message:kLoc(@"print_timeout")
                                                           delegate:nil
                                                  cancelButtonTitle:kLoc(@"confirm")
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLoc(@"print_error")
                                                        message:kLoc(@"print_timeout")
                                                       delegate:nil
                                              cancelButtonTitle:kLoc(@"confirm")
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally{
        [SMPort releasePort:starPort];
    }
    
    free(dataToSentToPrinter);
}

+ (void)PrintMyRecieptWithPortname:(NSString *)portName portSettings:(NSString *)portSettings withDishData:(NSDictionary *)dishDetailDict
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    unsigned char characterExpansion0[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion0[2] = 0 + '0';
    characterExpansion0[3] = 0 + '0';
    
    unsigned char characterExpansion1[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion1[2] = 1 + '0';
    characterExpansion1[3] = 1 + '0';
    
    unsigned char characterExpansion2[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion2[2] = 2 + '0';
    characterExpansion2[3] = 2 + '0';
    
    unsigned char characterExpansion3[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion3[2] = 3 + '0';
    characterExpansion3[3] = 3 + '0';
    
    unsigned char characterExpansion4[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion4[2] = 4 + '0';
    characterExpansion4[3] = 4 + '0';
    
    unsigned char alignmentLeftCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    alignmentLeftCommand[3] = 48;
    unsigned char alignmentCenterCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    alignmentCenterCommand[3] = 49;
    unsigned char alignmentRightCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    alignmentRightCommand[3] = 50;
    
    //-----餐厅名称，如：(居中显示)
    [commands appendBytes:characterExpansion1 length:4];
    [commands appendBytes:alignmentCenterCommand length:4];
    //[commands appendData:[kLoc(@"订餐易外卖订单\n\n", nil) dataUsingEncoding:enc]];
    
    [commands appendData:[[NSString stringWithFormat:@"%@\n\n",kLoc(@"etable_takeout_order")] dataUsingEncoding:enc]];

    
    //------称呼,手机(左对齐)
    NSString *nameStr = [PrinterFunctions firstNameWithTitle:[dishDetailDict objectForKey:@"guestName"] Sex:[[dishDetailDict objectForKey:@"guestSex"]integerValue]];
    [commands appendBytes:characterExpansion0 length:4];
    [commands appendBytes:alignmentLeftCommand length:4];
    [commands appendData:[[NSString stringWithFormat:@"%@ %@\n",nameStr,[dishDetailDict objectForKey:@"guestPhone"]] dataUsingEncoding:enc]];
    //------下单时间(左对齐)
    NSString *orderDateStr = [dishDetailDict objectForKey:@"orderTime"];
    NSDate *orderDate = [orderDateStr stringToNSDateWithFormat:@"yyyy-MM-dd HH:mm"];
    orderDateStr = [NSString dateToNSString:orderDate withFormat:@"yyyy-MM-dd HH:mm"];
    [commands appendBytes:characterExpansion0 length:4];
    [commands appendBytes:alignmentLeftCommand length:4];
    NSString *orderTimeStr = kLoc(@"order_time");
    [commands appendData:[[NSString stringWithFormat:@"%@：%@\n",orderTimeStr,orderDateStr] dataUsingEncoding:enc]];
    //------自取时间/送达时间(左对齐)
    int deliveryType = [[dishDetailDict objectForKey:@"deliveryType"] intValue];
    NSInteger mealDateType = [[dishDetailDict objectForKey:@"carryTimeType"] integerValue];
    NSString *keyStr = (0 == mealDateType)?@"mealTimes":@"carryTimeTypeDesc";
    NSString *mealTimesStr = [dishDetailDict objectForKey:keyStr];
    [commands appendBytes:characterExpansion0 length:4];
    [commands appendBytes:alignmentLeftCommand length:4];
    
    if (0 == deliveryType)
    {
        NSString *timeStr = kLoc(@"reach_time");
        [commands appendData:[[NSString stringWithFormat:@"%@：%@\n",timeStr,mealTimesStr] dataUsingEncoding:enc]];
        
        //------地址(左对齐)
        [commands appendBytes:characterExpansion0 length:4];
        [commands appendBytes:alignmentLeftCommand length:4];
        NSString *addressStr = kLoc(@"address");
        [commands appendData:[[NSString stringWithFormat:@"%@：%@\n",addressStr,[dishDetailDict objectForKey:@"takeoutAddress"]] dataUsingEncoding:enc]];
    }
    else
    {
        NSString *timeStr = kLoc(@"self_pick_time");
        [commands appendData:[[NSString stringWithFormat:@"%@：%@\n",timeStr,mealTimesStr] dataUsingEncoding:enc]];
    }
    //------分割线(左对齐)
    NSString *separationStr = @"--------------------------------------------\n";
    [commands appendBytes:characterExpansion0 length:4];
    [commands appendBytes:alignmentLeftCommand length:4];
    [commands appendData:[separationStr dataUsingEncoding:enc]];
    //菜品
    [commands appendBytes:characterExpansion0 length:4];
    [commands appendBytes:alignmentLeftCommand length:4];
    [commands appendData:[kLoc(@"dishes") dataUsingEncoding:enc]];
    //数量
    [commands appendBytes:characterExpansion0 length:4];
    [commands appendBytes:alignmentLeftCommand length:4];
    //[commands appendData:[kLoc(@"               数量", nil) dataUsingEncoding:enc]];
    [commands appendData:[[NSString stringWithFormat:@"               %@",kLoc(@"numbers")] dataUsingEncoding:enc]];

    //小计
    [commands appendBytes:characterExpansion0 length:4];
    [commands appendBytes:alignmentLeftCommand length:4];
    //[commands appendData:[kLoc(@"          小计\n", nil) dataUsingEncoding:enc]];
    
    [[NSString stringWithFormat:@"          %@\n",kLoc(@"subtotal")] dataUsingEncoding:enc];

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
        int isPackage =[[dishDict objectForKey:@"isPackage"] integerValue];
        //菜名
        NSString *dishesName = nil; 
        NSString *currentStyle = [[dishDict objectForKey:@"currentStyle"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([currentStyle length]>0)
        {
            dishesName = [NSString stringWithFormat:@"%@(%@)\n", [dishDict objectForKey:@"name"], currentStyle];
        }
        else
        {
            dishesName = [NSString stringWithFormat:@"%@\n",[dishDict objectForKey:@"name"]];
        }
        //数量
        int quanty = [[dishDict objectForKey:@"quantity"] integerValue];
        totalQty += quanty;
        NSString *quantySpace = @"                    ";
        NSString *quantyStr = [NSString stringWithFormat:@"%@%d",quantySpace,quanty];
        //价格
        CGFloat price = [[dishDict objectForKey:@"currentPrice"] floatValue];
        totalSum += price * quanty;
        NSString *priceSpace = @"           ";
        NSString *priceStr = [NSString stringWithFormat:@"%@%.2f",priceSpace,price * quanty];
        
        if (1 == isPackage)
        {
            [commands appendBytes:characterExpansion0 length:4];
            [commands appendBytes:alignmentLeftCommand length:4];
            [commands appendData:[[NSString stringWithFormat:@"%d.%@",k+ 1,dishesName] dataUsingEncoding:enc]];
            
            NSString *subTitleSpace = @"    ";
            NSArray *packageItem = [dishDict objectForKey:@"packageData"];
            for (int i=0; i<[packageItem count]; i++)
            {
                NSDictionary *package = [packageItem objectAtIndex:i];
                //套餐的某个子项
                NSString *subTitle = [[package objectForKey:@"title"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (0 != [subTitle length])
                {
                    [commands appendData:[[NSString stringWithFormat:@"%@%@:\n",subTitleSpace,subTitle] dataUsingEncoding:enc]];
                }
                else
                {
                    if (0 != i)
                    {
                        [commands appendData:[@"\n" dataUsingEncoding:enc]];
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
                    [commands appendData:[[NSString stringWithFormat:@"%@\n",[NSString stringWithFormat:@"%@%d)%@",subListSpace,selectedIndex, [sub objectForKey:@"name"]]] dataUsingEncoding:enc]];
                }
            }
            [commands appendBytes:characterExpansion0 length:4];
            [commands appendBytes:alignmentLeftCommand length:4];
            [commands appendData:[[NSString stringWithFormat:@"%@%@\n",quantyStr,priceStr] dataUsingEncoding:enc]];
        }
        else
        {
            [commands appendBytes:characterExpansion0 length:4];
            [commands appendBytes:alignmentLeftCommand length:4];
            [commands appendData:[[NSString stringWithFormat:@"%d.%@%@%@\n",k+ 1,dishesName,quantyStr,priceStr] dataUsingEncoding:enc]];
        }
    }
    //------分割线(左对齐)
    [commands appendBytes:characterExpansion0 length:4];
    [commands appendBytes:alignmentLeftCommand length:4];
    [commands appendData:[separationStr dataUsingEncoding:enc]];
    
    //------预估总价(左对齐)
    NSString *sumSpace = @"                        ";
    [commands appendBytes:characterExpansion0 length:4];
    [commands appendBytes:alignmentLeftCommand length:4];
    NSString *sumStr = kLoc(@"estimate_total_price");
    [commands appendData:[[NSString stringWithFormat:@"%@%@%.2f\n",sumStr,sumSpace,totalSum] dataUsingEncoding:enc]];
    //------折扣(左对齐)
    if (0 < discount)
    {
        NSString *tempStr= [NSString trimmingZeroInPrice:[NSString stringWithFormat:@"%.2f", discount * 10]];
        NSString *discountSpace = @"";
        switch ([tempStr length])
        {
            case 1:
            {
                discountSpace = @"                         ";
                break;
            }
            case 3:
            {
                discountSpace = @"                       ";
                break;
            }
            default:
            {
                discountSpace = @"                         ";
                break;
            }
        }
        [commands appendBytes:characterExpansion0 length:4];
        [commands appendBytes:alignmentLeftCommand length:4];
        NSString *tempStr2 = kLoc(@"total_bill");
        NSString *tempStr3 = kLoc(@"discount");
        [commands appendData:[[NSString stringWithFormat:@"%@%@%.2f\n",[NSString stringWithFormat:@"%@%@%@",tempStr2, tempStr,tempStr3],discountSpace,discount *totalSum] dataUsingEncoding:enc]];
    }
    //------配送费(左对齐)
    if (0 < carryfee)
    {
        NSString *carryfeeSpace = @"                          ";
        [commands appendBytes:characterExpansion0 length:4];
        [commands appendBytes:alignmentLeftCommand length:4];
        NSString *carryfeeStr = kLoc(@"carry_fee");
        [commands appendData:[[NSString stringWithFormat:@"%@%@%.2f\n",carryfeeStr, carryfeeSpace,carryfee] dataUsingEncoding:enc]];
    }
    //------优惠(左对齐)
    if (0 < favorableSum)
    {
        NSString *favorableSpace = @"                            ";
        [commands appendBytes:characterExpansion0 length:4];
        [commands appendBytes:alignmentLeftCommand length:4];
        NSString *favorableStr = kLoc(@"preferential");
        [commands appendData:[[NSString stringWithFormat:@"%@%@%.2f\n",favorableStr,favorableSpace,favorableSum] dataUsingEncoding:enc]];
    }
    //------分割线(左对齐)
    [commands appendBytes:characterExpansion0 length:4];
    [commands appendBytes:alignmentLeftCommand length:4];
    [commands appendData:[separationStr dataUsingEncoding:enc]];
    //------总价(左对齐) 打折后的总价 + 配送费 - 优惠
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
    NSString *finalSumSpace = @"                  ";
    [commands appendBytes:characterExpansion0 length:4];
    [commands appendBytes:alignmentLeftCommand length:4];
    //NSString *finalSumStr = kLoc(@"总价（人民币）", nil);
    
    NSString *finalSumStr = [NSString stringWithFormat:@"%@ （%@）",kLoc(@"total_price"),kLoc(@"the_yuan")];

    
    [commands appendData:[[NSString stringWithFormat:@"%@%@%.1f0",finalSumStr,finalSumSpace,finalSum] dataUsingEncoding:enc]];
    
    [commands appendData:[@"\n\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    //打印完二维码后己带有切纸功能，所以不需再切一次
    [commands appendBytes:"\x1b\x64\x02" length:sizeof("\x1b\x64\x02") - 1];    // CutPaper
    
    int commandSize = [commands length];
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [commands getBytes:dataToSentToPrinter];
    
    SMPort *starPort = nil;
    @try
    {
        starPort = [SMPort getPort:portName :portSettings :3000];
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLoc(@"no_link_printer")
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:kLoc(@"confirm")
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec){
                break;
            }
        }
        
        usleep(1000 * 1000);
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLoc(@"print_error")
                                                            message:kLoc(@"print_timeout")
                                                           delegate:nil
                                                  cancelButtonTitle:kLoc(@"confirm")
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLoc(@"print_error")
                                                        message:kLoc(@"print_timeout")
                                                       delegate:nil
                                              cancelButtonTitle:kLoc(@"confirm")
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally{
        [SMPort releasePort:starPort];
    }
    
    free(dataToSentToPrinter);
}

+ (NSString*)firstNameWithTitle:(NSString*)firstName Sex:(int)sex
{
    NSString *text = nil;
    NSString *manStr = kLoc(@"mister");
    NSString *womanStr = kLoc(@"lady");
    switch (sex)
    {
        case 1:
            text = [NSString stringWithFormat:@"%@%@",firstName,manStr];
            break;
        case 2:
            text = [NSString stringWithFormat:@"%@%@",firstName,womanStr];
            break;
        default:
            text = [NSString stringWithFormat:@"%@%@",firstName,manStr];
            break;
    }
    return text;
}

+ (void)PrintMyRecieptWithPortname:(NSString *)portName portSettings:(NSString *)portSettings restaurantName:(NSString*)r_Name queueType:(NSString*)qType currentRow:(int)cRow remaingRow:(int)rRow
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    unsigned char characterExpansion0[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion0[2] = 0 + '0';
    characterExpansion0[3] = 0 + '0';
    
    unsigned char characterExpansion1[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion1[2] = 1 + '0';
    characterExpansion1[3] = 1 + '0';
    
    unsigned char characterExpansion2[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion2[2] = 2 + '0';
    characterExpansion2[3] = 2 + '0';
    
    unsigned char characterExpansion3[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion3[2] = 3 + '0';
    characterExpansion3[3] = 3 + '0';
    
    unsigned char characterExpansion4[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion4[2] = 4 + '0';
    characterExpansion4[3] = 4 + '0';
    
    unsigned char alignmentLeftCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    alignmentLeftCommand[3] = 48;
    unsigned char alignmentCenterCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    alignmentCenterCommand[3] = 49;
    unsigned char alignmentRightCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    alignmentRightCommand[3] = 50;
    
    
    //-----餐厅名称，如：(居中显示)
    [commands appendBytes:characterExpansion1 length:4];
    [commands appendBytes:alignmentCenterCommand length:4];
    
    [commands appendData:[[NSString stringWithFormat:@"%@\n", r_Name] dataUsingEncoding:enc]];
    
    
    //------排号类别(左对齐)
    [commands appendBytes:characterExpansion0 length:4];
    [commands appendBytes:alignmentLeftCommand length:4];
    NSString *categoryStr = kLoc(@"arrang_category");
    [commands appendData:[[NSString stringWithFormat:@"%@：%@\n",categoryStr, qType] dataUsingEncoding:enc]];
    
    [commands appendBytes:characterExpansion0 length:4];
    [commands appendBytes:alignmentLeftCommand length:4];
    //----您的排号(左对齐)
    //[commands appendData:[kLoc(@"您的排号：\n", nil) dataUsingEncoding:enc]];
    [commands appendData:[[NSString stringWithFormat:@"%@ \n",kLoc(@"your_arranging")] dataUsingEncoding:enc]];

    
    for (int i=0; i<12; i++) {
        [commands appendData:[@" " dataUsingEncoding:enc]];
    }
    
    //----当前排号数，如5
    [commands appendBytes:characterExpansion4 length:4];
    //[commands appendBytes:alignmentLeftCommand length:4];
    [commands appendData:[[NSString stringWithFormat:@"%i", cRow] dataUsingEncoding:enc]];
    
    
    [commands appendBytes:characterExpansion0 length:4];
    for (int i=0; i<5; i++) {
        [commands appendData:[@" " dataUsingEncoding:enc]];
    }
    
    //----前面还有X人
    NSString *tempStr1 = kLoc(@"ahead_of");
    NSString *tempStr2 = kLoc(@"person");
    [commands appendData:[[NSString stringWithFormat:@"%@%i%@\n",tempStr1, rRow, tempStr2] dataUsingEncoding:enc]];
    
    
    //----排队说明
    [commands appendBytes:characterExpansion0 length:4];
    [commands appendBytes:alignmentLeftCommand length:4];
    [commands appendData:[kLoc(@"quene_describe") dataUsingEncoding:enc]];
    
    //打印日期，如:2013-03-24 08:30
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm"];
    NSString *nowStr = [dateFormatter stringFromDate:now];
    [commands appendData:[[NSString stringWithFormat:@"%@\n", nowStr] dataUsingEncoding:enc]];
    
    [commands appendData:[@"\n\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    //打印完二维码后己带有切纸功能，所以不需再切一次
    [commands appendBytes:"\x1b\x64\x02" length:sizeof("\x1b\x64\x02") - 1];    // CutPaper
    
    int commandSize = [commands length];
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [commands getBytes:dataToSentToPrinter];
    
    SMPort *starPort = nil;
    @try {
        starPort = [SMPort getPort:portName :portSettings :3000];
        
        if (starPort == nil)
        {
            return;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLoc(@"no_link_printer")
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:kLoc(@"confirm")
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec){
                break;
            }
        }
        
        usleep(1000 * 1000);
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLoc(@"print_error")
                                                            message:kLoc(@"print_timeout")
                                                           delegate:nil
                                                  cancelButtonTitle:kLoc(@"confirm")
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLoc(@"print_error")
                                                        message:kLoc(@"print_timeout")
                                                       delegate:nil
                                              cancelButtonTitle:kLoc(@"confirm")
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally{
        [SMPort releasePort:starPort];
    }
    
    free(dataToSentToPrinter);
}


/**
 * This function opens the cashdraw connected to the printer
 * This function just send the byte 0x07 to the printer which is the open cashdrawer command
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)OpenCashDrawerWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    SMPort *starPort = NULL;
    @try
    {
        starPort = [SMPort getPort:portName :portSettings :10000];
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port" 
                                                            message:@""
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        unsigned char opencashdrawer_command[] = {0x07};
        int totalAmountWritten = [starPort writePort:opencashdrawer_command :0 :1];
        if (totalAmountWritten == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                            message:@"data not written out"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                        message:@"Write port timed out"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally 
    {
        [SMPort releasePort:starPort];
    }
}

/**
 * This function checks the status of the printer.
 * The check status function can be used for both portable and non portable printers.
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */

+ (SMPort*)CheckStatusWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    SMPort *starPort = NULL;
    @try
    {
        starPort = [SMPort getPort:portName :portSettings :10000];
        if (starPort == nil)
        {
            return nil;
        }
//        usleep(1000 * 1000);
        
        StarPrinterStatus_2 status;
        [starPort getParsedStatus:&status :2];
        
        NSString *message = @"";
        if (status.offline == SM_TRUE)
        {
            message = @"The printer is offline";
            if (status.coverOpen == SM_TRUE)
            {
                message = [message stringByAppendingString:@"\nCover is Open"];
//                return 2;
            }
            else if (status.receiptPaperEmpty == SM_TRUE)
            {
                message = [message stringByAppendingString:@"\nOut of Paper"];
//                return 3;
            }
        }
        else
        {
            return starPort;
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                        message:@"Get status failed"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }
}



/**
 * This function is used to print a pdf417 bar code in a standard star printer
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * limit - Selection of the Method to use so specify the bar code size.  This is either 0 or 1. 0 is Use Limit method and 1 is Use Fixed method. See section 3-122 of the manual (Rev 1.12).
 * p1 - The vertical proportion to use.  The value changes with the limit select.  See section 3-122 of the manual (Rev 1.12). 
 * p2 - The horizontal proportion to use.  The value changes with the limit select.  See section 3-122 of the manual (Rev 1.12). 
 * securityLevel - This represents how well the bar code can be recovered if it is damaged. This value should be 0 to 8.
 * xDirection - Specifies the X direction size. This value should be from 1 to 10.  It is recommended that the value be 2 or less.
 * aspectRatio - Specifies the ratio of the pdf417.  This values should be from 1 to 10.  It is recommended that this value be 2 or less.
 * barcodeData - Specifies the characters in the pdf417 bar code.
 * barcodeDataSize - Specifies the amount of characters to put in the barcode.  This should be the size of the preceding parameter.
 */
+ (void)PrintPDF417CodeWithPortname:(NSString *)portName portSettings:(NSString *)portSettings limit:(Limit)limit p1:(unsigned char)p1 p2:(unsigned char)p2 securityLevel:(unsigned char)securityLevel xDirection:(unsigned char)xDirection aspectRatio:(unsigned char)aspectRatio barcodeData:(unsigned char[])barcodeData barcodeDataSize:(unsigned int)barcodeDataSize
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    unsigned char setBarCodeSize[] = {0x1b, 0x1d, 0x78, 0x53, 0x30, 0x00, 0x00, 0x00};
    switch (limit)
    {
        case USE_LIMITS:
            setBarCodeSize[5] = 0;
            break;
        case USE_FIXED:
            setBarCodeSize[5] = 1;
            break;
    }
    setBarCodeSize[6] = p1;
    setBarCodeSize[7] = p2;
    
    [commands appendBytes:setBarCodeSize length:8];
    
    unsigned char setSecurityLevel[] = {0x1b, 0x1d, 0x78, 0x53, 0x31, 0x00};
    setSecurityLevel[5] = securityLevel;
    [commands appendBytes:setSecurityLevel length:6];
    
    unsigned char setXDirections[] = {0x1b, 0x1d, 0x78, 0x53, 0x32, 0x00};
    setXDirections[5] = xDirection;
    [commands appendBytes:setXDirections length:6];
    
    unsigned char setAspectRatio[] = {0x1b, 0x1d, 0x78, 0x53, 0x33, 0x00};
    setAspectRatio[5] = aspectRatio;
    [commands appendBytes:setAspectRatio length:6];
    
    unsigned char *setBarcodeData = (unsigned char*)malloc(6 + barcodeDataSize);
    setBarcodeData[0] = 0x1b;
    setBarcodeData[1] = 0x1d;
    setBarcodeData[2] = 0x78;
    setBarcodeData[3] = 0x44;
    setBarcodeData[4] = barcodeDataSize % 256;
    setBarcodeData[5] = barcodeDataSize / 256;
    for (int index = 0; index < barcodeDataSize; index++)
    {
        setBarcodeData[index + 6] = barcodeData[index];
    }
    [commands appendBytes:setBarcodeData length:6 + barcodeDataSize];
    free(setBarcodeData);
    
    unsigned char printBarcode[] = {0x1b, 0x1d, 0x78, 0x50};
    [commands appendBytes:printBarcode length:4];
    
    unsigned char *commandsToSendToPrinter = (unsigned char*)malloc([commands length]);
    [commands getBytes:commandsToSendToPrinter length:[commands length]];
    unsigned int commandSize = [commands length];
    
    SMPort *starPort = NULL;
    @try
    {
        starPort = [SMPort getPort:portName :portSettings :10000];
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port" 
                                                            message:@""
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }

        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:commandsToSendToPrinter :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        usleep(1000 * 1000);
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                            message:@"Write port timed out"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                        message:@"Write port timed out"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally 
    {
        [SMPort releasePort:starPort];
    }
    
    free(commandsToSendToPrinter);
}


/**
 * This function is used to print bar codes in the 39 format
 * context - Activity for displaying messages to the user
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * barcodeData - These are the characters that will be printed in the bar code. The characters available for this bar code are listed in section 3-43 (Rev. 1.12). 
 * barcodeDataSize - This is the number of characters in the barcode.  This should be the size of the preceding parameter
 * option - This tell the printer weather put characters under the printed bar code or not.  This may also be used to line feed after the bar code is printed.
 * height - The height of the bar code.  This is measured in pixels
 * width - The Narrow wide width of the bar code.  This value should be between 1 to 9.  See section 3-42 (Rev. 1.12) for more information on the values.
 */
+ (void)PrintCode39WithPortname:(NSString*)portName portSettings:(NSString*)portSettings barcodeData:(unsigned char *)barcodeData barcodeDataSize:(unsigned int)barcodeDataSize barcodeOptions:(BarCodeOptions)option height:(unsigned char)height narrowWide:(NarrowWide)width
{
    unsigned char n1 = 0x34;
    unsigned char n2 = 0;
    switch (option) {
        case No_Added_Characters_With_Line_Feed:
            n2 = 49;
            break;
        case Adds_Characters_With_Line_Feed:
            n2 = 50;
            break;
        case No_Added_Characters_Without_Line_Feed:
            n2 = 51;
            break;
        case Adds_Characters_Without_Line_Feed:
            n2 = 52;
            break;
    }
    unsigned char n3 = 0;
    switch (width)
    {
        case NarrowWide_2_6:
            n3 = 49;
            break;
        case NarrowWide_3_9:
            n3 = 50;
            break;
        case NarrowWide_4_12:
            n3 = 51;
            break;
        case NarrowWide_2_5:
            n3 = 52;
            break;
        case NarrowWide_3_8:
            n3 = 53;
            break;
        case NarrowWide_4_10:
            n3 = 54;
            break;
        case NarrowWide_2_4:
            n3 = 55;
            break;
        case NarrowWide_3_6:
            n3 = 56;
            break;
        case NarrowWide_4_8:
            n3 = 57;
            break;
    }
    unsigned char n4 = height;
    
    unsigned char *command = (unsigned char*)malloc(6 + barcodeDataSize + 1);
    command[0] = 0x1b;
    command[1] = 0x62;
    command[2] = n1;
    command[3] = n2;
    command[4] = n3;
    command[5] = n4;
    for (int index = 0; index < barcodeDataSize; index++)
    {
        command[index + 6] = barcodeData[index];
    }
    command[6 + barcodeDataSize] = 0x1e;
    
    int commandSize = 6 + barcodeDataSize + 1;
    
    SMPort *starPort = nil;
    @try {
        starPort = [SMPort getPort:portName :portSettings :10000];
        
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port" 
                                                            message:@""
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:command :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        usleep(1000 * 1000);
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                            message:@"Write port timed out"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                        message:@"Write port timed out"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }
    
    free(command);
}

/**
 * This function is used to print bar codes in the 93 format
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * barcodeData - These are the characters that will be printed in the bar code. The characters available for this bar code are listed in section 3-43 (Rev. 1.12). 
 * barcodeDataSize - This is the number of characters in the barcode.  This should be the size of the preceding parameter
 * option - This tell the printer weather put characters under the printed bar code or not.  This may also be used to line feed after the bar code is printed.
 * height - The height of the bar code.  This is measured in pixels
 * width - This is the number of dots per module.  This value should be between 1 to 3.  See section 3-42 (Rev. 1.12) for more information on the values.
 */
+ (void)PrintCode93WithPortname:(NSString*)portName portSettings:(NSString*)portSettings barcodeData: (unsigned char *)barcodeData barcodeDataSize:(unsigned int)barcodeDataSize barcodeOptions:(BarCodeOptions)option height:(unsigned char)height min_module_dots:(Min_Mod_Size)width
{
    unsigned char n1 = 0x37;
    unsigned char n2 = 0;
    switch (option)
    {
        case No_Added_Characters_With_Line_Feed:
            n2 = 49;
            break;
        case Adds_Characters_With_Line_Feed:
            n2 = 50;
            break;
        case No_Added_Characters_Without_Line_Feed:
            n2 = 51;
            break;
        case Adds_Characters_Without_Line_Feed:
            n2 = 52;
            break;
    }
    unsigned char n3 = 0;
    switch (width)
    {
        case _2_dots:
            n3 = 49;
            break;
        case _3_dots:
            n3 = 50;
            break;
        case _4_dots:
            n3 = 51;
            break;
    }
    unsigned char n4 = height;
    unsigned char *command = (unsigned char*)malloc(6 + barcodeDataSize + 1);
    command[0] = 0x1b;
    command[1] = 0x62;
    command[2] = n1;
    command[3] = n2;
    command[4] = n3;
    command[5] = n4;
    for (int index = 0; index < barcodeDataSize; index++)
    {
        command[index + 6] = barcodeData[index];
    }
    command[6 + barcodeDataSize] = 0x1e;
    
    int commandSize = 6 + barcodeDataSize + 1;
    
    SMPort *starPort = nil;
    @try {
        starPort = [SMPort getPort:portName :portSettings :10000];
        
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port" 
                                                            message:@""
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:command :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        usleep(1000 * 1000);
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                            message:@"Write port timed out"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                        message:@"Write port timed out"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }
    
    free(command);
}

/**
 * This function is used to print bar codes in the ITF format
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * barcodeData - These are the characters that will be printed in the bar code. The characters available for this bar code are listed in section 3-43 (Rev. 1.12). 
 * barcodeDataSize - This is the number of characters in the barcode.  This should be the size of the preceding parameter
 * option - This tell the printer weather put characters under the printed bar code or not.  This may also be used to line feed after the bar code is printed.
 * height - The height of the bar code.  This is measured in pixels
 * width - This is the number of dots per module.  This value should be between 1 to 3.  See section 3-42 (Rev. 1.12) for more information on the values.
 */
+ (void)PrintCodeITFWithPortname:(NSString*)portName portSettings:(NSString*)portSettings barcodeData:(unsigned char *)barcodeData barcodeDataSize:(unsigned int)barcodeDataSize barcodeOptions:(BarCodeOptions)option height:(unsigned char)height narrowWide:(NarrowWideV2)width
{
    unsigned char n1 = 0x35;
    unsigned char n2 = 0;
    switch (option)
    {
        case No_Added_Characters_With_Line_Feed:
            n2 = 49;
            break;
        case Adds_Characters_With_Line_Feed:
            n2 = 50;
            break;
        case No_Added_Characters_Without_Line_Feed:
            n2 = 51;
            break;
        case Adds_Characters_Without_Line_Feed:
            n2 = 52;
            break;
    }
    unsigned char n3 = 0;
    switch (width)
    {
        case NarrowWideV2_2_5:
            n3 = 49;
            break;
        case NarrowWideV2_4_10:
            n3 = 50;
            break;
        case NarrowWideV2_6_15:
            n3 = 51;
            break;
        case NarrowWideV2_2_4:
            n3 = 52;
            break;
        case NarrowWideV2_4_8:
            n3 = 53;
            break;
        case NarrowWideV2_6_12:
            n3 = 54;
            break;
        case NarrowWideV2_2_6:
            n3 = 55;
            break;
        case NarrowWideV2_3_9:
            n3 = 56;
            break;
        case NarrowWideV2_4_12:
            n3 = 57;
            break;
    }
    
    unsigned char n4 = height;
    unsigned char *command = (unsigned char*)malloc(6 + barcodeDataSize + 1);
    command[0] = 0x1b;
    command[1] = 0x62;
    command[2] = n1;
    command[3] = n2;
    command[4] = n3;
    command[5] = n4;
    for (int index = 0; index < barcodeDataSize; index++)
    {
        command[index + 6] = barcodeData[index];
    }
    command[barcodeDataSize + 6] = 0x1e;
    int commandSize = 6 + barcodeDataSize + 1;
    
    SMPort *starPort = nil;
    @try {
        starPort = [SMPort getPort:portName :portSettings :10000];
        
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port" 
                                                            message:@""
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:command :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        usleep(1000 * 1000);
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                            message:@"Write port timed out"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                        message:@"Write port timed out"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }
    
    free(command);
}

/**
 * This function is used to print bar codes in the 128 format
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * barcodeData - These are the characters that will be printed in the bar code. The characters available for this bar code are listed in section 3-43 (Rev. 1.12). 
 * barcodeDataSize - This is the number of characters in the barcode.  This should be the size of the preceding parameter
 * option - This tell the printer weather put characters under the printed bar code or not.  This may also be used to line feed after the bar code is printed.
 * height - The height of the bar code.  This is measured in pixels
 * width - This is the number of dots per module.  This value should be between 1 to 3.  See section 3-42 (Rev. 1.12) for more information on the values.
 */
+ (void)PrintCode128WithPortname:(NSString*)portName portSettings:(NSString*)portSettings barcodeData:(unsigned char *)barcodeData barcodeDataSize:(unsigned int)barcodeDataSize barcodeOptions:(BarCodeOptions)option height:(unsigned char)height min_module_dots:(Min_Mod_Size)width
{
    unsigned char n1 = 0x36;
    unsigned char n2 = 0;
    switch (option)
    {
        case No_Added_Characters_With_Line_Feed:
            n2 = 49;
            break;
        case Adds_Characters_With_Line_Feed:
            n2 = 50;
            break;
        case No_Added_Characters_Without_Line_Feed:
            n2 = 51;
            break;
        case Adds_Characters_Without_Line_Feed:
            n2 = 52;
            break;
    }
    unsigned char n3 = 0;
    switch (width)
    {
        case _2_dots:
            n3 = 49;
            break;
        case _3_dots:
            n3 = 50;
            break;
        case _4_dots:
            n3 = 51;
            break;
    }
    unsigned char n4 = height;
    unsigned char *command = (unsigned char*)malloc(6 + barcodeDataSize + 1);
    command[0] = 0x1b;
    command[1] = 0x62;
    command[2] = n1;
    command[3] = n2;
    command[4] = n3;
    command[5] = n4;
    for (int index = 0; index < barcodeDataSize; index++)
    {
        command[index + 6] = barcodeData[index];
    }
    command[barcodeDataSize + 6] = 0x1e;
    int commandSize = 6 + barcodeDataSize + 1;
    
    
    SMPort *starPort = nil;
    @try {
        starPort = [SMPort getPort:portName :portSettings :10000];
        
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port" 
                                                            message:@""
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:command :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        usleep(1000 * 1000);
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                            message:@"Write port timed out"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                        message:@"Write port timed out"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }
    
    free(command);
}

/**
 * This function is used to print a qrcode on standard star printers
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * correctionLevel - The correction level for the qrcode.  The correction level can be 7, 15, 25, or 30.  See section 3-129 (Rev. 1.12).
 * model - The model to use when printing the qrcode. See section 3-129 (Rev. 1.12). 
 * cellSize - The cell size of the qrcode.  This value of this should be between 1 and 8. It is recommended that this value be 2 or less.
 * barCodeData - This is the characters in the qrcode.
 * barcodeDataSize - This is the number of characters that will be written into the qrcode.  This is the size of the preceding parameter
 */
+ (void)PrintQrcodeWithPortname:(NSString*)portName portSettings:(NSString*)portSettings correctionLevel:(CorrectionLevelOption)correctionLevel model:(Model)model cellSize:(unsigned char)cellSize barcodeData:(unsigned char*)barCodeData barcodeDataSize:(unsigned int)barCodeDataSize
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    unsigned char modelCommand[] = {0x1b, 0x1d, 0x79, 0x53, 0x30, 0x00};
    switch (model)
    {
        case Model1:
            modelCommand[5] = 1;
            break;
        case Model2:
            modelCommand[5] = 2;
            break;
    }
    
    [commands appendBytes:modelCommand length:6];
    
    unsigned char correctionLevelCommand[] = {0x1b, 0x1d, 0x79, 0x53, 0x31, 0x00};
    switch (correctionLevel)
    {
        case Low:
            correctionLevelCommand[5] = 0;
            break;
        case Middle:
            correctionLevelCommand[5] = 1;
            break;
        case Q:
            correctionLevelCommand[5] = 2;
            break;
        case High:
            correctionLevelCommand[5] = 3;
            break;
    }
    [commands appendBytes:correctionLevelCommand length:6];
    
    unsigned char cellCodeSize[] = {0x1b, 0x1d, 0x79, 0x53, 0x32, 0x00};
    cellCodeSize[5] = cellSize;
    [commands appendBytes:cellCodeSize length:6];
    
    unsigned char qrcodeStart[] = {0x1b, 0x1d, 0x79, 0x44, 0x31, 0x00};
    [commands appendBytes:qrcodeStart length:6];
    unsigned char qrcodeLow = barCodeDataSize % 256;
    unsigned char qrcodeHigh = barCodeDataSize / 256;
    [commands appendBytes:&qrcodeLow length:1];
    [commands appendBytes:&qrcodeHigh length:1];
    [commands appendBytes:barCodeData length:barCodeDataSize];
    
    unsigned char printQrcodeCommand[] = {0x1b, 0x1d, 0x79, 0x50};
    [commands appendBytes:printQrcodeCommand length:4];
    
    unsigned char *commandsToSendToPrinter = (unsigned char*)malloc([commands length]);
    [commands getBytes:commandsToSendToPrinter];
    int commandSize = [commands length];
    
    SMPort *starPort = nil;
    @try {
        starPort = [SMPort getPort:portName :portSettings :10000];
        
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port" 
                                                            message:@""
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:commandsToSendToPrinter :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        usleep(1000 * 1000);
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                            message:@"Write port timed out"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                        message:@"Write port timed out"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }
    
    free(commandsToSendToPrinter);
}

/**
 * This function is intended to show how to get a legacy printer to cut the paper
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * cuttype - The cut type to perform, the cut types are full cut, full cut with feed, partial cut, and partial cut with feed
 */
+ (void)PreformCutWithPortname:(NSString *)portName portSettings:(NSString*)portSettings cutType:(CutType)cuttype
{
    unsigned char autocutCommand[] = {0x1b, 0x64, 0x00};
    switch (cuttype)
    {
        case FULL_CUT:
            autocutCommand[2] = 48;
            break;
        case PARCIAL_CUT:
            autocutCommand[2] = 49;
            break;
        case FULL_CUT_FEED:
            autocutCommand[2] = 50;
            break;
        case PARTIAL_CUT_FEED:
            autocutCommand[2] = 51;
            break;
    }
    
    int commandSize = 3;
    
    SMPort *starPort = nil;
    @try {
        starPort = [SMPort getPort:portName :portSettings :10000];
        
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port" 
                                                            message:@""
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:autocutCommand :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        usleep(1000 * 1000);
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                            message:@"Write port timed out"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                        message:@"Write port timed out"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }
}

/**
 * This function prints raw text to the print.  It show how the text can be formated.  For example changing its size.
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * slashedZero - boolean variable to tell the printer to weather to put a slash in the zero characters that it print
 * underline - boolean variable that Tells the printer if should underline the text
 * invertColor - boolean variable that tells the printer if it should invert the text its printing.  All White space will become black and the characters will be left white
 * emphasized - boolean variable that tells the printer if it should emphasize the printed text.  This is sort of like bold but not as dark, but darker then regular characters.
 * upperline - boolean variable that tells the printer if to place a line above the text.  This only supported by new printers.
 * upsideDown - boolean variable that tells the printer if the text should be printed upside-down
 * heightExpansion - This integer tells the printer what multiple the character height should be, this should be from 0 to 5 representing multiples from 1 to 6
 * widthExpansion - This integer tell the printer what multiple the character width should be, this should be from 0 to 5 representing multiples from 1 to 6.
 * leftMargin - The left margin for the text.  Although the max value for this can be 255, the value shouldn't get that high or the text could be pushed off the page.
 * alignment - The alignment of the text. The printers support left, right, and center justification
 * textData - The text to print
 * textDataSize - The amount of text to send to the printer
 */
+ (void)PrintTextWithPortname:(NSString *)portName portSettings:(NSString*)portSettings slashedZero:(bool)slashedZero underline:(bool)underline invertColor:(bool)invertColor emphasized:(bool)emphasized upperline:(bool)upperline upsideDown:(bool)upsideDown heightExpansion:(int)heightExpansion widthExpansion:(int)widthExpansion leftMargin:(unsigned char)leftMargin alignment: (Alignment)alignment textData:(unsigned char*)textData textDataSize:(unsigned int)textDataSize
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
	unsigned char initial[] = {0x1b, 0x40};
	[commands appendBytes:initial length:2];
	
    unsigned char slashedZeroCommand[] = {0x1b, 0x2f, 0x00};
    if (slashedZero)
    {
        slashedZeroCommand[2] = 49;
    }
    else
    {
        slashedZeroCommand[2] = 48;
    }
    [commands appendBytes:slashedZeroCommand length:3];
    
    unsigned char underlineCommand[] = {0x1b, 0x2d, 0x00};
    if (underline)
    {
        underlineCommand[2] = 49;
    }
    else
    {
        underlineCommand[2] = 48;
    }
    [commands appendBytes:underlineCommand length:3];
    
    unsigned char invertColorCommand[] = {0x1b, 0x00};
    if (invertColor)
    {
        invertColorCommand[1] = 0x34;
    }
    else
    {
        invertColorCommand[1] = 0x35;
    }
    [commands appendBytes:invertColorCommand length:2];
    
    unsigned char emphasizedPrinting[] = {0x1b, 0x00};
    if (emphasized)
    {
        emphasizedPrinting[1] = 69;
    }
    else
    {
        emphasizedPrinting[1] = 70;
    }
    [commands appendBytes:emphasizedPrinting length:2];
    
    unsigned char upperLineCommand[] = {0x1b, 0x5f, 0x00};
    if (upperline)
    {
        upperLineCommand[2] = 0x49;
    }
    else
    {
        upperLineCommand[2] = 0x48;
    }
    [commands appendBytes:upperLineCommand length:3];
    
    if (upsideDown)
    {
        unsigned char upsd = 0x0f;
        [commands appendBytes:&upsd length:1];
    }
    else
    {
        unsigned char upsd = 0x12;
        [commands appendBytes:&upsd length:1];
    }
    
    unsigned char characterExpansion[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion[2] = heightExpansion + '0';
    characterExpansion[3] = widthExpansion + '0';
    [commands appendBytes:characterExpansion length:4];
    
    unsigned char leftMarginCommand[] = {0x1b, 0x6c, 0x00};
    leftMarginCommand[2] = leftMargin;
    [commands appendBytes:leftMarginCommand length:3];
    
    unsigned char alignmentCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    switch (alignment)
    {
        case Left:
            alignmentCommand[3] = 48;
            break;
        case Center:
            alignmentCommand[3] = 49;
            break;
        case Right:
            alignmentCommand[3] = 50;
            break;
    }
    [commands appendBytes:alignmentCommand length:4];
    
    [commands appendBytes:textData length:textDataSize];
    
    unsigned char lf = 0x0a;
    [commands appendBytes:&lf length:1];
    
    int commandSize = [commands length];
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [commands getBytes:dataToSentToPrinter];
    
    SMPort *starPort = nil;
    @try {
        starPort = [SMPort getPort:portName :portSettings :10000];
        
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port" 
                                                            message:@""
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        usleep(1000 * 1000);
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                            message:@"Write port timed out"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                        message:@"Write port timed out"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }
    
    free(dataToSentToPrinter);
}

/**
 * This function prints raw Kanji text to the print.  It show how the text can be formated.  For example changing its size.
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * kanjiMode - The segment index of Japanese Kanji mode that Tells the printer to weather Shift-JIS or JIS.
 * underline - boolean variable that Tells the printer if should underline the text
 * invertColor - boolean variable that tells the printer if it should invert the text its printing.  All White space will become black and the characters will be left white
 * emphasized - boolean variable that tells the printer if it should emphasize the printed text.  This is sort of like bold but not as dark, but darker then regular characters.
 * upperline - boolean variable that tells the printer if to place a line above the text.  This only supported by new printers.
 * upsideDown - boolean variable that tells the printer if the text should be printed upside-down
 * heightExpansion - This integer tells the printer what multiple the character height should be, this should be from 0 to 5 representing multiples from 1 to 6
 * widthExpansion - This integer tell the printer what multiple the character width should be, this should be from 0 to 5 representing multiples from 1 to 6.
 * leftMargin - The left margin for the text.  Although the max value for this can be 255, the value shouldn't get that high or the text could be pushed off the page.
 * alignment - The alignment of the text. The printers support left, right, and center justification
 * textData - The text to print
 * textDataSize - The amount of text to send to the printer
 */
+ (void)PrintKanjiTextWithPortname:(NSString *)portName portSettings:(NSString*)portSettings kanjiMode:(int)kanjiMode underline:(bool)underline invertColor:(bool)invertColor emphasized:(bool)emphasized upperline:(bool)upperline upsideDown:(bool)upsideDown heightExpansion:(int)heightExpansion widthExpansion:(int)widthExpansion leftMargin:(unsigned char)leftMargin alignment:(Alignment)alignment textData:(unsigned char*)textData textDataSize:(unsigned int)textDataSize
{
    NSMutableData *commands = [[NSMutableData alloc] init];

	unsigned char initial[] = {0x1b, 0x40};
	[commands appendBytes:initial length:2];
		
    unsigned char kanjiModeCommand[] = {0x1b, 0x24, 0x00, 0x1b, 0x00};
    if (kanjiMode == 0)	// Shift-JIS
    {
        kanjiModeCommand[2] = 0x01;
        kanjiModeCommand[4] = 0x71;
    }
    else				// JIS
    {
        kanjiModeCommand[2] = 0x00;
        kanjiModeCommand[4] = 0x70;
    }
    [commands appendBytes:kanjiModeCommand length:5];
    
    unsigned char underlineCommand[] = {0x1b, 0x2d, 0x00};
    if (underline)
    {
        underlineCommand[2] = 49;
    }
    else
    {
        underlineCommand[2] = 48;
    }
    [commands appendBytes:underlineCommand length:3];
    
    unsigned char invertColorCommand[] = {0x1b, 0x00};
    if (invertColor)
    {
        invertColorCommand[1] = 0x34;
    }
    else
    {
        invertColorCommand[1] = 0x35;
    }
    [commands appendBytes:invertColorCommand length:2];
    
    unsigned char emphasizedPrinting[] = {0x1b, 0x00};
    if (emphasized)
    {
        emphasizedPrinting[1] = 69;
    }
    else
    {
        emphasizedPrinting[1] = 70;
    }
    [commands appendBytes:emphasizedPrinting length:2];
    
    unsigned char upperLineCommand[] = {0x1b, 0x5f, 0x00};
    if (upperline)
    {
        upperLineCommand[2] = 0x49;
    }
    else
    {
        upperLineCommand[2] = 0x48;
    }
    [commands appendBytes:upperLineCommand length:3];
    
    if (upsideDown)
    {
        unsigned char upsd = 0x0f;
        [commands appendBytes:&upsd length:1];
    }
    else
    {
        unsigned char upsd = 0x12;
        [commands appendBytes:&upsd length:1];
    }
    
    unsigned char characterExpansion[] = {0x1b, 0x69, 0x00, 0x00};
    characterExpansion[2] = heightExpansion + '0';
    characterExpansion[3] = widthExpansion + '0';
    [commands appendBytes:characterExpansion length:4];
    
    unsigned char leftMarginCommand[] = {0x1b, 0x6c, 0x00};
    leftMarginCommand[2] = leftMargin;
    [commands appendBytes:leftMarginCommand length:3];
    
    unsigned char alignmentCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    switch (alignment)
    {
        case Left:
            alignmentCommand[3] = 48;
            break;
        case Center:
            alignmentCommand[3] = 49;
            break;
        case Right:
            alignmentCommand[3] = 50;
            break;
    }
    [commands appendBytes:alignmentCommand length:4];
    
    [commands appendBytes:textData length:textDataSize];
    
    unsigned char lf = 0x0a;
    [commands appendBytes:&lf length:1];
    
    int commandSize = [commands length];
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [commands getBytes:dataToSentToPrinter];
    
    SMPort *starPort = nil;
    @try {
        starPort = [SMPort getPort:portName :portSettings :10000];
        
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port" 
                                                            message:@""
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        usleep(1000 * 1000);
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                            message:@"Write port timed out"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                        message:@"Write port timed out"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }
    
    free(dataToSentToPrinter);
}

/**
 * This function is used to print a uiimage directly to the printer.
 * There are 2 ways a printer can usually print images, one is through raster commands the other is through line mode commands
 * This function uses raster commands to print an image.  Raster is support on the tsp100 and all legacy thermal printers
 * The line mode printing is not supported by the tsp100 so its not used
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 * source - the uiimage to convert to star raster data
 * maxWidth - the maximum with the image to print.  This is usually the page with of the printer.  If the image exceeds the maximum width then the image is scaled down.  The ratio is maintained. 
 */
+ (void)PrintImageWithPortname:(NSString *)portName portSettings:(NSString*)portSettings imageToPrint:(UIImage*)imageToPrint maxWidth:(int)maxWidth compressionEnable:(BOOL)compressionEnable
{
    RasterDocument *rasterDoc = [[RasterDocument alloc] initWithDefaults:RasSpeed_Medium endOfPageBehaviour:RasPageEndMode_FeedAndFullCut endOfDocumentBahaviour:RasPageEndMode_FeedAndFullCut topMargin:RasTopMargin_Standard pageLength:0 leftMargin:30 rightMargin:30];
    StarBitmap *starbitmap = [[StarBitmap alloc] initWithUIImage:imageToPrint :maxWidth :false];
    
    NSMutableData *commandsToPrint = [[NSMutableData alloc] init];
    NSData *shortcommand = [rasterDoc BeginDocumentCommandData];
    [commandsToPrint appendData:shortcommand];
    
    shortcommand = [starbitmap getImageDataForPrinting:compressionEnable];
    [commandsToPrint appendData:shortcommand];
    
    shortcommand = [rasterDoc EndDocumentCommandData];
    [commandsToPrint appendData:shortcommand];
    
    int commandSize = [commandsToPrint length];
    unsigned char *dataToSentToPrinter = (unsigned char*)malloc(commandSize);
    [commandsToPrint getBytes:dataToSentToPrinter];
    
    SMPort *starPort = nil;
    @try {
        starPort = [SMPort getPort:portName :portSettings :10000];
        
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port" 
                                                            message:@""
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        StarPrinterStatus_2 status;
        [starPort beginCheckedBlock:&status :2];
        if (status.offline == SM_TRUE) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Printer is offline"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }

        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :remaining];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                            message:@"Write port timed out"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        [starPort endCheckedBlock:&status :2];
        if (status.offline == SM_TRUE) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Printer is offline"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                        message:@"Write port timed out"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }
    
    free(dataToSentToPrinter);
}

+ (BOOL)waitForTransmissionToComplete:(SMPort *)starPort timeoutSec:(int)timeoutSec
{
    if ([[starPort.portName uppercaseString] hasPrefix:@"BT:"] == NO) {
        return YES;
    }
    
    struct timeval start, end;
    unsigned char queryStatusCommand[] = {0x1b, 0x06, 0x01};
    int amountWritten = 0;
    
    gettimeofday(&start, NULL);
    while (YES) {
        amountWritten += [starPort writePort:queryStatusCommand :amountWritten :sizeof(queryStatusCommand) - amountWritten];
        if (amountWritten == sizeof(queryStatusCommand))
            break;
        
        gettimeofday(&end, NULL);
        if (end.tv_sec - start.tv_sec > timeoutSec)
        {
            return NO;
        }
        
        usleep(200 * 1000);
    }
    
    while (YES) {
        unsigned char readBuffer[64];
        int readSize = [starPort readPort:readBuffer :0 :sizeof(readBuffer)];
        if (readSize > 0) {
            break;
        }
        
        gettimeofday(&end, NULL);
        if (end.tv_sec - start.tv_sec > timeoutSec)
        {
            return NO;
        }
        
        usleep(200 * 1000);
    }

    return YES;
}

/**
 * This function print the sample receipt (3inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintSampleReceipt3InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    NSMutableData *commands = [[NSMutableData alloc] init];

    [commands appendBytes:"\x1b\x1d\x61\x01"
            length:sizeof("\x1b\x1d\x61\x01") - 1];    // center

    [commands appendData:[@"Star Clothing Boutique\r\n" dataUsingEncoding:NSASCIIStringEncoding]];

    [commands appendData:[@"123 Star Road\r\nCity, State 12345\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];

    [commands appendBytes:"\x1b\x1d\x61\x00"
            length:sizeof("\x1b\x1d\x61\x00") - 1];    // Alignment(left)

    [commands appendBytes:"\x1b\x44\x02\x10\x22\x00"
            length:sizeof("\x1b\x44\x02\x10\x22\x00") - 1];    // SetHT

    [commands appendData:[@"Date: MM/DD/YYYY" dataUsingEncoding:NSASCIIStringEncoding]];

    [commands appendBytes:" \x09 "
            length:sizeof(" \x09 ") - 1];

    [commands appendData:[@"Time:HH:MM PM\r\n------------------------------------------------\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x45"
            length:sizeof("\x1b\x45") - 1];    // SetBold

    [commands appendData:[@"SALE \r\n" dataUsingEncoding:NSASCIIStringEncoding]];

    [commands appendBytes:"\x1b\x46"
            length:sizeof("\x1b\x46") - 1];    // CancelBold

    [commands appendData:[@"SKU " dataUsingEncoding:NSASCIIStringEncoding]];

    [commands appendBytes:"\x09"
            length:sizeof("\x09") - 1];    // HT

    [commands appendData:[@"  Description   \x09         Total\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300678566 \x09  PLAIN T-SHIRT\x09         10.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300692003 \x09  BLACK DENIM\x09         29.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300651148 \x09  BLUE DENIM\x09         29.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300642980 \x09  STRIPED DRESS\x09         49.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300638471 \x09  BLACK BOOTS\x09         35.99\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Subtotal \x09\x09        156.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];

    [commands appendData:[@"Tax \x09\x09          0.00\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"------------------------------------------------\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Total" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x09\x09\x1b\x69\x01\x01"
            length:sizeof("\x09\x09\x1b\x69\x01\x01") - 1];    // SetDoubleHW

    [commands appendData:[@"$156.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];

    [commands appendBytes:"\x1b\x69\x00\x00"
            length:sizeof("\x1b\x69\x00\x00") - 1];    // CancelDoubleHW

    [commands appendData:[@"------------------------------------------------\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];

    [commands appendData:[@"Charge\r\n159.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Visa XXXX-XXXX-XXXX-0123\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];

    [commands appendData:[@"\x1b\x34Refunds and Exchanges\x1b\x35\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Within " "\x1b\x2d\x01" "30 days\x1b\x2d\x00" " with receipt\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"And tags attached\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
     
    [commands appendBytes:"\x1b\x1d\x61\x01"
            length:sizeof("\x1b\x1d\x61\x01") - 1];    // Alignment(center)

    [commands appendBytes:"\x1b\x62\x06\x02\x02\x20" "12ab34cd56\x1e\r\n"
            length:sizeof("\x1b\x62\x06\x02\x02\x20" "12ab34cd56\x1e\r\n") - 1];    // PrintBarcode

    [commands appendBytes:"\x1b\x64\x02"
            length:sizeof("\x1b\x64\x02") - 1];    // CutPaper

    [commands appendBytes:"\x07"
            length:sizeof("\x07") - 1];    // KickCashDrawer

    int commandSize = [commands length];
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [commands getBytes:dataToSentToPrinter];
    
    SMPort *starPort = nil;
    @try {
        starPort = [SMPort getPort:portName :portSettings :10000];
        
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port" 
                                                            message:@""
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;

        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec){
                break;
            }
        }
        
        usleep(1000 * 1000);
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                            message:@"Write port timed out"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                        message:@"Write port timed out"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }
    
    free(dataToSentToPrinter);
}

/**
 * This function print the sample receipt (4inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintSampleReceipt4InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    [commands appendBytes:"\x1b\x1d\x61\x01"
            length:sizeof("\x1b\x1d\x61\x01") - 1];    // center
    
    [commands appendData:[@"Star Clothing Boutique\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"123 Star Road\r\nCity, State 12345\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x00"
            length:sizeof("\x1b\x1d\x61\x00") - 1];    // Alignment(left)
    
    [commands appendBytes:"\x1b\x44\x02\x1a\x37\x00"
            length:sizeof("\x1b\x44\x02\x1a\x37\x00") - 1];    // SetHT
    
    [commands appendData:[@"Date: MM/DD/YYYY" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:" \x09 "
            length:sizeof(" \x09 ") - 1];
    
    [commands appendData:[@"Time:HH:MM PM\r\n" "---------------------------------------------------------------------\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x45"
            length:sizeof("\x1b\x45") - 1];    // SetBold
    
    [commands appendData:[@"SALE \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x46"
            length:sizeof("\x1b\x46") - 1];    // CancelBold
    
    [commands appendData:[@"SKU " dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x09"
            length:sizeof("\x09") - 1];    // HT
    
    [commands appendData:[@" Description   \x09         Total\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300678566 \x09  PLAIN T-SHIRT\x09         10.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300692003 \x09  BLACK DENIM\x09         29.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300651148 \x09  BLUE DENIM\x09         29.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300642980 \x09  STRIPED DRESS\x09         49.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300638471 \x09  BLACK BOOTS\x09         35.99\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Subtotal \x09\x09        156.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Tax \x09\x09          0.00\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"---------------------------------------------------------------------\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Total" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x09\x09\x1b\x69\x01\x01"
            length:sizeof("\x09\x09\x1b\x69\x01\x01") - 1];    // SetDoubleHW
    
    [commands appendData:[@"$156.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x69\x00\x00"
            length:sizeof("\x1b\x69\x00\x00") - 1];    // CancelDoubleHW
    
    [commands appendData:[@"---------------------------------------------------------------------\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Charge\r\n159.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Visa XXXX-XXXX-XXXX-0123\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"\x1b\x34Refunds and Exchanges\x1b\x35\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Within " "\x1b\x2d\x01" "30 days\x1b\x2d\x00" " with receipt\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"And tags attached\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x01"
            length:sizeof("\x1b\x1d\x61\x01") - 1];    // Alignment(center)
    
    [commands appendBytes:"\x1b\x62\x06\x02\x02\x20" "12ab34cd56\x1e\r\n"
            length:sizeof("\x1b\x62\x06\x02\x02\x20" "12ab34cd56\x1e\r\n") - 1];    // PrintBarcode
    
    [commands appendBytes:"\x1b\x64\x02"
            length:sizeof("\x1b\x64\x02") - 1];    // CutPaper
    
    [commands appendBytes:"\x07"
            length:sizeof("\x07") - 1];    // KickCashDrawer
    
    int commandSize = [commands length];
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [commands getBytes:dataToSentToPrinter];
    
    SMPort *starPort = nil;
    @try {
        starPort = [SMPort getPort:portName :portSettings :10000];
        
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port" 
                                                            message:@""
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        usleep(1000 * 1000);
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                            message:@"Write port timed out"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                        message:@"Write port timed out"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }
    
    free(dataToSentToPrinter);
}

/**
 * This function print the Kanji sample receipt (3inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintKanjiSampleReceipt3InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    NSMutableData *commands = [[NSMutableData alloc] init];

    [commands appendBytes:"\x1b\x40"
            length:sizeof("\x1b\x40") - 1];    // Initialization

    [commands appendBytes:"\x1b\x24\x31"
            length:sizeof("\x1b\x24\x31") - 1];    // 漢字モード設定

    [commands appendBytes:"\x1b\x1d\x61\x31"
            length:sizeof("\x1b\x1d\x61\x31") - 1];    // 中央揃え設定

    [commands appendBytes:"\x1b\x69\x02\x00"
            length:sizeof("\x1b\x69\x02\x00") - 1];    // 文字縦拡大設定

    [commands appendBytes:"\x1b\x45"
            length:sizeof("\x1b\x45") - 1];    // 強調印字設定

    [commands appendData:[@"スター電機\n" dataUsingEncoding:NSShiftJISStringEncoding]];

    [commands appendBytes:"\x1b\x69\x01\x00"
            length:sizeof("\x1b\x69\x01\x00") - 1];    // 文字縦拡大設定

    [commands appendData:[@"修理報告書　兼領収書\n" dataUsingEncoding:NSShiftJISStringEncoding]];

    [commands appendBytes:"\x1b\x69\x00\x00"
            length:sizeof("\x1b\x69\x00\x00") - 1];    // 文字縦拡大解除

    [commands appendBytes:"\x1b\x46"
            length:sizeof("\x1b\x46") - 1];    // 強調印字解除

    [commands appendData:[@"------------------------------------------------\n" dataUsingEncoding:NSShiftJISStringEncoding]];

    [commands appendBytes:"\x1b\x1d\x61\x30"
            length:sizeof("\x1b\x1d\x61\x30") - 1];    //左揃え設定

    [commands appendData:[@"発行日時：YYYY年MM月DD日HH時MM分" "\n" dataUsingEncoding:NSShiftJISStringEncoding]];

    [commands appendData:[@"TEL：054-347-XXXX\n\n" dataUsingEncoding:NSShiftJISStringEncoding]];

    [commands appendData:[@"           ｲｹﾆｼ  ｼｽﾞｺ   ｻﾏ\n" dataUsingEncoding:NSShiftJISStringEncoding]];

    [commands appendData:[@"　お名前：池西　静子　様\n"
                           "　御住所：静岡市清水区七ツ新屋\n"
                           "　　　　　５３６番地\n"
                           "　伝票番号：No.12345-67890\n\n"
                           "　この度は修理をご用命頂き有難うございます。\n"
                           " 今後も故障など発生した場合はお気軽にご連絡ください。\n\n"
                          dataUsingEncoding:NSShiftJISStringEncoding]];

    [commands appendData:[@"品名／型名　          数量      金額　   備考\n"
                           "------------------------------------------------\n"
                           "制御基板　          　  1　　  10,000    配達\n"
                           "操作スイッチ            1　     3,800　  配達\n"
                           "パネル　　          　  1       2,000　  配達\n"
                           "技術料　          　　　1      15,000\n"
                           "出張費用　　            1　     5,000\n"
                           "------------------------------------------------\n"
                          dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendData:[@"\n"
                           "　　　　　　　       　  　     小計   35,800\n"
                           "　　　　　　 　　  　      　   内税    1,790\n"
                           "　　　　　　 　　   　　        合計   37,590\n\n"
                           "　お問合わせ番号　　12345-67890\n\n\n\n"
                          dataUsingEncoding:NSShiftJISStringEncoding]];

    [commands appendBytes:"\x1b\x64\x33"
            length:sizeof("\x1b\x64\x33") - 1];    // カット

    int commandSize = [commands length];
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [commands getBytes:dataToSentToPrinter];
    
    SMPort *starPort = nil;
    @try {
        starPort = [SMPort getPort:portName :portSettings :10000];
        
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port" 
                                                            message:@""
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        usleep(1000 * 1000);
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                            message:@"Write port timed out"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                        message:@"Write port timed out"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }
    
    free(dataToSentToPrinter);
}

/**
 * This function print the Kanji sample receipt (4inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintKanjiSampleReceipt4InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    NSMutableData *commands = [[NSMutableData alloc] init];
    
    [commands appendBytes:"\x1b\x40"
            length:sizeof("\x1b\x40") - 1];    // Initialization
    
    [commands appendBytes:"\x1b\x24\x31"
            length:sizeof("\x1b\x24\x31") - 1];    // 漢字モード設定
    
    [commands appendBytes:"\x1b\x1d\x61\x31"
            length:sizeof("\x1b\x1d\x61\x31") - 1];    // 中央揃え設定
    
    [commands appendBytes:"\x1b\x69\x02\x00"
            length:sizeof("\x1b\x69\x02\x00") - 1];    // 文字縦拡大設定
    
    [commands appendBytes:"\x1b\x45"
            length:sizeof("\x1b\x45") - 1];    // 強調印字設定
    
    [commands appendData:[@"スター電機\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x69\x01\x00"
            length:sizeof("\x1b\x69\x01\x00") - 1];    // 文字縦拡大設定
    
    [commands appendData:[@"修理報告書　兼領収書\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x69\x00\x00"
            length:sizeof("\x1b\x69\x00\x00") - 1];    // 文字縦拡大解除
    
    [commands appendBytes:"\x1b\x46"
            length:sizeof("\x1b\x46") - 1];    // 強調印字解除

    [commands appendData:[@"---------------------------------------------------------------------\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x30"
            length:sizeof("\x1b\x1d\x61\x30") - 1];    //左揃え設定
    
    [commands appendData:[@"発行日時：YYYY年MM月DD日HH時MM分" "\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendData:[@"TEL：054-347-XXXX\n\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendData:[@"           ｲｹﾆｼ  ｼｽﾞｺ   ｻﾏ\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendData:[@"　お名前：池西　静子　様\n"
                           "　御住所：静岡市清水区七ツ新屋\n"
                           "　　　　　５３６番地\n"
                           "　伝票番号：No.12345-67890\n\n"
                           "　この度は修理をご用命頂き有難うございます。\n"
                          " 今後も故障など発生した場合はお気軽にご連絡ください。\n\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendData:[@"品名／型名　                 数量             金額　          備考\n"
                           "---------------------------------------------------------------------\n"
                           "制御基板　                 　  1       　　  10,000           配達\n"
                           "操作スイッチ                   1　            3,800       　  配達\n"
                           "パネル　　                 　  1              2,000       　  配達\n"
                           "技術料       　          　　　1             15,000\n"
                           "出張費用　　                   1　            5,000\n"
                           "---------------------------------------------------------------------\n"
                          dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendData:[@"\n"
                           "　　　　　　　       　  　                          小計   35,800\n"
                           "　                     　　　　　 　　  　      　   内税    1,790\n"
                           "                     　　　　　　 　　   　　        合計   37,590\n\n"
                          "　お問合わせ番号　　12345-67890\n\n\n\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x64\x33"
            length:sizeof("\x1b\x64\x33") - 1];    // カット
    
    int commandSize = [commands length];
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [commands getBytes:dataToSentToPrinter];
    
    SMPort *starPort = nil;
    @try {
        starPort = [SMPort getPort:portName :portSettings :10000];
        
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port" 
                                                            message:@""
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        usleep(1000 * 1000);
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                            message:@"Write port timed out"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error" 
                                                        message:@"Write port timed out"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }
    
    free(dataToSentToPrinter);
}

/**
 * This function print the Raster sample receipt (3inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintRasterSampleReceipt3InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    NSString *textToPrint = @"        Star Clothing Boutique\r\n"
                             "             123 Star Road\r\n"
                             "           City, State 12345\r\n"
                             "\r\n" 
                             "Date: MM/DD/YYYY         Time:HH:MM PM\r\n"
                             "--------------------------------------\r\n"
                             "SALE\r\n"
                             "SKU            Description       Total\r\n" 
                             "300678566      PLAIN T-SHIRT     10.99\n"
                             "300692003      BLACK DENIM       29.99\n"
                             "300651148      BLUE DENIM        29.99\n"
                             "300642980      STRIPED DRESS     49.99\n"
                             "30063847       BLACK BOOTS       35.99\n"
                             "\n"
                             "Subtotal                        156.95\r\n"
                             "Tax                               0.00\r\n"
                             "--------------------------------------\r\n"
                             "Total                          $156.95\r\n"
                             "--------------------------------------\r\n"
                             "\r\n"
                             "Charge\r\n159.95\r\n"
                             "Visa XXXX-XXXX-XXXX-0123\r\n"
                             "Refunds and Exchanges\r\n"
                             "Within 30 days with receipt\r\n"
                             "And tags attached\r\n";
    
    int width = 576;
    
    NSString *fontName = @"Courier";
    
    double fontSize = 12.0;
    
    //  fontSize *= multiple;
    fontSize *= 2;
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    
    CGSize size = CGSizeMake(width, 10000);
    CGSize messuredSize = [textToPrint sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
	
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		if ([[UIScreen mainScreen] scale] == 2.0) {
			UIGraphicsBeginImageContextWithOptions(messuredSize, NO, 1.0);
		} else {
			UIGraphicsBeginImageContext(messuredSize);
		}
	} else {
		UIGraphicsBeginImageContext(messuredSize);
	}
    
    CGContextRef ctr = UIGraphicsGetCurrentContext();
    UIColor *color = [UIColor whiteColor];
    [color set];
    
    CGRect rect = CGRectMake(0, 0, messuredSize.width, messuredSize.height);
    CGContextFillRect(ctr, rect);
    
    color = [UIColor blackColor];
    [color set];
    
    [textToPrint drawInRect:rect withFont:font lineBreakMode:UILineBreakModeWordWrap];
    
    UIImage *imageToPrint = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [PrinterFunctions PrintImageWithPortname:portName portSettings:portSettings imageToPrint:imageToPrint maxWidth:width compressionEnable:YES];
}

/**
 * This function print the Raster sample receipt (4inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintRasterSampleReceipt4InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    NSString *textToPrint = @"                   Star Clothing Boutique\r\n"
                            "                        123 Star Road\r\n"
                            "                      City, State 12345\r\n"
                            "\r\n" 
                            "Date: MM/DD/YYYY                            Time:HH:MM PM\r\n"
                            "---------------------------------------------------------\r\n"
                            "SALE\r\n"
                            "SKU                     Description                 Total\r\n" 
                            "300678566               PLAIN T-SHIRT               10.99\n"
                            "300692003               BLACK DENIM                 29.99\n"
                            "300651148               BLUE DENIM                  29.99\n"
                            "300642980               STRIPED DRESS               49.99\n"
                            "300638471               BLACK BOOTS                 35.99\n"
                            "\n"
                            "Subtotal                                           156.95\r\n"
                            "Tax                                                  0.00\r\n"
                            "---------------------------------------------------------\r\n"
                            "Total                                             $156.95\r\n"
                            "---------------------------------------------------------\r\n"
                            "\r\n"
                            "Charge\r\n159.95\r\n"
                            "Visa XXXX-XXXX-XXXX-0123\r\n"
                            "Refunds and Exchanges\r\n"
                            "Within 30 days with receipt\r\n"
                            "And tags attached\r\n";
    
    int width = 832;
    
    NSString *fontName = @"Courier";
    
    double fontSize = 12.0;
    
//  fontSize *= multiple;
    fontSize *= 2;
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    
    CGSize size = CGSizeMake(width, 10000);
    CGSize messuredSize = [textToPrint sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
	
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		if ([[UIScreen mainScreen] scale] == 2.0) {
			UIGraphicsBeginImageContextWithOptions(messuredSize, NO, 1.0);
		} else {
			UIGraphicsBeginImageContext(messuredSize);
		}
	} else {
		UIGraphicsBeginImageContext(messuredSize);
	}
    
    CGContextRef ctr = UIGraphicsGetCurrentContext();
    UIColor *color = [UIColor whiteColor];
    [color set];
    
    CGRect rect = CGRectMake(0, 0, messuredSize.width, messuredSize.height);
    CGContextFillRect(ctr, rect);
    
    color = [UIColor blackColor];
    [color set];
    
    [textToPrint drawInRect:rect withFont:font lineBreakMode:UILineBreakModeWordWrap];
    
    UIImage *imageToPrint = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [PrinterFunctions PrintImageWithPortname:portName portSettings:portSettings imageToPrint:imageToPrint maxWidth:width compressionEnable:YES];
}

/**
 * This function print the Raster Kanji sample receipt (3inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintRasterKanjiSampleReceipt3InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    const char *sjisText = "　　　　　　　　　　スター電機\n"
               "　　　　　　　　修理報告書　兼領収書\n"
               "------------------------------------------------\r\n"
               "発行日時：YYYY年MM月DD日HH時MM分\n"
               "TEL：054-347-XXXX\n\n"
               "　　　　　ｲｹﾆｼ  ｼｽﾞｺ   ｻﾏ\n"
               "　お名前：池西　静子　様\n"
               "　御住所：静岡市清水区七ツ新屋\n"
               "　　　　　５３６番地\n"
               "　伝票番号：No.12345-67890\n\n"
               "　この度は修理をご用命頂き有難うございます。\n"
               " 今後も故障など発生した場合はお気軽にご連絡ください。\n"
               "\n"
               "品名／型名　　　　数量　　　　金額　　　　　備考\n"
               "------------------------------------------------\r\n"
               "制御基板　　　　　　１　１０，０００　　　　配達\n"
               "操作スイッチ　　　　１　　３，８００　　　　配達\n"
               "パネル　　　　　　　１　　２，０００　　　　配達\n"
               "技術料　　　　　　　１　１５，０００\n"
               "出張費用　　　　　　１　　５，０００\n"
               "------------------------------------------------\r\n"
               "\n"
               "　　　　　　　　　　　　　　　小計　３５，８００\n"
               "　　　　　　　　　　　　　　　内税　　１，７９０\n"
               "　　　　　　　　　　　　　　　合計　３７，５９０\n"
               "\n"
               "　お問合わせ番号　　12345-67890\n\n";

    NSString *textToPrint = [NSString stringWithCString:sjisText encoding:NSUTF8StringEncoding];

    int width = 576;
    
    NSString *fontName = @"STHeitiJ-Light";
    
    double fontSize = 12.0;
    
//  fontSize *= multiple;
    fontSize *= 2;
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    
    CGSize size = CGSizeMake(width, 10000);
    CGSize messuredSize = [textToPrint sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
	
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		if ([[UIScreen mainScreen] scale] == 2.0) {
			UIGraphicsBeginImageContextWithOptions(messuredSize, NO, 1.0);
		} else {
			UIGraphicsBeginImageContext(messuredSize);
		}
	} else {
		UIGraphicsBeginImageContext(messuredSize);
	}
    
    CGContextRef ctr = UIGraphicsGetCurrentContext();
    UIColor *color = [UIColor whiteColor];
    [color set];
    
    CGRect rect = CGRectMake(0, 0, messuredSize.width, messuredSize.height);
    CGContextFillRect(ctr, rect);
    
    color = [UIColor blackColor];
    [color set];
    
    [textToPrint drawInRect:rect withFont:font lineBreakMode:UILineBreakModeWordWrap];
    
    UIImage *imageToPrint = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [PrinterFunctions PrintImageWithPortname:portName portSettings:portSettings imageToPrint:imageToPrint maxWidth:width compressionEnable:YES];
}

/**
 * This function print the Raster Kanji sample receipt (4inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
+ (void)PrintRasterKanjiSampleReceipt4InchWithPortname:(NSString *)portName portSettings:(NSString *)portSettings
{
    const char *sjisText = "　　　　　　　　　　　　　　　スター電機\n"
               "　　　　　　　　　　　　　修理報告書　兼領収書\n"
               "--------------------------------------------------------------------\r\n"
               "発行日時：YYYY年MM月DD日HH時MM分\n"
               "TEL：054-347-XXXX\n\n"
               "　　　　　ｲｹﾆｼ  ｼｽﾞｺ   ｻﾏ\n"
               "　お名前：池西　静子　様\n"
               "　御住所：静岡市清水区七ツ新屋\n"
               "　　　　　５３６番地\n"
               "　伝票番号：No.12345-67890\n\n"
               "　この度は修理をご用命頂き有難うございます。\n"
               " 今後も故障など発生した場合はお気軽にご連絡ください。\n"
               "\n"
               "品名／型名　　　　　　　　　数量　　　　　　金額　　　　　　　　備考\n"
               "--------------------------------------------------------------------\r\n"
               "制御基板　　　　　　　　　　　１　　　　１０，０００　　　　　　配達\n"
               "操作スイッチ　　　　　　　　　１　　　　　３，８００　　　　　　配達\n"
               "パネル　　　　　　　　　　　　１　　　　　２，０００　　　　　　配達\n"
               "技術料　　　　　　　　　　　　１　　　　１５，０００\n"
               "出張費用　　　　　　　　　　　１　　　　　５，０００\n"
               "--------------------------------------------------------------------\r\n"
               "\n"
               "　　　　　　　　　　　　　　　　　　　　　　　　　小計　３５，８００\n"
               "　　　　　　　　　　　　　　　　　　　　　　　　　内税　　１，７９０\n"
               "　　　　　　　　　　　　　　　　　　　　　　　　　合計　３７，５９０\n"
               "\n"
               "　お問合わせ番号　　12345-67890\n\n";

    NSString *textToPrint = [NSString stringWithCString:sjisText encoding:NSUTF8StringEncoding];

    int width = 832;
    
    NSString *fontName = @"STHeitiJ-Light";
    
    double fontSize = 12.0;
    
//  fontSize *= multiple;
    fontSize *= 2;
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    
    CGSize size = CGSizeMake(width, 10000);
    CGSize messuredSize = [textToPrint sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
	
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		if ([[UIScreen mainScreen] scale] == 2.0) {
			UIGraphicsBeginImageContextWithOptions(messuredSize, NO, 1.0);
		} else {
			UIGraphicsBeginImageContext(messuredSize);
		}
	} else {
		UIGraphicsBeginImageContext(messuredSize);
	}
    
    CGContextRef ctr = UIGraphicsGetCurrentContext();
    UIColor *color = [UIColor whiteColor];
    [color set];
    
    CGRect rect = CGRectMake(0, 0, messuredSize.width, messuredSize.height);
    CGContextFillRect(ctr, rect);
    
    color = [UIColor blackColor];
    [color set];
    
    [textToPrint drawInRect:rect withFont:font lineBreakMode:UILineBreakModeWordWrap];
    
    UIImage *imageToPrint = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [PrinterFunctions PrintImageWithPortname:portName portSettings:portSettings imageToPrint:imageToPrint maxWidth:width compressionEnable:YES];
}




@end