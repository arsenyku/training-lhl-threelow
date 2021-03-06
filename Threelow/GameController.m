//
//  GameController.m
//  Threelow
//
//  Created by asu on 2015-08-26.
//  Copyright (c) 2015 asu. All rights reserved.
//

#import "GameController.h"
#import "InputCollector.h"
#import "Dice.h"

@implementation GameController



-(instancetype)init{
    self = [super init];
    _heldDice = [[NSMutableDictionary alloc] init];
    _rollableDice = [ @{ 	@"1":[[Dice alloc] initWithName:@"1"],
                            @"2":[[Dice alloc] initWithName:@"2"],
                            @"3":[[Dice alloc] initWithName:@"3"],
                            @"4":[[Dice alloc] initWithName:@"4"],
                            @"5":[[Dice alloc] initWithName:@"5"]
                            } mutableCopy ];
    _rollCountSinceReset = 0;
    _mustSelectDieToHold = NO;
    return self;
}

-(int)score{
    int result = 0;
    for (NSString* dieName in self.heldDice) {
        Dice* die = self.heldDice[ dieName ];
        result += die.currentValue;
    }
    return result;
}

-(void)rollDice{
    for (NSString* dieName in self.rollableDice) {
        Dice* die = self.rollableDice[ dieName ];
        [die roll];
    }
    _rollCountSinceReset += 1;
    _mustSelectDieToHold = YES;
}

-(void)showGameState{
    [InputCollector showLineWithText:@"\nCurrent Game State"];
    if ([self.rollableDice count] < 1){
        [InputCollector showLineWithText:@"All dice are being HELD."];
    } else {
	    for (NSString* dieName in [self.rollableDice.allKeys sortedArrayUsingSelector:(@selector(isGreaterThan:))] ) {
    	    Dice* die = self.rollableDice[ dieName ];
        	[InputCollector showLineWithText:[NSString stringWithFormat:@"Die %@ shows a %d", die.name, die.currentValue]];
        }
    }

    [InputCollector showLineWithText:@"\n--------"];

    if ([self.heldDice count] < 1){
        [InputCollector showLineWithText:@"No HELD dice"];
    } else {
        for (NSString* dieName in [self.heldDice.allKeys sortedArrayUsingSelector:(@selector(isGreaterThan:))] ) {
            Dice* die = self.heldDice[ dieName ];
            [InputCollector showLineWithText:[NSString stringWithFormat:@"Die %@ shows a %d [HELD]", die.name, die.currentValue] ];
        }
    }

    [InputCollector showLineWithText:[NSString stringWithFormat:@"\nRolls since last reset: %d", self.rollCountSinceReset]];
    
    [InputCollector showLineWithText:[NSString stringWithFormat:@"\nSCORE: %d", self.score]];

}

-(void)holdDie:(NSString*)dieName{
    Dice* die = self.rollableDice[ dieName ];
    
    if ([dieName isEqualToString:@""]){
        [InputCollector showLineWithText:[NSString stringWithFormat:
                                          @"Please provide the ID of the die to hold."]];
    }
    if (die == nil){
        die = self.heldDice[ dieName ];
        
        if (die == nil){
            [InputCollector showLineWithText:[NSString stringWithFormat:
                                              @"There is no die with ID %@.  No change to game state.", dieName]];
        }else{

        	// UNHOLD the die
            [self.heldDice removeObjectForKey:die.name];
            [self.rollableDice setValue:die forKey:die.name];
            [InputCollector showLineWithText:
	             [NSString stringWithFormat:@"Die %@ with value %d can now be rolled.",
    	          die.name, die.currentValue]];
        }
        
        
    } else {
        
        // HOLD the die
        
        [self.rollableDice removeObjectForKey:die.name];
        [self.heldDice setValue:die forKey:die.name];
        [InputCollector showLineWithText:
         	[NSString stringWithFormat:@"Now holding die %@ with value %d",
             						  die.name, die.currentValue]];

        _mustSelectDieToHold = NO;
    }
}

-(void)resetDice{
    NSArray* keys = [self.heldDice.allKeys copy];
    for (NSString* key in keys) {
        Dice* die = self.heldDice[ key ];
        [self.heldDice removeObjectForKey:key];
        [self.rollableDice setValue:die forKey:die.name];
    }

    _rollCountSinceReset = 0;
    _mustSelectDieToHold = NO;
    
    [InputCollector showLineWithText:
		[NSString stringWithFormat:@"All dice are now ROLLABLE"]];

}



-(BOOL)rollAllowed{
    return ( _mustSelectDieToHold == NO &&
            [self gameIsOver] == NO &&
            _rollCountSinceReset < 5 );
}

-(BOOL)gameIsOver{
    return [self.heldDice count] == 5;
}


-(void) winNow{
    [self resetDice];
    NSArray* keys = [self.rollableDice.allKeys copy];

    for (NSString* diceName in keys) {
        Dice* cheatDie = [[Dice alloc] initWithName:diceName];
    	
        while(cheatDie.currentValue != 6){
            [cheatDie roll];
        }
        
        self.heldDice[ diceName ] = cheatDie;
    }
    [self.rollableDice removeAllObjects];
    [self showGameState];
}

@end
