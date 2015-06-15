/*
 *  config.h
 *  XANImageBrowser
 *
 *  Created by Chen Xian'an on 1/3/11.
 *  Copyright 2011 lazyapps.com. All rights reserved.
 *
 */

#define ISPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define kThumbSize (ISPAD ? CGSizeMake(125.0, 125.0) : (CGSizeMake(75.0, 75.0)))
#define kSpacing (ISPAD ? 8.0 : 4.0)
#define kCapacityOfThumbsInARowPortrait 4
#define kCapacityOfThumbsInARowLandscape (ISPAD ? 4 : 6)
#define PAGE_GAP 20.0
