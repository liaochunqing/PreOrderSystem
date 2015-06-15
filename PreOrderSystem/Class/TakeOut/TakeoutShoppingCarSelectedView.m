//
//  TakeoutShoppingCarSelectedView.m
//  PreOrderSystem
//
//  Created by mac on 14-7-16.
//
//

#import "TakeoutShoppingCarSelectedView.h"


#import "UIImage+imageWithContentsOfFile.h"
#import "DiningTableImageName.h"
#import "NsstringAddOn.h"
#import "PSAlertView.h"
#import "Constants.h"
#import "NsstringAddOn.h"
#import "OfflineManager.h"
#import "DtMenusCommon.h"
#import "MainViewController.h"

#define kHeightForRowAtIndexPath 50
#define kHeightForHeaderInSection 40
#define kFontSizeForItemName 18
#define kCancelAlertViewTag 1000
/*套餐栏目 + 备注选项*/
#define kNumberOfSectionsInTableView [self.shoppingCarDataClass.packageArray count]

@implementation TakeoutShoppingCarSelectedView

- (id)initWithData:(DtMenuShoppingCarDataClass *)data
{
    self = [super init];
    if (self)
    {
        self.shoppingCarDataClass = data;
        float height = [self calculateSelfHeight];
        self.packageSelectTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 450, height)];
        self.packageSelectTableView.delegate = self;
        self.packageSelectTableView.dataSource = self;
        self.packageSelectTableView.scrollEnabled = NO;
        self.packageSelectTableView.backgroundColor = [UIColor clearColor];
        self.packageSelectTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.packageSelectTableView];
        if (self.isNeedScroll)
        {
            self.canScrollImv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 320, 450, 10)];
            self.canScrollImv.backgroundColor = [UIColor clearColor];
            [self.canScrollImv setImage:[UIImage imageNamed:@"moreScroll"]];
            [self addSubview:self.canScrollImv];
        }
    }
    return self;
}
#pragma mark -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint contentOffsetPoint = self.packageSelectTableView.contentOffset;
    CGRect frame = self.packageSelectTableView.frame;
    if (contentOffsetPoint.y == self.packageSelectTableView.contentSize.height - frame.size.height || self.packageSelectTableView.contentSize.height < frame.size.height)
    {
        //tableView已滚动到最底部
        self.canScrollImv.hidden = YES;
        self.isScrollToBottom = YES;
    }
    else
    {
        self.isScrollToBottom = NO;
        NSLog(@">>>>滚>>>>");
        self.canScrollImv.hidden = NO;
    }
}
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if (self.isScrollToBottom)
//    {
//        self.canScrollImv.hidden = YES;
//    }
//    else
//    {
//        self.canScrollImv.hidden = NO;
//    }
//}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
    }
    return self;
}

#pragma mark -public method
- (CGFloat)calculateSelfHeight
{
    CGFloat selfHeight = 0.0;
    NSInteger sectionCount = [self.shoppingCarDataClass.packageArray count];
    NSInteger allRow = 0;
    for (int i = 0; i < sectionCount; i++)
    {
       allRow += [self calculateNumberOfRowsInSection:i];
    }
    selfHeight = kHeightForHeaderInSection * sectionCount + allRow * kHeightForRowAtIndexPath;
    /*
     暂时屏蔽高度限制,开启后同时也会开启可滚动提示图显示.
    if (selfHeight > 322)
    {
        self.isNeedScroll = YES;
        selfHeight = 320;
    }
    */
    return selfHeight;
}



#pragma mark - Private method

- (NSInteger)calculateNumberOfRowsInSection:(NSInteger)section
{
    int tempCount = [[self getPackageDataClass:section].memberArray count];
    int number = 0;
    if ( 0 == tempCount % kDtMenuPackageCellNum) {
        number = tempCount / kDtMenuPackageCellNum;
    } else {
        number = tempCount / kDtMenuPackageCellNum + 1;
    }
    return number;
}

/*套餐 dataClass*/

