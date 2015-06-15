//
//  CustomSideBar.m
//  PreOrderSystem
//
//  Created by sWen on 13-3-25.
//
//

#import "CustomSideBar.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "CustomBadge.h"

@implementation CustomSideBar
@synthesize delegate;
@synthesize bgFlag;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        
        // 背景
        bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 135, 65)];
        [self addSubview:bgImageView];
        
        // 分割线
        lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 65, 135, 2)];
        [self addSubview:lineImageView];
        
        // 功能按钮
        sideButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sideButton.frame = CGRectMake(0, 0, 135, 65);
        sideButton.titleLabel.font = [UIFont boldSystemFontOfSize:25.0];
        sideButton.titleEdgeInsets = UIEdgeInsetsMake(0, 35, 0, 0);
        [sideButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sideButton];
        
        // 未读数量
        sideBadge = [CustomBadge customBadgeWithString:@"0"
                                       withStringColor:[UIColor whiteColor]
                                        withInsetColor:[UIColor redColor]
                                        withBadgeFrame:YES
                                   withBadgeFrameColor:[UIColor whiteColor]
                                             withScale:1.0
                                           withShining:YES];
        sideBadge.hidden = YES;
        [self addSubview:sideBadge];
        
        // 催单数量视图
        remindersBadge = [CustomBadge customBadgeWithString:@"0"
                                            withStringColor:[UIColor whiteColor]
                                             withInsetColor:[UIColor greenColor]
                                             withBadgeFrame:YES
                                        withBadgeFrameColor:[UIColor whiteColor]
                                                  withScale:1.0
                                                withShining:YES];
        remindersBadge.hidden = YES;
        [self addSubview:remindersBadge];
    }
    return self;
}

- (void)updateViewAfterCreateBar
{
    NSInteger imgIndex = self.tag - kDiningTableSideBarTag + 1;
    if (bgFlag) {
        lineImageView.hidden = YES;
        bgImageView.hidden = NO;
        bgImageView.image = [UIImage imageFromMainBundleFile:@"nav_sideBarSelectedBg.png"];
        [sideButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        NSString *imgName = [NSString stringWithFormat:@"nav_sideBar0%dButtonSelected.png",imgIndex];
        [sideButton setBackgroundImage:[UIImage imageFromMainBundleFile:imgName] forState:UIControlStateNormal];
    } else {
        bgImageView.hidden = YES;
        lineImageView.hidden = NO;
        lineImageView.image = [UIImage imageFromMainBundleFile:@"nav_sideBar_line.png"];
        UIColor *titleColor = [UIColor colorWithRed:120.0/255.0 green:75.0/255.0 blue:18.0/255.0 alpha:1.0];
        [sideButton setTitleColor:titleColor forState:UIControlStateNormal];
        NSString *imgName = [NSString stringWithFormat:@"nav_sideBar0%dButtonNormal.png",imgIndex];
        [sideButton setBackgroundImage:[UIImage imageFromMainBundleFile:imgName] forState:UIControlStateNormal];
    }
    
    NSString *btnTitleString = nil;
    switch (self.tag) {
        case kDiningTableSideBarTag: {
            btnTitleString = kLoc(@"table");
            break;
        }
        case kTakeOutSideBarTag: {
            btnTitleString = kLoc(@"takeout");
            break;
        }
        case kPreOrderSideBarTag: {
            btnTitleString = kLoc(@"order_seats");
            break;
        }
        case kDishCardSideBarTag: {
            btnTitleString = kLoc(@"menus");
            break;
        }
        case kQueueSideBarTag: {
            btnTitleString = kLoc(@"queue");
            break;
        }
        case kCallServiceSideBarTag: {
            btnTitleString = kLoc(@"service");
            break;
        }
        case kMemberSideBarTag: {
            btnTitleString = kLoc(@"member");
            break;
        }
        case kMoreSideBarTag: {
            btnTitleString = kLoc(@"more");
            break;
        }
        default: {
            btnTitleString = @"";
            break;
        }
    }
    [sideButton setTitle:btnTitleString forState:UIControlStateNormal];
}



#pragma mark - public methods

- (void)updateSideBadge:(int)unread
{
    if (unread > 0) {
        sideBadge.hidden = NO;
        [sideBadge autoBadgeSizeWithString:[NSString stringWithFormat:@"%i", unread]];
        [sideBadge setFrame:CGRectMake(sideButton.frame.origin.x + sideButton.frame.size.width - sideBadge.frame.size.width * 2/3, sideButton.frame.origin.y - 10, sideBadge.frame.size.width, sideBadge.frame.size.height)];
    } else {
        sideBadge.hidden = YES;
    }
}

- (void)updateRemindersBadge:(int)reminders
{
    if (reminders > 0) {
        remindersBadge.hidden = NO;
        [remindersBadge autoBadgeSizeWithString:[NSString stringWithFormat:@"%i", reminders]];
        [remindersBadge setFrame:CGRectMake(sideButton.frame.origin.x - remindersBadge.frame.size.width / 3,
                                            sideButton.frame.origin.y - 10,
                                            remindersBadge.frame.size.width,
                                            remindersBadge.frame.size.height)];
    } else {
        remindersBadge.hidden = YES;
    }
}

- (void)buttonPressed:(UIButton *)sender
{
    if ([delegate respondsToSelector:@selector(sideBarPressed:)]) {
        [delegate sideBarPressed:self];
    }
}

@end
