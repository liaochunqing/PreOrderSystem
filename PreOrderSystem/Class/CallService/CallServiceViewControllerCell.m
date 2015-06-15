//
//  CallServiceViewControllerCell.m
//  PreOrderSystem
//
//  Created by sWen on 12-10-29.
//
//

#import "CallServiceViewControllerCell.h"
#import "NsstringAddOn.h"
#import "UILabel+AdjustFontSize.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "Constants.h"

#define BEGIN_FLAG @"["
#define END_FLAG @"]"
#define KFacialSizeWidth  60 
#define KFacialSizeHeight 60  
#define MAX_WIDTH 450

@implementation CallServiceViewControllerCell

@synthesize seatLabel;
@synthesize contentImageView;
@synthesize timeLabel;
@synthesize handleImageView;
@synthesize bgImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIView *)updateWithData:(NSDictionary *)dict
{
    //NSString *chatNString = @"发顺丰很少见的房价[加台]快速的回复会计师的恢[餐牌][抹台]复[纸巾]开[加水][加冰][叉子][服务员][开台]机的首付款的回复发货时看到[结账][加台][加台][加台][加台]和福克斯的恢复开机的首付款的[牙签][筷子][加碗]经适房十分好看是[加台][加冰][结账]对方肯定会发生的海口市的恢复快接电话[加杯][加冰][加冰][勺子][加冰][结账][加冰][加冰][结账][加冰][加位][加冰][结账][餐刀][加冰]疯狂的身份开始的回复客户的法师打发";

    
    self.backgroundColor = [UIColor clearColor];
     
    //标题
    self.seatLabel.text = [dict objectForKey:@"sortName"];
    [self.seatLabel adjustLabelHeight];
    //时间
    NSString *callDateStr = [dict objectForKey:@"sendTime"];
    NSDate *callDate = [callDateStr stringToNSDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.timeLabel.text = [NSString dateToNSString:callDate withFormat:@"HH:mm"];
    //状态
    NSInteger state = [[dict objectForKey:@"status"]integerValue];
    switch (state)
    {
        case 1:
        {
            self.handleImageView.hidden = YES;
            break;
        }
        case 2:
        {
            self.handleImageView.hidden = NO;
            break;
        }
        default:
        {
            self.handleImageView.hidden = YES;
            break;
        }
    }
    BOOL haveImage = NO;
    NSString *chatNString = kLoc([dict objectForKey:@"content"]);
    if (nil == pictureNameArray)
    {
        NSString *pathStr = @"callServicePic";
        //繁体
        if (![kCurrentLanguageOfDevice isEqualToString:kChineseFamiliarStyle])
        {
            pathStr = @"callServicePic_Traditional";
        }
        pictureNameArray = [[NSMutableArray alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:pathStr ofType:@"plist"]];
    }
    //图片名称替换
    for (int i = 0; i <[pictureNameArray count]; i++)
    {
        //字符串替换，如果chatNString中包含有tempString，则替换
        NSString *tempString = [NSString stringWithFormat:@"[%@]",[pictureNameArray objectAtIndex:i]];
        
        NSRange iconRange = [chatNString rangeOfString:tempString];
        if (iconRange.location != NSNotFound)
        {
            NSString *suffixStr = nil;
            if (2 == state)
            {
                suffixStr = @"Handle";
            }
            else
            {
                suffixStr = @"Normal";
            }
            NSString *replacedString = [chatNString stringByReplacingOccurrencesOfString: tempString withString:[NSString stringWithFormat:@"[ic_icon_%d%@]", i, suffixStr]];
            chatNString = replacedString;
            haveImage = YES;
        }
    }
    //内容视图
    UIView *charView = [self assembleMessageAtIndex:chatNString haveImage:haveImage];
    CGRect frame = contentImageView.frame;
    frame.size.height = charView.frame.size.height;
    contentImageView.frame = frame;
    [self.contentImageView addSubview:charView];
    //背景
    frame = bgImageView.frame;
    frame.size.height = charView.frame.size.height + 75;
    bgImageView.frame = frame;
    UIImage *bgImage = [UIImage imageFromMainBundleFile:@"callService_cellBg.png"];
    bgImageView.image = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 2, 0)];
    
    return charView;
}

