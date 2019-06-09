//
//  ContactInfoViewController.h
//  ContactsBooks
//
//  Created by Dima on 6/9/19.
//  Copyright © 2019 Dima. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactInfoViewController : UIViewController

@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSArray* phoneNumbers;
@property (strong, nonatomic) UIImage* image;

@end
