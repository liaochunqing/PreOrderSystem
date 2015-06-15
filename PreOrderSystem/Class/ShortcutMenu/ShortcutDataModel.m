//
//  ShortcutDataModel.m
//  PreOrderSystem
//
//  Created by mac on 14-7-21.
//
//

#import "ShortcutDataModel.h"

@implementation ShortcutDataModel

- (id)initWithData:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        self.shortcutID = [dic objectForKey:@"key"];
        self.shortcutTag = [dic objectForKey:@"tag"];
        self.shortcutName = [dic objectForKey:@"name"];
        self.isSelected = [[dic objectForKey:@"isActive"]boolValue];
        if ([self.shortcutTag isEqualToString:@"tag_soldout"])
        {
            self.shortcutImg = @"soldout";
            self.shortcutImgGray = @"soldout_gray";
        }
        else if ([self.shortcutTag isEqualToString:@"tag_test"])
        {
            self.shortcutImg = @"menber";
            self.shortcutImgGray = @"member_gray";
        }

    
    }
    return self;
}
@end
