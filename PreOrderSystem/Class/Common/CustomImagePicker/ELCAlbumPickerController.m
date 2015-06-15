//
//  AlbumPickerController.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import "ELCAssetTablePicker.h"
#import "Constants.h"

@implementation ELCAlbumPickerController

@synthesize parent, assetGroups;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addButtonAndTitleToNavigationBar];
    [self getAllPhotoFromAlbums];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationMaskLandscape;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",[self class]);
#endif
}

- (void)addButtonAndTitleToNavigationBar
{
    [self.navigationItem setTitle:kLoc(@"select_a_photo_album")];
    //取消
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.parent action:@selector(cancelImagePicker)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
}

//获取图片
-(void)getAllPhotoFromAlbums
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.assetGroups = tempArray;
    
    library = [[ALAssetsLibrary alloc] init];
    
    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       @autoreleasepool
                       {
                           // Group enumerator Block
                           void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
                           {
                               if (group == nil)
                               {
                                   return;
                               }
                               
                               [self.assetGroups addObject:group];
                               
                               // Reload albums
                               [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
                           };
                           
                           // Group Enumerator Failure Block
                           void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error)
                           {
                               UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:kLoc(@"etable_dont_have_permission_to_read_your_photos") delegate:nil cancelButtonTitle:kLoc(@"i_know") otherButtonTitles:nil];
                               [alert show];
                               
                           };	
                           // Enumerate Albums
                           [library enumerateGroupsWithTypes:ALAssetsGroupAll
                                                  usingBlock:assetGroupEnumerator 
                                                failureBlock:assetGroupEnumberatorFailure];
                           
                       }
                   });
}

-(void)reloadTableView
{
	[self.tableView reloadData];
}

-(void)selectedAssets:(NSArray*)_assets
{
	[(ELCImagePickerController*)parent selectedAssets:_assets];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [assetGroups count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get count
    ALAssetsGroup *g = (ALAssetsGroup*)[assetGroups objectAtIndex:indexPath.row];
    [g setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSInteger gCount = [g numberOfAssets];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)",[g valueForProperty:ALAssetsGroupPropertyName], gCount];
    [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup*)[assetGroups objectAtIndex:indexPath.row] posterImage]]];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ELCAssetTablePicker *picker = [[ELCAssetTablePicker alloc] initWithNibName:@"ELCAssetTablePicker" bundle:[NSBundle mainBundle]];
	picker.parent = self;
    
    [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:kTakeOutSelectedPicNum];

    // Move me    
    picker.assetGroup = [assetGroups objectAtIndex:indexPath.row];
    [picker.assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    
	[self.navigationController pushViewController:picker animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 57;
}

@end

