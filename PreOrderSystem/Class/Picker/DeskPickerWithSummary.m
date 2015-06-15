//
//  DeskPicker.m
//  PreOrderSystem
//
//  Created by AaronKwok on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DeskPickerWithSummary.h"
#import "Constants.h"
#import "DeskWithSummaryTableviewCell.h"
#import "OfflineManager.h"
#import "MBProgressHUD.h"
#import "UIImage+imageWithContentsOfFile.h"

@interface DeskPickerWithSummary (Private)
-(IBAction)clearButtonPressed:(UIButton*)sender;
-(IBAction)doneButtonPressed:(UIButton*)sender;


@end

@implementation DeskPickerWithSummary
@synthesize delegate;
@synthesize tag;
@synthesize deskPickerType;
@synthesize deskTableview;
@synthesize headLabel;
@synthesize headImageView;
@synthesize clearButton;
@synthesize quitButton;
@synthesize trueButton;

//picker_subBackgroundFrame.png

#pragma mark LIFE CYCLE
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
    
    if (!diningTableListArray)
    {
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        NSArray *array = [pref objectForKey:kDiningTableList];
        if (!array)
        {
            
        }
        else
        {
            diningTableListArray = [[NSMutableArray alloc] initWithArray:array];
        }
    }
    [deskTableview reloadData];
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    //若是单选，则滚动到tableview的己选位置
    if (deskPickerType==DeskPickerWithSummaryTypeSingle) {
        [deskTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    [self getDingTableData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ((kSystemVersionOfCurrentDevice >= 6.0) && [self isViewLoaded] && ![self.view window])
    {
        [self setView:nil];
    }
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",[self class]);
#endif
}

//获取即时的房台信息
-(void)getDingTableData
{
    if (nil == jsonPicker)
    {
        jsonPicker = [[JsonPicker alloc] init];
    }
    jsonPicker.delegate = self;
    jsonPicker.tag = 0;
    jsonPicker.showActivityIndicator = NO;
    jsonPicker.loadingMessage = nil;
    jsonPicker.loadedSuccessfulMessage = nil;
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:@"1" forKey:@"type"];
    [jsonPicker postData:postData withBaseRequest:@"GetOptions"];
}

#pragma mark PUBLIC METHODS
-(id)initWithSelectedList:(NSArray*)selectedList{
    self = [super init];
    if (self) {
        if (!selectedList || [selectedList isKindOfClass:[NSNull class]]) {
            selectedList = [NSArray array];
        }
        
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        NSArray *array = [pref objectForKey:kDiningTableList];
        
        if (array==nil || [array count]==0) {
            
        }
        else {
            
            
            diningTableListArray = [[NSMutableArray alloc] initWithArray:array];
            //初如化己选的数组
            //结构如下所示：
            /*
             ( [0,1,1,1,0,0,1],
             [1,1,0,1,0,0,0]
             )
             */
            selectedArray = [[NSMutableArray alloc] init];
            for (int i=0; i<[diningTableListArray count]; i++) {
                NSDictionary *classify = [diningTableListArray objectAtIndex:i];
                NSMutableArray *list = [[NSMutableArray alloc] init];
                for (int j=0; j<[[classify objectForKey:@"diningTableList"] count]; j++) {
                    NSDictionary *desk = [[classify objectForKey:@"diningTableList"] objectAtIndex:j];
                    
                    [list addObject:[NSNumber numberWithBool:NO]];
                    for (NSString *seatsId in selectedList) {
                        if ([seatsId isEqualToString:[desk objectForKey:@"seatsId"]]) {
                            if (deskPickerType==DeskPickerWithSummaryTypeSingle) {
                                selectedSection = i;
                                selectedRow = j;
                            }
                            [list replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:YES]];
                            break;
                        }
                    }
                }
                
                [selectedArray addObject:list];
            }
            
            isZipped = [[NSMutableArray alloc] init];
            for (NSDictionary *classify in diningTableListArray) {
                [isZipped addObject:[NSNumber numberWithBool:YES]];
            }
        }
    }
    
    return self;
}


