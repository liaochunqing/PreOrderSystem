//
//  DtPreOrderDishViewController.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-19.
//
//

#import "DtPreOrderDishViewController.h"
#import "DtPreOrderDishTableViewCell.h"
#import "DtMenuDataClass.h"
#import "QueueArrangDataClass.h"
#import "Constants.h"
#import "NsstringAddOn.h"
#import "DtPreOrderDishTotalPriceTableViewCell.h"
#import "DtPreOrderDishQueueInfoTableViewCell.h"
#import "JsonPicker.h"
#import "PSAlertView.h"

@interface DtPreOrderDishViewController ()<UITableViewDataSource, UITableViewDelegate, DtPreOrderDishQueueInfoTableViewCellDelegate, JsonPickerDelegate>
{
    JsonPicker *jsonPicker;
}

@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITableView *arrangTableView;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *trueButton;

- (IBAction)cancelBtnClicked:(UIButton *)sender;
- (IBAction)trueBtnClicked:(UIButton *)sender;

@end

@implementation DtPreOrderDishViewController

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
    
    [self addPictureToView];
    [self addLocalizedString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addLocalizedString
{
    self.titleLabel.text = kLoc(@"prepare_order_dish_to_table");
}

- (void)addPictureToView
{
    self.bgImageView.image = LoadImageWithPNGType(@"dt_menuPreOrderBg");
    [self.cancelButton setBackgroundImage:LoadImageWithPNGType(@"dt_cancleBtn") forState:UIControlStateNormal];
    [self.trueButton setBackgroundImage:LoadImageWithPNGType(@"dt_trueBtn") forState:UIControlStateNormal];
}

/**
 * 获取DtQueueDataClass
 */
- (DtQueueDataClass *)getDtQueueDataClass:(NSInteger)index
{
    DtQueueDataClass *dtQueueClass = nil;
    if (index < [self.queueListArray count])
    {
        dtQueueClass = [self.queueListArray objectAtIndex:index];
    }
    return dtQueueClass;
}

#pragma mark - UIButton Clicked

- (IBAction)cancelBtnClicked:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(dismissDtPreOrderDishViewController)])
    {
        [self.delegate dismissDtPreOrderDishViewController];
    }
}

- (IBAction)trueBtnClicked:(UIButton *)sender
{
    [self commitDtPreOrderMenuData:YES];
}

#pragma mark - network

/*  特别需要注意设置这个属性 jsonPicker.isShowUpdateAlert   */

