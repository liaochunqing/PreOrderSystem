//
//  DiningTableCommon.h
//  PreOrderSystem
//
//  Created by SWen on 14-2-28.
//
//

#ifndef PreOrderSystem_DiningTableCommon_h
#define PreOrderSystem_DiningTableCommon_h

#define kDtAreaNameMaxLen 8
#define kDtHousingNameMaxLen 8

//房台切换状态
typedef enum {
    kHousingOrderSwitchState = 0,/*订座*/
    kHousingStopSwitchState,/*停用*/
    kHousingClearSwitchState,/*清空*/
    kHousingUnKnownSwitchState
}kHousingSwitchStateType;

/*房台状态，0:未开台；1:已停台；2:已订台；3:已开台；4:已下单*/
typedef enum {
    kHousingNotOpen = 0,
    kHousingHavedStop,
    kHousingHavedOrder,
    kHousingHavedOpen,
    kHousingHavedDish,
    kHousingUnKnownState
}kHousingStateType;

#endif
