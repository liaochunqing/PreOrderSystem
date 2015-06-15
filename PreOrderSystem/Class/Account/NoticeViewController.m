//
//  NoticeViewController.m
//  PreOrderSystem
//
//  Created by sWen on 13-1-29.
//
//

#import "NoticeViewController.h"
#import "UILabel+AdjustFontSize.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "Constants.h"

@interface NoticeViewController ()
- (void)loadInfoData;
@end

@implementation NoticeViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.contentSizeForViewInPopover = CGSizeMake(345, 445);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadInfoData];
    [self addPictureToView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    infoArray = nil;
#ifdef DEBUG
    NSLog(@"===LoginViewController viewDidUnload===");
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ((kSystemVersionOfCurrentDevice >= 6.0) && [self isViewLoaded] && ![self.view window])
    {
        [self viewDidUnload];
        [self setView:nil];
    }
}

-(void)dealloc
{
#ifdef DEBUG
    NSLog(@"===NoticeViewController dealloc===");
#endif
}

- (void)addPictureToView
{
    self.bgImageView.image = [UIImage imageFromMainBundleFile:@"Account_infoBg.png"];
}

- (void)loadInfoData
{
    infoArray = [[NSMutableArray alloc]initWithCapacity:3];
    [infoArray addObject:kLoc(@"etable_discriptions")];
    [infoArray addObject:kLoc(@"online_takeout")];
    [infoArray addObject:kLoc(@"takeout_descriptions")];
    [infoArray addObject:kLoc(@"online_order_seat")];
    [infoArray addObject:kLoc(@"order_seat_descriptions")];
    [infoArray addObject:kLoc(@"show_menus")];
    [infoArray addObject:kLoc(@"menus_descriptions")];
    [infoArray addObject:kLoc(@"queue_with_phone")];
    [infoArray addObject:kLoc(@"queue_descriptions")];
    [infoArray addObject:kLoc(@"call_serivce")];
    [infoArray addObject:kLoc(@"qrcode_descriptions")];
}

#pragma mark UITableViewController datasource & delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    cell.textLabel.numberOfLines = 0;
    if (0 != indexPath.row && 0 != indexPath.row % 2)
    {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        cell.textLabel.textColor = [UIColor colorWithRed:1.0 green:140.0/255.0 blue:60.0/255.0 alpha:1.0];
    }
    else
    {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    cell.textLabel.text = [infoArray objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [infoArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 50.0;
    UILabel *tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 260, 30)];
    tempLabel.numberOfLines = 0;
    if (0 != indexPath.row && 0 != indexPath.row % 2)
    {
        tempLabel.font = [UIFont boldSystemFontOfSize:20];
    }
    else
    {
        tempLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    tempLabel.text = [infoArray objectAtIndex:indexPath.row];
    height = [tempLabel adjustLabelHeight] + 10;
	return height;
}

@end
