//
//  PrintManagementViewController.m
//  PreOrderSystem
//
//  Created by AaronKwok on 13-4-8.
//
//

#import "PrintManagementViewController.h"
#import "PSAlertView.h"
#import "Constants.h"
#import "SocketPrinterFunctions.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "PrinterDataClass.h"
#import "NsstringAddOn.h"
#import "PrintManagementTableViewCell.h"
#import "PrintSearchingViewController.h"
#import "MainViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "PrintSearchingTableViewCell.h"
#import "StarIO/SMPort.h"


@interface PrintManagementViewController ()<UITableViewDataSource, UITableViewDelegate, PrintManagementTableViewCellDelegate,PrintSearchingViewControllerDelegate>
{
    NSArray *printerListArray;
}

@property (nonatomic, weak) IBOutlet UITableView *printTableView;
@property (nonatomic, weak) IBOutlet UIButton *addPrinterButton;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *searchPrinterBtn;

- (IBAction)searchPrinterBtnClicked:(UIButton *)sender;
- (IBAction)saveBtnClicked:(UIButton*)sender;
- (IBAction)addPrinterBtnClicked:(UIButton *)sender;

@end

@implementation PrintManagementViewController


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
    
    [self addLocalizedString];
    [self addPictureToView];
    [self addNotifications];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self removeNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setObject:kLoc(@"more_printer_management") forKey:@"title"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateNavTitle object:nil userInfo:info];
    
    [self updatePrinterManagmentView:kForeverPrinterDataKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ((kSystemVersionOfCurrentDevice >= 6.0) && [self isViewLoaded] && ![self.view window])
    {
        [self viewDidUnload];
        [self setView:nil];
    }
}

- (void)dealloc
{
    [self removeNotification];
#ifdef DEBUG
    NSLog(@"===PrintManagementViewController,dealloc===");
#endif
}

- (void)addPictureToView
{
    [self.saveButton setBackgroundImage:[UIImage imageFromMainBundleFile:@"more_longButton.png"] forState:UIControlStateNormal];
}

- (void)addLocalizedString
{
    [self.addPrinterButton setTitle:kLoc(@"add_printer") forState:UIControlStateNormal];
    [self.searchPrinterBtn setTitle:kLoc(@"search_printer") forState:UIControlStateNormal];
    [self.saveButton setTitle:kLoc(@"save") forState:UIControlStateNormal];
}

- (void)updatePrinterManagmentView:(NSString *)key
{
    printerListArray = [PrinterDataClass getPrinterData:key];
    if ([key isEqualToString:kForeverPrinterDataKey])
    {
        if ([printerListArray count])
        {
            [PrinterDataClass saveTemporaryPrinterData:printerListArray];
        }
        else
        {
            [PrinterDataClass saveTemporaryPrinterData:[NSArray array]];
            [self addPrinterBtnClicked:nil];
        }
    }
    [self.printTableView reloadData];
}

#pragma mark - button clicked

- (IBAction)searchPrinterBtnClicked:(UIButton *)sender
{
    PrintSearchingViewController *vc = [[PrintSearchingViewController alloc] initWithNibName:@"PrintSearchingViewController" bundle:nil];
    vc.delegate = self;
    vc.defaultSearchingPrinterArray = printerListArray;
    
    [[MainViewController getMianViewShareInstance] presentPopupViewController:vc animationType:MJPopupViewAnimationSlideBottomBottom];
    // 缩放视图
    scaleView(vc.view);
}