- (DtMenuCookbookPackageDataClass *)getPackageDataClass:(int)index
{
    DtMenuCookbookPackageDataClass *tempDataClass = nil;
    NSMutableArray *tempArray = self.shoppingCarDataClass.packageArray;
    if (index < [tempArray count]) {
        tempDataClass = [[DtMenuCookbookPackageDataClass alloc] initWithDtMenuPackageData:[tempArray objectAtIndex:index]];
    }
    return tempDataClass;
}

/*套餐栏目成员 dataClass*/

- (DtMenuCookbookPackageMemberDataClass *)getPackageMemberDataClass:(int)index withPackageData:(NSMutableArray *)memberArray
{
    DtMenuCookbookPackageMemberDataClass *tempDataClass = nil;
    if (index < [memberArray count]) {
        tempDataClass = [[DtMenuCookbookPackageMemberDataClass alloc] initWithDtMenuPackageMemberData:[memberArray objectAtIndex:index]];
    }
    return tempDataClass;
}

- (NSString *)getTitleForHeaderInSection:(NSInteger)section
{
    NSString *tempStr = nil;
    DtMenuCookbookPackageDataClass *tempClass = [self getPackageDataClass:section];
    switch (tempClass.choiceType) {
        case 1: {
            tempStr = [NSString stringWithFormat:@"(%@%d%@)", kLoc(@"required"),
                       tempClass.choiceNum, kLoc(@"item")];
            break;
        }
        case 2: {
            tempStr = [NSString stringWithFormat:@"(%@)", kLoc(@"optional_choose")];
            break;
        }
        default: {
            tempStr = @"";
            break;
        }
    }
    return [NSString stringWithFormat:@"%@%@",tempClass.itemName, tempStr];
}

- (int)getMemberSelectedNum:(int)itemIndex
{
    int totalNum = 0;
    NSMutableArray *tempArray = self.shoppingCarDataClass.packageArray;
    int tempCount = [tempArray count];
    if (itemIndex < tempCount)
    {
        NSMutableDictionary *tempDict = [tempArray objectAtIndex:itemIndex];
        NSMutableArray *tempMemberArray = [tempDict objectForKey:kDtMenuCookbookPackageDataMemberKey];
        int tempMemberCount = [tempMemberArray count];
        for (int j = 0; j < tempMemberCount; j++)
        {
            NSMutableDictionary *memberDict = [tempMemberArray objectAtIndex:j];
            int checked = [[memberDict objectForKey:kDtMenuCookbookPackageMemberCheckedKey] integerValue];
            if (checked)
            {
                totalNum++;
            }
        }
    }
    return totalNum;
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSectionsInTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int tempCount = [[self getPackageDataClass:section].memberArray count];
    int number = 0;
    if ( 0 == tempCount % kDtMenuPackageCellNum) {
        number = tempCount / kDtMenuPackageCellNum;
    } else {
        number = tempCount / kDtMenuPackageCellNum + 1;
    }
    return number;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeightForHeaderInSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeightForRowAtIndexPath;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int indexSection = indexPath.section;
    int indexRow = indexPath.row;
    
    
    /*套餐内容*/
    static NSString *cellIdentifier = @"DtMenuPackageTableViewCell";
    DtMenuCookbookPackageTableViewCell *cell = (DtMenuCookbookPackageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DtMenuCookbookPackageTableViewCell"
                                              owner:self
                                            options:nil] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.sectionIndex = indexSection;
    cell.tag = indexRow;
    cell.selectedTotalNum = [self getMemberSelectedNum:indexSection];
    
    DtMenuCookbookPackageDataClass *tempClass = [self getPackageDataClass:indexSection];
    NSDictionary *firstDict = nil;
    NSDictionary *secondDict = nil;
    NSMutableArray *tempArray = tempClass.memberArray;
    int tempCount = [tempArray count];
    int indexForCell = indexRow * kDtMenuPackageCellNum;
    const int firstIndex = indexForCell;
    const int secondIndex = firstIndex + 1;
    if (secondIndex < tempCount) {
        firstDict = [tempArray objectAtIndex:firstIndex];
        secondDict = [tempArray objectAtIndex:secondIndex];
    } else if(firstIndex < tempCount) {
        firstDict = [tempArray objectAtIndex:firstIndex];
    }
    cell.choiceType = tempClass.choiceType;
    cell.choiceNum = tempClass.choiceNum;
    [cell updateDtMenuCookbookPackageCell:firstDict withSecondItemDict:secondDict];
    
    return cell;
    
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = nil;
    if ((kNumberOfSectionsInTableView) != section) {
        headView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                            0.0,
                                                            self.packageSelectTableView.frame.size.width,
                                                            kHeightForHeaderInSection)];
        headView.backgroundColor = [UIColor colorWithRed:242.0/255.0
                                                   green:243.0/255.0
                                                    blue:239.0/255.0
                                                   alpha:1.0];
        
        if (0 != section) {
            UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0,
                                                                                  0.0,
                                                                                  headView.frame.size.width - 30.0,
                                                                                  5.0)];
            lineView.backgroundColor = [UIColor clearColor];
            lineView.image = [UIImage imageFromMainBundleFile:kDtMenuCookbookPackageItemLineBgImageName];
            [headView addSubview:lineView];
        }
        
        NSString *tempStr = [NSString getStrWithoutWhitespace:[self getTitleForHeaderInSection:section]];
        if (![NSString strIsEmpty:tempStr]) {
            UILabel *itemNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.packageSelectTableView.frame.size.width - 30, kHeightForHeaderInSection)];
            itemNameLabel.backgroundColor = [UIColor clearColor];
            itemNameLabel.textAlignment = UITextAlignmentLeft;
            itemNameLabel.font = [UIFont systemFontOfSize:kFontSizeForItemName];
            itemNameLabel.textColor = [UIColor colorWithRed:92.0/255.0 green:92.0/255.0 blue:94.0/255.0 alpha:1.0];
            itemNameLabel.adjustsFontSizeToFitWidth = YES;
            itemNameLabel.text = tempStr;
            [headView addSubview:itemNameLabel];
        }
    }
    return headView;
}

