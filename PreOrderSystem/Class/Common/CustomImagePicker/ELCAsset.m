//
//  Asset.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAsset.h"
#import "ELCAssetTablePicker.h"
#import "Constants.h"
#import "UIImage+imageWithContentsOfFile.h"

@implementation ELCAsset

@synthesize asset;
@synthesize parent;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

-(id)initWithAsset:(ALAsset*)_asset {
	
	if (self = [super initWithFrame:CGRectMake(0, 0, 0, 0)]) {
		
		self.asset = _asset;
		
		CGRect viewFrames = CGRectMake(0, 0, 75, 75);
		
		UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:viewFrames];
		[assetImageView setContentMode:UIViewContentModeScaleToFill];
		[assetImageView setImage:[UIImage imageWithCGImage:[self.asset thumbnail]]];
		[self addSubview:assetImageView];
		
		overlayView = [[UIImageView alloc] initWithFrame:viewFrames];
		[overlayView setImage:[UIImage imageFromMainBundleFile:@"Overlay.png"]];
		[overlayView setHidden:YES];
		[self addSubview:overlayView];
    }
    
	return self;	
}
         
-(void)toggleSelection
{
    int numberOfSelectedGridItems =  [[[NSUserDefaults standardUserDefaults]objectForKey:kTakeOutSelectedPicNum]integerValue];
    
    if (overlayView.hidden == YES)
    {
        numberOfSelectedGridItems++;
    }
    else
    {
        if (numberOfSelectedGridItems > 0)
            numberOfSelectedGridItems--;
    }
    
    int num =  [[[NSUserDefaults standardUserDefaults]objectForKey:kTakeOutPicNum]integerValue]; 
    
    if(/*[(ELCAssetTablePicker*)self.parent totalSelectedAssets]*/numberOfSelectedGridItems > num)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLoc(@"sorry_the_picture_has_reached_the_limit") message:@"" delegate:nil cancelButtonTitle:kLoc(@"confirm") otherButtonTitles:nil, nil];
        
		[alert show];
        
        overlayView.hidden = YES;
        if (numberOfSelectedGridItems > 0)
        {
            numberOfSelectedGridItems--;
        }
    }
    else
    {
        overlayView.hidden = !overlayView.hidden;
    }
    [[NSUserDefaults standardUserDefaults]setInteger:numberOfSelectedGridItems forKey:kTakeOutSelectedPicNum];
}

-(BOOL)selected {
	
	return !overlayView.hidden;
}

-(void)setSelected:(BOOL)_selected {
    
	[overlayView setHidden:!_selected];
}

@end

