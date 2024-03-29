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
static NSString* const TITLE_NAME = @"Контакты";
static NSString* const BACK_BUTTON_IMAGE = @"arrow_left";

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

- (void) viewDidLoad {
    [super viewDidLoad];
    self.title = TITLE_NAME;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:BACK_BUTTON_IMAGE] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                              style:UIBarButtonItemStyleDone target:self
                                                             action:@selector(popToRootView:)];
    self.navigationItem.leftBarButtonItem = backButton;

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tableView.scrollEnabled = ![self areAllCellsVisible];

}

#pragma mark - Navigation

- (void)popToRootView:(id) sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Cells visibility check

- (BOOL) areAllCellsVisible {
    NSUInteger visibleCount = [self.tableView.visibleCells count];
    NSUInteger allCount = [self.phoneNumbers count];
    return allCount == visibleCount;
}

#pragma mark - CustomBackButton

- (void) setCustomNavigationBackButton
{
    UIImage *backBtn = [UIImage imageNamed:BACK_BUTTON_IMAGE];
    backBtn = [backBtn imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil]];
    self.navigationController.navigationBar.backIndicatorImage = backBtn;
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = backBtn;
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
    headerView.layer.borderWidth = 0.5f;
    headerView.layer.borderColor = [UIColor colorWithRed:(223/255.0) green:(223/255.0) blue:(223/255.0) alpha:1].CGColor;
    
    UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMidX(headerView.bounds) - 75, CGRectGetMidY(headerView.bounds) - 75, 150, 150)];
    [headerView addSubview:image];
    image.self.image = [self circularScaleAndCropImage:self.image frame:CGRectMake(0, 0, 150, 150)];
    
    UILabel* fullName = [[UILabel alloc] init];
    [headerView addSubview:fullName];
    fullName.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:23];
    fullName.text = [NSString stringWithFormat:@"%@ %@", self.lastName, self.firstName];
    [fullName setTextAlignment:NSTextAlignmentCenter];
    
    fullName.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [fullName.centerXAnchor constraintEqualToAnchor:headerView.centerXAnchor],
                                              [fullName.centerYAnchor constraintEqualToAnchor:headerView.centerYAnchor constant:+100],
                                              [fullName.heightAnchor constraintEqualToConstant:35],
                                              [fullName.widthAnchor constraintEqualToConstant:300]
                                              ]];
    
    return headerView;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - DrawAvatar

- (UIImage*) circularScaleAndCropImage:(UIImage*)image frame:(CGRect)frame {

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(frame.size.width, frame.size.height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat rectWidth = frame.size.width;
    CGFloat rectHeight = frame.size.height;
    
    CGFloat scaleFactorX = rectWidth/imageWidth;
    CGFloat scaleFactorY = rectHeight/imageHeight;
    
    CGFloat imageCentreX = rectWidth/2;
    CGFloat imageCentreY = rectHeight/2;
    
    CGFloat radius = rectWidth/2;
    CGContextBeginPath (context);
    CGContextAddArc (context, imageCentreX, imageCentreY, radius, 0, 2*M_PI, 0);
    CGContextClosePath (context);
    CGContextClip (context);
    
    CGContextScaleCTM (context, scaleFactorX, scaleFactorY);
    
    CGRect myRect = CGRectMake(0, 0, imageWidth, imageHeight);
    [image drawInRect:myRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
















