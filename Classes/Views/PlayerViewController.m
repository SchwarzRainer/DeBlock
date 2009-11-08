//
//  PlayerViewController.m
//  Deblock
//
//  Created by Maarten Billemont on 17/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "PlayerViewController.h"
#import "DeblockAppDelegate.h"
#import "FontManager.h"


@interface PlayerViewController ()

- (void)playerAutocomplete:(NSString *)userText;

@end

@implementation PlayerViewController

@synthesize playerField, playerSuggestion, next;

- (id)init {
    
    return [super initWithNibName:@"PlayerView" bundle:nil];
}

- (void)viewDidLoad {
    
    self.next.zFont             = [[FontManager sharedManager] zFontWithName:[Config get].fontName pointSize:[[Config get].fontSize intValue]];
    self.playerField.text       = [DeblockConfig get].userName;
    self.playerSuggestion.text  = @"";
}

- (void)touched {
    
    if (!self.playerField.text.length) {
        [AudioController vibrate];
        return;
    }
    
    [DeblockConfig get].userName = [self playerName];
    [[DeblockAppDelegate get] showDirector];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    NSString *oldText = textField.text;
    NSString *newText = [[oldText stringByReplacingCharactersInRange:range withString:string]
                         stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (textField == self.playerField)
        [self playerAutocomplete:newText];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == self.playerField)
        [self playerAutocomplete:self.playerField.text];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == self.playerField) {
        self.playerField.text       = [self playerName];
        self.playerSuggestion.text  = @"";
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (![textField.text length])
        return NO;
    
    [textField resignFirstResponder];
    return YES;
}

- (void)playerAutocomplete:(NSString *)userText {

    self.playerSuggestion.text  = @"";
    
    NSArray *playerNames = [[[DeblockConfig get] players] allKeys];
    for (NSString *playerName in playerNames)
        if ([playerName hasPrefix:userText]) {
            NSMutableString *paddedSuggestionText = [NSMutableString stringWithCapacity:[playerName length]];
            for (NSUInteger pad = [userText length]; pad > 0; --pad)
                [paddedSuggestionText appendString:@" "];
            [paddedSuggestionText appendString:[playerName stringByReplacingCharactersInRange:NSMakeRange(0, [userText length])
                                                                                   withString:@""]];
            
            self.playerSuggestion.text  = paddedSuggestionText;
            break;
        }
}

- (NSString *)playerName {
    
    NSMutableString *name = [NSMutableString stringWithCapacity:fmaxf([self.playerSuggestion.text length],
                                                                      [self.playerField.text length])];
    [name appendString:self.playerField.text];
    if ([self.playerSuggestion.text length] > [name length])
        [name appendString:[self.playerSuggestion.text stringByReplacingCharactersInRange:NSMakeRange(0, [name length])
                                                                               withString:@""]];
    
    return name;
}

@end
