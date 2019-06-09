//
//  MainContactsViewController.m
//  ContactsBooks
//
//  Created by Dima on 6/8/19.
//  Copyright © 2019 Dima. All rights reserved.
//

#import "MainContactsViewController.h"
#import "CustomTableViewCell.h"
#import "SectionName.h"
#import "ContactTableItem.h"
#import "CustomHeaderView.h"
#import "ContactInfoViewController.h"
#import <Contacts/Contacts.h>


@interface MainContactsViewController () <UITableViewDataSource, UITableViewDelegate, CustomHeaderViewListener, CustomTableViewCellListener>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CNContactStore* adressBook;
@property (strong, nonatomic) NSMutableArray* groupOfContacts;
@property (strong, nonatomic) NSMutableArray* phoneNumbersArray;
@property (strong, nonatomic) NSMutableArray* sectionsArray;
@property (strong, nonatomic) NSDictionary* contactsById;
@property (strong, nonatomic) NSMutableArray* sectionsExpendedState;
@end

static NSString* cellIdentifier = @"Cell";
static NSString* headerIdentifier = @"Header";

@implementation MainContactsViewController

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
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.groupOfContacts = [NSMutableArray array];
    UINib* nib = [UINib nibWithNibName:@"CustomTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    
    if (status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Access to contacts." message:@"This app requires access to contacts because ..." preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"Go to Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:TRUE completion:nil];
        return;
    }
    
    [self getAllContacts];
    
    self.sectionsArray = [NSMutableArray array];
    
    NSString* currentLetter = nil;
    
    for (CNContact* contact in self.groupOfContacts) {
        NSString* family = contact.familyName;
        
        NSString* firstLetter = [family substringToIndex:1];
        
        SectionName* section = nil;
        
        if (![currentLetter isEqualToString:firstLetter]) {
            section = [[SectionName alloc] init];
            section.sectionName = firstLetter;
            section.items = [NSMutableArray array];
            currentLetter = firstLetter;
            [self.sectionsArray addObject:section];
        } else {
            section = [self.sectionsArray lastObject];
        }
        ContactTableItem* contactItem = [[ContactTableItem alloc] initWith:contact.identifier name:[NSString stringWithFormat:@"%@ %@", family, contact.givenName]];
        [section.items addObject:contactItem];
    }
    
    [self.tableView registerClass:[CustomHeaderView class] forHeaderFooterViewReuseIdentifier:headerIdentifier];
    
    self.sectionsExpendedState = [NSMutableArray array];
    for (int i = 0; i < [self.sectionsArray count]; i++) {
        [self.sectionsExpendedState addObject:@NO];
    }
    
}

#pragma mark - Contacts

- (void) getAllContacts {
    if ([CNContactStore class]) {
        
        self.adressBook = [[CNContactStore alloc] init];
        
        NSArray* keysToFetch = @[CNContactGivenNameKey,
                                 CNContactFamilyNameKey,
                                 CNContactPhoneNumbersKey,
                                 CNContactImageDataAvailableKey,
                                 CNContactImageDataKey];
        
        CNContactFetchRequest* fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
        NSMutableArray* allContact = [[NSMutableArray alloc] init];
        [self.adressBook enumerateContactsWithFetchRequest:fetchRequest
                                                     error:nil
                                                usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                                                    [allContact addObject:contact];
                                                    [allContact sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]]];
                                                }];
        
        self.contactsById = [NSDictionary dictionaryWithObjects:allContact
                                                        forKeys:[allContact valueForKey:@"identifier"]];
        self.groupOfContacts = allContact;
    }
}

- (void) deleteContact:(CNContact*) contactToDelte {
    
    [self.adressBook requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted == YES) {
            
            if (error) {
                NSLog(@"error fetching contacts %@", error);
            } else {
                CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
                
                [saveRequest deleteContact:[contactToDelte mutableCopy]];
                
                [self.adressBook executeSaveRequest:saveRequest error:nil];
            }
        }
    }];
    
}


#pragma mark - UITableViewDataSourse

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sectionsArray count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    SectionName* sec = [self.sectionsArray objectAtIndex:section];
    CustomHeaderView* customHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    customHeader.textLabel.text = [NSString stringWithFormat:@"%@  contacts:%@", sec.sectionName, @([sec.items count])];
    customHeader.section = section;
    customHeader.listener = self;
    
    return customHeader;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSNumber* state = self.sectionsExpendedState[section];
    SectionName* sec = [self.sectionsArray objectAtIndex:section];
    return [state boolValue] ? 0 : [sec.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomTableViewCell* cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.listener = self;
    SectionName* section = [self.sectionsArray objectAtIndex:indexPath.section];
    
    NSString* contactFullName = [[section.items objectAtIndex:indexPath.row] name];
    
    cell.infLabel.text = [NSString stringWithFormat:@"%@", contactFullName];
    
    return cell;
}


#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        SectionName* section = [self.sectionsArray objectAtIndex:indexPath.section];
        
        ContactTableItem* contactItem = [section.items objectAtIndex:indexPath.row];
        
        [self deleteContact:[self.contactsById objectForKey:contactItem.identifier]];
        
        [section.items removeObjectAtIndex:indexPath.row];
        
        [self.tableView reloadData];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SectionName* section = [self.sectionsArray objectAtIndex:indexPath.section];
    ContactTableItem* contactItem = [section.items objectAtIndex:indexPath.row];
    
    CNContact* contact = [self.contactsById objectForKey:contactItem.identifier];
    NSString* phone = [[[contact.phoneNumbers firstObject] value] valueForKey:@"digits"];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Contact info."
                                                                   message:[NSString stringWithFormat:@"FirstName: %@ \nLastName: %@ \nPhone number: %@", contact.givenName, contact.familyName, phone]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - CustomHeaderViewListener

- (void) didTapOnHeaderView:(CustomHeaderView *)header {

    BOOL state = [self.sectionsExpendedState[header.section] boolValue];
    self.sectionsExpendedState[header.section] = @(!state);

    SectionName* section = [self.sectionsArray objectAtIndex:header.section];

    if (state) {
        NSMutableArray* paths = [NSMutableArray array];
        for (int i = 0; i < [section.items count]; i++) {
            NSIndexPath* path = [NSIndexPath indexPathForRow:i inSection:header.section];
            [paths addObject:path];
        }
        [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        NSMutableArray* paths = [NSMutableArray array];
        for (int i = 0; i < [section.items count]; i++) {
            NSIndexPath* path = [NSIndexPath indexPathForRow:i inSection:header.section];
            [paths addObject:path];
            }

        [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
}
}

#pragma mark - CustomTableViewCellListener

- (void) didTapOnCustomViewCell:(CustomTableViewCell *)header {

    NSIndexPath* path = [self.tableView indexPathForCell:header];
    
    SectionName* section = [self.sectionsArray objectAtIndex:path.section];
    ContactTableItem* contactItem = [section.items objectAtIndex:path.row];
    CNContact* contact = [self.contactsById objectForKey:contactItem.identifier];
    
    UIImage* photo = contact.imageDataAvailable ? [[UIImage alloc] initWithData:contact.imageData] : nil;
    ContactInfoViewController* c = [[ContactInfoViewController alloc] initWith:contact.givenName lastName:contact.familyName phone:contact.phoneNumbers image:photo];
    [self.navigationController pushViewController:c animated:YES];
}


@end













