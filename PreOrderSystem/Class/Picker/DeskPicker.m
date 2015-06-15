//
//  DeskPicker.m
//  PreOrderSystem
//
//  Created by AaronKwok on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DeskPicker.h"
#import "Constants.h"
#import "DeskTableviewCell.h"
#import "UIImage+imageWithContentsOfFile.h"

@interface DeskPicker (Private)
-(IBAction)clearButtonPressed:(UIButton*)sender;
-(IBAction)cancelButtonPressed:(UIButton*)sender;
-(IBAction)doneButtonPressed:(UIButton*)sender;
@end

@implementation DeskPicker
@synthesize delegate;
@synthesize tag;
@synthesize deskTableview;
@synthesize headLabel;
@synthesize headImageView;
@synthesize clearButton;
@synthesize quitButton;
@synthesize trueButton;

#pragma mark LIFE CYCLE

- (id)init
{
    self = [super init];
    if (self)
    {
       
    }
    return self;
}

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
    
    if (!diningTableListArray) {
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        NSArray *array = [pref objectForKey:kDiningTableList];
        if (!array) {
            
        }
        else {
            diningTableListArray = [[NSArray alloc] initWithArray:array];
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

#pragma mark PUBLIC METHODS

-(id)initWithSelectedList:(NSArray*)selectedList{
    self = [super init];
    if (self) {
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        NSArray *array = [pref objectForKey:kDiningTableList];
        if (array==nil) {
            
        }
        else {
            diningTableListArray = [[NSArray alloc] initWithArray:array];
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
                for (int i=0; i<[[classify objectForKey:@"diningTableList"] count]; i++) {
                    NSDictionary *desk = [[classify objectForKey:@"diningTableList"] objectAtIndex:i];
                    
                    [list addObject:[NSNumber numberWithBool:NO]];
                    for (NSString *seatsId in selectedList) {
                        if ([seatsId isEqualToString:[desk objectForKey:@"seatsId"]]) {
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


-(id)initWithSelectedList2:(NSArray*)selectedList{
    self = [super init];
    if (self) {
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        NSArray *array = [pref objectForKey:kDiningTableList];
        if (array==nil) {
            
        }
        else {
            diningTableListArray = [[NSArray alloc] initWithArray:array];
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

//房台ID转换为对应的文字(用于：指定的开放台号)
+(NSString *)seatsIdsToText:(NSArray*)diningTable
{
    //初始化房台信息
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSArray *dinningTablesArray = [pref objectForKey:kDiningTableList];
    
    NSMutableString *deskStr = [[NSMutableString alloc] init];
    for (int i=0; i<[diningTable count]; i++)
    {
        for (NSDictionary *classify in dinningTablesArray)
        {
            for (NSDictionary *table in [classify objectForKey:@"diningTableList"])
            {
                NSString *seatsId = [table objectForKey:@"seatsId"];
                if ([[diningTable objectAtIndex:i] isEqualToString:seatsId])
                {
                    [deskStr appendString:[table objectForKey:@"seatsName"]];
                    
                    if (i<[diningTable count]-1)
                    {
                        [deskStr appendString:@"、"];
                    }
                    break;
                }
            }
        }
    }
    if ([deskStr length]==0)
    {
        [deskStr appendString:kLoc(@"specify_the_open_platform_number_optional")];
        //[deskStr appendString:@"指定开放台号（选填）"];

    }
    return deskStr;
}

//
-(CGSize)pickerSize{
    return CGSizeMake(334, 419);
}

#pragma mark PRIVATE METHODS
-(IBAction)cancelButtonPressed:(UIButton*)sender{
    if ([delegate respondsToSelector:@selector(DeskPicker:didPressedCancelButton:)]) {
        [delegate DeskPicker:self didPressedCancelButton:YES];
    }
}


-(IBAction)doneButtonPressed:(UIButton*)sender{
    if ([delegate respondsToSelector:@selector(DeskPicker:didPickedDesks:)]) {
        NSMutableArray *selectedDeskIDs = [[NSMutableArray alloc] init];
        for (int i=0; i<[selectedArray count]; i++) {
            for (int j=0; j<[[selectedArray objectAtIndex:i] count]; j++) {
                if ([[[selectedArray objectAtIndex:i] objectAtIndex:j] boolValue]) {
                    NSString *seatsId = [[[[diningTableListArray objectAtIndex:i] objectForKey:@"diningTableList"] objectAtIndex:j] objectForKey:@"seatsId"];
                    [selectedDeskIDs addObject:seatsId];
                }
            }
        }
        [delegate DeskPicker:self didPickedDesks:selectedDeskIDs];
    }
    
    if ([delegate respondsToSelector:@selector(DeskPicker:didPickedDesks2:)]) {
        NSMutableArray *selectedDeskIDs = [[NSMutableArray alloc] init];
        for (int i=0; i<[selectedArray count]; i++) {
            for (int j=0; j<[[selectedArray objectAtIndex:i] count]; j++) {
                if ([[[selectedArray objectAtIndex:i] objectAtIndex:j] boolValue]) {
                    NSDictionary *desk = [[[diningTableListArray objectAtIndex:i] objectForKey:@"diningTableList"] objectAtIndex:j];
                    [selectedDeskIDs addObject:desk];
                }
            }
        }
        [delegate DeskPicker:self didPickedDesks2:selectedDeskIDs];
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
	DeskTableviewCell *cell = (DeskTableviewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"DeskTableviewCell" owner:self options:nil] lastObject];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
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
	return 40;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DeskTableviewCell *cell = (DeskTableviewCell *)[tableView cellForRowAtIndexPath:indexPath];
    //修改Cell的值
    
    int section = cell.tag/100;
    int row = cell.tag%100;
    
    NSMutableArray *list = [selectedArray objectAtIndex:section];
    BOOL isSelected = [[[selectedArray objectAtIndex:section] objectAtIndex:row] boolValue];
    [list replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:!isSelected]];
    [selectedArray replaceObjectAtIndex:section withObject:list];
    
    //修改HeaderView的值
    
    //刷新
    [deskTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
    
    [deskTableview reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(-5, 0, 344, 50)];
    //aView.backgroundColor = [UIColor grayColor];
    
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-5, 0, 344, 50)];
    backgroundImageView.image = [UIImage imageFromMainBundleFile:@""];
    [aView addSubview:backgroundImageView];
    
    //
    BOOL isZip = [[isZipped objectAtIndex:section] boolValue];
    UIButton *classifyNameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    classifyNameBtn.tag = section;
    [classifyNameBtn setFrame:CGRectMake(-5, 0, 344, 50)];
    [classifyNameBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"deskPicker_headerviewCellBackgroundNormal.png"] forState:UIControlStateNormal];
    [classifyNameBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"deskPicker_headerviewCellBackgroundSelected.png"] forState:UIControlStateSelected];
    classifyNameBtn.selected = isZip;
    [classifyNameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [classifyNameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    classifyNameBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    NSString *classifyName = [[diningTableListArray objectAtIndex:section] objectForKey:@"seatsAreaName"];
    [classifyNameBtn setTitle:classifyName forState:UIControlStateNormal];
    [classifyNameBtn setTitle:classifyName forState:UIControlStateSelected];
    [classifyNameBtn addTarget:self action:@selector(zipHeaderView:) forControlEvents:UIControlEventTouchUpInside];
    [aView addSubview:classifyNameBtn];
    
    
    //
    BOOL isAll = YES;
    for (NSNumber *isSelect in [selectedArray objectAtIndex:section]) {
        if (![isSelect boolValue]) {
            isAll = NO;
            break;
        }
    }
    
    
    UIButton *selectAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectAllBtn.tag = section;
    [selectAllBtn setFrame:CGRectMake(290, 3, 35, 35)];
    [selectAllBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishesPicker_packageNormal.png"] forState:UIControlStateNormal];
    [selectAllBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"dishesPicker_packageSelected.png"] forState:UIControlStateSelected];
    selectAllBtn.selected = isAll;
    [selectAllBtn addTarget:self action:@selector(selectAllButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    if (0 == [[selectedArray objectAtIndex:section]count])
    {
        selectAllBtn.hidden = YES;
    }
    [aView addSubview:selectAllBtn];
    
    return aView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}



@end
