//
//  UIImagePickerController+InterfaceOrientations.m
//  PreOrderSystem
//
//  Created by sWen on 13-3-4.
//
//

#import "UIImagePickerController+InterfaceOrientations.h"

@implementation UIImagePickerController (InterfaceOrientations)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

@end
