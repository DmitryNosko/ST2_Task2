//
//  CustomHeaderView.m
//  ContactsBooks
//
//  Created by Dima on 6/8/19.
//  Copyright © 2019 Dima. All rights reserved.
//

#import "CustomHeaderView.h"

@interface CustomHeaderView ()
@end

@implementation CustomHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {

        self.expandButon = [UIButton buttonWithType:UIButtonTypeCustom];
        self.expandButon.frame = CGRectMake(300, 10, 35, 35);
        self.expandButon.backgroundColor = [UIColor greenColor];
        [self.expandButon addTarget:self action:@selector(expandRows:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.expandButon];
    }
    return self;
}

- (void) expandRows:(id) sender {
    if ([self.listener respondsToSelector:@selector(didTapOnHeaderView:)]) {
        [self.listener didTapOnHeaderView:self];
    }
}


@end
