//
//  DtMenuRemarkPickerViewController.m
//  PreOrderSystem
//
//  Created by SWen on 13-12-31.
//
//

#import "DtMenuRemarkPickerViewController.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "DtMenuDataClass.h"

#define kDtMenuRemarkItemBtnTag 1000

@interface DtMenuRemarkPickerViewController ()
{
    
}

@end

@implementation DtMenuRemarkPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self addRemarkItemToScrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%s===", __FUNCTION__);
#endif
}

- (void)remarkItemBtnClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

- (void)addRemarkItemToScrollView
{
    NSArray *btnCellArray = self.remarkScrollView.subviews;
    int btnCellCount = [btnCellArray count];
    for (int i = 0; i < btnCellCount; i++)
    {
        id tempClass = [btnCellArray objectAtIndex:i];
        if ([tempClass isKindOfClass:NSClassFromString(@"DtMenuRemarkOptionsCell")])
        {
            DtMenuRemarkOptionsCell *tempBtnCell = (DtMenuRemarkOptionsCell *)tempClass;
            [tempBtnCell removeFromSuperview];
        }
    }
    
    
    CGFloat contentSizeWidth = 10.0, contentSizeHeight = 0.0, originY = 15.0, btnSpace = 10.0, btnWidth, btnHeight = 40;
    CGFloat lastOriginY = 0;//用来判断是否是在同一行
    BOOL flag = NO;
    NSArray *tempArray = self.cuisineRemarkArray;
    int tempCount = [tempArray count];
    for (int i = 0; i < tempCount; i++)
    {
        NSString *remarkStr = [tempArray objectAtIndex:i];
        flag = NO;
        NSMutableArray *tempDishRemarkkArray = self.dishRemarkArray;
        int tempDishRemarkCount = [tempDishRemarkkArray count];
        if (self.vcTag < tempDishRemarkCount)
        {
            DtMenuCookbookRemarkDataClass *tempClass = [[DtMenuCookbookRemarkDataClass alloc] initWithDtMenuRemarkData:[tempDishRemarkkArray objectAtIndex:self.vcTag]];
            for (int k = 0; k < [tempClass.contentArray count]; k++)
            {
                if ([remarkStr isEqualToString:[tempClass.contentArray objectAtIndex:k]])
                {
                    flag = YES;
                    break;
                }
            }
        }
        
        UIFont *titleFont = [UIFont boldSystemFontOfSize:15.0];
        CGSize titleSize = [remarkStr sizeWithFont:titleFont];
        btnWidth = titleSize.width;
        if (btnWidth < 40)
        {
            btnWidth = 40;
        }
        btnWidth = btnWidth + 40;
        
        
#ifdef DEBUG
        NSLog(@"===%s,%f,btnWidth:%f===", __FUNCTION__, contentSizeWidth,btnWidth);
#endif
        if (btnWidth > 240)
        {
            originY = originY + btnHeight + btnSpace;
            contentSizeWidth = 10;
            btnHeight = 20 * (btnWidth/295 + 1) + 20;
            btnWidth = btnWidth + 40;
            if (btnWidth > 295)
            {
                btnWidth = 295;
            }
        }
        else
        {
            if ((contentSizeWidth + btnWidth)> 300)
            {
                originY = originY + btnHeight + btnSpace;
                contentSizeWidth = 10;
            }
            btnHeight = 40;
        }
        
        DtMenuRemarkOptionsCell *optionCell = [[DtMenuRemarkOptionsCell alloc] initWithRemarkText:remarkStr withSelectedFlag:flag];
        optionCell.delegate = self;
        optionCell.tag = i + kDtMenuRemarkItemBtnTag;
        optionCell.frame = CGRectMake(contentSizeWidth, originY, btnWidth, btnHeight);
        [self.remarkScrollView addSubview:optionCell];
        
        contentSizeWidth = contentSizeWidth + btnWidth + btnSpace;
        if (0 != i)
        {
            if (lastOriginY != originY)
            {
                contentSizeHeight = contentSizeHeight + btnHeight + btnSpace;
            }
        }
        else
        {
            contentSizeHeight = contentSizeHeight + btnHeight + btnSpace;
        }
        lastOriginY = originY;
    }
    self.remarkScrollView.contentSize = CGSizeMake(self.remarkScrollView.frame.size.width, contentSizeHeight + (2 * btnSpace));
    self.noDataLabel.hidden = (tempCount)?YES:NO;
}
    
#pragma mark - DtMenuRemarkOptionsCellDelegate

- (void)DtMenuRemarkOptionsCellHavedSelected:(NSString *)remarkStr withAddFlag:(BOOL)flag
{
    NSMutableArray *tempDishRemarkkArray = self.dishRemarkArray;
    int tempDishRemarkCount = [tempDishRemarkkArray count];
    if (self.vcTag < tempDishRemarkCount)
    {
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:[tempDishRemarkkArray objectAtIndex:self.vcTag]];
        NSMutableArray *tempContentArray = [[NSMutableArray alloc] initWithArray:[tempDict objectForKey:kRemarkContent]];
        if (flag)
        {
            [tempContentArray addObject:remarkStr];
        }
        else
        {
            [tempContentArray removeObject:remarkStr];
        }
        [tempDict setObject:tempContentArray forKey:kRemarkContent];
        [tempDishRemarkkArray replaceObjectAtIndex:self.vcTag withObject:tempDict];
    }
    if ([self.delegate respondsToSelector:@selector(DtMenuRemarkPickerViewController:withDishRemarkData:)])
    {
        [self.delegate DtMenuRemarkPickerViewController:self withDishRemarkData:tempDishRemarkkArray];
    }
}

@end
