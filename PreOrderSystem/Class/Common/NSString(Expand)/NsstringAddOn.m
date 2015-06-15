//
//  NsstringAddOn.m
//  Ordering
//
//  Created by USER on 11-6-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NsstringAddOn.h"
#import "Constants.h"

@implementation NSString (NsstringAdditional)

-(NSDate *)stringToNSDateWithFormat:(NSString*)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
    //#define kDEFAULT_DATE_TIME_FORMAT (@"yyyy-MM-dd'T'HH:mm:ss'Z'")
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:self];
    return date;
}

+(NSString *)dateToNSString:(NSDate*)date withFormat:(NSString*)format
{
    NSString *currentLanguage = kChineseFamiliarStyle;
    //繁体
    //程序的当前语言
    NSString *savedLangType = [[NSUserDefaults standardUserDefaults] objectForKey:kApplicationLanguageKey];
//    if (![kCurrentLanguageOfDevice isEqualToString:kChineseFamiliarStyle])
    if ([savedLangType isEqualToString:@"ENG"])
    {
        currentLanguage = @"en";
    }
    else if ([savedLangType isEqualToString:@"CHS"])
    {
        currentLanguage = @"zh-Hans";
    }
    else if ([savedLangType isEqualToString:@"CHT"])
    {
        currentLanguage = @"zh-Hant";
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:format];
    [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:currentLanguage]];
    NSString *string = [dateFormatter stringFromDate:date];
    
    return string;
}

+(NSString *)dateToNSString:(NSDate*)date withFormat:(NSString*)format andTimezone:(NSTimeZone*)tz{
    
    
    NSDate* sourceDate = date;
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = tz;
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *string = [dateFormatter stringFromDate:destinationDate];
    
    return string;
}


-(NSString*)stringToPhoneNumber{
    NSMutableString *phone = [[NSMutableString alloc] init];
    //删除电话号码中多余的字符，如－（ ）
    for (int i=0; i<[self length]; i++) {
        NSString *subStr = [self substringWithRange:NSMakeRange(i, 1)];
        if ([subStr isEqualToString:@"0"] || [subStr isEqualToString:@"1"] || [subStr isEqualToString:@"2"] ||
            [subStr isEqualToString:@"3"] || [subStr isEqualToString:@"4"] || [subStr isEqualToString:@"5"] ||
            [subStr isEqualToString:@"6"] || [subStr isEqualToString:@"7"] || [subStr isEqualToString:@"8"] ||
            [subStr isEqualToString:@"9"]) {
            [phone appendString:subStr];
        }
    }
    return phone;
}

//去掉.0,.00,.50中的0
+ (NSString *)trimmingZeroInPrice:(NSString *)tempString
{
    NSRange zeroRange = [tempString rangeOfString:@"."];
    if (zeroRange.location == NSNotFound)
    {
        return tempString;
    }
    NSString *resultString = @"";
    if ([[tempString substringFromIndex:([tempString length] - 1)] isEqualToString:@"0"])
    {
        //有两位小数
        if ([[tempString substringWithRange:NSMakeRange([tempString length] - 2, 1)] isEqualToString:@"0"])
        {
            resultString = [tempString substringToIndex:([tempString length] - 3)];
        }
        else
        {
            //一位小数
            if ([[tempString substringWithRange:NSMakeRange([tempString length] - 2, 1)] isEqualToString:@"."])
            {
                resultString = [tempString substringToIndex:([tempString length] - 2)];
            }
            else
            {
                resultString = [tempString substringToIndex:([tempString length] - 1)];
            }
        }
    }
    else
    {
        resultString = tempString;
    }
    return resultString;
}

//截取字符串
+ (NSString *)cutString:(NSString *)originStr withMaxLengthOfStr:(int)maxLength
{
    NSString *cutStr = nil;
    if (maxLength < [originStr length])
    {
        cutStr = [originStr substringToIndex:maxLength];
    }
    else
    {
        cutStr = originStr;
    }
    return cutStr;
}

//字符串是否为空
+ (BOOL)strIsEmpty:(NSString *)str
{
    return ([str length] > 0) ? NO : YES;
}

