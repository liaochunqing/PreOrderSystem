//
//  ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by Collin Ruffenach on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerController.h"
#import "ELCAsset.h"
#import "ELCAssetCell.h"
#import "ELCAssetTablePicker.h"
#import "ELCAlbumPickerController.h"
#import "Constants.h"

@implementation ELCImagePickerController

@synthesize delegate;

-(void)cancelImagePicker {
	if([delegate respondsToSelector:@selector(elcImagePickerControllerDidCancel:)]) {
		[delegate performSelector:@selector(elcImagePickerControllerDidCancel:) withObject:self];
	}
}

-(void)selectedAssets:(NSArray*)_assets {

	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	
	for(ALAsset *asset in _assets) {

		NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
		[workingDictionary setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
        [workingDictionary setObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forKey:@"UIImagePickerControllerOriginalImage"];
		[workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
		
		[returnArray addObject:workingDictionary];
	}
    [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:kTakeOutSelectedPicNum];
	
    /* 避免视图切换时相冲突 Unbalanced calls to begin/end appearance transitions for <ELCAssetTablePicker: 0x1dc768e0> */
    [self performSelector:@selector(dismissImagePickerWithData:) withObject:returnArray afterDelay:0.5];
}

- (void)dismissImagePickerWithData:(NSMutableArray *)imageArray
{
    if([delegate respondsToSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:)])
    {
        [delegate performSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:) withObject:self withObject:[NSArray arrayWithArray:imageArray]];
    }
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationMaskLandscape;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",[self class]);
#endif
}

@end
