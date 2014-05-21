/*
 * This file is part of the Presenter package.
 * (c) James Tang <j@jamztang.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UITableView+Presenter.h"
#import "NSObject+Subclass.h"

@implementation UITableView (Presenter)

- (void)registerNib:(UINib *)nib
       forCellClass:(Class)aClass
withReuseIdentifier:(NSString *)identifier {
    [self registerNib:nib
         forCellClass:aClass
       cellIdentifier:identifier
  withReuseIdentifier:identifier];
}

- (void)registerNib:(UINib *)nib
       forCellClass:(Class)aClass
     cellIdentifier:(NSString *)cellIdentifier
withReuseIdentifier:(NSString *)identifier {

    NSString *className = [NSString stringWithFormat:@"%@-%@", NSStringFromClass(aClass), cellIdentifier];

    __strong Class newClass = NSClassFromString(className);

    if ( ! newClass) {
        newClass =[aClass newSubclassNamed:className
                                 protocols:NULL
                                     impls:PAIR_LIST {
                                         @selector(initWithStyle:reuseIdentifier:),
                                         BLOCK_CAST ^id (UITableViewCellStyle style, NSString *reuseIdentifier) {

                                             NSArray *topLevelObjects = [nib instantiateWithOwner:nil options:nil];

                                             __block id cell;

                                             [topLevelObjects enumerateObjectsUsingBlock:^(UITableViewCell *obj, NSUInteger idx, BOOL *stop) {
                                                 if ([obj isKindOfClass:aClass]) {
                                                     cell = obj; // forgiving to nibs that has only one cell without specifying identifiers
                                                     if ([obj.reuseIdentifier isEqualToString:cellIdentifier]) {
                                                         cell = obj;
                                                         *stop = YES;
                                                     }
                                                 }
                                             }];

                                             NSAssert2(cell != nil, @"%s: couldn't find a cell with identifier \"%@\" in the nib file.", __PRETTY_FUNCTION__, cellIdentifier);

                                             return cell;
                                         },
                                         NIL_PAIR
                                     }];
    }
    
    [self registerClass:newClass forCellReuseIdentifier:identifier];
}

@end
