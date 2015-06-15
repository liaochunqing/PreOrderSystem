//
//  AddShortcutMenuViewController.m
//  PreOrderSystem
//
//  Created by mac on 14-7-19.
//
//

#import "AddShortcutMenuViewController.h"
#import "ShortcutDataModel.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "PSAlertView.h"
#import "JsonPicker.h"
@interface AddShortcutMenuViewController ()
{
    //获取/提交数据的小玩意
    JsonPicker *jsonPicker;;
}
@end

@implementation AddShortcutMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shotcutItemArr = [[NSMutableArray alloc]init];
    //数据源,暂时在MainViewController中获取.
    self.shotcutItemArr = [MainViewController getMianViewShareInstance].shortcutArr;
    self.shortcutTableView.delegate = self;
    self.shortcutTableView.dataSource = self;
    [self.shortcutTableView setEditing:YES animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - Network
/**
 *  保存快捷键设置
 */
- (void)saveHotKeySetting:(NSDictionary *)submitDic
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 0;
    jsonPicker.showActivityIndicator = NO;
    jsonPicker.loadedSuccessfulMessage = nil;
    //NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [jsonPicker postData:submitDic withBaseRequest:@"hotkey/saveList"];
}
#pragma mark - UIButton press

- (IBAction)cancelBtnPress:(id)sender;
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissEditDiscountViewController:)])
    {
        [self.delegate dismissEditDiscountViewController:self];
    }
}
- (IBAction)submitBtnPress:(id)sender
{
    NSMutableArray *submitArr = [[NSMutableArray alloc]init];
    for (ShortcutDataModel *shortData in _shotcutItemArr)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:shortData.shortcutID,@"key",[NSNumber numberWithBool:shortData.isSelected],@"isActive", nil];
        [submitArr addObject:dic];
    }
    NSDictionary *submitDic = [NSDictionary dictionaryWithObjectsAndKeys:submitArr,@"list", nil];
    
    [self saveHotKeySetting:submitDic];
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissEditDiscountViewController:)])
    {
        MainViewController *mainView = [MainViewController getMianViewShareInstance];
        [mainView dismissEditDiscountViewController:self];
    }
    [[MainViewController getMianViewShareInstance] showGrid];
}


#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.shotcutItemArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reUseID = @"ReuseIdentifier";
    AddShortcutMenuTableViewCell *cell = (AddShortcutMenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reUseID];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"AddShortcutMenuTableViewCell" owner:self options:nil]lastObject];
        cell.delegate = self;
    }
    if (self.shotcutItemArr.count > indexPath.row)
    {
        ShortcutDataModel *shortData = (ShortcutDataModel *)[self.shotcutItemArr objectAtIndex:indexPath.row];
        cell.shortCutImageView.image = [UIImage imageNamed:shortData.shortcutImgGray];
        [cell isSelected:shortData.isSelected];
        cell.shotCutNameLabel.text = shortData.shortcutName;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.shotcutItemArr.count > indexPath.row)
    {
        ShortcutDataModel *shortData = (ShortcutDataModel *)[self.shotcutItemArr objectAtIndex:indexPath.row];
        shortData.isSelected = !shortData.isSelected;
        
        [self.shortcutTableView reloadData];
    }
}

- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (self.shotcutItemArr.count >sourceIndexPath.row && self.shotcutItemArr.count > destinationIndexPath.row)
    {
        [self.shotcutItemArr exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        [tableView reloadData];
    }    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  UITableViewCellEditingStyleNone;
}

#pragma mark - AddShortcutMenuTableViewCellDelegate

- (void)AddShortcutMenuTableViewCell:(AddShortcutMenuTableViewCell *)cell didPressBtn:(UIButton *)btn
{
    NSIndexPath *indexPath = [self.shortcutTableView indexPathForCell:cell];
    if (self.shotcutItemArr.count > indexPath.row)
    {
        ShortcutDataModel *shortData = (ShortcutDataModel *)[self.shotcutItemArr objectAtIndex:indexPath.row];
        shortData.isSelected = !shortData.isSelected;
        //[self.shortcutTableView reloadData];
    }
}

#pragma mark JsonPickerDelegate
-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    int responseStatus = [[dict objectForKey:@"status"] intValue];
    if (picker.tag == 0)//获取所有可用快捷键.
    {
        switch (responseStatus)
        {
            case 200:
            {
                NSLog(@">>>submitSuccess!");
                break;
            }
            default:
            {
                NSString *str = [dict objectForKey:@"desc"];
                [PSAlertView showWithMessage:str];
                break;
            }
        }
    }
}


// JSON解释错误时返回
-(void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error
{
    
}

// 网络连接失败时返回（无网络的情况）
-(void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error
{
    
}

@end
