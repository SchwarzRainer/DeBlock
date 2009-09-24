/*
 * This file is part of Deblock.
 *
 *  Deblock is open software: you can use or modify it under the
 *  terms of the Java Research License or optionally a more
 *  permissive Commercial License.
 *
 *  Deblock is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  You should have received a copy of the Java Research License
 *  along with Deblock in the file named 'COPYING'.
 *  If not, see <http://stuff.lhunath.com/COPYING>.
 */

//
//  DMConfig.m
//  Deblock
//
//  Created by Maarten Billemont on 21/07/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "DMConfig.h"


@implementation DMConfig

@dynamic level, levelScore, levelPenalty;
@dynamic gameMode;
@dynamic skyColorFrom, skyColorTo;
@dynamic flawlessBonus;
@dynamic userName, userScoreHistory;


- (id)init {
    
    if (!(self = [super init]))
        return nil;
    
    [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithLong:0x38343C00],               cShadeColor,

                                [NSNumber numberWithLong:0],                        cLevel,
                                [NSNumber numberWithLong:0],                        cLevelScore,
                                [NSNumber numberWithLong:0],                        cLevelPenalty,

                                [NSNumber numberWithLong:DbModeClassic],            cGameMode,
                                
                                [NSNumber numberWithLong:0x58748Cff],               cSkyColorFrom,
                                [NSNumber numberWithLong:0xB3D5F2ff],               cSkyColorTo,
                                
                                [NSNumber numberWithInt:10],                        cFlawlessBonus,

                                [[[UIDevice currentDevice].name
                                  componentsSeparatedByString:@"’"]
                                 objectAtIndex:0],                                  cUserName,
                                [NSDictionary dictionary],                          cUserScoreHistory,

                                nil
                                ]];
    
    self.userScoreHistory = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:random() % 200],
                              [NSString stringWithFormat:@"%f", [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] timeIntervalSince1970]],
                              nil],
                             @"Foo",

                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:random() % 200],
                              [NSString stringWithFormat:@"%f", [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] timeIntervalSince1970]],
                              nil],
                             @"Bar",
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:random() % 200],
                              [NSString stringWithFormat:@"%f", [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] timeIntervalSince1970]],
                              nil],
                             @"Pom",
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:random() % 200],
                              [NSString stringWithFormat:@"%f", [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] timeIntervalSince1970]],
                              nil],
                             @"Lala",
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:random() % 200],
                              [NSString stringWithFormat:@"%f", [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] timeIntervalSince1970]],
                              nil],
                             @"Jumbo",
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:random() % 200],
                              [NSString stringWithFormat:@"%f", [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] timeIntervalSince1970]],
                              nil],
                             @"Lefty",
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:random() % 200],
                              [NSString stringWithFormat:@"%f", [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] timeIntervalSince1970]],
                              nil],
                             @"Hitsy",
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:random() % 200],
                              [NSString stringWithFormat:@"%f", [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] timeIntervalSince1970]],
                              nil],
                             @"Totsy",
                             
                             [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:random() % 200],
                              [NSString stringWithFormat:@"%f", [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] timeIntervalSince1970]],
                              nil],
                             @"Nana",
                             
                             nil];
    
    return self;
}


+ (DMConfig *)get {

    return (DMConfig *)[super get];
}


#pragma mark ###############################
#pragma mark Behaviors

- (void)recordScore:(NSInteger)score {
    
    if (score < 0)
        score = 0;
    
    [super recordScore:score];
}

- (void)saveScore {

    // Find the user's current scores in the score history.
    NSMutableDictionary *newUserScores = [[self userScoreHistory] mutableCopy];
    NSDictionary *currentUserScores = [newUserScores objectForKey:[self userName]];
    
    // Store the new score on the current date amoungst the user's scores.
    NSMutableDictionary *newCurrentUserScores = nil;
    if (currentUserScores)
        newCurrentUserScores = [currentUserScores mutableCopy];
    else
        newCurrentUserScores = [NSMutableDictionary new];
    [newCurrentUserScores setObject:[self score] forKey:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]];

    // Store the user's new scores in the score history.
    [newUserScores setObject:newCurrentUserScores forKey:[self userName]];
    [self setUserScoreHistory:newUserScores];

    // Clean up. 
    [newCurrentUserScores release];
    [newUserScores release];
}

@end