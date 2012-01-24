//
//  VPPDropDown.m
//  VPPLibraries
//
//  Created by Víctor on 12/12/11.
//  Copyright (c) 2011 Víctor Pena Placer. All rights reserved.
//

#import "VPPDropDown.h"
#import "VPPDropDownElement.h"

#define CUSTOM_DETAILED_LABEL_COLOR_R	56.0
#define CUSTOM_DETAILED_LABEL_COLOR_G	84.0
#define CUSTOM_DETAILED_LABEL_COLOR_B	135.0


@implementation VPPDropDown
@synthesize delegate=_delegate;
@synthesize type=_type;
@synthesize elements=_elements;
@synthesize title=_title;
@synthesize indexPath=_rootIndexPath;
@synthesize expanded=_expanded;
@synthesize tableView=_tableView;
@synthesize usesEntireSection;

+ (UIColor *) detailColor {
    float R = CUSTOM_DETAILED_LABEL_COLOR_R/255.0;
    float G = CUSTOM_DETAILED_LABEL_COLOR_G/255.0;
    float B = CUSTOM_DETAILED_LABEL_COLOR_B/255.0;
    
    return [UIColor colorWithRed:R green:G blue:B alpha:1.0];
}

#pragma mark -
#pragma mark Constructors

- (VPPDropDown *) initWithTitle:(NSString *)title 
                           type:(VPPDropDownType)type
                      tableView:(UITableView *)tableView
                      indexPath:(NSIndexPath *)indexPath
                       elements:(NSArray *)elements 
                       delegate:(id<VPPDropDownDelegate>)delegate {
    
    if (self = [super init]) {
        _title = [title retain];
        _type = type;
        _elements = [elements retain];
        _delegate = [delegate retain];
        _rootIndexPath = [indexPath retain];
        _tableView = [tableView retain];
    }
    
    return self;
}


- (void) dealloc {
    if (_title != nil) {
        [_title release];
        _title = nil;
    }    
    if (_elements != nil) {
        [_elements release];
        _elements = nil;
    }
    if (_delegate != nil) {
        [_delegate release];
        _delegate = nil;
    }
    if (_rootIndexPath != nil) {
        [_rootIndexPath release];
        _rootIndexPath = nil;
    }
    if (_tableView != nil) {
        [_tableView release];
        _tableView = nil;
    }
    
    [super dealloc];
}


- (VPPDropDown *) initDisclosureWithTitle:(NSString *)title 
                                tableView:(UITableView *)tableView
                                indexPath:(NSIndexPath *)indexPath
                                 delegate:(id<VPPDropDownDelegate>)delegate
                            elementTitles:(NSString *)firstObject, ... {
    NSMutableArray *arr = [NSMutableArray array];
    
    NSString *eachObject;
    va_list argumentList;
    VPPDropDownElement *element;
    if (firstObject) // The first argument isn't part of the varargs list,
    {                                   // so we'll handle it separately.
        element = [[VPPDropDownElement alloc] init];
        element.title = firstObject;
        element.object = nil;
        [arr addObject:element];
        [element release];
        va_start(argumentList, firstObject); // Start scanning for arguments after firstObject.
        while ((eachObject = va_arg(argumentList, NSString *))) {// As many times as we can get an argument of type "NSString *"
            // that isn't nil, add it to self's contents.
            element = [[VPPDropDownElement alloc] init];
            element.title = eachObject;
            element.object = nil;
            [arr addObject:element];
            [element release];
        }
        va_end(argumentList);
    }

    return [self initWithTitle:title type:VPPDropDownTypeDisclosure tableView:tableView indexPath:indexPath elements:arr delegate:delegate];
}

- (VPPDropDown *) initSelectionWithTitle:(NSString *)title
                               tableView:(UITableView *)tableView
                               indexPath:(NSIndexPath *)indexPath
                                delegate:(id<VPPDropDownDelegate>)delegate 
                           selectedIndex:(int)selectedIndex
                           elementTitles:(NSString *)firstObject, ... {
    NSMutableArray *arr = [NSMutableArray array];
    
    NSString *eachObject;
    va_list argumentList;
    VPPDropDownElement *element;
    if (firstObject) // The first argument isn't part of the varargs list,
    {                                   // so we'll handle it separately.
        element = [[VPPDropDownElement alloc] init];
        element.title = firstObject;
        element.object = nil;
        [arr addObject:element];
        [element release];
        va_start(argumentList, firstObject); // Start scanning for arguments after firstObject.
        while ((eachObject = va_arg(argumentList, NSString *))) {// As many times as we can get an argument of type "NSString *"
            // that isn't nil, add it to self's contents.
            element = [[VPPDropDownElement alloc] init];
            element.title = eachObject;
            element.object = nil;
            [arr addObject:element];
            [element release];
        }
        va_end(argumentList);
    }
    
    VPPDropDown *dd = [self initWithTitle:title type:VPPDropDownTypeSelection tableView:tableView indexPath:indexPath elements:arr delegate:delegate];
    dd->_selectedIndex = selectedIndex;
    
    return dd;
}


