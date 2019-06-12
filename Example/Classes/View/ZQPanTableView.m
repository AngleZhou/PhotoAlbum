//
//  PanTableView.m
//  dope
//
//  Created by 盛杰厚 on 2019/6/8.
//  Copyright © 2019 Dope. All rights reserved.
//

#import "ZQPanTableView.h"

@implementation ZQPanTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UIPanGestureRecognizer")]) {
        CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:gestureRecognizer.view];
        if (self.contentOffset.y >= 0 && velocity.y > 0) {
            return NO;
        }
    }
    return YES;
}


@end