-(IBAction)saveBtnClicked:(UIButton*)sender
{
    int tempCount = [printerListArray count];
    if (tempCount > 0) {
        NSMutableString *alertStr = [NSMutableString string];
        for (int i = 0; i < tempCount; i++) {
            PrintManagementTableViewCell *tempcell = (PrintManagementTableViewCell *)[self.printTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [tempcell hidePrintManagementCellKeyBoard];
            
            PrinterDataClass *tempClass = [[PrinterDataClass alloc] initWithPrinterData:[printerListArray objectAtIndex:i]];
            
            NSString *nameStr = tempClass.printerName;
            
            if ([NSString strIsEmpty:nameStr]) {
                [PSAlertView showWithMessage:kLoc(@"printer_name_can_not_be_empty")];
                return;
            }
            
            NSString *ipStr = tempClass.printerIPStr;
            if ([NSString strIsEmpty:ipStr]) {
                [PSAlertView showWithMessage:kLoc(@"printer_ip_can_not_be_empty")];
                return;
            } else {
                if (![NSString isValidateIPAddress:ipStr]) {
                    [alertStr appendString:nameStr];
                    [alertStr appendString:@"、"];
                }
            }
        }
        
        if (![NSString strIsEmpty:alertStr]) {
            NSString *finalAlertStr = [alertStr substringToIndex:([alertStr length] - 1)];
            [PSAlertView showWithMessage:[NSString stringWithFormat:@"%@%@", finalAlertStr, kLoc(@"invalid_printer_ip_format")]];
            return;
        } else {
            // 适用范围检测
            NSMutableString *namesString = [NSMutableString string];
            for (NSDictionary *tempData in printerListArray) {
                NSString *name = [tempData objectForKey:@"printerName"];
                BOOL isOrderdish = [[tempData objectForKey:@"isOrderdishBtnCheck"] boolValue];
                BOOL isKitchenBtn = [[tempData objectForKey:@"isKitchenBtnCheck"] boolValue];
                BOOL isTakeout = [[tempData objectForKey:@"isTakeoutBtnCheck"] boolValue];
                BOOL isQueue = [[tempData objectForKey:@"isQueueBtnCheck"] boolValue];
                if (!isOrderdish && !isKitchenBtn && !isTakeout && !isQueue) {
                    if (namesString.length == 0) {
                        [namesString appendString:name];
                    } else {
                        [namesString appendFormat:@"、%@", name];
                    }
                }
            }
            
            if (namesString.length > 0) {
                
                NSString *msg = [NSString stringWithFormat:@"“%@：”%@",kLoc(@"applicable"),kLoc(@"can_not_be_empty")];
                
                [PSAlertView showWithMessage:[NSString stringWithFormat:@"%@%@: %@",
                                              kLoc(@"printer"),
                                              namesString,
                                              msg]];
                
                return;
            }
        }
    }
    
    [PrinterDataClass saveForeverPrinterData:printerListArray];
    [PSAlertView showWithMessage:kLoc(@"save_succeed")];
}

- (IBAction)addPrinterBtnClicked:(UIButton *)sender
{
    if ([PrinterDataClass allowAddNewPrinter])
    {
        [PrinterDataClass addNewPrinterData];
        [self updatePrinterManagmentView:kTemporaryPrinterDataKey];
    }
}

#pragma mark Notifications

- (void)addNotifications
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification*)notify
{
    NSDictionary *userInfo = [notify userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    keyboardRect = [self.view convertRect:keyboardRect fromView:window];
    CGRect intersectionOfKeyboardRectAndWindowRect = CGRectIntersection(window.frame, keyboardRect);
    CGFloat bottomInset = intersectionOfKeyboardRectAndWindowRect.size.height;
    self.printTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset,0.0f);
    self.printTableView.scrollEnabled = NO;
    
    [UIView commitAnimations];
    
#ifdef DEBUG
    NSLog(@"===%@,keyboardWillShow:%@",self.class,NSStringFromCGRect(keyboardRect));
#endif
}

