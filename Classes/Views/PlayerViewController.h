//
//  PlayerViewController.h
//  Deblock
//
//  Created by Maarten Billemont on 17/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "ButtonFontLabel.h"


@interface PlayerViewController : UIViewController<UITextFieldDelegate, ButtonFontLabelDelegate> {

    UITextField                 *playerField;
    UILabel                     *playerSuggestion;
    ButtonFontLabel             *next;
}

@property (retain) IBOutlet UITextField     *playerField;
@property (retain) IBOutlet UILabel         *playerSuggestion;
@property (retain) IBOutlet ButtonFontLabel *next;

- (NSString *)playerName;

@end
