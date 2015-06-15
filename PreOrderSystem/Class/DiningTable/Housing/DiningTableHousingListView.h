//
//  DiningTableAddAreaView.h
//  PreOrderSystem
//
//  Created by SWen on 13-12-20.
//
//

#import <UIKit/UIKit.h>

#import "CustomUIView.h"
#import "HousingListTableViewCell.h"
#import "AddMoreHousingViewController.h"
#import "DiningTableDataClass.h"

@class DiningTableHousingListView;
@protocol DiningTableHousingListViewDelegate <NSObject>

- (void)dismissHousingListView:(DiningTableHousingListView *)listView WithNewData:(NSMutableArray *)housingArray;

@end

@interface DiningTableHousingListView : CustomUIView<HousingListTableViewCellDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, AddMoreHousingViewControllerDelegete>

@property(nonatomic, weak) id <DiningTableHousingListViewDelegate> delegate;
@property(nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property(nonatomic, weak) IBOutlet UITextField *addHousingTextField;
@property(nonatomic, weak) IBOutlet UIButton *backButton;
@property(nonatomic, weak) IBOutlet UIButton *trueButton;
@property(nonatomic, weak) IBOutlet UIButton *clearAllButton;
@property(nonatomic, weak) IBOutlet UIButton *addManyButton;
@property(nonatomic, weak) IBOutlet UIButton *addOnlyButton;
@property(nonatomic, weak) IBOutlet UITableView *housingTableView;
@property(nonatomic, strong) NSMutableArray *housingArray;

- (void)updateHousingListView;
- (void)dismissHousingListView:(NSMutableArray *)array;

@end
