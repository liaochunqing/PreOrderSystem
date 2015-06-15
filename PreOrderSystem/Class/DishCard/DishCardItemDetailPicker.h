//
//  DishCardItemDetailPicker.h
//  PreOrderSystem
//
//  Created by AaronKwok on 13-4-15.
//
//

#import <UIKit/UIKit.h>

#import "XANImageViewController.h"
#import "DishCardItemPriceTableviewCell.h"
#import "JsonPicker.h"
#import "NSData+Base64.h"
#import "DataDownloader.h"
#import "PECropViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoReviewView.h"
#import "DisplayHelper.h"

@class DishCardItemDetailPicker;
@protocol DishCardItemDetailPickerDelegate <NSObject>
- (void)DishCardItemDetailPickerDidAddedNewItem:(NSDictionary*)item;
- (void)dismissDishCardItemDetailPicker:(DishCardItemDetailPicker*)ctrl;

@end

@interface DishCardItemDetailPicker : UIViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, XANImageViewControllerDelegate, XANImageViewControllerDataSource, DataDownloaderDelegate, UITableViewDataSource, UITableViewDelegate, DishCardItemPriceTableviewCellDelegate, PECropViewControllerDelegate, JsonPickerDelegate>
{
    id <DishCardItemDetailPickerDelegate> __weak delegate;
    __weak UITableView *itemTableview;
    __weak UIImageView *itemPicImageview;
    __weak UIImageView *bgImageView;
    __weak UIButton *takeoutAvailableButton;
    __weak UIButton *isSoldOutButton;
    __weak UIButton *editPicButton;
    __weak UIActivityIndicatorView *activityView;
    
    UITextField *itemSerialNumTextfield;//编号
    UITextField *itemDishNameTextfield;//菜名
    UITextView *itemDishDescripTextview;//简介
    UILabel *optionalLabel;//选填
    id popController;
    
    int cuisineID;
    int isAllowTakeout;
    int isSoldOut;
    JsonPicker *jsonPicker;
    //新建item时，isEditing＝NO，否则为YES
    BOOL isEditing;
    NSMutableDictionary *dishCardDict;
    NSString *imgBaseURL;
    CGPoint tableviewContentOffset;
    DishCardItemPriceTableviewCell *selectedPriceCell;
}

@property (weak, nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet UITableView *itemTableview;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIButton *cancleButton;
@property (weak, nonatomic) IBOutlet UIButton *trueButton;
@property (weak, nonatomic) IBOutlet UIImageView *itemPicBgImageview;
@property (weak, nonatomic) IBOutlet UIImageView *itemPicImageview;
@property (weak, nonatomic) IBOutlet UIButton *takeoutAvailableButton;
@property (weak, nonatomic) IBOutlet UIButton *isSoldOutButton;
@property (weak, nonatomic) IBOutlet UIButton *editPicButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UILabel *takeOutLabel;
@property (weak, nonatomic) IBOutlet UILabel *soldOutLabel;
@property (weak, nonatomic) IBOutlet UITextField *packfeeTextField;//打包费
@property (weak, nonatomic) IBOutlet UIImageView *packfeeImgBg;
@property (weak, nonatomic) IBOutlet UILabel *packfeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *yuanLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (strong, nonatomic) NSMutableDictionary *dishCardDict;
@property (strong, nonatomic) id popover;
@property (assign, nonatomic) BOOL isEditEnable;

- (void)updateViewWithCuisineID:(int)cid withImgBaseURL:(NSString *)imageURL;
- (void)updateViewWithDishInfo:(NSDictionary *)info withImgBaseURL:(NSString *)imageURL;
- (void)dismissView;

@end
