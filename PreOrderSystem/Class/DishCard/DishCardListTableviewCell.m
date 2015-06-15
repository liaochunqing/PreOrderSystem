//
//  DishCardListTableviewCell.m
//  PreOrderSystem
//
//  Created by AaronKwok on 13-4-10.
//
//

#import "DishCardListTableviewCell.h"
#import "OfflineManager.h"
#import "NsstringAddOn.h"

//间隔时间，避免同时推出两个视图
#define kSpaceTime 1.0
static NSDate *lastClickedDate = nil;
static BOOL isDeleting = NO;

@interface DishCardListTableviewCell ()

@end

@implementation DishCardListTableviewCell
@synthesize delegate;
@synthesize col1DishNameLabel,col1PriceLabel,col1SerialNumLabel,col2DishNameLabel,col2PriceLabel,col2SerialNumLabel;
@synthesize col1FrameImageview,col1SoldOutImageview,col2FrameImageview,col2SoldOutImageview;
@synthesize delete1Btn,delete2Btn,col1FrameBtn,col2FrameBtn;
@synthesize tag;

- (void)dealloc
{
    lastClickedDate = nil;
#ifdef DEBUG
    NSLog(@"===DishCardListTableviewCell,dealloc===");
#endif
}

//转换菜牌价格
- (NSString*)priceArrayToString:(NSArray*)prices
{
    NSMutableString *str = [NSMutableString string];
    [str appendString:[[OfflineManager sharedOfflineManager] getCurrencySymbol]];
    int priceCount = [prices count];
    switch (priceCount)
    {
        case 1:
        {
            CGFloat priceValue = [[[prices firstObject] objectForKey:@"price"]floatValue];
            [str appendFormat:@"%@", [NSString trimmingZeroInPrice:[NSString stringWithFormat:@"%.2f", priceValue]]];
            break;
        }
        default:
        {
            CGFloat minPrice = [[NSString stringWithFormat:@"%@",[[prices firstObject] objectForKey:@"price"]] floatValue];
            CGFloat maxPrice = minPrice;
            for (int i = 1; i < priceCount; i ++)
            {
                CGFloat tempPrice = [[[prices objectAtIndex:i] objectForKey:@"price"]floatValue];
                if (minPrice > tempPrice)
                {
                    minPrice = tempPrice;
                }
                if (maxPrice < tempPrice)
                {
                    maxPrice = tempPrice;
                }
            }
            if (minPrice == maxPrice)
            {
                [str appendFormat:@"%@", [NSString trimmingZeroInPrice:[NSString stringWithFormat:@"%.2f",minPrice]]];
            }
            else
            {
                [str appendFormat:@"%@", [NSString trimmingZeroInPrice:[NSString stringWithFormat:@"%.2f",minPrice]]];
                [str appendString:@"~"];
                [str appendFormat:@"%@", [NSString trimmingZeroInPrice:[NSString stringWithFormat:@"%.2f",maxPrice]]];
            }
            break;
        }
    }
    return str;
}

- (void)addPictureToView
{
    col1FrameImageview.image = col2FrameImageview.image = [UIImage imageNamed:@"dishCard_menuListCellBg.png"];
}

- (void)addLocalizedString
{
    self.col1IsTakeOutLabel.text = kLoc(@"no_takeout_notice");
    self.col2IsTakeOutLabel.text = kLoc(@"no_takeout_notice");
}

- (void)adjustsFontSizeToLabel
{
    col1DishNameLabel.adjustsFontSizeToFitWidth = NO;
    col1PriceLabel.adjustsFontSizeToFitWidth = YES;
    col1SerialNumLabel.adjustsFontSizeToFitWidth = YES;
    col2DishNameLabel.adjustsFontSizeToFitWidth = NO;
    col2PriceLabel.adjustsFontSizeToFitWidth = YES;
    col2SerialNumLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)addLongPressGesture
{
    isDeleting = NO;
    
    UILongPressGestureRecognizer *longPressGR1 =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleLongPress:)];
    longPressGR1.minimumPressDuration = 1;//长按时间1秒
    [self.col1FrameBtn addGestureRecognizer:longPressGR1];
    
    UILongPressGestureRecognizer *longPressGR2 =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleLongPress:)];
    longPressGR2.minimumPressDuration = 1;
    [self.col2FrameBtn addGestureRecognizer:longPressGR2];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (![gestureRecognizer.view isKindOfClass:[UIButton class]])
    {
        return;
    }
    UIButton *tempButton = (UIButton *)gestureRecognizer.view;
    switch (tempButton.tag)
    {
        case 1:
        {
            delete1Btn.hidden = NO;
            break;
        }
        case 2:
        {
            delete2Btn.hidden = NO;
            break;
        }
        default:
            break;
    }
    isDeleting = YES;
    if ([delegate respondsToSelector:@selector(deleteDishCardState:)])
    {
        [delegate deleteDishCardState:isDeleting];
    }
}

