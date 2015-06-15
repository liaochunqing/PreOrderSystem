//
//  DiningTableAddAreaView.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-20.
//
//

#import <UIKit/UIKit.h>

#import "CustomUIView.h"
#import "JsonPicker.h"
#import "AreaListTableViewCell.h"
#import "DiningTableDataClass.h"
#import "DiningTableHousingListView.h"
#import "AddMoreAreaViewController.h"

@class DiningTableAreaListView;
@protocol DiningTableAreaListViewDelegate <NSObject>

- (void)dismissAreaViewWithNewData:(NSMutableArray *)dtArray;

@end

@interface DiningTableAreaListView : CustomUIView<AreaListTableViewCellDelegate, JsonPickerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, DiningTableHousingListViewDelegate, AddMoreAreaViewControllerDelegete>

@property(nonatomic, weak) id <DiningTableAreaListViewDelegate> delegate;
@property(nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property(nonatomic, weak) IBOutlet UITextField *addAreaTextField;
@property(nonatomic, weak) IBOutlet UIButton *backButton;
@property(nonatomic, weak) IBOutlet UIButton *trueButton;
@property(nonatomic, weak) IBOutlet UIButton *clearAllButton;
@property(nonatomic, weak) IBOutlet UIButton *addManyButton;
@property(nonatomic, weak) IBOutlet UIButton *addOnlyButton;
@property(nonatomic, weak) IBOutlet UITableView *areaTableView;
@property(nonatomic, strong) NSMutableArray *diningTableListArray;

- (void)updateAreaListView;
- (void)dismissAreaListView:(NSMutableArray *)areaArray;

@end
