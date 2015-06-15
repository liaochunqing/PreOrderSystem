//
//  StaffManagementSuperDataClass.m
//  PreOrderSystem
//
//  Created by SWen on 14-3-7.
//
//

#import "StaffManagementSuperDataClass.h"

@implementation StaffManagementSuperDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithStaffManagementSuperData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        NSMutableArray *postMutableArray = [[NSMutableArray alloc] init];
        NSArray *postArray = [dict objectForKey:@"glist"];
        for (NSDictionary *postDict in postArray)
        {
            StaffManagementPostDataClass *post = [[StaffManagementPostDataClass alloc] initWithStaffManagementPostData:postDict];
            [postMutableArray addObject:post];
        }
        self.postArray = postMutableArray;
        
        NSMutableArray *listMutableArray = [[NSMutableArray alloc] init];
        NSArray *listArray = [dict objectForKey:@"list"];
        for (NSDictionary *staffDict in listArray)
        {
            StaffManagementStaffInfoDataClass *staff = [[StaffManagementStaffInfoDataClass alloc] initWithStaffManagementStaffInfoData:staffDict];
            [listMutableArray addObject:staff];
        }
        self.staffListArray = listMutableArray;
        
        NSMutableArray *sortMutableArray = [[NSMutableArray alloc] init];
        NSArray *sortArray = [dict objectForKey:@"ofield"];
        for (NSDictionary *sortDict in sortArray)
        {
            StaffManagementSortDataClass *sortClass = [[StaffManagementSortDataClass alloc] initWithStaffManagementSortData:sortDict];
            [sortMutableArray addObject:sortClass];
        }
        self.sortArray = sortMutableArray;
    }
    return self;
}

@end

#pragma mark - StaffManagementPostSuperDataClass

@implementation StaffManagementPostSuperDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithStaffManagementPostSuperData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        NSMutableArray *postMutableArray = [[NSMutableArray alloc] init];
        NSArray *postArray = [dict objectForKey:@"list"];
        for (NSDictionary *postDict in postArray)
        {
            StaffManagementPostDataClass *post = [[StaffManagementPostDataClass alloc] initWithStaffManagementPostData:postDict];
            [postMutableArray addObject:post];
        }
        self.postListArray = postMutableArray;
        
        StaffManagementPostDataClass *samplePost = [[StaffManagementPostDataClass alloc] initWithStaffManagementPostData:[dict objectForKey:@"sample"]];
        self.samplePostClass = samplePost;
        self.roomNumberStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"pnumber"]];
    }
    return self;
}

@end

#pragma mark - StaffManagementSortDataClass

@implementation StaffManagementSortDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithStaffManagementSortData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.name = [dict objectForKey:@"name"];
        self.valueStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"value"]];
    }
    return self;
}

@end

#pragma mark - StaffManagementPostDataClass

@implementation StaffManagementPostDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithStaffManagementPostData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.postIdStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
        self.postName = [dict objectForKey:@"name"];
        
        NSMutableArray *authMutableArray = [[NSMutableArray alloc] init];
        NSArray *authArray = [dict objectForKey:@"auth"];
        for (NSDictionary *authDict in authArray)
        {
            StaffManagementAuthDataClass *auth = [[StaffManagementAuthDataClass alloc] initWithStaffManagementAuthData:authDict];
            [authMutableArray addObject:auth];
        }
        self.authArray = authMutableArray;
    }
    return self;
}

- (id)initWithPostClass:(StaffManagementPostDataClass *)postClass
{
    self = [super init];
    if (self)
    {
        self.postIdStr = postClass.postIdStr;
        self.postName = postClass.postName;
        
        NSMutableArray *authMutableArray = [[NSMutableArray alloc] init];
        NSArray *authArray = postClass.authArray;
        for (StaffManagementAuthDataClass *auth in authArray)
        {
            StaffManagementAuthDataClass *authClass = [[StaffManagementAuthDataClass alloc] initWithStaffAuthData:auth];
            [authMutableArray addObject:authClass];
        }
        self.authArray = authMutableArray;
    }
    return self;
}

@end

#pragma mark - StaffManagementStaffInfoDataClass

@implementation StaffManagementStaffInfoDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithStaffManagementStaffInfoData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.staffIdStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
        self.numberStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"number"]];
        self.postIdStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"gid"]];
        self.postName = [dict objectForKey:@"gname"];
        self.roomNumberStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"pnumber"]];
        self.name = [dict objectForKey:@"name"];
        self.pictureURL = [dict objectForKey:@"picture"];
        self.passwordStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"pwd"]];
        
        NSMutableArray *authMutableArray = [[NSMutableArray alloc] init];
        NSArray *authArray = [dict objectForKey:@"auth"];
        for (NSDictionary *authDict in authArray)
        {
            StaffManagementAuthDataClass *auth = [[StaffManagementAuthDataClass alloc] initWithStaffManagementAuthData:authDict];
            [authMutableArray addObject:auth];
        }
        self.authArray = authMutableArray;
    }
    return self;
}

- (id)initWithStaffInfoClass:(StaffManagementStaffInfoDataClass *)staffClass
{
    self = [super init];
    if (self)
    {
        self.staffIdStr = staffClass.staffIdStr;
        self.numberStr = staffClass.numberStr;
        self.postIdStr = staffClass.postIdStr;
        self.postName = staffClass.postName;
        self.roomNumberStr = staffClass.roomNumberStr;
        self.name = staffClass.name;
        self.pictureURL = staffClass.pictureURL;
        self.passwordStr = staffClass.passwordStr;
        
        NSMutableArray *authMutableArray = [[NSMutableArray alloc] init];
        NSArray *authArray = staffClass.authArray;;
        for (StaffManagementAuthDataClass *tempAuth in authArray)
        {
            StaffManagementAuthDataClass *auth = [[StaffManagementAuthDataClass alloc] initWithStaffAuthData:tempAuth];
            [authMutableArray addObject:auth];
        }
        self.authArray = authMutableArray;
    }
    return self;
}

@end

#pragma mark - StaffManagementAuthDataClass

@implementation StaffManagementAuthDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithStaffManagementAuthData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.indexStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"index"]];
        self.name = [dict objectForKey:@"name"];
        self.open = [[dict objectForKey:@"open"] boolValue];
        self.pageArray = [dict objectForKey:@"page"];
        
        NSMutableArray *childrenMutableArray = [[NSMutableArray alloc] init];
        NSArray *childrenArray = [dict objectForKey:@"children"];
        for (NSDictionary *subDict in childrenArray)
        {
            StaffManagementSubAuthDataClass *subAuth = [[StaffManagementSubAuthDataClass alloc] initWithStaffManagementSubAuthData:subDict];
            [childrenMutableArray addObject:subAuth];
        }
        self.childrenArray = childrenMutableArray;
    }
    return self;
}

- (id)initWithStaffAuthData:(StaffManagementAuthDataClass *)authClass
{
    self = [super init];
    if (self)
    {
        self.indexStr = authClass.indexStr;
        self.name = authClass.name;
        self.open = authClass.open;
        self.pageArray = authClass.pageArray;
        
        NSMutableArray *childrenMutableArray = [[NSMutableArray alloc] init];
        NSArray *childrenArray = authClass.childrenArray;;
        for (StaffManagementSubAuthDataClass *tempSubAuth in childrenArray)
        {
            StaffManagementSubAuthDataClass *subAuth = [[StaffManagementSubAuthDataClass alloc] initWithStaffSubAuthData:tempSubAuth];
            [childrenMutableArray addObject:subAuth];
        }
        self.childrenArray = childrenMutableArray;
    }
    return self;
}

@end

#pragma mark - StaffManagementSubAuthDataClass

@implementation StaffManagementSubAuthDataClass

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"===%@,dealloc===",self.class);
#endif
}

- (id)initWithStaffManagementSubAuthData:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.idStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
        self.indexStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"index"]];
        self.name = [dict objectForKey:@"name"];
        self.checkedArray = [dict objectForKey:@"checked"];
        self.uncheckedArray = [dict objectForKey:@"unchecked"];
        self.open = [[dict objectForKey:@"open"] boolValue];
    }
    return self;
}

- (id)initWithStaffSubAuthData:(StaffManagementSubAuthDataClass *)subAuthClass
{
    self = [super init];
    if (self)
    {
        self.idStr = subAuthClass.idStr;
        self.indexStr = subAuthClass.indexStr;
        self.name = subAuthClass.name;
        self.checkedArray = subAuthClass.checkedArray;
        self.uncheckedArray = subAuthClass.uncheckedArray;
        self.open = subAuthClass.open;
    }
    return self;
}

@end



