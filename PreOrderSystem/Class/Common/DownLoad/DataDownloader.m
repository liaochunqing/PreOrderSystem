//
//  PhotoDownloader.m
//  Ordering
//
//  Created by USER on 11-6-14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
/*
 图片下载器
 */

#import "DataDownloader.h"

@implementation DataDownloader
@synthesize delegate;
@synthesize receivedData;
@synthesize tag;
@synthesize con;

-(void)dealloc
{
    delegate = nil;
    fileName = nil;
#ifdef DEBUG
    NSLog(@"===DataDownloader,dealloc===");
#endif
}

-(void)parseWithURL:(NSString *)url type:(int)type
{
    dataType = type;
    fileName = [[NSString alloc] initWithString:[url lastPathComponent]];
    
	if ([[Reachability shareReachability] checkNetworking])
    {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		
        NSURL *fileURL = [[NSURL alloc] initWithString:url];
		NSURLRequest *req = [[NSURLRequest alloc] initWithURL:fileURL];
		self.con =[[NSURLConnection alloc] initWithRequest:req delegate:self];
		if (con)
        {
			self.receivedData = [[NSMutableData alloc] init];
		}
	}
	else
    {
        if ([delegate respondsToSelector:@selector(DataDownloader:didFailWithNetwork:)])
        {
            [delegate DataDownloader:self didFailWithNetwork:nil];
        }
	}
}

-(void)cancelParse
{
    [self.con cancel];
}

-(NSString*)url
{
    return fileName;
}

#pragma mark NSURLConnection Callbacks
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Can check response code here
    [receivedData setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //NSLog(@"Connection didFailWithError");
    self.receivedData = nil;
	switch (dataType) {
        case 0:{
            //网络连接失败，返回默认图片
            if ([delegate respondsToSelector:@selector(DataDownloader:didFailedLoadPhoto:)]) {
                [delegate DataDownloader:self didFailedLoadPhoto:nil];
            }
            break;
        }
        case 1:{
            //网络连接失败
            if ([delegate respondsToSelector:@selector(DataDownloader:didFailedLoadSound:)]) {
                [delegate DataDownloader:self didFailedLoadSound:nil];
            }
            break;
        }
        case 2:{
            //网络连接失败
            if ([delegate respondsToSelector:@selector(DataDownloader:didFailedLoadZipFile:)]) {
                [delegate DataDownloader:self didFailedLoadZipFile:nil];
            }
            break;
        }
    }
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (receivedData) {
        //NSLog(@"receivedData:  %i  %@", [receivedData length], [receivedData description]);
        switch (dataType) {
            case 0:{
                if ([receivedData length]>240) {
                    if ([delegate respondsToSelector:@selector(DataDownloader:didLoadPhoto:)]) {
                        UIImage *image = [UIImage imageWithData:receivedData];
                        [delegate DataDownloader:self didLoadPhoto:image];
                    }
                }
                else {
                    if ([delegate respondsToSelector:@selector(DataDownloader:didFailedLoadPhoto:)]) {
                        [delegate DataDownloader:self didFailedLoadPhoto:nil];
                    }
                }
                break;
            }
            case 1:{
                if ([delegate respondsToSelector:@selector(DataDownloader:didLoadSound:)]) {
                    [delegate DataDownloader:self didLoadSound:receivedData];
                }
                break;
            }
            case 2:{
                if ([delegate respondsToSelector:@selector(DataDownloader:didLoadZipFile:)]) {
                    [delegate DataDownloader:self didLoadZipFile:self.receivedData];
                }
                break;
            }
        }
    }
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
