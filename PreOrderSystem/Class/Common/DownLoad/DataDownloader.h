//
//  PhotoDownloader.h
//  Ordering
//
//  Created by USER on 11-6-14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*
 数据下载器：每次只能单独下载一个文件
 */

#import <Foundation/Foundation.h>
#import "Reachability.h"

typedef enum{
	DataDownloaderTypePic = 0,
	DataDownloaderTypeAudio,
    DataDownloaderTypeZipFile,
} DataDownloaderType;


@class DataDownloader;
@protocol DataDownloaderDelegate<NSObject>

@optional

-(void)DataDownloader:(DataDownloader *)loader didLoadPhoto:(UIImage *)image;
/*加载失败，返回默认图像*/
-(void)DataDownloader:(DataDownloader *)loader didFailedLoadPhoto:(UIImage *)image;

-(void)DataDownloader:(DataDownloader *)loader didLoadSound:(NSData *)audio;
/*加载失败，返回默认图像*/
-(void)DataDownloader:(DataDownloader *)loader didFailedLoadSound:(UIImage *)image;

//下载zip文件
-(void)DataDownloader:(DataDownloader *)loader didLoadZipFile:(NSData *)file;
/*加载失败*/
-(void)DataDownloader:(DataDownloader *)loader didFailedLoadZipFile:(NSData *)file;

// 网络连接失败时返回（无网络的情况）
-(void)DataDownloader:(DataDownloader *)loader didFailWithNetwork:(NSError *)error;

@end


@interface DataDownloader : NSObject
{
    __weak id <DataDownloaderDelegate> delegate;
	NSMutableData *receivedData;
	
	NSInteger tag;
    NSURLConnection *con;
    
    //0 图片; 1 音频 ; 2 zip文件
    int dataType;
    NSString *fileName;
}
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLConnection *con;
@property (nonatomic, assign, readwrite) NSInteger tag;

-(void)parseWithURL:(NSString *)url type:(int)type;
-(void)cancelParse;
-(NSString*)url;

@end
