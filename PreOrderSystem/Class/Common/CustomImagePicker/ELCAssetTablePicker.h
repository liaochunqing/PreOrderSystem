//
//  AssetTablePicker.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ELCAssetTablePicker : UITableViewController
{
	ALAssetsGroup *__weak assetGroup;
	NSMutableArray *elcAssets;
	int selectedAssets;
	
	id __weak parent;
	
	NSOperationQueue *queue;
    __weak UILabel *selectedAssetsLabel;
}

@property (nonatomic, weak) id parent;
@property (nonatomic, weak) ALAssetsGroup *assetGroup;
@property (nonatomic, strong) NSMutableArray *elcAssets;
@property (nonatomic, weak) IBOutlet UILabel *selectedAssetsLabel;

-(int)totalSelectedAssets;
-(void)preparePhotos;

-(void)doneAction:(id)sender;

@end