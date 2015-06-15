//
//  NsstringAddOn.h
//  Ordering
//
//  Created by USER on 11-6-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kOneDecimal 10.0   //一位小数
#define kTwoDecimal 100.0  //二位小数

@interface NSString (NsstringAdditional)

/*字符串转换为format格式的时间*/
-(NSDate *)stringToNSDateWithFormat:(NSString*)format;

+(NSString *)dateToNSString:(NSDate*)date withFormat:(NSString*)format;
//转换date为某个时区
+(NSString *)dateToNSString:(NSDate*)date withFormat:(NSString*)format andTimezone:(NSTimeZone*)tz;
//返回电话号码
-(NSString*)stringToPhoneNumber;
//去掉价格.00,.50中的0
+ (NSString *)trimmingZeroInPrice:(NSString *)tempString;
//截取字符串
+ (NSString *)cutString:(NSString *)originStr withMaxLengthOfStr:(int)maxLength;
//利用正则表达式验证格式是否是数字
+ (BOOL)isValidateNumber:(NSString *)numString;
+ (BOOL)isValidateIPAddress:(NSString *)IPStr;
+ (NSString*)firstNameWithTitle:(NSString*)firstName withSex:(int)sex;
//字符串是否为空
+ (BOOL)strIsEmpty:(NSString *)str;
+ (BOOL)strIsOverMaxLen:(NSString *)str withMaxLen:(NSInteger)maxLen;
+ (NSString *)getStrWithoutWhitespace:(NSString *)originStr;
+ (float)getStrHeight:(NSString *)str withMaxWidth:(CGFloat)maxWidth withFont:(UIFont *)textFont withLineBreakMode:(NSLineBreakMode)lineBreakMode;
+ (float)getStrWidth:(NSString *)str withMaxHeight:(CGFloat)maxHeight withFont:(UIFont *)textFont withLineBreakMode:(NSLineBreakMode)lineBreakMode;
//是否是闰年
+ (BOOL)isLeapYear;
//获取一个月份的天数
+ (NSInteger)getMonthDay:(NSInteger)month;
//四舍五入
+ (NSString *)notRounding:(float)price afterPoint:(int)position;
//保留一位小数
+ (NSString *)oneDecimalOfPrice:(float)totalPrice;

@end
