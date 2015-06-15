//
//  PromotionMainViewTableViewCell.m
//  PreOrderSystem
//
//  Created by SWen on 14-6-30.
//
//

#import "PromotionMainViewTableViewCell.h"
#import "JsonPicker.h"
#import "PSAlertView.h"

@implementation PromotionMainViewTableViewCell 
{
    JsonPicker *_jsonPicker;
    NSString *key;
}
- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteBtnClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(PromotionMainViewTableViewCell:didDeletedAtIndex:)])
    {
        [self.delegate PromotionMainViewTableViewCell:self didDeletedAtIndex:self.tag];
    }
}

- (IBAction)switchAction:(UISwitch *)sender
{
//    NSString *string = sender.on?kLoc(@"sure_to_open_favourable_activity"):kLoc(@"sure_to_shutdown_favourable_activity");
    
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:nil
                                                       message:kLoc(@"是否进行当前操作")
                                                      delegate:self
                                             cancelButtonTitle:kLoc(@"cancel")
                                             otherButtonTitles:kLoc(@"confirm"), nil];
    [alerView show];
    
}

//weekday的index转换为文字（如：，1对应于周一，6对应于周六,7对应于周日...）
-(NSString*)weekdayText:(NSArray*)week
{
    NSMutableString *text = [[NSMutableString alloc] init];
    if (0 == week.count)
    {
        return text;
    }
    
    NSArray *array = [NSArray arrayWithObjects:kLoc(@"one"), kLoc(@"two"), kLoc(@"three"), kLoc(@"four"), kLoc(@"five"), kLoc(@"six"), kLoc(@"seven"), nil];
    
    for (int i=0; i<week.count; i++)
    {
        NSString *weekString = week[i];
        if (weekString.length > 0)
        {
            int index = [weekString integerValue] - 1;
            if (index >= 0 && index <7)
            {
                [text appendString:array[index]];
                if (i < week.count - 1)
                {
                    [text appendString:@"、"];
                }
            }
            
        }
    }
    
    return text;
}

- (void)updateData:(NSDictionary *)dict status:(BOOL)isSelected;
{
    if (dict == nil)
    {
        return;
    }
    
    self.deleteButton.hidden = YES;
    self.detailImageView.hidden = YES;
    key = [dict objectForKey:@"key"];
    self.swicthView.on = [[dict objectForKey:@"isActive"] intValue];
    self.identifyLabel.text = [dict objectForKey:@"number"];
    self.nameLabel.text = [dict objectForKey:@"name"];
    
    NSString *weekly = [self weekdayText:[dict objectForKey:@"weekly"]] ;
    NSString *fromDate = [dict objectForKey:@"fromDate"];
    
    self.dateLabel.text = [NSString stringWithFormat:@"%@ 到 %@", [dict objectForKey:@"fromDate"], [dict objectForKey:@"toDate"]];
    self.weekLabel.text = [NSString stringWithFormat:@"%@",weekly];
    
    if (weekly.length == 0)
    {
        self.weekLabel.hidden = YES;
        
        CGRect frame = self.dateLabel.frame;
        frame.origin.y = (self.contentView.frame.size.height - frame.size.height) / 2;
        self.dateLabel.frame = frame;
        
    }
    
    if (fromDate.length == 0)
    {
        self.dateLabel.hidden = YES;
        CGRect frame = self.weekLabel.frame;
        frame.origin.y = (self.contentView.frame.size.height - frame.size.height) / 2;
        self.weekLabel.frame = frame;
    }

}
#pragma mark - network

/*  上传开关状态*/
- (void)uploadswicth:(BOOL)animated
{
    if (!_jsonPicker)
    {
        _jsonPicker = [[JsonPicker alloc] init];
    }
    
    _jsonPicker.delegate = self;
    _jsonPicker.tag = 1;
    _jsonPicker.showActivityIndicator = animated;
    _jsonPicker.isShowUpdateAlert = YES;
    
    if (animated)
    {
        _jsonPicker.loadingMessage = kLoc(@"submitting_data_please_wait");
    }
    else
    {
        _jsonPicker.loadingMessage = nil;
    }
    
    _jsonPicker.loadedSuccessfulMessage = nil;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    // 开关状态
    int i = self.swicthView.on?1:0;
    [dict setObject:[NSNumber numberWithInt:i] forKey:@"switch"];
    
    // key
    [dict setObject:key forKey:@"key"];
    NSArray *array = [[NSMutableArray alloc] initWithObjects:dict, nil];
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:array,@"item", nil];
    [_jsonPicker postData:postData withBaseRequest:@"CookbookPromote/switchPromoteActivityItem"];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0://取消
        {
            self.swicthView.on = !self.swicthView.on;
            break;
        }
        case 1://确定
        {
            [self uploadswicth:YES];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - JsonPickerDelegate
-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    if (picker.tag==1)
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        
        switch (responseStatus)
        {
            case 200:
            {
                [PSAlertView showWithMessage:kLoc(@"success")];
                break;
            }
                
            default:
            {
                [PSAlertView showWithMessage:[dict objectForKey:@"desc"]];
                break;
            }
        }
    }
}


// JSON解释错误时返回
-(void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error{
}


// 网络连接失败时返回（无网络的情况）
-(void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error{
}


@end
