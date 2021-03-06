//
//  PrinterFunctions.h
//  IOS_SDK
//
//  Created by Tzvi on 8/2/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StarIO/SMPort.h"

typedef enum {
    USE_LIMITS = 0,
    USE_FIXED = 1
} Limit;

typedef enum {
    NarrowWide_2_6 = 0,
    NarrowWide_3_9 = 1,
    NarrowWide_4_12 = 2,
    NarrowWide_2_5 = 3,
    NarrowWide_3_8 = 4,
    NarrowWide_4_10 = 5,
    NarrowWide_2_4 = 6,
    NarrowWide_3_6 = 7,
    NarrowWide_4_8 = 8
} NarrowWide;

typedef enum 
{
    NarrowWideV2_2_5 = 0,
    NarrowWideV2_4_10 = 1,
    NarrowWideV2_6_15 = 2,
    NarrowWideV2_2_4 = 3,
    NarrowWideV2_4_8 = 4,
    NarrowWideV2_6_12 = 5,
    NarrowWideV2_2_6 = 6,
    NarrowWideV2_3_9 = 7,
    NarrowWideV2_4_12 = 8
} NarrowWideV2;

typedef enum{
    No_Added_Characters_With_Line_Feed = 0,
    Adds_Characters_With_Line_Feed = 1,
    No_Added_Characters_Without_Line_Feed = 2,
    Adds_Characters_Without_Line_Feed = 3
} BarCodeOptions;

typedef enum
{
    _2_dots = 0,
    _3_dots = 1,
    _4_dots = 2
} Min_Mod_Size;

typedef enum 
{
    Low = 0,
    Middle = 1,
    Q = 2,
    High = 3
} CorrectionLevelOption;

typedef enum
{
    Model1 = 0,
    Model2 = 1
} Model;

typedef enum
{
    FULL_CUT = 0,
    PARCIAL_CUT = 1,
    FULL_CUT_FEED = 2,
    PARTIAL_CUT_FEED = 3
} CutType;

typedef enum
{
    Left = 0,
    Center = 1,
    Right = 2
} Alignment;

@interface PrinterFunctions : NSObject
{
    
}

+ (void)OpenCashDrawerWithPortname:(NSString *)portName
                      portSettings:(NSString *)portSettings;

//0表示无法打开端口
//1表示成功打开端口（在线）
//2表示无法打开端口（不在线或盖子打开了）
//3表示无法打开端口（不在线或没纸了）
+ (SMPort*)CheckStatusWithPortname:(NSString *)portName
                   portSettings:(NSString *)portSettings;

+ (void)PrintPDF417CodeWithPortname:(NSString *)portName
                       portSettings:(NSString *)portSettings
                              limit:(Limit)limit
                                 p1:(unsigned char)p1
                                 p2:(unsigned char)p2
                      securityLevel:(unsigned char)securityLevel
                         xDirection:(unsigned char)xDirection
                        aspectRatio:(unsigned char)aspectRatio
                        barcodeData:(unsigned char[])barcodeDat
                    barcodeDataSize:(unsigned int)barcodeDataSize;
+ (void)PrintCode39WithPortname:(NSString *)portName
                   portSettings:(NSString *)portSettings
                    barcodeData:(unsigned char*)barcodeData
                barcodeDataSize:(unsigned int)barcodeDataSize
                 barcodeOptions:(BarCodeOptions)option
                         height:(unsigned char)height
                     narrowWide:(NarrowWide)width;
+ (void)PrintCode93WithPortname:(NSString *)portName
                   portSettings:(NSString *)portSettings
                    barcodeData:(unsigned char*)barcodeData
                barcodeDataSize:(unsigned int)barcodeDataSize
                 barcodeOptions:(BarCodeOptions)option
                         height:(unsigned char)height
                min_module_dots:(Min_Mod_Size) width;
+ (void)PrintCodeITFWithPortname:(NSString*)portName
                    portSettings:(NSString*)portSettings
                     barcodeData:(unsigned char*)barcodeData
                 barcodeDataSize:(unsigned int)barcodeDataSize
                  barcodeOptions:(BarCodeOptions)option
                          height:(unsigned char)height
                      narrowWide:(NarrowWideV2) width;
