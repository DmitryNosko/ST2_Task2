//
//  CustomHeaderView.h
//  ContactsBooks
//
//  Created by Dima on 6/8/19.
//  Copyright © 2019 Dima. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomHeaderView;

@protocol CustomHeaderViewListener <NSObject>
- (void) didTapOnHeaderView:(CustomHeaderView*) header;
@end

@interface CustomHeaderView : UITableViewHeaderFooterView
@property (weak, nonatomic) id<CustomHeaderViewListener> listener;
@property (assign, nonatomic) NSInteger section;
@property (strong, nonatomic) UIButton* expandButon;
@property (assign, nonatomic) BOOL isTapped;
@property (strong, nonatomic) UILabel* alphabetLetter;
@property (strong, nonatomic) UILabel* contactsAmount;
@end