- (void)keyboardWillHide:(NSNotification*)notify
{
    NSDictionary *userInfo = [notify userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    self.printTableView.scrollEnabled = YES;
    self.printTableView.contentInset = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
}

#pragma mark - UITableViewController datasource & delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = kPrintTableViewCellReuseIdentifier;
    PrintManagementTableViewCell *cell = (PrintManagementTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PrintManagementTableViewCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    int indexRow = indexPath.row;
    cell.delegate = self;
    cell.tag = indexRow;
    [cell updatePrinterCell:[printerListArray objectAtIndex:indexRow]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return printerListArray.count ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return 210;
    return 246;
}

#pragma mark - PrintManagementTableViewCellDelegate
- (void)printManagementTableViewCell:(PrintManagementTableViewCell *)cell
{
    [PrinterDataClass modifyPrinterDataWithCell:cell withIndex:cell.tag];
    [self updatePrinterManagmentView:kTemporaryPrinterDataKey];
}

- (void)printManagementTableViewCell:(PrintManagementTableViewCell *)cell withPrinterName:(NSString *)nameStr
{
    /*判断打印机名称是否重复*/
    BOOL isRepeat = NO;
    NSInteger tempIndex = 0;
    NSInteger printerIndex = cell.tag;
    for (NSDictionary *printerDict in printerListArray)
    {
        if (tempIndex != printerIndex)
        {
            NSString *printerName = [printerDict objectForKey:kPrinterName];
            if ([printerName isEqualToString:nameStr])
            {
                isRepeat = YES;
                break;
            }
        }
        tempIndex++;
    }
    if (isRepeat)
    {
        [PSAlertView showWithMessage:kLoc(@"duplicated_printer_name")];
        [self.printTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
    }
    else
    {
        [PrinterDataClass modifyPrinterDataWithName:nameStr withIndex:printerIndex];
        [self updatePrinterManagmentView:kTemporaryPrinterDataKey];
    }
}

- (void)printManagementTableViewCell:(PrintManagementTableViewCell *)cell withPrinterIP:(NSString *)ipStr
{
    /*判断打印机名称是否重复*/
    BOOL isRepeat = NO;
    NSInteger tempIndex = 0;
    NSInteger printerIndex = cell.tag;
    for (NSDictionary *printerDict in printerListArray)
    {
        if (tempIndex != printerIndex)
        {
            NSString *printerIp = [printerDict objectForKey:kPrinterIP];
            if ([printerIp isEqualToString:ipStr])
            {
                isRepeat = YES;
                break;
            }
        }
        tempIndex++;
    }
    if (isRepeat)
    {
        [PSAlertView showWithMessage:kLoc(@"duplicated_printer_ip")];
        [self.printTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
    }
    else
    {
        [PrinterDataClass modifyPrinterDataWithPrinterIPStr:ipStr withIndex:cell.tag];
        [self updatePrinterManagmentView:kTemporaryPrinterDataKey];
    }
}

/*判断star打印机名称是否重复*/
- (BOOL)isStarPrintermacAddressRepeat:(NSString *)macAddress
{
    for (NSDictionary *printerDict in printerListArray)
    {
        NSString *printerIp = [printerDict objectForKey:kPrinterMac];
        if ([printerIp isEqualToString:macAddress])
        {
//            [PSAlertView showWithMessage:kLoc(@"打印机mac地址不能重复", nil)];
            return YES;
        }
    }
    
    return NO;

}

- (void)printManagementTableViewCell:(PrintManagementTableViewCell *)cell withPrinterType:(NSInteger)type
{
    [PrinterDataClass modifyPrinterDataWithPrinterType:type withIndex:cell.tag];
    [self updatePrinterManagmentView:kTemporaryPrinterDataKey];
}

- (void)printManagementTableViewCell:(PrintManagementTableViewCell *)cell withDeleteIndex:(NSInteger)deleteIndex
{
    [PrinterDataClass deletePrinterData:deleteIndex];
    [self updatePrinterManagmentView:kTemporaryPrinterDataKey];
}


#pragma mark - PrintSearchingViewControllerDelegate

- (void)PrintSearchingViewController:(PrintSearchingViewController*)ctrl withConnectedCell:(NSMutableArray *) cellArray
{    
    if (cellArray && cellArray.count > 0) {
        for (PrintSearchingTableViewCell *cell in cellArray) {
            PortInfo *info = cell.printerInfo;
            NSString *macAddress = info.macAddress;
            if ([self isStarPrintermacAddressRepeat:macAddress] == NO) {
                
                // 如果之前只有一个空打印机，删除之前的打印机，再添加star打印机（相当于替换）
                NSArray *tempArray = [PrinterDataClass getPrinterData:kTemporaryPrinterDataKey];
                if (tempArray.count == 1) {
                    NSDictionary *tempDict = [tempArray lastObject];
                    NSString *ip = [tempDict objectForKey:@"printerIP"];
                    NSString *name = [tempDict objectForKey:@"printerName"];
                    
                    if ([ip length] == 0 && [name length] == 0) {
                        [PrinterDataClass deletePrinterData:0];
                    }
                }
                
                [PrinterDataClass addNewStrPrinterData:info];
                [self updatePrinterManagmentView:kTemporaryPrinterDataKey];
            }
        }
    } else {
        [self updatePrinterManagmentView:kForeverPrinterDataKey];
    }
}

@end