- (IBAction)deleteButtonPressed:(UIButton*)sender
{
    NSString *itemIdStr = nil;
    switch (sender.tag)
    {
        case 1:
        {
            itemIdStr = item1IdString;
            
            break;
        }
        case 2:
        {
            itemIdStr = item2IdString;
            
            break;
        }
        default:
        {
            return;
        }
    }
    if ([delegate respondsToSelector:@selector(deleteDishCard: withItemId:)])
    {
        [delegate deleteDishCard:self withItemId:itemIdStr];
    }
}


-(IBAction)columnButtonPressed:(UIButton*)sender
{
    NSTimeInterval distantTime = 0;
    NSDate *currentDate = [NSDate date];
    if (nil != lastClickedDate)
    {
        distantTime = [currentDate timeIntervalSinceDate:lastClickedDate];
        lastClickedDate = currentDate;
#ifdef DEBUG
        NSLog(@"===distantTime:%f===",distantTime);
#endif
        if (kSpaceTime > distantTime)
        {
            return;
        }
    }
    lastClickedDate = currentDate;
    
    int index = 0;
    switch (sender.tag)
    {
        case 1:
        {
            index = self.tag * 2;
            break;
        }
        case 2:
        {
            index = self.tag * 2 + 1;
            break;
        }
        default:
        {
            return;
        }
    }
    if ([delegate respondsToSelector:@selector(dishCardCellSelectedAtIndex:)])
    {
        [delegate dishCardCellSelectedAtIndex:index];
    }
}

-(void)updateCellInfoAtColumn1:(NSDictionary*)col1 column2:(NSDictionary*)col2
{
    [self adjustsFontSizeToLabel];
    [self addPictureToView];
    [self addLongPressGesture];
    [self addLocalizedString];
    
    self.delete1Btn.hidden = YES;
    if (col1)
    {
        item1IdString = [NSString stringWithFormat:@"%@",[col1 objectForKey:@"id"]];
        col1SerialNumLabel.text = [col1 objectForKey:@"code"];
        col1DishNameLabel.text = [col1 objectForKey:@"name"];
        NSArray *priceArray = [col1 objectForKey:@"price"];
        self.col1PriceLabel.text = (0 < [priceArray count])?[self priceArrayToString:priceArray]:@"";
        
        int isAllowTakeout = [[col1 objectForKey:@"isAllowTakeout"] intValue];
        int isSoldOut = [[col1 objectForKey:@"isSoldOut"] intValue];
        BOOL isActive = [[col1 objectForKey:@"isActive"]boolValue];
        self.col1StopImv.hidden = isActive;
        col1SoldOutImageview.hidden = isSoldOut==0?YES:NO;
        self.col1IsTakeOutLabel.hidden = (1 == isAllowTakeout)?YES:NO;
        self.col1FrameBtn.hidden = NO;
    }
    else
    {
        col1FrameImageview.hidden = YES;
        self.col1StopImv.hidden = YES;
        col1SerialNumLabel.text = @"";
        col1PriceLabel.text = @"";
        col1DishNameLabel.text = @"";
        self.col1SoldOutImageview.hidden = YES;
        self.col1IsTakeOutLabel.hidden = YES;
        self.col1FrameBtn.hidden = YES;
    }
    
    self.delete2Btn.hidden = YES;
    if (col2)
    {
        item2IdString = [NSString stringWithFormat:@"%@",[col2 objectForKey:@"id"]];
        col2FrameImageview.hidden = NO;
        col2SerialNumLabel.text = [col2 objectForKey:@"code"];
        col2DishNameLabel.text = [col2 objectForKey:@"name"];
        NSArray *priceArray = [col2 objectForKey:@"price"];
        self.col2PriceLabel.text = (0 < [priceArray count])?[self priceArrayToString:priceArray]:@"";
        
        int isAllowTakeout = [[col2 objectForKey:@"isAllowTakeout"] intValue];
        int isSoldOut = [[col2 objectForKey:@"isSoldOut"] intValue];
        col2SoldOutImageview.hidden = isSoldOut==0?YES:NO;
        BOOL isActive = [[col2 objectForKey:@"isActive"]boolValue];
        self.col2StopImv.hidden = isActive;
        self.col2IsTakeOutLabel.hidden = (1 == isAllowTakeout)?YES:NO;
        self.col2FrameBtn.hidden = NO;
    }
    else
    {
        col2FrameImageview.hidden = YES;
        self.col2StopImv.hidden = YES;
        col2SerialNumLabel.text = @"";
        col2PriceLabel.text = @"";
        col2DishNameLabel.text = @"";
        self.col2SoldOutImageview.hidden = YES;
        self.col2IsTakeOutLabel.hidden = YES;
        self.col2FrameBtn.hidden = YES;
    }
}

@end
