//
//  AssetTablePicker.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetTablePicker.h"
#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "ELCAlbumPickerController.h"


@implementation ELCAssetTablePicker

@synthesize parent;
@synthesize selectedAssetsLabel;
@synthesize assetGroup, elcAssets;

-(void)viewDidLoad {
        
	[self.tableView setSeparatorColor:[UIColor clearColor]];
	[self.tableView setAllowsSelection:NO];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;
	
	UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
	[self.navigationItem setRightBarButtonItem:doneButtonItem];
	[self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",[self class]);
#endif
}

-(void)preparePhotos {
    
    @autoreleasepool {

        [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) 
         {         
             if(result == nil) 
             {
                 return;
             }
             
             ELCAsset *elcAsset = [[ELCAsset alloc] initWithAsset:result];
             [elcAsset setParent:self];
             [self.elcAssets addObject:elcAsset];
         }];    
	
	[self.tableView reloadData];
    [self.navigationItem setTitle:kLoc(@"select_picture")];
    
    }

}

- (void) doneAction:(id)sender {
	
	NSMutableArray *selectedAssetsImages = [[NSMutableArray alloc] init];
	    
	for(ELCAsset *elcAsset in self.elcAssets) 
    {		
		if([elcAsset selected]) {
			
			[selectedAssetsImages addObject:[elcAsset asset]];
		}
	}
        
    [(ELCAlbumPickerController*)self.parent selectedAssets:selectedAssetsImages];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ceil([self.assetGroup numberOfAssets] / 6.0);
}

- (NSArray*)assetsForIndexPath:(NSIndexPath*)_indexPath {
    
	int index = (_indexPath.row*6);
	int maxIndex = (_indexPath.row*6+5);
    
	if(maxIndex < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				[self.elcAssets objectAtIndex:index+2],
				[self.elcAssets objectAtIndex:index+3],
                [self.elcAssets objectAtIndex:index+4],
				[self.elcAssets objectAtIndex:index+5],
				nil];
	}
    
	else if(maxIndex-1 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				[self.elcAssets objectAtIndex:index+2],
                [self.elcAssets objectAtIndex:index+3],
                [self.elcAssets objectAtIndex:index+4],
				nil];
	}
    
	else if(maxIndex-2 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
                [self.elcAssets objectAtIndex:index+2],
                [self.elcAssets objectAtIndex:index+3],
				nil];
	}
    
	else if(maxIndex-3 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
                [self.elcAssets objectAtIndex:index+2],
				nil];
	}
    else if(maxIndex-4 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				nil];
	}
    else if(maxIndex-5 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],nil];
	}
    
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
        
    ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) 
    {		        
        cell = [[ELCAssetCell alloc] initWithAssets:[self assetsForIndexPath:indexPath] reuseIdentifier:CellIdentifier];
    }	
	else 
    {		
		[cell setAssets:[self assetsForIndexPath:indexPath]];
	}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	return 79;
}

- (int)totalSelectedAssets {
    
    int count = 0;
    
    for(ELCAsset *asset in self.elcAssets) 
    {
		if([asset selected])
        {            
            count++;
		}
	}
    
    return count;
}


@end
