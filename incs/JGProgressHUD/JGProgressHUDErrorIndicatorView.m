//
//  JGProgressHUDErrorIndicatorView.m
//  JGProgressHUD
//
//  Created by Jonas Gessner on 19.08.14.
//  Copyright (c) 2014 Jonas Gessner. All rights reserved.
//

#import "JGProgressHUDErrorIndicatorView.h"
#import "JGProgressHUD.h"

@implementation JGProgressHUDErrorIndicatorView

- (instancetype)initWithContentView:(UIView *__unused)contentView {
    NSBundle *resourceBundle = [NSBundle bundleWithPath:@"/Library/Application Support/Prenesi2/JGProgressHUD Resources.bundle"];
    
    NSString *imgPath = [resourceBundle pathForResource:@"jg_hud_error" ofType:@"png"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imgPath]];
    
    self = [super initWithContentView:imageView];
    
    return self;
}

- (instancetype)init {
    return [self initWithContentView:nil];
}

- (void)updateAccessibility {
    self.accessibilityLabel = NSLocalizedString(@"Error",);
}

@end
