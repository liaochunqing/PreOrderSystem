//
//  MemoPicker.m
//  PreOrderSystem
//
//  Created by AaronKwok on 12-8-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MemoPicker.h"
#import "OfflineManager.h"
#import "UIImage+imageWithContentsOfFile.h"
#import "Constants.h"

@interface MemoPicker ()

@end

@implementation MemoPicker
@synthesize delegate;
@synthesize backImageView;
@synthesize isShowing;

#pragma mark LIFE CYCLE
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    OfflineManager *offlineMgr = [OfflineManager sharedOfflineManager];
    if (memosListArray==nil) {
        NSArray *tmp = [offlineMgr offlineMemos];
        if (tmp!=nil) {
            memosListArray = [[NSArray alloc] initWithArray:tmp];
        }
    }
    
    selectedTypeIndex = 0;
    //
    //分栏
    UIScrollView *typeScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 70)];
    
    if (!memosViewArray) {
        memosViewArray = [[NSMutableArray alloc] init];
    }
    
    if (!typeBtnsArray) {
        typeBtnsArray = [[NSMutableArray alloc] init];
    }
    if (!memoPageControlsArray) {
        memoPageControlsArray = [[NSMutableArray alloc] init];
    }
    
    for (int i=0; i<[memosListArray count]; i++) {
        UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 1024, 180)];
        aView.backgroundColor = [UIColor clearColor];
        aView.userInteractionEnabled = YES;
        
        //
        UIButton *typeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        typeBtn.tag = i;
        [typeBtn setFrame:CGRectMake(i*128, 0, 128, 68)];
        [typeBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"memoPicker_typeButtonNormal.png"] forState:UIControlStateNormal];
        typeBtn.titleLabel.font = [UIFont systemFontOfSize:23];
        
        [typeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [typeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
        NSString *typeName = [[memosListArray objectAtIndex:i] objectForKey:@"typeName"];
        [typeBtn setTitle:typeName forState:UIControlStateNormal];
        [typeBtn setTitle:typeName forState:UIControlStateSelected];
        [typeBtn addTarget:self action:@selector(typeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        if (i==selectedTypeIndex) {
            typeBtn.selected = YES;
            typeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:23];
            [typeBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"memoPicker_typeButtonSelected.png"] forState:UIControlStateNormal];
        }
        [typeBtnsArray addObject:typeBtn];
        
        [typeScrollview addSubview:typeBtn];
        
        
        //----------
        int pages = 0;
        int memosCount = [[[memosListArray objectAtIndex:i] objectForKey:@"memos"] count];
        pages = memosCount/12;
        if (memosCount%12>0) {
            pages++;
        }
        UIScrollView *memoScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 150)];
        memoScrollview.delegate = self;
        memoScrollview.tag = i;
        memoScrollview.contentSize = CGSizeMake(1024*pages, 150);
        memoScrollview.pagingEnabled = YES;
        memoScrollview.showsHorizontalScrollIndicator = NO;
        memoScrollview.showsVerticalScrollIndicator = NO;
        
        
        for (int j=0; j<[[[memosListArray objectAtIndex:i] objectForKey:@"memos"] count]; j++) {
            UIButton *memoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            memoBtn.tag = i*100+j;
            [memoBtn setFrame:CGRectMake(j%6*170+(j/12)*1024+10, j/6%2*80, 149, 57)];
            [memoBtn setBackgroundImage:[UIImage imageFromMainBundleFile:@"memoPicker_memoButton.png"] forState:UIControlStateNormal];
            [memoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [memoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            NSString *memoName = [[[[memosListArray objectAtIndex:i] objectForKey:@"memos"] objectAtIndex:j] objectForKey:@"memo"];
            [memoBtn setTitle:memoName forState:UIControlStateNormal];
            [memoBtn setTitle:memoName forState:UIControlStateSelected];
            [memoBtn addTarget:self action:@selector(memoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [memoScrollview addSubview:memoBtn];
        }
        [aView addSubview:memoScrollview];
        
        
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 154, 1024, 36)];
        pageControl.numberOfPages = pages;
        [aView addSubview:pageControl];
        
        [memoPageControlsArray addObject:pageControl];
        [memosViewArray addObject:aView];
        
        if (i==selectedTypeIndex) {
            [self.view addSubview:aView];
        }
    }
    [self.view addSubview:typeScrollview];
}