-(void)updateWithSelectedList:(NSArray*)selectedList{
    if (selectedList==nil || [selectedList isKindOfClass:[NSNull class]]) {
        selectedList = [NSArray array];
    }
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSArray *array = [pref objectForKey:kDiningTableList];
    
    if (array==nil || [array count]==0) {
        
    }
    else {
        if (!diningTableListArray) {
            diningTableListArray = [[NSMutableArray alloc] initWithArray:array];
        }
        
        //初如化己选的数组
        //结构如下所示：
        /*
         ( [0,1,1,1,0,0,1],
         [1,1,0,1,0,0,0]
         )
         */
        //
        if (!selectedArray) {
            selectedArray = [[NSMutableArray alloc] init];
        }
        [selectedArray removeAllObjects];
        
        for (int i=0; i<[diningTableListArray count]; i++) {
            NSDictionary *classify = [diningTableListArray objectAtIndex:i];
            NSMutableArray *list = [[NSMutableArray alloc] init];
            for (int j=0; j<[[classify objectForKey:@"diningTableList"] count]; j++) {
                NSDictionary *desk = [[classify objectForKey:@"diningTableList"] objectAtIndex:j];
                
                [list addObject:[NSNumber numberWithBool:NO]];
                for (NSString *seatsId in selectedList) {
                    if ([seatsId isEqualToString:[desk objectForKey:@"seatsId"]]) {
                        if (deskPickerType==DeskPickerWithSummaryTypeSingle) {
                            selectedSection = i;
                            selectedRow = j;
                        }
                        [list replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:YES]];
                        break;
                    }
                }
            }
            
            [selectedArray addObject:list];
        }
        
        
        //
        if (!isZipped) {
            isZipped = [[NSMutableArray alloc] init];
        }
        [isZipped removeAllObjects];
        for (NSDictionary *classify in diningTableListArray) {
            [isZipped addObject:[NSNumber numberWithBool:YES]];
        }
    }
    
    [deskTableview reloadData];
}