+ (NSString *)getStrWithoutWhitespace:(NSString *)originStr
{
    NSString *tempStr = [originStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([NSString strIsEmpty:tempStr])
    {
        tempStr = @"";
    }
    return tempStr;
}

//字符串是否超过长度
+ (BOOL)strIsOverMaxLen:(NSString *)str withMaxLen:(NSInteger)maxLen
{
    NSInteger textLen = [str length];
    if (textLen > maxLen)
    {
        return YES;
    }
    return NO;
}

//利用正则表达式验证格式是否是数字
+ (BOOL)isValidateNumber:(NSString *)numString
{
    NSString *emailRegex = @"[0-9]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:numString];
}

+ (BOOL)isValidateIPAddress:(NSString *)IPStr
{
    NSString * regex        = @"\\b(?:\\d{1,3}\\.){3}\\d{1,3}\\b";
    NSPredicate * pred      = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:IPStr];
}

+ (NSString*)firstNameWithTitle:(NSString*)firstName withSex:(int)sex
{
    NSString *text = nil;
    NSString *manStr = kLoc(@"mister");
    NSString *womanStr = kLoc(@"lady");
    switch (sex)
    {
        case 1:
            text = [NSString stringWithFormat:@"%@%@", firstName,manStr];
            break;
        case 2:
            text = [NSString stringWithFormat:@"%@%@", firstName,womanStr];
            break;
        default:
            text = [NSString stringWithFormat:@"%@", firstName];
            break;
    }
    return text;
}

+ (float)getStrHeight:(NSString *)str withMaxWidth:(CGFloat)maxWidth withFont:(UIFont *)textFont withLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize maxSize = CGSizeMake(maxWidth, 999999);
    CGSize expectedSize = [str sizeWithFont:textFont
                          constrainedToSize:maxSize
                              lineBreakMode:lineBreakMode];
    return expectedSize.height;
}

+ (float)getStrWidth:(NSString *)str withMaxHeight:(CGFloat)maxHeight withFont:(UIFont *)textFont withLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize maxSize = CGSizeMake(999999, maxHeight);
    CGSize expectedSize = [str sizeWithFont:textFont
                          constrainedToSize:maxSize
                              lineBreakMode:lineBreakMode];
    return expectedSize.width;
}

//是否是闰年
+ (BOOL)isLeapYear
{
    NSString *nowTimeStr = [NSString dateToNSString:[NSDate date] withFormat:@"yyyy/MM/dd"];
    NSArray *timeComponent = [nowTimeStr componentsSeparatedByString:@"/"];
    NSInteger currentYear = [[timeComponent objectAtIndex:0]integerValue];
    BOOL isLeapYear = NO;//用来判断是否是润年
    if((currentYear % 400 == 0)||((currentYear % 4 == 0)&&(currentYear % 100 != 0)))
    {
        isLeapYear = YES;
    }
    return isLeapYear;
}

//获取一个月份的天数
+ (NSInteger)getMonthDay:(NSInteger)month
{
    NSInteger number = 0;
    if ((1 == month) || (3 == month) ||(5 == month) || (7 == month) ||(8 == month) || (10 == month) || (12 == month))
    {
        number = 31;
    }
    else if((4 == month) ||(6 == month) || (9 == month) ||(11 == month))
    {
        number = 30;
    }
    else
    {
        if ([NSString isLeapYear] == YES)
        {
            number = 29;
        }
        else
        {
            number = 28;
        }
    }
    return number;
}

+ (NSString *)notRounding:(float)price afterPoint:(int)position
{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [NSString stringWithFormat:@"%@",roundedOunces];
}

//保留一位小数
+ (NSString *)oneDecimalOfPrice:(float)totalPrice
{
    NSString *totalPriceStr = nil;
    float totalSumPrice = roundf(totalPrice*10)/10;
    
    NSString *summaryPriceStr = [NSString stringWithFormat:@"%.1lf",totalSumPrice];
    if ([summaryPriceStr hasSuffix:@".0"]) {
        int totalInt = totalSumPrice;
        totalPriceStr = [NSString stringWithFormat:@"%i",totalInt];
    }
    else{
        totalPriceStr = [NSString stringWithFormat:@"%@",summaryPriceStr];
    }
    return totalPriceStr;
}

@end
