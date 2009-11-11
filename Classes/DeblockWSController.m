//
//  DeblockWSController.m
//  Deblock
//
//  Created by Maarten Billemont on 03/11/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "DeblockWSController.h"
#import "ASIFormDataRequest.h"
#import "NSDictionary_JSONExtensions.h"
#import "CryptUtils.h"

#define dScoreWSThread          @"scoreWSThread"
#define dScoreServlet           @"/scores.json"

#define dErrorHeader            @"X-Deblock-Error"
#define dErrorMissingName       @"missing.name"
#define dErrorMissingPass       @"missing.pass"
#define dErrorMissingCheck      @"missing.check"
#define dErrorIncorrectPass     @"incorrect.pass"
#define dErrorIncorrectCheck    @"incorrect.check"


@interface DeblockWSController ()

- (NSString *)checksumForName:(NSString *)name withScore:(NSInteger)score atTime:(NSNumber *)timeStamp;

@property (readwrite, retain) UIAlertView   *alertPassword;
@property (readwrite, retain) UIAlertView   *alertConnection;
@property (readwrite, retain) Player        *alertPlayer;

@end


@implementation DeblockWSController

@synthesize alertPlayer, alertPassword, alertConnection;

+ (DeblockWSController *)get {
    
    static DeblockWSController* instance;
    if (!instance)
        instance = [DeblockWSController new];
    
    return instance;
}

- (id)init {
    
    if (!(self = [super init]))
        return nil;
    
    requestsPlayer = [NSMutableDictionary new];
    
    return self;
}

- (void)reloadScores {

    [self submitScoreForPlayer:nil];
}


- (void)submitScoreForPlayer:(Player *)player {
    
    if (![[[NSThread currentThread] name] isEqualToString:dScoreWSThread]) {
        NSThread *scoreWSThread = [[NSThread alloc] initWithTarget:self selector:_cmd object:player];
        [scoreWSThread setName:dScoreWSThread];
        [scoreWSThread start];
        [scoreWSThread release];
        
        return;
    }

    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:dScoreServlet
                                                                            relativeToURL:[NSURL URLWithString:[DeblockConfig get].wsUrl]]];
    NSValue *requestValue = [NSValue valueWithPointer:request];
    [request setDelegate:self];

    if (player) {
        NSDate *achievedDate = [NSDate date];
        NSNumber *timeStamp = [NSNumber numberWithLongLong:[achievedDate timeIntervalSince1970] * 1000];
        [[Logger get] inf:@"Submitting score %d for %@ at %@", player.score, player.onlineName, achievedDate];

        [request setPostValue:[NSNumber numberWithInteger:player.score] forKey:@"score"];
        [request setPostValue:player.onlineName forKey:@"name"];
        [request setPostValue:player.pass forKey:@"pass"];
        [request setPostValue:timeStamp forKey:@"date"];
        [request setPostValue:[self checksumForName:player.onlineName withScore:player.score atTime:timeStamp] forKey:@"check"];
    }
    
    [requestsPlayer setObject:player? player: (id)[NSNull null] forKey:requestValue];
    [request startAsynchronous];
    [request retain];
    [pool drain];
}


- (NSString *)checksumForName:(NSString *)name withScore:(NSInteger)score atTime:(NSNumber *)timeStamp {
    
    NSDictionary *secrets = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Secret" ofType:@"plist"]];
    NSString *check = [CryptUtils md5:[NSString stringWithFormat:@"%@:%@:%d:%lld",
                                       [secrets objectForKey:@"Salt"], name, score, [timeStamp longLongValue]]];
    [[Logger get] dbg:@"checksum of: %@:%@:%d:%lld = %@",
     [secrets objectForKey:@"Salt"], name, score, [timeStamp longLongValue], check];

    return check;
}


- (void)requestFinished:(ASIHTTPRequest *)request {
    
    NSValue *requestValue = [NSValue valueWithPointer:request];
    Player *player = [requestsPlayer objectForKey:requestValue];
    if (player == (id)[NSNull null])
        player = nil;
    
    [[Logger get] dbg:@"Response Error: %@", [request error]];
    [[Logger get] dbg:@"Response Headers:\n%@", [request responseHeaders]];
    [[Logger get] dbg:@"Response Body:\n%@", [request responseString]];

    NSError *error = nil;
    NSDictionary *playersScoreHistory = [NSDictionary dictionaryWithJSONData:[request responseData] error:&error];
    if (error)
        [[Logger get] err:@"Couldn't parse online scores: %@", error];
    else {
        [[Logger get] dbg:@"Response Scores:\n%@", playersScoreHistory];
        [DeblockConfig get].userScoreHistory = playersScoreHistory;
    }
    
    NSString *errorHeader = [[request responseHeaders] objectForKey:dErrorHeader];
    if (!errorHeader || errorHeader == (id)[NSNull null])
        player.onlineOk         = YES;
    
    else if ([errorHeader isEqualToString:dErrorIncorrectPass] || [errorHeader isEqualToString:dErrorMissingPass]) {
        player.onlineOk         = NO;
        self.alertPlayer        = player;
        self.alertPassword      = [[[UIAlertView alloc] initWithTitle:@"Online Name Taken" message:
                                    [NSString stringWithFormat:
                                     @"«%@» is already taken.",
                                     self.alertPlayer.onlineName]
                                                             delegate:self cancelButtonTitle:@"Don't Compete"
                                                    otherButtonTitles:@"Change Name", @"Change Code", nil] autorelease];
        [self.alertPassword show];
    }

    else if ([errorHeader isEqualToString:dErrorMissingName]) {
        player.name             = nil;
        [self submitScoreForPlayer:player];
    }
    
    [requestsPlayer removeObjectForKey:requestValue];
    [request release];
}


- (void)requestFailed:(ASIHTTPRequest *)request {
    
    NSValue *requestValue = [NSValue valueWithPointer:request];

    [[Logger get] err:@"Couldn't fetch online scores from %@: %@", request.url, request.error];

    /* GAE isn't quite reliable enough for this to be on.
    id player               = [requestsPlayer objectForKey:requestValue];
    self.alertPlayer        = player == [NSNull null]? nil: player;
    self.alertConnection    = [[[UIAlertView alloc] initWithTitle:@"Scores Unavailable" message:
                                @"Online scores were temporarily unavailable.\nDo you want to retry?"
                                                         delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] autorelease];
    [self.alertConnection show];
     */
    
    [requestsPlayer removeObjectForKey:requestValue];
    [request release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView == self.alertPassword) {

        if (buttonIndex == [alertView cancelButtonIndex])
            // Don't Compete
            [DeblockConfig get].compete = [NSNumber numberWithBool:NO];
        
        else if (buttonIndex == [alertView firstOtherButtonIndex])
            // Change Name
            self.alertPlayer.name       = nil;
        
        else
            // Change Code
            self.alertPlayer.pass       = nil;
        
        // Retry if still enabled.
        if ([[DeblockConfig get].compete boolValue])
            [self submitScoreForPlayer:self.alertPlayer];

        // Clean up.
        self.alertPlayer                = nil;
        self.alertPassword              = nil;
    }
    
    else if (alertView == self.alertConnection) {
        
        if (buttonIndex == [alertView cancelButtonIndex])
            // Don't Retry
            [DeblockConfig get].compete = [NSNumber numberWithBool:NO];
        
        // Retry if still enabled.
        if ([[DeblockConfig get].compete boolValue])
            [self submitScoreForPlayer:self.alertPlayer];
        
        // Clean up.
        self.alertPlayer                = nil;
        self.alertConnection            = nil;
    }
}

@end
