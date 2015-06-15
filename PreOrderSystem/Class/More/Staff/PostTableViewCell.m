//
//  PostTableViewCell.m
//  PreOrderSystem
//
//  Created by sWen on 13-5-15.
//
//

#import "PostTableViewCell.h"
#import "Constants.h"

@interface PostTableViewCell ()<UITextFieldDelegate>
{
    
}

@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UILabel *postLabel;
@property (nonatomic, weak) IBOutlet UIButton *modifyBtn;
@property (nonatomic, weak) IBOutlet UIButton *deleteBtn;

- (IBAction)modifyBtnClicked:(id)sender;
- (IBAction)deleteBtnClicked:(id)sender;

@end

@implementation PostTableViewCell

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
}

- (void)updatePostTableViewCell:(NSString *)postStr withSelected:(BOOL)flag
{
    self.backgroundColor = [UIColor clearColor];
    self.postLabel.text = postStr;
    if (flag)
    {
        self.postLabel.textColor = [UIColor colorWithRed:72.0/255.0 green:169.0/255.0 blue:203.0/255.0 alpha:1.0];
        self.bgImageView.image = LoadImageWithPNGType(@"more_postSelectedBg");
        [self.modifyBtn setBackgroundImage:LoadImageWithPNGType(@"more_postModifyHighlight") forState:UIControlStateNormal];
        [self.deleteBtn setBackgroundImage:LoadImageWithPNGType(@"more_postDelete") forState:UIControlStateNormal];
    }
    else
    {
        self.postLabel.textColor = [UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1.0];
        self.bgImageView.image = nil;
        [self.modifyBtn setBackgroundImage:nil forState:UIControlStateNormal];
        [self.deleteBtn setBackgroundImage:nil forState:UIControlStateNormal];
        
    }
    
}

- (IBAction)modifyBtnClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(postTableViewCell:withModifyPostName:)])
    {
        [self.delegate postTableViewCell:self withModifyPostName:self.postLabel.text];
    }
}

- (IBAction)deleteBtnClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(postTableViewCell:withDeleteIndex:)])
    {
        [self.delegate postTableViewCell:self withDeleteIndex:self.tag];
    }
}

@end
