//
//  PostAuthorityTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-12.
//
//

#import "PostAuthorityTableViewCell.h"
#import "StaffAuthorityCell.h"
#import "StaffManagementSuperDataClass.h"

#define kPostAuthorityCellSpace 20
#define kAuthorityTableViewWidth 354

@interface PostAuthorityTableViewCell ()<StaffAuthorityCellDelegate>
{
    StaffManagementAuthDataClass *authDataClass;
    StaffAuthorityCell *mainAuthorityCell;
}

@end

@implementation PostAuthorityTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updatePostAuthorityCell:(StaffManagementAuthDataClass *)authInfo
{
    authDataClass = authInfo;
    self.backgroundColor = [UIColor clearColor];
    //主权限
    mainAuthorityCell = [[StaffAuthorityCell alloc] initWithFrameType:kStaffAuthorityCellBigType withMainAuthorityFlag:YES withAuthName:authInfo.name withAuthOpenFlag:[self whetherOpenAllAuth] withSubAuthOpenFlag:[self whetherSelectedAuth]];
    mainAuthorityCell.delegate = self;
    [self.contentView addSubview:mainAuthorityCell];
    
    //子权限
    CGFloat subAuthCellAllHeight = [self addSubAuthCellToView:authDataClass.childrenArray];
    
    //线
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kStaffAuthorityCellHeight + subAuthCellAllHeight + kPostAuthorityCellSpace - 2, kAuthorityTableViewWidth, 1)];
    lineImageView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:lineImageView];
    
    
#ifdef DEBUG
    NSLog(@"===%s,%d===", __FUNCTION__, authInfo.open);
#endif
}

- (CGFloat)addSubAuthCellToView:(NSArray *)subAuthArray
{
    const CGFloat zeroFloatNum = 0.0, maxWidth = kAuthorityTableViewWidth, btnXSpace = 70, btnYSpace = 10, originX = 0;
    const NSInteger zeroIntNum = 0;
    CGFloat originY = mainAuthorityCell.frame.origin.y + mainAuthorityCell.frame.size.height + btnYSpace;
    CGFloat contentSizeWidth = originX, contentSizeHeight = zeroFloatNum, authCellWidth = zeroFloatNum, authCellHeight = zeroFloatNum;
    CGFloat lastOriginY = zeroFloatNum;//用来判断是否是在同一行
    NSInteger btnNum = zeroIntNum;//用来判断同一行放了多少个Btn
    NSInteger index = zeroIntNum;
    for (StaffManagementSubAuthDataClass *subAuth in subAuthArray)
    {
        StaffAuthorityCell *subAuthorityCell = [[StaffAuthorityCell alloc] initWithFrameType:kStaffAuthorityCellBigType withMainAuthorityFlag:NO withAuthName:subAuth.name withAuthOpenFlag:subAuth.open withSubAuthOpenFlag:NO];
        subAuthorityCell.delegate = self;
        subAuthorityCell.tag = index;
        authCellWidth = subAuthorityCell.frame.size.width;
        authCellHeight = subAuthorityCell.frame.size.height;
        if ((contentSizeWidth + authCellWidth)> maxWidth)
        {
            originY = originY + authCellHeight + btnYSpace;
            contentSizeWidth = originX;
        }
        subAuthorityCell.frame = CGRectMake(contentSizeWidth, originY, authCellWidth, authCellHeight);
        [self.contentView addSubview:subAuthorityCell];
        
        contentSizeWidth = contentSizeWidth + authCellWidth + btnXSpace;
        if (zeroIntNum != index)
        {
            if (lastOriginY != originY)
            {
                contentSizeHeight = contentSizeHeight + authCellHeight + btnYSpace;
                btnNum = zeroIntNum;
            }
            else
            {
                btnNum ++;
            }
        }
        else
        {
            contentSizeHeight = contentSizeHeight + authCellHeight + btnYSpace;
        }
        lastOriginY = originY;
        index++;
    }
    return contentSizeHeight;
}

- (BOOL)whetherSelectedAuth
{
    BOOL isSelected = NO;
    for (StaffManagementSubAuthDataClass *subAuth in authDataClass.childrenArray)
    {
        if (subAuth.open)
        {
            isSelected = YES;
            break;
        }
    }
    return isSelected;
}

- (BOOL)whetherOpenAllAuth
{
    BOOL isOpenAll = YES;
    for (StaffManagementSubAuthDataClass *subAuth in authDataClass.childrenArray)
    {
        if (!subAuth.open)
        {
            isOpenAll = NO;
            break;
        }
    }
    return isOpenAll;
}

- (CGFloat)getPostAuthorityCellHeight:(StaffManagementAuthDataClass *)authInfo
{
    CGFloat cellHeight = 0;
    cellHeight = kStaffAuthorityCellHeight + [self addSubAuthCellToView:authInfo.childrenArray] + kPostAuthorityCellSpace;
    return cellHeight;
}

#pragma mark - StaffAuthorityCellDelegate

- (void)staffAuthorityCell:(StaffAuthorityCell *)cell withAuthStateHavedChange:(BOOL)openFlag withMainAuthorityFlag:(BOOL)isMain
{
    if ([self.delegate respondsToSelector:@selector(postAuthorityTableViewCell:withAuthStateHavedChange:)])
    {
        if (isMain)
        {
            authDataClass.open = openFlag;
            for (StaffManagementSubAuthDataClass *subAuth in authDataClass.childrenArray)
            {
                subAuth.open = openFlag;
            }
        }
        else
        {
            NSInteger index = cell.tag;
            NSInteger childrenCount = [authDataClass.childrenArray count];
            if (index < childrenCount)
            {
                StaffManagementSubAuthDataClass *subAuth = [authDataClass.childrenArray objectAtIndex:index];
                subAuth.open = openFlag;
                for (StaffManagementSubAuthDataClass *tempSubAuth in authDataClass.childrenArray)
                {
                    if (![tempSubAuth isEqual:subAuth])
                    {
                        for (NSString *indexStr in (subAuth.open?subAuth.checkedArray:subAuth.uncheckedArray))
                        {
                            if ([indexStr isEqualToString:tempSubAuth.indexStr])
                            {
                                tempSubAuth.open = subAuth.open;
                            }
                        }
                    }
                }
                authDataClass.open = [self whetherOpenAllAuth];
            }
        }
        [self.delegate postAuthorityTableViewCell:self withAuthStateHavedChange:authDataClass];
    }
}

@end
