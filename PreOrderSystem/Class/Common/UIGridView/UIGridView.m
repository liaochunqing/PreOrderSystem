//
//  UIGridViewView.m
//  foodling2
//
//  Created by Tanin Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UIGridView.h"
#import "UIGridViewDelegate.h"
#import "UIGridViewCell.h"
#import "UIGridViewRow.h"

@implementation UIGridView


@synthesize uiGridViewDelegate;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		[self setUp];
    }
    return self;
}


- (id) initWithCoder:(NSCoder *)aDecoder
{
	
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
		self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}


- (void) setUp
{
	self.delegate = self;
	self.dataSource = self;
}

- (void)setEGORefreshView
{
    _reloading = NO;
    if (_styleBoxRefreshHeaderView == nil)
    {
        CGRect refreshRect = CGRectMake(0.0f,
                                        0.0f - self.bounds.size.height,
                                        self.bounds.size.width,
                                        self.bounds.size.height);
		_styleBoxRefreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:refreshRect];
		_styleBoxRefreshHeaderView.delegate = self;
        _styleBoxRefreshHeaderView.backgroundColor = [UIColor clearColor];
		[self addSubview:_styleBoxRefreshHeaderView];
        [_styleBoxRefreshHeaderView release];
	}

}

- (void)dealloc {
	self.delegate = nil;
	self.dataSource = nil;
	self.uiGridViewDelegate = nil;
    self.styleBoxRefreshHeaderView = nil;
    [super dealloc];
}

- (UIGridViewCell *) dequeueReusableCell
{
	UIGridViewCell* temp = tempCell;
	tempCell = nil;
	return temp;
}


// UITableViewController specifics


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = [self.uiGridViewDelegate gridView:self heightForHeaderInSection:0];
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self.uiGridViewDelegate gridView:self viewForHeaderInSection:0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int residue =  ([uiGridViewDelegate numberOfCellsOfGridView:self] % [uiGridViewDelegate numberOfColumnsOfGridView:self]);
	
	if (residue > 0) residue = 1;
	
	return ([uiGridViewDelegate numberOfCellsOfGridView:self] / [uiGridViewDelegate numberOfColumnsOfGridView:self]) + residue;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [uiGridViewDelegate gridView:self heightForRowAt:indexPath.row];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UIGridViewRow";
	
    UIGridViewRow *row = (UIGridViewRow *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (row == nil) {
        row = [[[UIGridViewRow alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	int numCols = [uiGridViewDelegate numberOfColumnsOfGridView:self];
	int count = [uiGridViewDelegate numberOfCellsOfGridView:self];
	
	CGFloat x = 0.0;
	CGFloat height = [uiGridViewDelegate gridView:self heightForRowAt:indexPath.row];
	
	for (int i=0;i<numCols;i++) {
		
		if ((i + indexPath.row * numCols) >= count) {
			
			if ([row.contentView.subviews count] > i) {
				((UIGridViewCell *)[row.contentView.subviews objectAtIndex:i]).hidden = YES;
			}
			
			continue;
		}
		
		if ([row.contentView.subviews count] > i) {
			tempCell = [row.contentView.subviews objectAtIndex:i];
		} else {
			tempCell = nil;
		}
		
		UIGridViewCell *cell = [uiGridViewDelegate gridView:self 
												cellForRowAt:indexPath.row 
												 AndColumnAt:i];
		
		if (cell.superview != row.contentView) {
			[cell removeFromSuperview];
			[row.contentView addSubview:cell];
			
			[cell addTarget:self action:@selector(cellPressed:) forControlEvents:UIControlEventTouchUpInside];
		}
		
		cell.hidden = NO;
		cell.rowIndex = indexPath.row;
		cell.colIndex = i;
		
		CGFloat thisWidth = [uiGridViewDelegate gridView:self widthForColumnAt:i];
		cell.frame = CGRectMake(x, 0, thisWidth, height);
		x += thisWidth;
	}
	
	row.frame = CGRectMake(row.frame.origin.x,
							row.frame.origin.y,
							x,
							height);
	
    return row;
}


- (IBAction) cellPressed:(id) sender
{
	UIGridViewCell *cell = (UIGridViewCell *) sender;
	[uiGridViewDelegate gridView:self didSelectRowAt:cell.rowIndex AndColumnAt:cell.colIndex];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_styleBoxRefreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_styleBoxRefreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark Data Source Loading / Reloading Methods

- (void)doneLoadingTableViewData
{
	_reloading = NO;
    [_styleBoxRefreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
}

//结束加载数据,无论是否成功加载数据
- (void)finishLoading
{
    [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    if (self.uiGridViewDelegate)
    {
        [self.uiGridViewDelegate gridView:self didTriggerRefresh:view];
    }
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doneLoadingTableViewData) userInfo:nil repeats:NO];
}



- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date];
}
@end