- (void)commitDtPreOrderMenuData:(BOOL)animated
{
    DtQueueDataClass *selectedQueueClass = nil;
    for (DtQueueDataClass *tempQueue in self.queueListArray)
    {
        if (tempQueue.isSelected)
        {
            selectedQueueClass = tempQueue;
            break;
        }
    }
    if (!selectedQueueClass)
    {
        [PSAlertView showWithMessage:kLoc(@"please_selected_prepare_dish")];
        return;
    }
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    NSString *networkPathStr = @"diningtable/qorder";
    [postData setObject:[NSNumber numberWithInt:self.housingId] forKey:@"tableId"];
    [postData setObject:selectedQueueClass.queueIdStr forKey:@"queueId"];
    [postData setObject:selectedQueueClass.originDishesArray forKey:@"dishes"];
    
    if (!jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = kJsonPickerFirstTag;
    jsonPicker.showActivityIndicator = animated;
    jsonPicker.isShowUpdateAlert = YES;
    jsonPicker.loadingMessage = kLoc(@"saving_data_please_wait");
    jsonPicker.loadedSuccessfulMessage = nil;
    [jsonPicker postData:postData withBaseRequest:networkPathStr];
}

#pragma mark - UITableViewCell

- (DtPreOrderDishQueueInfoTableViewCell *)getDtPreOrderDishQueueInfoTableViewCell:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPth
{
    static NSString *cellIdentifier = kDtPreOrderDishQueueInfoCellReuseIdentifier;
    DtPreOrderDishQueueInfoTableViewCell *cell = (DtPreOrderDishQueueInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"DtPreOrderDishQueueInfoTableViewCell" owner:self options:nil]lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    cell.tag = indexPth.section;
    return cell;
}

- (DtPreOrderDishTableViewCell *)getDtPreOrderDishTableViewCell:(UITableView *)tableView
{
    DtPreOrderDishTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"DtPreOrderDishTableViewCell" owner:self options:nil]lastObject];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (DtPreOrderDishTotalPriceTableViewCell *)getDtPreOrderDishTotalPriceTableViewCell:(UITableView *)tableView
{
    DtPreOrderDishTotalPriceTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"DtPreOrderDishTotalPriceTableViewCell" owner:self options:nil]lastObject];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger indexSection = indexPath.section;
    NSInteger indexRow = indexPath.row;
    DtQueueDataClass *dtQueueClass = [self getDtQueueDataClass:indexSection];
    
    if (dtQueueClass.isUnfold)
    {
        if (kTableViewFirstRow == indexRow)
        {
            DtPreOrderDishQueueInfoTableViewCell *cell = [self getDtPreOrderDishQueueInfoTableViewCell:tableView withIndexPath:indexPath];
            [cell updateDtPreOrderDishQueueInfoCell:dtQueueClass];
            
            return cell;
        }
        else if (indexRow == (1 + [dtQueueClass.dishesArray count]))
        {
            DtPreOrderDishTotalPriceTableViewCell *cell = [self getDtPreOrderDishTotalPriceTableViewCell:tableView];
            CGFloat totalPrice = 0;
            for (QueueArrangDishDataClass *dishClass in dtQueueClass.dishesArray)
            {
                totalPrice = totalPrice + [dishClass.currentPriceStr floatValue] * dishClass.quantity;
            }
            [cell updateQueueLookDishTotalPriceCell:totalPrice withFinalRemark:dtQueueClass.remark];
            
            return cell;
        }
        else
        {
            DtPreOrderDishTableViewCell *cell = [self getDtPreOrderDishTableViewCell:tableView];
            cell.tag = indexRow - 1;
            [cell updateQueueLookDishCell:[dtQueueClass.dishesArray objectAtIndex:cell.tag]];
            
            return cell;
        }
    }
    else
    {
        DtPreOrderDishQueueInfoTableViewCell *cell = [self getDtPreOrderDishQueueInfoTableViewCell:tableView withIndexPath:indexPath];
        [cell updateDtPreOrderDishQueueInfoCell:dtQueueClass];
        
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.queueListArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DtQueueDataClass *dtQueueClass = [self getDtQueueDataClass:section];
    if (dtQueueClass.isUnfold)
    {
         /*房台信息 + 菜的数量 + 总价/总备注*/
        return (1 + [dtQueueClass.dishesArray count] + 1);
    }
    else
    {
         /*房台信息*/
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger indexSection = indexPath.section;
    NSInteger indexRow = indexPath.row;
    DtQueueDataClass *dtQueueClass = [self getDtQueueDataClass:indexSection];
    if (dtQueueClass.isUnfold)
    {
        if (kTableViewFirstRow == indexRow)
        {
            return 50;
        }
        else if (indexRow == (1 + [dtQueueClass.dishesArray count]))
        {
            DtPreOrderDishTotalPriceTableViewCell *cell = [self getDtPreOrderDishTotalPriceTableViewCell:tableView];
            return [cell getDtPreOrderDishTotalPriceTableViewCellHeight:dtQueueClass.remark];
        }
        else
        {
            DtPreOrderDishTableViewCell *cell = [self getDtPreOrderDishTableViewCell:tableView];
            return [cell getDtPreOrderDishTableViewCellHeight:[dtQueueClass.dishesArray objectAtIndex:(indexRow -1)]];
        }
    }
    else
    {
        return 50;
    }
}

#pragma mark - DtPreOrderDishQueueInfoTableViewCellDelegate

- (void)dtPreOrderDishQueueInfoTableViewCell:(DtPreOrderDishQueueInfoTableViewCell *)cell wihtNewDtQueueData:(DtQueueDataClass *)queueClass
{
    NSInteger i = 0;
    for (DtQueueDataClass *tempQueeu in self.queueListArray)
    {
        if (i != cell.tag)
        {
            tempQueeu.isSelected = NO;
        }
        i++;
    }
    [self.arrangTableView reloadData];
}

- (void)dtPreOrderDishQueueInfoTableViewCell:(DtPreOrderDishQueueInfoTableViewCell *)cell wihtDeleteIndex:(NSInteger )index
{
    if (index < [self.queueListArray count])
    {
        [self.queueListArray objectAtIndex:index];
        [self.arrangTableView reloadData];
    }
}

#pragma mark - JsonPickerDelegate

- (void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
#ifdef DEBUG
    NSLog(@"===%@,dict:%@===",self.class,dict);
#endif
    
    if (kJsonPickerFirstTag == picker.tag)
    {
        SuperDataClass *dataClass = [[SuperDataClass alloc] initWithData:dict];
        
        NSString *alertMsgStr = [NSString getStrWithoutWhitespace:dataClass.alertMsg];
        switch (dataClass.responseStatus)
        {
            case kFirstResponseStatus:
            {
                if (![NSString strIsEmpty:alertMsgStr])
                {
                    [PSAlertView showWithMessage:alertMsgStr];
                }
                [self performSelector:@selector(cancelBtnClicked:) withObject:nil afterDelay:1.0];
                break;
            }
            default:
            {
                if (![NSString strIsEmpty:alertMsgStr])
                {
                    [PSAlertView showWithMessage:alertMsgStr];
                }
                break;
            }
        }
    }
}

// JSON解释错误时返回
- (void)JsonPicker:(JsonPicker *)picker didFailWithError:(NSError *)error
{

}

// 网络连接失败时返回（无网络的情况）
- (void)JsonPicker:(JsonPicker *)picker didFailWithNetwork:(NSError *)error
{
    
}

@end
