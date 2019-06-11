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
@property (strong, nonatomic) NSArray* groupOfContacts;
@property (strong, nonatomic) NSMutableArray* phoneNumbersArray;
@property (strong, nonatomic) NSMutableArray* sectionsArray;
@property (strong, nonatomic) NSDictionary* contactsById;
@property (strong, nonatomic) NSMutableArray* sectionsExpendedState;
@property (strong, nonatomic) NSSet* russianAlphabet;


@end

static NSString* cellIdentifier = @"Cell";
static NSString* headerIdentifier = @"Header";
static NSString* const TITLE_NAME = @"Контакты";

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
    self.title = TITLE_NAME;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    
    self.russianAlphabet = [NSSet setWithObjects:@"а",@"б",@"в",@"г",@"д",@"е",@"ё",@"ж",@"з",@"и",@"й",@"к",@"л",@"м",@"н",@"о",
                                                @"п",@"р",@"с",@"т",@"у",@"ф",@"х",@"ц",@"ч",@"щ",@"ъ",@"ы", @"ь",@"э",@"ю", @"я",nil];
    
    self.groupOfContacts = [NSMutableArray array];
    
    UINib* nib = [UINib nibWithNibName:@"CustomTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    
    [self checkPermissionForCNContacts];

}

- (void) showContactsView {
    [self getAllContacts];
    
    self.sectionsArray = [NSMutableArray array];
    
    NSString* currentLetter = nil;
    
    for (CNContact* contact in self.groupOfContacts) {
        
        NSString* groupName = contact.familyName.length == 0 ? contact.givenName : contact.familyName;
        
        NSString* firstLetter = [groupName substringToIndex:1];
        
        SectionName* section = nil;
        
        if ([currentLetter isEqualToString:firstLetter]) {
            section = [self.sectionsArray lastObject];
        } else {
            section = [[SectionName alloc] init];
            BOOL isValidName =
            [self.russianAlphabet containsObject:[firstLetter lowercaseString]] || [firstLetter rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location != NSNotFound;
            section.sectionName = isValidName ? firstLetter : @"#";
            section.items = [NSMutableArray array];
            currentLetter = firstLetter;
            [self.sectionsArray addObject:section];
        }
        
        ContactTableItem* contactItem = [[ContactTableItem alloc] initWith:contact.identifier name:[NSString stringWithFormat:@"%@ %@", contact.familyName, contact.givenName]];
        [section.items addObject:contactItem];
    }
    
    [self.tableView registerClass:[CustomHeaderView class] forHeaderFooterViewReuseIdentifier:headerIdentifier];
    
    self.sectionsExpendedState = [NSMutableArray array];
    for (int i = 0; i < [self.sectionsArray count]; i++) {
        [self.sectionsExpendedState addObject:@NO];
    }
}


#pragma mark - Contacts

- (void)checkPermissionForCNContacts {
    
    switch ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts])
    {
        case CNAuthorizationStatusNotDetermined:
        case CNAuthorizationStatusRestricted:
        case CNAuthorizationStatusDenied:
            [self showNoAccessView];
            self.tableView.hidden = YES;
            break;
        case CNAuthorizationStatusAuthorized:
            [self showContactsView];
            break;
    }
}


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
                                                    
                                                }];

        self.contactsById = [NSDictionary dictionaryWithObjects:allContact
                                                        forKeys:[allContact valueForKey:@"identifier"]];
        
        self.groupOfContacts = [allContact sortedArrayUsingComparator:^NSComparisonResult(CNContact* obj1, CNContact* obj2) {
            
            NSString* str1 = !(obj1.familyName.length == 0) ? obj1.familyName : obj1.givenName;
            NSString* str2 = !(obj2.familyName.length == 0) ? obj2.familyName : obj2.givenName;
            
            NSString *s1 = [str1 substringToIndex:1];
            NSString *s2 = [str2 substringToIndex:1];
            BOOL b1 = [s1 canBeConvertedToEncoding:NSISOLatin1StringEncoding];
            BOOL b2 = [s2 canBeConvertedToEncoding:NSISOLatin1StringEncoding];
            
            if ((b1 == b2) && b1) {
                NSRange r1 = [s1 rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
                NSRange r2 = [s2 rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
                if (r1.location == r2.location ) {
                    return [str1 compare:str2 options:NSDiacriticInsensitiveSearch|NSCaseInsensitiveSearch];
                } else {
                    if ([s1 rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound) {
                        return NSOrderedAscending;
                    }
                    return NSOrderedDescending;
                }
            } else if((b1 == b2) && !b1){
                return [str1 compare:str2 options:NSDiacriticInsensitiveSearch|NSCaseInsensitiveSearch];
            } else {
                if (b1) return NSOrderedDescending;
                return NSOrderedAscending;
            }
            
        }];;
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

#pragma mark - NoAccessView

- (void) showNoAccessView {
    UIView* noAccessView = [[UIView alloc] init];
    [self.view addSubview:noAccessView];
    noAccessView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [noAccessView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
                                              [noAccessView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
                                              [noAccessView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
                                              [noAccessView.topAnchor constraintEqualToAnchor:self.view.topAnchor]
                                              ]];
    
    noAccessView.backgroundColor = [UIColor colorWithRed:(249/255.0) green:(249/255.0) blue:(249/255.0) alpha:1];
    
    
    UITextView* noAccessMesage = [[UITextView alloc] init];
    [noAccessView addSubview:noAccessMesage];
    noAccessMesage.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [noAccessMesage.centerXAnchor constraintEqualToAnchor:noAccessView.centerXAnchor],
                                              [noAccessMesage.centerYAnchor constraintEqualToAnchor:noAccessView.centerYAnchor],
                                              [noAccessMesage.heightAnchor constraintEqualToConstant:150],
                                              [noAccessMesage.widthAnchor constraintEqualToConstant:300]
                                              ]];
    
    
    noAccessMesage.backgroundColor = [UIColor colorWithRed:(249/255.0) green:(249/255.0) blue:(249/255.0) alpha:1];
    [noAccessMesage setTextAlignment:NSTextAlignmentCenter];
    [noAccessMesage setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:17]];
    noAccessMesage.text = @"Доступ к списку контактов запрещен. Войдите в Settings и разрешите доступ.";
    noAccessMesage.editable = NO;
}


#pragma mark - UITableViewDataSourse

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sectionsArray count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    SectionName* sec = [self.sectionsArray objectAtIndex:section];
    
    CustomHeaderView* customHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    customHeader.layer.borderWidth = 0.5f;
    customHeader.layer.borderColor = [UIColor colorWithRed:(223/255.0) green:(223/255.0) blue:(223/255.0) alpha:1].CGColor;
    customHeader.expandButon.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [customHeader.expandButon.trailingAnchor constraintEqualToAnchor:customHeader.trailingAnchor constant:-20],
                                              [customHeader.expandButon.centerYAnchor constraintEqualToAnchor:customHeader.centerYAnchor],
                                              [customHeader.expandButon.heightAnchor constraintEqualToConstant:35],
                                              [customHeader.expandButon.widthAnchor constraintEqualToConstant:35]
                                              ]];
    
    UILabel* alphabetLetter = [[UILabel alloc] init];
    [customHeader addSubview:alphabetLetter];
    alphabetLetter.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [alphabetLetter.leadingAnchor constraintEqualToAnchor:customHeader.leadingAnchor constant:25],
                                              [alphabetLetter.centerYAnchor constraintEqualToAnchor:customHeader.centerYAnchor],
                                              [alphabetLetter.heightAnchor constraintEqualToConstant:23],
                                              [alphabetLetter.widthAnchor constraintEqualToConstant:23]
                                              ]];
    
    alphabetLetter.text = [NSString stringWithFormat:@"%@", sec.sectionName];
    alphabetLetter.textColor = [UIColor blackColor];
    alphabetLetter.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    customHeader.alphabetLetter = alphabetLetter;
    
    UILabel* contactsAmount = [[UILabel alloc] init];
    [customHeader addSubview:contactsAmount];
    contactsAmount.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [contactsAmount.leadingAnchor constraintEqualToAnchor:alphabetLetter.trailingAnchor constant:10],
                                              [contactsAmount.centerYAnchor constraintEqualToAnchor:customHeader.centerYAnchor],
                                              [contactsAmount.heightAnchor constraintEqualToConstant:35],
                                              [contactsAmount.widthAnchor constraintEqualToConstant:100]
                                              ]];
    
    contactsAmount.text = [NSString stringWithFormat:@"контактов:%@",  @([sec.items count])];
    contactsAmount.textColor= [UIColor colorWithRed:(153/255.0) green:(153/255.0) blue:(153/255.0) alpha:1];
    customHeader.contactsAmount = contactsAmount;
    
    customHeader.section = section;
    customHeader.listener = self;
    [self setUpHeaderCollor:customHeader];
    
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
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:168 green:246 blue:254 alpha:1];
    [cell setSelectedBackgroundView:bgColorView];
    
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
        [self.sectionsArray removeObject:section];
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
    [self.navigationController presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - CustomHeaderViewListener

- (void) didTapOnHeaderView:(CustomHeaderView *)header {
    
    BOOL state = [self.sectionsExpendedState[header.section] boolValue];
    self.sectionsExpendedState[header.section] = @(!state);
    header.isExpanded = !state;
    
    [self setUpHeaderExpanding:header];
    [self setUpHeaderCollor:header];
}

- (void) setUpHeaderExpanding:(CustomHeaderView*) header {
    
    SectionName* section = [self.sectionsArray objectAtIndex:header.section];
    
    NSMutableArray* paths = [NSMutableArray array];
    for (int i = 0; i < [section.items count]; i++) {
        NSIndexPath* path = [NSIndexPath indexPathForRow:i inSection:header.section];
        [paths addObject:path];
    }
    
    if (header.isExpanded) {
        [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
        [header.expandButon setImage:[UIImage imageNamed:@"arrow_up"] forState:UIControlStateNormal];
    } else {
        [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
        [header.expandButon setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    }
}

- (void) setUpHeaderCollor:(CustomHeaderView*) header {
    if (header.isExpanded) {
        header.alphabetLetter.textColor = [UIColor colorWithRed:(217/255.0) green:(145/255.0) blue:(0/255.0) alpha:1];
        header.contactsAmount.textColor = [UIColor colorWithRed:(217/255.0) green:(145/255.0) blue:(0/255.0) alpha:1];
    } else {
        header.alphabetLetter.textColor = [UIColor blackColor];
        header.contactsAmount.textColor = [UIColor colorWithRed:(153/255.0) green:(153/255.0) blue:(153/255.0) alpha:1];
    }
}

#pragma mark - CustomTableViewCellListener

- (void) didTapOnCustomViewCell:(CustomTableViewCell *)header {

    NSIndexPath* path = [self.tableView indexPathForCell:header];
    
    SectionName* section = [self.sectionsArray objectAtIndex:path.section];
    ContactTableItem* contactItem = [section.items objectAtIndex:path.row];
    CNContact* contact = [self.contactsById objectForKey:contactItem.identifier];
    
    UIImage* photo = contact.imageDataAvailable ? [[UIImage alloc] initWithData:contact.imageData] : [UIImage imageNamed:@"noPhoto"];
    
    ContactInfoViewController* contactInfo = [[ContactInfoViewController alloc] initWithNibName:@"ContactInfoViewController" bundle:nil];
    contactInfo.lastName = contact.familyName;
    contactInfo.firstName = contact.givenName;
    contactInfo.phoneNumbers = contact.phoneNumbers;
    contactInfo.image = photo;
    
    [self.navigationController pushViewController:contactInfo animated:YES];
}


@end