//图文混排
-(void)getImageRange:(NSString*)message transformateToView:(NSMutableArray*)array
{
    //判断左右耳朵的个数是否相等
    int rangeCount = 0;
    int range1Count = 0;
    int length = [message length];
    for (int i = 0; i < length; i ++)
    {
        NSRange range=[[message substringWithRange:NSMakeRange(i, 1)] rangeOfString: BEGIN_FLAG];
        NSRange range1=[[message substringWithRange:NSMakeRange(i, 1)] rangeOfString: END_FLAG];
        if (range.location != NSNotFound)
        {
            rangeCount ++;
        }
        if (range1.location != NSNotFound)
        {
            range1Count ++;
        }
    }
    
    NSRange range=[message rangeOfString: BEGIN_FLAG];
    NSRange range1=[message rangeOfString: END_FLAG];
    //判断当前字符串是否还有表情的标志。
    if (range.length>0 && range1.length>0)
    {
        if (range.location > 0)
        {
            if (rangeCount <= range1Count)
            {
                [array addObject:[message substringToIndex:range.location]];
                [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location +1-range.location)]];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str transformateToView:array];
            }
            else
            {
                [array addObject:[message substringToIndex:range.location+1]];
                NSString *str=[message substringFromIndex:range.location+1];
                [self getImageRange:str transformateToView:array];
            }
        }
        else
        {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""])
            {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str transformateToView:array];
            }
            else
            {
                return;
            }
        }
        
    }
    else if (message != nil)
    {
        [array addObject:message];
    }
}

//少返回了一行高度，tableview要多加一行的高度
-(UIView *)assembleMessageAtIndex:(NSString *)message haveImage:(BOOL)haveImage
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self getImageRange:message transformateToView:array];
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    NSArray *data = array;
    UIFont *fon = [UIFont boldSystemFontOfSize:20.0f];
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat X = 0;
    CGFloat Y = 0;
    CGFloat originX = 0;
    if (data)
    {
        for (int i=0;i < [data count];i++)
        {
            NSString *str=[data objectAtIndex:i];
            if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG])
            {
                if (upX >= MAX_WIDTH)
                {
                    upY = upY + 50;//KFacialSizeHeight;
                    upX = 0;
                    X = MAX_WIDTH;
                    Y = upY;
                }
                
                NSString *imageName=[str substringWithRange:NSMakeRange(1, str.length - 2)];
                UIImage *tempImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:imageName ofType:@"png"]];
                if (tempImage)
                {
                    UIImageView *img=[[UIImageView alloc]initWithImage:tempImage];
                    img.frame = CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight);
                    [returnView addSubview:img];
                    upX=KFacialSizeWidth+upX;
                    if (X < MAX_WIDTH)
                    {
                        X = upX;
                    }
                }
                else
                {
                    for (int j = 0; j < [str length]; j++)
                    {
                        NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                        //文字的行距
                        CGFloat textSpaceOfHeight = haveImage?50:25;
                        if (upX >= MAX_WIDTH)
                        {
                            upY = upY + textSpaceOfHeight;// KFacialSizeHeight;
                            upX = 0;
                            X = MAX_WIDTH;
                            Y =upY;
                        }
                        CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(MAX_WIDTH, 30)];
                        if (0 == j)
                        {
                            originX = 20;
                        }
                        UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX + originX, upY+20, size.width, size.height)];
                        la.font = fon;
                        la.textAlignment = UITextAlignmentLeft;
                        la.textColor = [UIColor blackColor];
                        la.text = temp;
                        la.backgroundColor = [UIColor clearColor];
                        [returnView addSubview:la];
                        upX=upX+size.width;
                        if (X<MAX_WIDTH)
                        {
                            X = upX;
                        }
                    }
                }
            }
            else
            {
                for (int j = 0; j < [str length]; j++)
                {
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                    //文字的行距
                    CGFloat textSpaceOfHeight = haveImage?50:25;
                    if (upX >= MAX_WIDTH)
                    {
                        upY = upY + textSpaceOfHeight;// KFacialSizeHeight;
                        upX = 0;
                        X = MAX_WIDTH;
                        Y =upY;
                    }
                    CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(MAX_WIDTH, 30)];
                    if (0 == j)
                    {
                        originX = 20;
                    }
                    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX + originX, upY+20,size.width,size.height)];
                    la.font = fon;
                    la.textAlignment = UITextAlignmentLeft;
                    la.textColor = [UIColor blackColor];
                    la.text = temp;
                    la.backgroundColor = [UIColor clearColor];
                    [returnView addSubview:la];
                    upX=upX+size.width;
                    if (X<MAX_WIDTH)
                    {
                        X = upX;
                    }
                }
            }
        }
    }
    returnView.frame = CGRectMake(0.0f,0.0f, X, Y);
    return returnView;
}


@end
