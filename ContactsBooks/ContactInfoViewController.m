//
//  ContactInfoViewController.m
//  ContactsBooks
//
//  Created by Dima on 6/9/19.
//  Copyright © 2019 Dima. All rights reserved.
//

#import "ContactInfoViewController.h"

@interface ContactInfoViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

static NSString* identifier = @"Cell";

@implementation ContactInfoViewController


- (void) loadView {
    [super loadView];
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
                                              [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
                                              [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
                                              [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor]
                                              ]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Contacts";
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    if ([self.phoneNumbers count] <= 4) {
        self.tableView.scrollEnabled = NO;
    }
    
}

#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.phoneNumbers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSArray* phonesNumbers = [[self.phoneNumbers valueForKey:@"value"] valueForKeyPath:@"digits"];
    
    cell.textLabel.text = [phonesNumbers objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 300;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 300)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMidX(headerView.bounds) - 75, CGRectGetMidY(headerView.bounds) - 75, 150, 150)];
    [image setImage:self.image];
    [headerView addSubview:image];
    
    UILabel* fullName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(headerView.bounds) - 50, CGRectGetMidY(headerView.bounds) + 100, 300, 40)];
    fullName.text = [NSString stringWithFormat:@"%@ %@", self.lastName, self.firstName];
    [headerView addSubview:fullName];
    return headerView;
}

//- (UIImage*) getAvatar {
//    CGSize size = CGSizeMake(150, 150);
//
//    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
//
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//    UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(size.width / 2, size.height / 3) radius:23 startAngle:0 endAngle:2 * M_PI clockwise:YES];
//    CGContextAddPath(context, path.CGPath);
//    CGContextDrawPath(context, kCGPathFill);
//    [self.image drawInRect:CGRectMake(size.width / 2,size.height / 2, 150, 150)];
//    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
//
//    UIGraphicsEndImageContext();
//    return image;
//}

@end
















