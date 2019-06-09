//
//  ContactTableItem.m
//  ContactsBooks
//
//  Created by Dima on 6/8/19.
//  Copyright © 2019 Dima. All rights reserved.
//

#import "ContactTableItem.h"

@implementation ContactTableItem

- (instancetype)initWith:(NSString*) identifier name:(NSString*) name
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _name = name;
    }
    return self;
}

@end
