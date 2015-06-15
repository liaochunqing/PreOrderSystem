//
//  DtMenuCookbookStyleView.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-30.
//
//

#import "DtMenuCookbookStyleView.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "DiningTableImageName.h"
#import "DtMenuDataClass.h"
#import "NsstringAddOn.h"

@interface DtMenuCookbookStyleView ()
{
    NSArray *styleArray;
}

@end

@implementation DtMenuCookbookStyleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addPictureToView];
    }
    return self;
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%s===", __FUNCTION__);
#endif
}

- (void)updateDtMenuCookbookStyleView:(NSArray *)array
{
    styleArray = array;
    [self.styleTableView reloadData];
}

- (void)addPictureToView
{
    self.bgImageView.image = [UIImage imageFromMainBundleFile:kDtMenuCookbookShowAllStyleBgImageName];
}

- (void)setTableViewWidth:(CGFloat)width
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,width, self.frame.size.height);
    CGRect imvRect = self.bgImageView.frame;
    imvRect.size.width = width;
    self.bgImageView.frame = imvRect;
    self.styleTableView.frame = CGRectMake(self.styleTableView.frame.origin.x, self.styleTableView.frame.origin.y, width, self.styleTableView.frame.size.height);
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    int row = indexPath.row;
    
    DtMenuStyleTableViewCell *cell = (DtMenuStyleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DtMenuStyleTableViewCell" owner:self options:nil] lastObject];
        if (self.width > 0)
        {
            [cell setTableViewWidth:self.width];
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.tag = row;
    DtMenuCookbookPriceDataClass *tempClass = [[DtMenuCookbookPriceDataClass alloc] initWithDtMenuPriceData:[styleArray objectAtIndex:row]];
    [cell uopdateDtMenuStyleCell:tempClass.style];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [styleArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(DtMenuCookbookStyleHavedSelected:withSelectStyle:)])
    {
        self.styleIndex = indexPath.row;
        DtMenuCookbookPriceDataClass *tempClass = [[DtMenuCookbookPriceDataClass alloc] initWithDtMenuPriceData:[styleArray objectAtIndex:self.styleIndex]];
        
        NSString *styleStr = [NSString cutString:tempClass.style withMaxLengthOfStr:kDtMenuCookbookMaxStyleLen];
        [self.delegate DtMenuCookbookStyleHavedSelected:self withSelectStyle:styleStr];
    }
    
    //jhh_test:
    if (self.delegate && [self.delegate respondsToSelector:@selector(DtMenuCookbookStyleHavedSelected:withSelectIndex:)])
    {
        [self.delegate DtMenuCookbookStyleHavedSelected:self withSelectIndex:indexPath];
    }
}

@end
