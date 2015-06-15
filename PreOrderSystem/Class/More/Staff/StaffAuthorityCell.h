//
//  StaffAuthorityCell.h
//  PreOrderSystem
//
//  Created by SWen on 14-3-8.
//
//

#import <UIKit/UIKit.h>

#define kStaffAuthorityCellHeight 30
#define kStaffAuthorityCellMinWidth 110
#define kNameLabelDefaultWidth 70
#define kNameLabelFontSize 16

typedef enum
{
    kStaffAuthorityCellSmallType = 1000,
    kStaffAuthorityCellMiddleType,
    kStaffAuthorityCellBigType
}kStaffAuthorityCellFrameType;

@class StaffAuthorityCell;
@protocol StaffAuthorityCellDelegate <NSObject>

- (void)staffAuthorityCell:(StaffAuthorityCell *)cell withAuthStateHavedChange:(BOOL)openFlag withMainAuthorityFlag:(BOOL)isTrue;

@end

@interface StaffAuthorityCell : UIView

@property (nonatomic, weak) id <StaffAuthorityCellDelegate> delegate;
- (id)initWithFrameType:(kStaffAuthorityCellFrameType)type withMainAuthorityFlag:(BOOL)isTrue withAuthName:(NSString *)authName withAuthOpenFlag:(BOOL)authFlag withSubAuthOpenFlag:(BOOL)subFlag;

@end
