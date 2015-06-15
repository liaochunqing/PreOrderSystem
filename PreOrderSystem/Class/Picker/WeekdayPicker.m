//
//  WeekdayPicker.m
//  PreOrderSystem
//
//  Created by AaronKwok on 12-8-30.
//
//

#import "WeekdayPicker.h"
#import "DeskTableviewCell.h"
#import "PSAlertView.h"
#import "Constants.h"

@interface WeekdayPicker (Private)
//“清空”按钮点击
-(IBAction)clearButtonPressed:(UIButton*)sender;
-(IBAction)cancelButtonPressed:(UIButton*)sender;
-(IBAction)doneButtonPressed:(UIButton*)sender;
@end

@implementation WeekdayPicker
@synthesize delegate;
@synthesize weekdayTableview;
@synthesize quitButton,trueButton,clearButton;
@synthesize headImageView;
@synthesize headLabel;
@synthesize tag;
#pragma mark LIFE CYCLE
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addLocalizedString];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    NSLog(@"===WeekdayPicker,dealloc===");
#endif
}

#pragma mark PUBLIC METHODS
-(void)updateWeekdays:(NSArray*)week
{
    if (weekdaysArray == nil)
    {
        weekdaysArray = [[NSArray alloc] initWithObjects:kLoc(@"monday"), kLoc(@"tuesday"), kLoc(@"wednesday"), kLoc(@"thursday"), kLoc(@"friday"), kLoc(@"saturday"), kLoc(@"sunday"), nil];
    }
    
    if (selectedArray == nil)
    {
        selectedArray = [[NSMutableArray alloc] init];
    }
    
    [selectedArray removeAllObjects];
    
    for (int i=0; i<[weekdaysArray count]; i++)
    {
        [selectedArray addObject:[NSNumber numberWithBool:NO]];
    }
    
    for (int i=0; i<[week count]; i++)
    {
        int index = [week[i] intValue]-1;
        if (index >= 0 )
        {
            [selectedArray replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:YES]];
        }
    }
}


-(CGSize)pickerSize{
    return CGSizeMake(334, 380);
}


#pragma mark PRIVATE METHODS
//“清空”按钮点击
-(IBAction)clearButtonPressed:(UIButton*)sender{
    for (int i=0; i<[weekdaysArray count]; i++) {
        [selectedArray replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
    }
    [weekdayTableview reloadData];
}


-(IBAction)cancelButtonPressed:(UIButton*)sender{
    if ([delegate respondsToSelector:@selector(WeekdayPicker:didPressedCancelButton:)]) {
        [delegate WeekdayPicker:self didPressedCancelButton:YES];
    }
}


-(IBAction)doneButtonPressed:(UIButton*)sender
{
//    BOOL isClear = YES;
//    for (int i=0; i<[selectedArray count]; i++) {
//        BOOL isSelected = [[selectedArray objectAtIndex:i] boolValue];
//        if (isSelected) {
//            isClear = NO;
//            break;
//        }
//    }
//    if (isClear) {
//        [PSAlertView showWithMessage:kLoc(@"must_select_a_week")];
//    }
//    else {
        if ([delegate respondsToSelector:@selector(WeekdayPicker:didPickedWeekdays:)])
        {
            NSMutableArray *weeks = [[NSMutableArray alloc] init];
            for (int i=0; i<[selectedArray count]; i++)
            {
                BOOL isSelected = [[selectedArray objectAtIndex:i] boolValue];
                if (isSelected)
                {
                    [weeks addObject:[NSNumber numberWithInt:i+1]];
                }
            }
            [delegate WeekdayPicker:self didPickedWeekdays:weeks];
        }
//    }
}

- (void)addLocalizedString
{
    self.headLabel.text = kLoc(@"select_week");
    [self.trueButton setTitle:kLoc(@"confirm") forState:UIControlStateNormal];
    [self.quitButton setTitle:kLoc(@"cancel") forState:UIControlStateNormal];
    [self.clearButton setTitle:kLoc(@"clear") forState:UIControlStateNormal];
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
    [cell setDeskTitle:[weekdaysArray objectAtIndex:row]];
    BOOL isSelected = [[selectedArray objectAtIndex:row] boolValue];
    [cell isSelected:isSelected];
	return cell;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [weekdaysArray count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 40;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int row = indexPath.row;
    BOOL isSelected = [[selectedArray objectAtIndex:row] boolValue];
    [selectedArray replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:!isSelected]];
    //刷新
    [weekdayTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}



@end