-(id)initWithSelectedList2:(NSArray*)selectedList{
    self = [super init];
    if (self) {
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        NSArray *array = [pref objectForKey:kDiningTableList];
        if (array==nil) {
            
        }
        else {
            diningTableListArray = [[NSMutableArray alloc] initWithArray:array];
            //初如化己选的数组
            //结构如下所示：
            /*
             ( [0,1,1,1,0,0,1],
             [1,1,0,1,0,0,0]
             )
             */
            selectedArray = [[NSMutableArray alloc] init];
            for (NSDictionary *classify in diningTableListArray) {
                NSMutableArray *list = [[NSMutableArray alloc] init];
                for (int i=0; i<[[classify objectForKey:@"list"] count]; i++) {
                    NSDictionary *desk = [[classify objectForKey:@"list"] objectAtIndex:i];
                    
                    [list addObject:[NSNumber numberWithBool:NO]];
                    for (NSDictionary *table in selectedList) {
                        if ([[table objectForKey:@"seatsId"] isEqualToString:[desk objectForKey:@"seatsId"]]) {
                            [list replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
                            break;
                        }
                    }
                }
                
                [selectedArray addObject:list];
            }
            
            
            isZipped = [[NSMutableArray alloc] init];
            for (NSDictionary *classify in diningTableListArray) {
                [isZipped addObject:[NSNumber numberWithBool:YES]];
            }
        }
    }
    
    return self;
}



+(NSString *)seatsIdsToSummary:(NSArray*)diningTable{
    if (diningTable==nil || [diningTable isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    //初始化房台信息
    NSArray *dinningTablesArray;
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSArray *array = [pref objectForKey:kDiningTableList];
    if (array==nil) {
        
    }
    else {
        dinningTablesArray = [[NSArray alloc] initWithArray:array];
    }
    
    //deskStr返回的餐桌字段
    NSMutableString *deskStr = [[NSMutableString alloc] init];
    for (int i=0; i<[diningTable count]; i++) {
        for (NSDictionary *classify in dinningTablesArray) {
            for (NSDictionary *table in [classify objectForKey:@"diningTableList"]) {
                NSString *seatsId = [table objectForKey:@"seatsId"];
                if ([[diningTable objectAtIndex:i] isEqualToString:seatsId]) {
                    [deskStr appendFormat:@"%@/%@", [classify objectForKey:@"seatsAreaName"], [table objectForKey:@"seatsName"]];
                    
                    //int minCapacity = [[table objectForKey:@"capacity2"] intValue];
                    //int maxCapacity = [[table objectForKey:@"capacity1"] intValue];
                    //[deskStr appendFormat:@"%i人 - %i人", minCapacity, maxCapacity];
                    
                    int minConsumption = [[table objectForKey:@"minimumConsumption"] intValue];
                    if (minConsumption > 0)
                    {
                        [deskStr appendFormat:@"（低消 %i元）", minConsumption];
                    }
                    
                    
                    if (i<[diningTable count]-1) {
                        [deskStr appendString:@","];
                    }
                    break;
                }
            }
        }
    }
    if ([deskStr length]==0) {
        [deskStr appendString:kLoc(@"specify_the_open_platform_number_optional")];
    }
    return deskStr;
}


+(NSString *)seatsIdsToSeatName:(NSArray*)diningTable{
    if (diningTable==nil || [diningTable isKindOfClass:[NSNull class]]) {
        return @"";
    }
    //初始化房台信息
    NSArray *dinningTablesArray;
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSArray *array = [pref objectForKey:kDiningTableList];
    if (array==nil) {
        
    }
    else {
        dinningTablesArray = [[NSArray alloc] initWithArray:array];
    }
    
    //deskStr返回的餐桌字段
    NSMutableString *deskStr = [[NSMutableString alloc] init];
    for (int i=0; i<[diningTable count]; i++) {
        for (NSDictionary *classify in dinningTablesArray) {
            for (NSDictionary *table in [classify objectForKey:@"diningTableList"]) {
                NSString *seatsId = [table objectForKey:@"seatsId"];
                NSString *seatsId2 = [[diningTable objectAtIndex:i] objectForKey:@"seatsId"];
                if ([seatsId2 isEqualToString:seatsId]) {
                    [deskStr appendFormat:@"%@", [table objectForKey:@"seatsName"]];
                    
                    if (i<[diningTable count]-1) {
                        [deskStr appendString:@","];
                    }
                    break;
                }
            }
        }
    }
    return deskStr;
}

-(CGSize)pickerSize{
    return CGSizeMake(334, 437);
}

#pragma mark PRIVATE METHODS
-(IBAction)cancelButtonPressed:(UIButton*)sender{
    if ([delegate respondsToSelector:@selector(DeskPickerWithSummary:didPressedCancelButton:)]) {
        [delegate DeskPickerWithSummary:self didPressedCancelButton:YES];
    }
}


-(IBAction)doneButtonPressed:(UIButton*)sender{
    if ([delegate respondsToSelector:@selector(DeskPickerWithSummary:didPickedDesks:)]) {
        NSMutableArray *selectedDeskIDs = [[NSMutableArray alloc] init];
        BOOL isPicked = NO;
        for (int i=0; i<[selectedArray count]; i++) {
            for (int j=0; j<[[selectedArray objectAtIndex:i] count]; j++) {
                if ([[[selectedArray objectAtIndex:i] objectAtIndex:j] boolValue]) {
                    NSString *seatsId = [[[[diningTableListArray objectAtIndex:i] objectForKey:@"diningTableList"] objectAtIndex:j] objectForKey:@"seatsId"];
                    [selectedDeskIDs addObject:seatsId];
                    isPicked = YES;
                }
            }
        }
        
        if (isPicked) {
            [delegate DeskPickerWithSummary:self didPickedDesks:selectedDeskIDs];
        }
        else {
            [delegate DeskPickerWithSummary:self didPickedDesks:nil];
        }
    }
    
    if ([delegate respondsToSelector:@selector(DeskPickerWithSummary:didPickedDesksDetail:)]) {
        NSMutableArray *selectedDeskIDs = [[NSMutableArray alloc] init];
        BOOL isPicked = NO;
        for (int i=0; i<[selectedArray count]; i++) {
            for (int j=0; j<[[selectedArray objectAtIndex:i] count]; j++) {
                if ([[[selectedArray objectAtIndex:i] objectAtIndex:j] boolValue]) {
                    NSDictionary *classify = [diningTableListArray objectAtIndex:i] ;
                    NSMutableDictionary *deskInfo = [[NSMutableDictionary alloc] init];
                    [deskInfo setObject:[classify objectForKey:@"seatsAreaId"] forKey:@"seatsAreaId"];
                    [deskInfo setObject:[classify objectForKey:@"seatsAreaName"] forKey:@"seatsAreaName"];
                    
                    NSDictionary *table = [[classify objectForKey:@"diningTableList"] objectAtIndex:j];
                    [deskInfo setObject:[table objectForKey:@"seatsId"] forKey:@"seatsId"];
                    [deskInfo setObject:[table objectForKey:@"seatsName"] forKey:@"seatsName"];
                    [deskInfo setObject:[table objectForKey:@"capacity2"] forKey:@"maxCapacity"];
                    [deskInfo setObject:[table objectForKey:@"minimumConsumption"] forKey:@"minimumConsumption"];
                    [selectedDeskIDs addObject:deskInfo];
                    
                    isPicked = YES;
                }
            }
        }
        
        if (isPicked) {
            [delegate DeskPickerWithSummary:self didPickedDesksDetail:selectedDeskIDs];
        }
        else {
            [delegate DeskPickerWithSummary:self didPickedDesksDetail:nil];
        }
    }
}


//“清空”按钮点击
-(IBAction)clearButtonPressed:(UIButton*)sender{
    for (int i=0; i<[selectedArray count]; i++) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for (int j=0; j<[[selectedArray objectAtIndex:i] count]; j++) {
            [list addObject:[NSNumber numberWithBool:NO]];
        }
        [selectedArray replaceObjectAtIndex:i withObject:list];
    }
    
    [deskTableview reloadData];
}


//折叠Headerview
-(void)zipHeaderView:(UIButton*)sender{
    int section = sender.tag;
    sender.selected = !sender.selected;
    [isZipped replaceObjectAtIndex:sender.tag withObject:[NSNumber numberWithBool:sender.selected]];
    
    [deskTableview reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
   
    if (0 == [[selectedArray objectAtIndex:section]count])
    {
        [deskTableview reloadData];
    }
    else
    {
        if (sender.selected)
        {
            [deskTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }
}

//全选某个分类
-(void)selectAllButtonPressed:(UIButton*)sender{
    sender.selected = !sender.selected;
    int section = sender.tag;
    BOOL isAll = sender.selected;
    NSMutableArray *list = [selectedArray objectAtIndex:section];
    NSMutableArray *newList = [[NSMutableArray alloc] init];
    for (int i=0; i<[list count]; i++) {
        [newList addObject:[NSNumber numberWithBool:isAll]];
    }
    [selectedArray replaceObjectAtIndex:section withObject:newList];
    
    [deskTableview reloadData];
}

#pragma mark UITableViewController datasource & delegate 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *CellIdentifier = @"CellIdentifier";
	DeskWithSummaryTableviewCell *cell = (DeskWithSummaryTableviewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"DeskWithSummaryTableviewCell" owner:self options:nil] lastObject];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.textColor = [UIColor grayColor];
	}
    
    int row = indexPath.row;
    int section = indexPath.section;
    NSDictionary *tableInfo = [[[diningTableListArray objectAtIndex:section] objectForKey:@"diningTableList"] objectAtIndex:row];
    cell.tag = section*100 + row;
    cell.deskInfo = tableInfo;
    BOOL isSelected = [[[selectedArray objectAtIndex:section] objectAtIndex:row] boolValue];
    [cell isSelected:isSelected];
    
	return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [diningTableListArray count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    BOOL isZip = [[isZipped objectAtIndex:section] boolValue];
    if (isZip) {
        return [[[diningTableListArray objectAtIndex:section] objectForKey:@"diningTableList"] count];
    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 60;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DeskPickerWithSummary *cell = (DeskPickerWithSummary *)[tableView cellForRowAtIndexPath:indexPath];
    //修改Cell的值
    
    int section = cell.tag/100;
    int row = cell.tag%100;
    
    //------------单选
    if (deskPickerType==DeskPickerWithSummaryTypeSingle) {
        int lastSelectedSectionIndex = -1;
        int lastSelectedRowIndex = -1;
        for (int i=0; i<[selectedArray count]; i++) {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            for (int j=0; j<[[selectedArray objectAtIndex:i] count]; j++) {
                BOOL isSelected = [[[selectedArray objectAtIndex:i] objectAtIndex:j] boolValue];
                if (isSelected) {
                    lastSelectedSectionIndex = i;
                    lastSelectedRowIndex = j;
                }
                if (i==section && j==row) {
                    [list addObject:[NSNumber numberWithBool:YES]];
                }
                else {
                    [list addObject:[NSNumber numberWithBool:NO]];
                }
            }
            [selectedArray replaceObjectAtIndex:i withObject:list];
        }
        
        //刷新
        if (lastSelectedRowIndex>=0 && lastSelectedSectionIndex>=0) {
            [deskTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:lastSelectedRowIndex inSection:lastSelectedSectionIndex]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        [deskTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
    }
    //-----------多选
    else {
        NSMutableArray *list = [selectedArray objectAtIndex:section];
        BOOL isSelected = [[[selectedArray objectAtIndex:section] objectAtIndex:row] boolValue];
        [list replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:!isSelected]];
        [selectedArray replaceObjectAtIndex:section withObject:list];
        
        //修改HeaderView的值
        
        //刷新
        [deskTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
        
        [deskTableview reloadData];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(-5, 0, 344, 50)];
    aView.backgroundColor = [UIColor whiteColor];
    //
    BOOL isZip = [[isZipped objectAtIndex:section] boolValue];
    UIButton *classifyNameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    classifyNameBtn.tag = section;
    [classifyNameBtn setFrame:CGRectMake(-5, 0, 344, 50)];
    [classifyNameBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"deskPicker_headerviewCellBackgroundNormal.png"] forState:UIControlStateNormal];
    [classifyNameBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"deskPicker_headerviewCellBackgroundSelected.png"] forState:UIControlStateSelected];
    classifyNameBtn.selected = isZip;
    [classifyNameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [classifyNameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    classifyNameBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    NSString *classifyName = [[diningTableListArray objectAtIndex:section] objectForKey:@"seatsAreaName"];
    [classifyNameBtn setTitle:classifyName forState:UIControlStateNormal];
    [classifyNameBtn setTitle:classifyName forState:UIControlStateSelected];
    [classifyNameBtn addTarget:self action:@selector(zipHeaderView:) forControlEvents:UIControlEventTouchUpInside];
    [aView addSubview:classifyNameBtn];
    
    
    if (deskPickerType==DeskPickerWithSummaryMultiple)
    {
        //
        BOOL isAll = YES;
        for (NSNumber *isSelect in [selectedArray objectAtIndex:section])
        {
            if (![isSelect boolValue])
            {
                isAll = NO;
                break;
            }
            
        }
        
        UIButton *selectAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        selectAllBtn.tag = section;
        [selectAllBtn setFrame:CGRectMake(290, 2, 35, 35)];
        [selectAllBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishesPicker_packageNormal.png"] forState:UIControlStateNormal];
        [selectAllBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishesPicker_packageSelected.png"] forState:UIControlStateSelected];
        selectAllBtn.selected = isAll;
        [selectAllBtn addTarget:self action:@selector(selectAllButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    if (0 == [[selectedArray objectAtIndex:section]count])
    {
        selectAllBtn.hidden = YES;
    }
    
        [aView addSubview:selectAllBtn];
    }
    return aView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}



#pragma mark JsonPickerDelegate
-(void)JsonPicker:(JsonPicker *)picker didParsingSuccessfulWithDict:(NSDictionary *)dict
{
    if (picker.tag==0)
    {
        int responseStatus = [[dict objectForKey:@"status"] intValue];
        
        switch (responseStatus)
        {
            case 200:
            {
                OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
                if (diningTableListArray==nil)
                {
                    diningTableListArray = [[NSMutableArray alloc] init];
                }
                [diningTableListArray removeAllObjects];
                [diningTableListArray addObjectsFromArray:[[dict objectForKey:@"data"] objectForKey:@"dataList"]];
                
                //保存房台数据
                [offlineMgr saveOfflineDinningTable:[[dict objectForKey:@"data"] objectForKey:@"dataList"] withUpdatedDate:[[dict objectForKey:@"data"] objectForKey:@"lastUpdate"]];
                
                //刷新
                [deskTableview reloadData];
                
                break;
            }
            default:
            {
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
