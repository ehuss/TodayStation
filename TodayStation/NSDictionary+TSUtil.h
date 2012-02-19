//
//  NSDictionary+TSUtil.h
//  TodayStation
//
//  Created by Eric Huss on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (TSUtil)
- (id)tsObjectForKeyPath:(NSString *)inKeyPath numberToString:(BOOL)nts;
@end
