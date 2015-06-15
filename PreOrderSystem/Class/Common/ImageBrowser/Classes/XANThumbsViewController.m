//
//  XANThumbsViewController.m
//  XANPhotoBrowser
//
//  Created by Chen Xian'an on 12/17/10.
//  Copyright 2010 lazyapps.com. All rights reserved.
//

#import "XANThumbsViewController.h"
#import "XANImageViewController.h"
#import "config.h"

#define ROW_HEIGHT (kThumbSize.height + kSpacing)
#define kStatusBarHeight 20

@interface XANThumbsViewController()
- (void)updateTableLayout;
- (NSUInteger)numberOfThumbsForRow:(NSUInteger)row;
@end

@implementation XANThumbsViewController
@synthesize showsDoneButton;
@synthesize dataSource, delegate;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithDataSource:(id <XANThumbsViewControllerDataSource>)theDataSource
                delegate:(id <XANThumbsViewControllerDelegate>)theDelegate;
{
  if (self = [super initWithStyle:UITableViewStylePlain]){
    self.dataSource = theDataSource;
    self.delegate = theDelegate;
    self.wantsFullScreenLayout = YES;
    
    fromStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
  }
  
  return self;
}


- (void)reloadData
{
  numberOfThumbs = [dataSource numberOfThumbs];
  numberOfColumns = [dataSource numberOfColumnsForPortrait];
  
  if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) &&
      [dataSource respondsToSelector:@selector(numberOfColumnsForLandscape)])
     numberOfColumns = [dataSource numberOfColumnsForLandscape];                
  
  numberOfRows = numberOfThumbs / numberOfColumns;
 
 if (numberOfThumbs % numberOfColumns)
   numberOfRows += 1;
 
 [self.tableView reloadData];
}

- (NSUInteger)thumbIndexForColumn:(NSUInteger)column
                            inRow:(NSUInteger)row
{
  return numberOfColumns*row + column;
}

- (void)loadView
{
  [super loadView];

  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.tableView.rowHeight = ROW_HEIGHT;

  if (self.title) self.navigationItem.title = self.title;
  self.navigationController.navigationBar.barStyle
    = self.navigationController.toolbar.barStyle
    = UIBarStyleBlack;
  self.navigationController.navigationBar.translucent
    = self.navigationController.toolbar.translucent
    = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:YES];
  self.navigationController.toolbarHidden = YES;
  if (showsDoneButton){
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    [leftBarButtonItem release];
  }
  
  if (!ISPAD)
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
  
  [self updateTableLayout];
  [self reloadData];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
  if (ISPAD) return YES;
  
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
 */

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                         duration:(NSTimeInterval)duration
{
  [self updateTableLayout];
  [self reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  return numberOfRows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  
  XANThumbsCell *cell = (XANThumbsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[XANThumbsCell alloc] initWithReuseIdentifier:CellIdentifier thumbDelegate:self] autorelease];
  }
  
  cell.capacityOfThumbs = numberOfColumns;
  cell.numberOfThumbs = [self numberOfThumbsForRow:indexPath.row];
  cell.rowIndex = indexPath.row;

  for (int i=0; i<cell.numberOfThumbs; i++){
    NSUInteger realIndex = [self thumbIndexForColumn:i inRow:cell.rowIndex];
    [cell updateImage:[dataSource thumbImageForIndex:realIndex] forColumn:i];
  }
  
  return cell;
}

#pragma mark Table view delegate

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
  // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
  // For example: self.myOutlet = nil;
}


- (void)dealloc 
{
  self.dataSource = nil;
  self.delegate = nil;
  
  [super dealloc];
}

#pragma mark privates

- (void)updateTableLayout
{
  CGFloat barsHeight = 0;
  if (self.wantsFullScreenLayout && self.navigationController.modalPresentationStyle == UIModalPresentationFullScreen) barsHeight += kStatusBarHeight;
  if (self.navigationController.navigationBar.translucent) barsHeight += self.navigationController.navigationBar.bounds.size.height;
  self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(barsHeight, 0, 0, 0);
  barsHeight += kSpacing;
  self.tableView.contentInset = UIEdgeInsetsMake(barsHeight, 0, 0, 0);
}

- (NSUInteger)numberOfThumbsForRow:(NSUInteger)row
{  
  if (row == numberOfRows-1){
    NSUInteger remainder = numberOfThumbs % numberOfColumns;
    
    return remainder == 0 ? numberOfColumns : remainder;
  }

  return numberOfColumns;
}

- (void)done
{
  [self.navigationController dismissModalViewControllerAnimated:YES];
  [UIApplication sharedApplication].statusBarStyle = fromStatusBarStyle;
  if ([delegate respondsToSelector:@selector(doneWithThumbsViewController:)])
    [delegate doneWithThumbsViewController:self];
}

#pragma mark XANThumbsCellDelegate
- (void)cell:(XANThumbsCell *)cell
didSelectThumbAtColumn:(NSUInteger)column
       inRow:(NSUInteger)rowIndex
{
  if ([delegate respondsToSelector:@selector(thumbsViewController:didSelectThumbAtIndex:)]){
    NSUInteger realIndex = cell.capacityOfThumbs * rowIndex + column;
    [delegate thumbsViewController:self
             didSelectThumbAtIndex:realIndex];
  }
}


@end