#pragma mark -
#pragma mark Query methods

- (BOOL) containsRelativeIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != _rootIndexPath.section) {
        return NO;
    }
    
    int tmp = indexPath.row - _rootIndexPath.row;
    return (tmp >= 0) && (tmp <= [self numberOfRows]);
}

- (NSIndexPath *) convertIndexPath:(NSIndexPath *)indexPath {
    if (![self containsRelativeIndexPath:indexPath]) {
        return nil;
    }
    
    NSIndexPath *new = [NSIndexPath indexPathForRow:indexPath.row-_rootIndexPath.row inSection:_rootIndexPath.section];
    
    return new;
}


- (BOOL) isRootCellAtRelativeIndexPath:(NSIndexPath *)relativeIndexPath {
    NSIndexPath *converted = [self convertIndexPath:relativeIndexPath];
    
    if (!converted) {
        return NO;
    }
    
    return converted.row == 0;
}

#pragma mark -
#pragma mark Table View Data Source

- (int) numberOfRows {
    int tmp = 0; // root cell is not counted
    if (_expanded) {
        tmp += [_elements count];
    }
    
    return tmp;
}

- (UITableViewCell *) disclosureCellForRowAtRelativeIndexPath:(NSIndexPath *)indexPath globalIndexPath:(NSIndexPath *)globalIndexPath  {
    static NSString *SelectionCellIdentifier = @"VPPDropDownDisclosureCell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:SelectionCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SelectionCellIdentifier] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.textColor = [UIColor darkTextColor];    
    cell.accessoryView = nil;
    cell.detailTextLabel.text = nil;
    cell.textLabel.textColor = [UIColor darkTextColor];
    
    NSIndexPath *iPath = [self convertIndexPath:indexPath];
    
    if (iPath.row == 0) {
        cell.textLabel.text = _title;
        if (_expanded) {
            UIImageView *imView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UITableContract"]];
            cell.accessoryView = imView;
            [imView release];
            cell.textLabel.textColor = [VPPDropDown detailColor];
        }
        else {
            UIImageView *imView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UITableExpand"]];
            cell.accessoryView = imView;
            [imView release];            
        }
        
    }
    else {
        VPPDropDownElement *elt = (VPPDropDownElement*)[_elements objectAtIndex:iPath.row-1]; // -1 because options cells start in 1 (0 is root cell)
        cell.textLabel.text = elt.title;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (UITableViewCell *) selectionCellForRowAtRelativeIndexPath:(NSIndexPath *)indexPath globalIndexPath:(NSIndexPath *)globalIndexPath  {
    static NSString *SelectionCellIdentifier = @"VPPDropDownSelectionCell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:SelectionCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SelectionCellIdentifier] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.textColor = [UIColor darkTextColor];    
    cell.accessoryView = nil;
    cell.detailTextLabel.text = nil;
    cell.textLabel.textColor = [UIColor darkTextColor];
    
    NSIndexPath *iPath = [self convertIndexPath:indexPath];
    
    if (iPath.row == 0) {
        cell.textLabel.text = _title;
        if (_expanded) {
            UIImageView *imView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UITableContract"]];
            cell.accessoryView = imView;
            [imView release];
            cell.textLabel.textColor = [VPPDropDown detailColor];
        }
        else {
            cell.detailTextLabel.text = [(VPPDropDownElement*)[_elements objectAtIndex:_selectedIndex] title];            
            UIImageView *imView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UITableExpand"]];
            cell.accessoryView = imView;
            [imView release];            
        }
                                
    }
    else {
        VPPDropDownElement *elt = (VPPDropDownElement*)[_elements objectAtIndex:iPath.row-1]; // -1 because options cells start in 1 (0 is root cell)
        cell.textLabel.text = elt.title;
        if (_selectedIndex == iPath.row-1) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.textLabel.textColor = [VPPDropDown detailColor];
        }
    }
    
    return cell;
}


- (UITableViewCell *) customCellForRowAtRelativeIndexPath:(NSIndexPath *)relativeIndexPath globalIndexPath:(NSIndexPath *)globalIndexPath {
    NSIndexPath *iPath = [self convertIndexPath:relativeIndexPath];
    
    UITableViewCell *cell = nil;
    if (iPath.row == 0) {
        cell = [_delegate dropDown:self rootCellAtGlobalIndexPath:globalIndexPath];
        
    }
    else {
        cell = [_delegate dropDown:self cellForElement:(VPPDropDownElement*)[_elements objectAtIndex:iPath.row-1] atGlobalIndexPath:globalIndexPath];
    }
    
    // if user doesn't return a customized cell, we'll create a basic one
    if (cell == nil) {
        cell = [self disclosureCellForRowAtRelativeIndexPath:relativeIndexPath globalIndexPath:globalIndexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
        
    if (iPath.row == 0) {
        if (_expanded) {
            UIImageView *imView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UITableContract"]];
            cell.accessoryView = imView;
            [imView release];
        }
        else {
            UIImageView *imView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UITableExpand"]];
            cell.accessoryView = imView;
            [imView release];            
        }
        
    }
    
    return cell;
}



- (UITableViewCell *) cellForRowAtRelativeIndexPath:(NSIndexPath *)indexPath globalIndexPath:(NSIndexPath *)globalIndexPath  {
    if (![self containsRelativeIndexPath:indexPath]) {
        NSLog(@"VPPDropDown - Receveing actions about an unknown cell");
        return nil;
    }
    
    switch (_type) {
        case VPPDropDownTypeDisclosure:
            return [self disclosureCellForRowAtRelativeIndexPath:indexPath globalIndexPath:globalIndexPath];

        case VPPDropDownTypeSelection:
            return [self selectionCellForRowAtRelativeIndexPath:indexPath globalIndexPath:globalIndexPath];

        case VPPDropDownTypeCustom:
            return [self customCellForRowAtRelativeIndexPath:indexPath globalIndexPath:globalIndexPath];
    }
    
    return nil;
}


#pragma mark -
#pragma mark Table View Delegate

- (void) toggleDropDown {
    _expanded = !_expanded;

    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 1; i <= [_elements count]; i++) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:_rootIndexPath.row+i inSection:_rootIndexPath.section];
        [indexPaths addObject:ip];
    }
    
    if (self.usesEntireSection) {
        // we can add or 
        if (_expanded) {
            // table view insert rows at index paths blah
            [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        
        else {
            // table view remove rows at index paths blah
            [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];        
        }
        
        [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_rootIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }

    else {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:_rootIndexPath.section];
        [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void) disclosureDidSelectRowAtRelativeIndexPath:(NSIndexPath *)relativeIndexPath globalIndexPath:(NSIndexPath *)globalIndexPath {
    NSIndexPath *iPath = [self convertIndexPath:relativeIndexPath];
        
    // delegate would do whatever it wants: change nspreference, ...
    [_delegate dropDown:self elementSelected:[_elements objectAtIndex:iPath.row-1] atGlobalIndexPath:globalIndexPath];
}

- (void) selectionDidSelectRowAtRelativeIndexPath:(NSIndexPath *)relativeIndexPath globalIndexPath:(NSIndexPath *)globalIndexPath {
    NSIndexPath *iPath = [self convertIndexPath:relativeIndexPath];
    NSIndexPath *previousSelectedItem = [NSIndexPath indexPathForRow:_selectedIndex+1 inSection:relativeIndexPath.section];

    _selectedIndex = iPath.row-1;
    
    // delegate would do whatever it wants: change nspreference, ...
    [_delegate dropDown:self elementSelected:[_elements objectAtIndex:_selectedIndex] atGlobalIndexPath:globalIndexPath];
    
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:previousSelectedItem, _rootIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:globalIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
}


- (void) didSelectRowAtRelativeIndexPath:(NSIndexPath *)relativeIndexPath
                         globalIndexPath:(NSIndexPath *)globalIndexPath {
    if ([self containsRelativeIndexPath:relativeIndexPath]) {
        if ([self convertIndexPath:relativeIndexPath].row == 0) {
            // we are on root cell
            [self toggleDropDown];
        }
        
        else {
            switch (_type) {
                case VPPDropDownTypeCustom: // at this time, clicking on custom dropdown does the same thing than clicking on disclosure
                case VPPDropDownTypeDisclosure:
                    [self disclosureDidSelectRowAtRelativeIndexPath:relativeIndexPath globalIndexPath:globalIndexPath];
                    break;
                case VPPDropDownTypeSelection:
                    [self selectionDidSelectRowAtRelativeIndexPath:relativeIndexPath globalIndexPath:globalIndexPath];
                    [_tableView deselectRowAtIndexPath:globalIndexPath animated:YES];
                    break;
            }
        }
    }
    
    else {
        NSLog(@"VPPDropDown - Receveing actions about an unknown cell");
    }
}


@end



//Copied from http://developer.apple.com/library/mac/#qa/qa1405/_index.html
//
//- (void) appendObjects:(id) firstObject, ...
//{
//    id eachObject;
//    va_list argumentList;
//    if (firstObject) // The first argument isn't part of the varargs list,
//    {                                   // so we'll handle it separately.
//        [self addObject: firstObject];
//        va_start(argumentList, firstObject); // Start scanning for arguments after firstObject.
//        while (eachObject = va_arg(argumentList, id)) // As many times as we can get an argument of type "id"
//            [self addObject: eachObject]; // that isn't nil, add it to self's contents.
//        va_end(argumentList);
//    }
//}