+ (void)PrintCode128WithPortname:(NSString*)portName
                    portSettings:(NSString*)portSettings
                     barcodeData:(unsigned char*)barcodeData
                 barcodeDataSize:(unsigned int)barcodeDataSize
                  barcodeOptions:(BarCodeOptions)option
                          height:(unsigned char)height
                 min_module_dots:(Min_Mod_Size)width;
+ (void)PrintQrcodeWithPortname:(NSString*)portName
                   portSettings:(NSString*)portSettings
                correctionLevel:(CorrectionLevelOption) correctionLevel
                          model:(Model)model
                       cellSize:(unsigned char)cellSize
                    barcodeData:(unsigned char*)barCodeData
                barcodeDataSize:(unsigned int)barCodeDataSize;

+ (void)PreformCutWithPortname:(NSString *)portName
                  portSettings:(NSString*)portSettings
                       cutType:(CutType)cuttype;

+ (void)PrintTextWithPortname:(NSString *)portName
                 portSettings:(NSString*)portSettings
                  slashedZero:(bool)slashedZero
                    underline:(bool)underline
                  invertColor:(bool)invertColor
                   emphasized:(bool)emphasized
                    upperline:(bool)upperline
                   upsideDown:(bool)upsideDown
              heightExpansion:(int)heightExpansion
               widthExpansion:(int)widthExpansion
                   leftMargin:(unsigned char)leftMargin
                    alignment:(Alignment) alignment
                     textData:(unsigned char *)textData
                 textDataSize:(unsigned int)textDataSize;
+ (void)PrintKanjiTextWithPortname:(NSString *)portName
                      portSettings:(NSString*)portSettings
                         kanjiMode:(int)kanjiMode
                         underline:(bool)underline
                       invertColor:(bool)invertColor
                        emphasized:(bool)emphasized
                         upperline:(bool)upperline
                        upsideDown:(bool)upsideDown
                   heightExpansion:(int)heightExpansion
                    widthExpansion:(int)widthExpansion
                        leftMargin:(unsigned char)leftMargin
                         alignment:(Alignment) alignment
                          textData:(unsigned char *)textData
                      textDataSize:(unsigned int)textDataSize;
+ (void)PrintImageWithPortname:(NSString *)portName
                  portSettings:(NSString *)portSettings
                  imageToPrint:(UIImage *)imageToPrint
                      maxWidth:(int)maxWidth
             compressionEnable:(BOOL)compressionEnable;
/*
+ (void)Print3mImageWithPortname:(NSString *)portName
                    portSettings:(NSString *)portSettings;
 */
+ (void)PrintSampleReceipt3InchWithPortname:(NSString *)portName
                               portSettings:(NSString *)portSettings;
+ (void)PrintSampleReceipt4InchWithPortname:(NSString *)portName
                               portSettings:(NSString *)portSettings;
+ (void)PrintKanjiSampleReceipt3InchWithPortname:(NSString *)portName
                                    portSettings:(NSString *)portSettings;
+ (void)PrintKanjiSampleReceipt4InchWithPortname:(NSString *)portName
                                    portSettings:(NSString *)portSettings;
+ (void)PrintRasterSampleReceipt3InchWithPortname:(NSString *)portName
                                     portSettings:(NSString *)portSettings;
+ (void)PrintRasterSampleReceipt4InchWithPortname:(NSString *)portName
                                     portSettings:(NSString *)portSettings;
+ (void)PrintRasterKanjiSampleReceipt3InchWithPortname:(NSString *)portName
                                          portSettings:(NSString *)portSettings;
+ (void)PrintRasterKanjiSampleReceipt4InchWithPortname:(NSString *)portName
                                          portSettings:(NSString *)portSettings;

//餐厅接口
//portSettings默认为10000
//r_Name：餐厅名
//qType：排队类别
//cRow：当前的排队号数
//rRow：还需排队的号数
//rid：餐厅ID
+ (void)PrintMyRecieptWithPortname:(NSString *)portName portSettings:(NSString *)portSettings restaurantName:(NSString*)r_Name queueType:(NSString*)qType currentRow:(int)cRow remaingRow:(int)rRow;
//打印测试
+ (void)PrintTestWithPortname:(NSString *)portName portSettings:(NSString *)portSettings;
//菜单订单打印
+ (void)PrintMyRecieptWithPortname:(NSString *)portName portSettings:(NSString *)portSettings withDishData:(NSDictionary *)dishDetailDict;


@end
