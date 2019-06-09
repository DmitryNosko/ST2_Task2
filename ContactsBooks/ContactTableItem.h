//
//  ContactTableItem.h
//  ContactsBooks
//
//  Created by Dima on 6/8/19.
//  Copyright © 2019 Dima. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactTableItem : NSObject
@property (strong, nonatomic) NSString* identifier;
@property (strong, nonatomic) NSString* name;

- (instancetype)initWith:(NSString*) identifier name:(NSString*) name;
@end