#pragma mark - DtMenuCookbookPackageTableViewCellDelegate

- (void)dtMenuCookbookPackageTableViewCell:(DtMenuCookbookPackageTableViewCell *)cell withMemberDict:(NSDictionary *)selectedDict withMemberIndex:(int)index
{
    //NSLog(@"****%@",selectedDict);
    int sectionIndex = cell.sectionIndex;
    DtMenuCookbookPackageDataClass *tempClass = [self getPackageDataClass:sectionIndex];
    if (1 == cell.choiceNum && kPackageSecondChoiceType == cell.choiceType) {
        NSMutableArray *tempMemberArray = tempClass.memberArray;
        int tempCount = [tempMemberArray count];
        for (int i = 0; i < tempCount; i++) {
            if (i != index) {
                NSMutableDictionary *memberDict = [[NSMutableDictionary alloc] initWithDictionary:[tempMemberArray objectAtIndex:i]];
                [memberDict setObject:[NSNumber numberWithInt:0]
                               forKey:kDtMenuCookbookPackageMemberCheckedKey];
                [DtMenuCookbookPackageDataClass modifyPackageData:tempMemberArray
                                                       withMember:memberDict
                                                        withIndex:i];
            } else {
                [DtMenuCookbookPackageDataClass modifyPackageData:tempMemberArray
                                                       withMember:selectedDict
                                                        withIndex:index];
            }
        }
    } else {
        [DtMenuCookbookPackageDataClass modifyPackageData:tempClass.memberArray
                                               withMember:selectedDict
                                                withIndex:index];
    }
    NSMutableArray *tempArray = self.shoppingCarDataClass.packageArray;
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:[tempArray objectAtIndex:sectionIndex]];
    [tempDict setObject:tempClass.memberArray forKey:kDtMenuCookbookPackageDataMemberKey];
    [tempArray replaceObjectAtIndex:sectionIndex withObject:tempDict];
    
    //isModified_ = YES;
    //[self updatePriceByStyleAndCheck];
    [self.packageSelectTableView reloadData];
    if (self.delegatqe && [self.delegatqe respondsToSelector:@selector(TakeoutShoppingCarSelectedView:didChangedPackageArr:withChangeMember:)])
    {
        [self.delegatqe TakeoutShoppingCarSelectedView:self didChangedPackageArr:tempArray withChangeMember:selectedDict];
    }

}



@end
