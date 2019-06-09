//
//  ContactInfoViewController.m
//  ContactsBooks
//
//  Created by Dima on 6/9/19.
//  Copyright © 2019 Dima. All rights reserved.
//

#import "ContactInfoViewController.h"

@interface ContactInfoViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableVIew;

@end

@implementation ContactInfoViewController

- (instancetype)initWith:(NSString*) firstName lastName:(NSString*) lastName phone:(NSArray*) phone image:(UIImage*) image
{
    self = [super init];
    if (self) {
        _firstName = firstName;
        _lastName = lastName;
        _phoneNumbers = phone;
        _image = image;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