- (void)viewDidUnload{
    [super viewDidUnload];
    
    memosListArray = nil;
    typeBtnsArray = nil;
    memosViewArray = nil;
    memoPageControlsArray = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return YES;
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
    NSLog(@"===MemoPicker,dealloc===");
#endif
}

#pragma mark PUBLIC METHODS
-(void)showInView:(UIView*)aView atPoint:(CGPoint)point{
    CGRect frame = self.view.frame;
    frame.origin.y = -400;
    self.view.frame = frame;
    
    [aView addSubview:self.view];
    
    [UIView beginAnimations:@"animationID" context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationRepeatAutoreverses:NO];
    
    self.view.alpha = 1.0f;
    
    CGRect aFrame = self.view.frame;
    aFrame.origin.x = point.x;
    aFrame.origin.y = point.y;
    self.view.frame = aFrame;
	[UIView commitAnimations];
    
    isShowing = YES;
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
	[self.view removeFromSuperview];
}

-(void)dismissView{
    //self.view.alpha = 1.0f;
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    [UIView setAnimationDuration:0.5f];
    
    CGRect aFrame = self.view.frame;
    aFrame.origin.y = -40;
    self.view.frame = aFrame;
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //self.view.alpha = 0.0f;
    [UIView commitAnimations];
    
    isShowing = NO;
}



#pragma mark PRIVATE METHODS
-(void)typeButtonPressed:(UIButton*)sender{
    int index = sender.tag;
    if (selectedTypeIndex!=index) {
        UIButton *typeBtn = (UIButton*)[typeBtnsArray objectAtIndex:selectedTypeIndex];
        typeBtn.selected = NO;
        [typeBtn setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"memoPicker_typeButtonNormal" ofType:@"png"]] forState:UIControlStateNormal];
        typeBtn.titleLabel.font = [UIFont systemFontOfSize:23];
        
        UIButton *typeBtn2 = (UIButton*)[typeBtnsArray objectAtIndex:index];
        typeBtn2.selected = YES;
        [typeBtn2 setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"memoPicker_typeButtonSelected" ofType:@"png"]] forState:UIControlStateNormal];
        typeBtn2.titleLabel.font = [UIFont boldSystemFontOfSize:23];
        
        UIView *aView = (UIView *)[memosViewArray objectAtIndex:selectedTypeIndex];
        [aView removeFromSuperview];
        
        UIView *aView2 = (UIView *)[memosViewArray objectAtIndex:index];
        [self.view addSubview:aView2];
        
        selectedTypeIndex = index;
    }
}


-(void)memoButtonPressed:(UIButton*)sender{
    if ([delegate respondsToSelector:@selector(MemoPicker:didPickedMemo:)]) {
        int typeIndex = sender.tag/100;
        int memoIndex = sender.tag%100;
        
        NSString *memo = [[[[memosListArray objectAtIndex:typeIndex] objectForKey:@"memos"] objectAtIndex:memoIndex] objectForKey:@"memo"];
        [delegate MemoPicker:self didPickedMemo:memo];
    }
}


#pragma mark UIScrollViewDelegate Methods
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    int offsetx = offset.x;
    if (offsetx%1024==0) {
        int index = scrollView.tag;
        UIPageControl *pageCtrl = (UIPageControl *)[memoPageControlsArray objectAtIndex:index];
        
        CGPoint offset = scrollView.contentOffset;
        pageCtrl.currentPage = offset.x / 1024.0f;
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
}
@end
