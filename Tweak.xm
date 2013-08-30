

#import <UIKit/UIKit.h>

#import <SpringBoard/SBIconView.h>
#import <UIKit/UIGestureRecognizer.h>
#import <SpringBoard/SBFluidSlideGestureRecognizer.h>
#import <SpringBoard/SBIconListView.h>
#import <SpringBoard/SBApplicationIcon.h>
#import <AppList/AppList.h>
#import <SpringBoard/SBIconController.h>
#import <SpringBoard/SBIconModel.h>
#import <SPringBoard/SBUIController.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

#import <SpringBoard/SBDockIconListView.h>
#import <SpringBoard/SBIconContentView.h>

#import <SpringBoard/SBAppSwitcherController.h>

//options for settings
static BOOL globalEnable = YES;
static int deltaVerticalSpacing = -10;
static BOOL iconPeek = YES;
static BOOL rightHanded = YES;
static BOOL showAnimations = YES;
static int animationDirection = 0;

static float stackLaunchSensitivity = 35.0f;
static BOOL useBackground = YES;
static int backgroundColor = 1;
static float backgroundRoundedness = 5.0f;
static float stackViewOpacity = 1.0f;
static float entireStackDeltaVerticalSpacing = 0.0f;
static BOOL restrictStacksToDock = YES;
static BOOL dimSpringBoard = YES;
static float amountToDimBackground = 0.5f;
static float stackAnimationDuration = 1.0f;
static BOOL cascadeIcons = NO;
static float cascadeInterval = 0.1f;
static BOOL invertAnimationDirection = NO;
static float stackViewScale = 1.0f;
static BOOL curveStacks = NO;
static float highlightOpacity = 0.7f;
static float highlightThickness = 2.0f;

//used statics
static NSMutableDictionary *dictOfGestureRecognizers;
static NSMutableDictionary *dictOfIDsAndStacks;
static NSDictionary *stacksPreferencesDict = nil;
static NSMutableArray *listOfSBIconViewInstances = nil;
static NSDictionary *stacksContents = nil;
static UIView *dimBackgroundView;
static BOOL iconsDidFinishAnimation = NO;
static float heightOfIcons = 0;
static float widthOfIcons = 0;


#define StacksAnimationDirectionUPtoDOWN 0
#define StacksAnimationDirectionDOWNtoUP 1
#define StacksAnimationDirectionLEFTtoRIGHT 2
#define StacksAnimationDirectionRIGHTtoLEFT 3

#define StacksContentsPath [NSString stringWithFormat:@"%@/Library/Preferences/com.mattcmultimedia.stacks.stacksContents.plist", NSHomeDirectory()]
#define PrefPath [NSString stringWithFormat:@"%@/Library/Preferences/com.mattcmultimedia.stacks.plist", NSHomeDirectory()]

//________________________________________________________________
//      StacksStackUIView Stuff
//________________________________________________________________
@interface StacksStackUIView : UIView

//add method and property to init with an application link and image to show
@end


@implementation StacksStackUIView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

@end
//________________________________________________________________
//      END StacksStackUIView Stuff
//________________________________________________________________

static StacksStackUIView *stackView;


static void stackViewUpdateBg() {
    //NSLog(@"stackViewUpdateBG");
    if (stackView) {
        if (useBackground && !curveStacks) {
            UIColor *bgColor = [UIColor clearColor];
            if (backgroundColor == 15) {
                //set it to a random number between 1 and 14
                int randColor = (arc4random() % 14) + 1;
                switch (randColor) {
                    case 0: bgColor = [UIColor clearColor]; break;
                    case 1: bgColor = [UIColor blackColor]; break;
                    case 2: bgColor = [UIColor darkGrayColor]; break;
                    case 3: bgColor = [UIColor lightGrayColor]; break;
                    case 4: bgColor = [UIColor whiteColor]; break;
                    case 5: bgColor = [UIColor grayColor]; break;
                    case 6: bgColor = [UIColor redColor]; break;
                    case 7: bgColor = [UIColor greenColor]; break;
                    case 8: bgColor = [UIColor blueColor]; break;
                    case 9: bgColor = [UIColor cyanColor]; break;
                    case 10: bgColor = [UIColor yellowColor]; break;
                    case 11: bgColor = [UIColor magentaColor]; break;
                    case 12: bgColor = [UIColor orangeColor]; break;
                    case 13: bgColor = [UIColor purpleColor]; break;
                    case 14: bgColor = [UIColor brownColor]; break;
                }
            } else {
                switch (backgroundColor) {
                    case 0: bgColor = [UIColor clearColor]; break;
                    case 1: bgColor = [UIColor blackColor]; break;
                    case 2: bgColor = [UIColor darkGrayColor]; break;
                    case 3: bgColor = [UIColor lightGrayColor]; break;
                    case 4: bgColor = [UIColor whiteColor]; break;
                    case 5: bgColor = [UIColor grayColor]; break;
                    case 6: bgColor = [UIColor redColor]; break;
                    case 7: bgColor = [UIColor greenColor]; break;
                    case 8: bgColor = [UIColor blueColor]; break;
                    case 9: bgColor = [UIColor cyanColor]; break;
                    case 10: bgColor = [UIColor yellowColor]; break;
                    case 11: bgColor = [UIColor magentaColor]; break;
                    case 12: bgColor = [UIColor orangeColor]; break;
                    case 13: bgColor = [UIColor purpleColor]; break;
                    case 14: bgColor = [UIColor brownColor]; break;
                }
            }
            [stackView setBackgroundColor:bgColor];
            stackView.layer.cornerRadius = backgroundRoundedness;
        } else {
            [stackView setBackgroundColor:[UIColor clearColor]];
        }

        stackView.alpha = stackViewOpacity;
        //NSLog(@"done stackViewUpdateBg");
        //CGRect oldFrame = stackView.frame;
        stackView.layer.anchorPoint = CGPointMake(0.5, 1);
        stackView.layer.transform = CATransform3DMakeScale(stackViewScale, stackViewScale, 0.0001);
        //stackView.frame = oldFrame;
        //stackView.transform = CGAffineTransformMakeScale(stackViewScale,stackViewScale);
    }
}

static void stacksUpdatePreferences() {

    //NSLog(@"stacksUpdatePreferences");
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PrefPath];
    //NSLog(@"prefs: %@", prefs);
    if(!prefs) {
        //options for settings
        globalEnable = YES;
        deltaVerticalSpacing = -10;
        iconPeek = YES;
        rightHanded = YES;
        showAnimations = YES;
        animationDirection = 0;
        stackLaunchSensitivity = 35.0f;
        useBackground = YES;
        backgroundColor = 1;
        backgroundRoundedness = 5.0f;
        stackViewOpacity = 1.0f;
        entireStackDeltaVerticalSpacing = 0.0f;
        restrictStacksToDock = YES;
        stackAnimationDuration = 1.0f;
        cascadeIcons = NO;
        cascadeInterval = 0.1f;
        invertAnimationDirection = NO;
        stackViewScale = 1.0f;
        curveStacks = NO;
        highlightOpacity = 0.7f;
        highlightThickness = 2.0f;
        return;
    }
    stacksPreferencesDict = prefs;
    //NSLog(@"begin loading booleans");


    id temp;
    temp = [stacksPreferencesDict valueForKey:@"globalEnable"];
    globalEnable = temp ? [temp boolValue] : YES;

    temp = [stacksPreferencesDict valueForKey:@"dimSpringBoard"];
    dimSpringBoard = temp ? [temp boolValue] : YES;

    temp = [stacksPreferencesDict valueForKey:@"iconPeek"];
    iconPeek = temp ? [temp boolValue] : YES;

    temp = [stacksPreferencesDict valueForKey:@"rightHanded"];
    rightHanded = temp ? [temp boolValue] : YES;

    temp = [stacksPreferencesDict valueForKey:@"useBackground"];
    useBackground = temp ? [temp boolValue] : NO;

    temp = [stacksPreferencesDict valueForKey:@"restrictStacksToDock"];
    restrictStacksToDock = temp ? [temp boolValue] : YES;

    temp = [stacksPreferencesDict valueForKey:@"curveStacks"];
    curveStacks = temp ? [temp boolValue] : NO;

    temp = [stacksPreferencesDict valueForKey:@"stackLaunchSensitivity"];
    stackLaunchSensitivity = temp ? [temp floatValue] : 35.0f;

    temp = [stacksPreferencesDict valueForKey:@"backgroundColor"];
    backgroundColor = temp ? [temp intValue] : 12;

    temp = [stacksPreferencesDict valueForKey:@"highlightOpacity"];
    highlightOpacity = temp ? [temp floatValue] : 0.7f;

    temp = [stacksPreferencesDict valueForKey:@"highlightThickness"];
    highlightThickness = temp ? [temp floatValue] : 2.0f;

    temp = [stacksPreferencesDict valueForKey:@"backgroundRoundedness"];
    backgroundRoundedness = temp ? [temp floatValue] : 5.0f;

    temp = [stacksPreferencesDict valueForKey:@"stackViewOpacity"];
    stackViewOpacity = temp ? [temp floatValue] : 1.0f;

    temp = [stacksPreferencesDict valueForKey:@"amountToDimBackground"];
    amountToDimBackground = temp ? [temp floatValue] : 0.5f;

    //NSLog(@"begin loading ints and floats");

    if ([stacksPreferencesDict valueForKey:@"deltaVerticalSpacingExact"] != nil && [[stacksPreferencesDict valueForKey:@"deltaVerticalSpacingExact"] intValue] != 0) {
        //if exact is set and isnt 0, use exact, else load deltaVerticalSpacing like normal

        deltaVerticalSpacing = [[stacksPreferencesDict valueForKey:@"deltaVerticalSpacingExact"] intValue];
    } else {

        if ([stacksPreferencesDict valueForKey:@"deltaVerticalSpacing"] != nil) {
            deltaVerticalSpacing = [[stacksPreferencesDict valueForKey:@"deltaVerticalSpacing"] intValue];
        } else {
            deltaVerticalSpacing = -10.0f;
        }
    }

    if ([stacksPreferencesDict valueForKey:@"stackViewScaleExact"] != nil && [[stacksPreferencesDict valueForKey:@"stackViewScaleExact"] intValue] != 0) {
        //if exact is set and isnt 0, use exact, else load stackViewScale like normal

        stackViewScale = [[stacksPreferencesDict valueForKey:@"stackViewScaleExact"] floatValue];
    } else {

        if ([stacksPreferencesDict valueForKey:@"stackViewScale"] != nil) {
            stackViewScale = [[stacksPreferencesDict valueForKey:@"stackViewScale"] floatValue];
        } else {
            stackViewScale = 1.0f;
        }
    }

    if ([stacksPreferencesDict valueForKey:@"entireStackDeltaVerticalSpacingExact"] != nil && [[stacksPreferencesDict valueForKey:@"entireStackDeltaVerticalSpacingExact"] intValue] != 0) {
        //if exact is set and isnt 0, use exact, else load deltaVerticalSpacing like normal

        entireStackDeltaVerticalSpacing = [[stacksPreferencesDict valueForKey:@"entireStackentireStackDeltaVerticalSpacingExact"] intValue];
    } else {

        if ([stacksPreferencesDict valueForKey:@"entireStackDeltaVerticalSpacing"] != nil) {
            entireStackDeltaVerticalSpacing = [[stacksPreferencesDict valueForKey:@"entireStackDeltaVerticalSpacing"] intValue];
        } else {
            entireStackDeltaVerticalSpacing = 0;
        }
    }


    if ([UIPanGestureRecognizer instancesRespondToSelector:@selector(_setHysteresis:)]) {
        for (id key in dictOfGestureRecognizers) {
            [[dictOfGestureRecognizers objectForKey:key] _setHysteresis:stackLaunchSensitivity];
        }
    }
    //NSLog(@"begin stackViewUpdateBg");
    stackViewUpdateBg();

    //NSLog(@"UPDATED PREFERENCES YAY");
    NSDictionary *tempStacksContents = [NSDictionary dictionaryWithContentsOfFile:StacksContentsPath];
    if(!tempStacksContents) return;
    if(!stacksContents || ![stacksContents isEqualToDictionary:tempStacksContents]) {
        [stacksContents release];
        stacksContents = [tempStacksContents retain];
    }


    //ANIMATIONS

    temp = [stacksPreferencesDict valueForKey:@"showAnimations"];
    showAnimations = temp ? [temp boolValue] : YES;

    temp = [stacksPreferencesDict valueForKey:@"cascadeIcons"];
    cascadeIcons = temp ? [temp boolValue] : NO;

    temp = [stacksPreferencesDict valueForKey:@"invertAnimationDirection"];
    invertAnimationDirection = temp ? [temp boolValue] : NO;

    temp = [stacksPreferencesDict valueForKey:@"animationDirection"];
    animationDirection = temp ? [temp intValue] : 0;

    temp = [stacksPreferencesDict valueForKey:@"stackAnimationDuration"];
    stackAnimationDuration = temp ? [temp floatValue] : 0.5f;

    temp = [stacksPreferencesDict valueForKey:@"cascadeInterval"];
    cascadeInterval = temp ? [temp floatValue] : 0.1f;





}



//have option in settings for swipe vs tap
//if tap, use swipeGestureRecognizer
//if swipe, use panGestureRecognizer
//if tap, add tap recognizer to image. else, don't add
//if swipe, in handlePan, grab ending location and see if it intersects with one of the StacksIconImageViews

//in settings update callbacks, I should be able to update a StackIconStack's instance's appsToShow and have it update on the fly

//________________________________________________________________
//      StacksIconImageView Stuff
//________________________________________________________________
@interface StacksIconImageView : UIImageView <UIGestureRecognizerDelegate>

//add method and property to init with an application link and image to show
@end


@implementation StacksIconImageView

@end
//________________________________________________________________
//      END StacksIconImageView Stuff
//________________________________________________________________

//________________________________________________________________
//      StacksIconStack Stuff
//________________________________________________________________
@interface StacksIconStack : NSObject <UIGestureRecognizerDelegate>
- (void)loadApplicationStackWithApplications:(NSMutableArray *)listOfBundleIDs forApp:(NSString *)bundleIdentifier;
- (void)stacks_handlePan:(UIPanGestureRecognizer *)recognizer;

@property (nonatomic, retain) NSMutableArray *appsToShow;
@property (nonatomic, assign) CGPoint originalLocation;
@property (nonatomic, retain) NSString *bundleIDForApp;
@property (nonatomic, retain) NSMutableArray *stacksIconImageViews;
@property (nonatomic, retain) NSMutableArray *iconImageViewIntersectionLocations;
@property (nonatomic, retain) NSMutableArray *iconImageViewFrames;

@end


@implementation StacksIconStack
@synthesize originalLocation;
@synthesize appsToShow;
@synthesize bundleIDForApp;
@synthesize stacksIconImageViews;
@synthesize iconImageViewIntersectionLocations;
@synthesize iconImageViewFrames;


- (void)stacks_handlePan:(UIPanGestureRecognizer *)recognizer
{

    if (!globalEnable) return;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        iconsDidFinishAnimation = NO;
        //SBDockIconListView *dockView = (SBDockIconListView *)recognizer.view.superview;

        //REMOVE ALL StackIconImageViews attached to stackView
        //NSLog(@"recognizer.view.layer.sublayerTransform: %f", currentScale );
        [[stackView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];


        CGRect stackFrame = CGRectMake( recognizer.view.frame.origin.x, recognizer.view.frame.origin.y - (((recognizer.view.frame.size.height + deltaVerticalSpacing) * [appsToShow count])+5+entireStackDeltaVerticalSpacing) ,
                                        recognizer.view.frame.size.width, (recognizer.view.frame.size.height + deltaVerticalSpacing) * [appsToShow count]);

        heightOfIcons = recognizer.view.frame.size.height;
        widthOfIcons = recognizer.view.frame.size.width;
        //[cellView convertRect:theFrame toView:self.view]

        //CGRect newStackFrame = [recognizer.view.superview convertRect:stackFrame toView:[[%c(SBIconController) sharedInstance] currentRootIconList]];
        UIView *viewToAddTo = [[%c(SBIconController) sharedInstance] contentView];
        CGPoint newOrigin = [recognizer.view.superview convertPoint:stackFrame.origin toView:viewToAddTo];
        stackFrame.origin = newOrigin;
        //NSLog(@"recognizer.view.superview: %@", [[%c(SBIconController) sharedInstance] contentView]);
        if (!stackView) {
            stackView = [[StacksStackUIView alloc] initWithFrame:stackFrame];

            [viewToAddTo addSubview:stackView];
            [viewToAddTo bringSubviewToFront:stackView];
            //NSLog(@"dockView: %@", recognizer.view.superview);

            stackViewUpdateBg();

        }
        stackView.frame = stackFrame;

        if (backgroundColor == 15 && useBackground) {
            stackViewUpdateBg();
        }
        if (showAnimations) {
            stackView.alpha = 0.0f;
        }
        if (dimSpringBoard) {
            // create UIView with .5 opacity, make it the frame of the device, convert the rect to
            // the view of [stackView superview] and then add and bring to front (?)
            if (!dimBackgroundView) {
                CGRect screenRect = [[UIScreen mainScreen] bounds];
                CGRect modifiedRect = [stackView.superview convertRect:screenRect toView:stackView.superview];
                // CGFloat screenWidth = screenRect.size.width;
                // CGFloat screenHeight = screenRect.size.height;
                dimBackgroundView = [[UIView alloc] initWithFrame:modifiedRect];
                dimBackgroundView.backgroundColor = [UIColor blackColor];

                [viewToAddTo addSubview:dimBackgroundView];

            }
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGRect modifiedRect = [stackView.superview convertRect:screenRect toView:stackView.superview];
            dimBackgroundView.frame = modifiedRect;
            dimBackgroundView.alpha = 0;
            [dimBackgroundView setHidden:NO];
            //dimBackgroundView.alpha = amountToDimBackground;
            [UIView animateWithDuration:1.2
                                delay:0
                                options: UIViewAnimationCurveEaseOut
                                animations:^{
                                    dimBackgroundView.alpha = amountToDimBackground;
                                }
                                completion:^(BOOL finished){
                                    //NSLog(@"Done!");
                                }];
        }

        originalLocation = [recognizer locationInView:stackView];
        //NSLog(@"originalLocation: %@", NSStringFromCGPoint(originalLocation));

        ALApplicationList *al = [%c(ALApplicationList) sharedApplicationList];

        stacksIconImageViews = [[NSMutableArray alloc] init];
        iconImageViewFrames = [[NSMutableArray alloc] init];
        iconImageViewIntersectionLocations = [[NSMutableArray alloc] init];

        NSMutableArray *appsToRemoveBecauseNoIcon = [[NSMutableArray alloc] init];
        float amountToTranslateEachIcon = 0.9*recognizer.view.frame.size.width / [appsToShow count];
        float degreeToRotateEachIcon = 35/[appsToShow count];
        for (unsigned int i = 0; i < [appsToShow count]; ++i)
        {
            //for each bundle id, grab the icon
            //create a StacksIconImageView for each, set the .image propery as the icon image, and add the StacksIconImageView
            //to the stacksIconImageViews array

            //SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:[appsToShow objectAtIndex:i]];
            //[app displayName] if I want to include labels
            //now grab icons using applist
            UIImage *largeIcon = [al iconOfSize:ALApplicationIconSizeLarge forDisplayIdentifier:[appsToShow objectAtIndex:i]];
            if (largeIcon) {
                StacksIconImageView *imageView = [[StacksIconImageView alloc] initWithImage:largeIcon];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                CGSize imageSize = largeIcon.size;

                imageView.frame = (CGRect){ { roundf(1), roundf(((recognizer.view.frame.size.height + deltaVerticalSpacing)* i) ) }, imageSize };
                //original location for intersection stuff
                [iconImageViewIntersectionLocations addObject:[NSValue valueWithCGRect:imageView.frame]];
                //possibly now have two arrays, one used for intersection and the other used for placement. all of the animation ones would need to use the placement array
                if (curveStacks) {
                    //NSLog(@"WOULD ATTEMPT TO CURVE STACKS HERE");

                    //determine which side of the screen the stack root is on
                    // if on left, curve right and vise versa. default to curve to right
                    // change this bool to an actual function later
                    CGRect screenRect = [[UIScreen mainScreen] bounds];
                    CGRect modifiedScreenRect = [stackView.superview convertRect:screenRect toView:stackView.superview];

                    BOOL isOnRightSideOfScreen = NO;
                    //NSLog(@"stackView.center , modifiedScreenRect.size.width/2: %f, %f", recognizer.view.center.x, modifiedScreenRect.size.width/2);
                    if (recognizer.view.center.x > modifiedScreenRect.size.width/2){
                        isOnRightSideOfScreen = YES;
                    }

                    int backWardi = -1*(i) + [appsToShow count];
                    imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
                    float translationScalar = backWardi * 0.3;
                    if (isOnRightSideOfScreen){
                        //curve stack to left side


                        imageView.center = CGPointMake(imageView.center.x - amountToTranslateEachIcon*backWardi*translationScalar, imageView.center.y);

                        imageView.transform = CGAffineTransformMakeRotation(-1 * degreeToRotateEachIcon*backWardi * (M_PI/180));
                    } else {
                        //curve stack to right side
                        // translate frame to right by adding amountToTranslateEachIcon*i to the center's x
                        imageView.center = CGPointMake(imageView.center.x + amountToTranslateEachIcon*backWardi*translationScalar, imageView.center.y);
                        //now rotate
                        imageView.transform = CGAffineTransformMakeRotation(degreeToRotateEachIcon*backWardi * (M_PI/180));



                    }
                }
                //actual location after curve or whatever
                [iconImageViewFrames addObject:[NSValue valueWithCGRect:imageView.frame]];
                //CHANGE ITS LOCATION BASED ON ANIMATION PROPERTIES HERE
                //NSLog(@"showAnimations: %i", showAnimations);
                if (showAnimations) {
                    //NSLog(@"showAnimations");
                    //create a new initial frame based on which direction the user has chosen
                    CGRect screenRect = [[UIScreen mainScreen] bounds];
                    CGRect modifiedScreenRect = [stackView.superview convertRect:screenRect toView:stackView.superview];
                    //modified rect now contains the size of the sceen, but in relation to the stackView's superview
                    switch (animationDirection) {
                        case StacksAnimationDirectionUPtoDOWN: {
                            //starts above screen
                            //imageView.frame = CGRectMake(imageView.frame.origin.x, 0, imageView.frame.size.width, imageView.frame.size.height);
                            imageView.center = CGPointMake(imageView.center.x, 0 + heightOfIcons/2);
                            break;
                        }
                        case StacksAnimationDirectionDOWNtoUP: {
                            //imageView.frame = CGRectMake(imageView.frame.origin.x, modifiedScreenRect.size.height, imageView.frame.size.width, imageView.frame.size.height);
                            imageView.center = CGPointMake(imageView.center.x, modifiedScreenRect.size.height + heightOfIcons/2);
                            break;
                        }
                        case StacksAnimationDirectionLEFTtoRIGHT: {
                            //stuff
                            //imageView.frame = CGRectMake(-1 * modifiedScreenRect.size.width, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
                            imageView.center = CGPointMake((-1 * modifiedScreenRect.size.width) - widthOfIcons/2 , imageView.center.y);
                            break;
                        }
                        case StacksAnimationDirectionRIGHTtoLEFT: {
                            //stuff
                            // imageView.frame = CGRectMake(modifiedScreenRect.size.width + imageView.frame.size.width, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
                            imageView.center = CGPointMake(modifiedScreenRect.size.width + widthOfIcons/2, imageView.center.y);
                            break;
                        }
                   }

                }
                [stackView addSubview:imageView];
                //add imageView to list of Image views
                [stacksIconImageViews addObject:imageView];

                [imageView release];
            } else {
                UIImage *smallIcon = [al iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:[appsToShow objectAtIndex:i]];
                if (smallIcon) {
                    StacksIconImageView *imageView = [[StacksIconImageView alloc] initWithImage:smallIcon];
                    imageView.contentMode = UIViewContentModeScaleAspectFit;
                    CGSize imageSize = smallIcon.size;

                    imageView.frame = (CGRect){ { roundf(1), roundf(((recognizer.view.frame.size.height + deltaVerticalSpacing)* i) ) }, imageSize };
                    [iconImageViewIntersectionLocations addObject:[NSValue valueWithCGRect:imageView.frame]];
                    //curve stacks here

                    [iconImageViewFrames addObject:[NSValue valueWithCGRect:imageView.frame]];
                    //CHANGE ITS LOCATION BASED ON ANIMATION PROPERTIES HERE
                    if (showAnimations) {
                        //NSLog(@"showAnimations");
                        //create a new initial frame based on which direction the user has chosen
                        CGRect screenRect = [[UIScreen mainScreen] bounds];
                        CGRect modifiedScreenRect = [stackView.superview convertRect:screenRect toView:stackView.superview];
                        //modified rect now contains the size of the sceen, but in relation to the stackView's superview
                        switch (animationDirection) {
                            case StacksAnimationDirectionUPtoDOWN: {
                                //starts above screen
                                //imageView.frame = CGRectMake(imageView.frame.origin.x, 0, imageView.frame.size.width, imageView.frame.size.height);
                                imageView.center = CGPointMake(imageView.center.x, 0 + heightOfIcons/2);
                                break;
                            }
                            case StacksAnimationDirectionDOWNtoUP: {
                                //imageView.frame = CGRectMake(imageView.frame.origin.x, modifiedScreenRect.size.height, imageView.frame.size.width, imageView.frame.size.height);
                                imageView.center = CGPointMake(imageView.center.x, stackView.frame.size.height - heightOfIcons/2);
                                break;
                            }
                            case StacksAnimationDirectionLEFTtoRIGHT: {
                                //stuff
                                //imageView.frame = CGRectMake(-1 * modifiedScreenRect.size.width, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
                                imageView.center = CGPointMake((-1 * modifiedScreenRect.size.width) - widthOfIcons/2 , imageView.center.y);
                                break;
                            }
                            case StacksAnimationDirectionRIGHTtoLEFT: {
                                //stuff
                                // imageView.frame = CGRectMake(modifiedScreenRect.size.width + imageView.frame.size.width, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
                                imageView.center = CGPointMake(modifiedScreenRect.size.width + widthOfIcons/2, imageView.center.y);
                                break;
                            }
                       }

                    }
                    [stackView addSubview:imageView];
                    //add imageView to list of Image views
                    [stacksIconImageViews addObject:imageView];

                    [imageView release];
                } else {
                    //NO ICON?
                    NSLog(@"ALERT: NO ICON FOR BUNDLEID: %@", [appsToShow objectAtIndex:i]);
                    //appsToShow removeObjectAtIndex:i];
                    [appsToRemoveBecauseNoIcon addObject:[appsToShow objectAtIndex:i]];
                    continue;
                }
            }
            // NSLog(@"App: %@", app);
            // NSLog(@"");
        }
        //when this is over, remove the ones that
        for (unsigned int i = 0; i < [appsToRemoveBecauseNoIcon count]; ++i)
        {
            [appsToShow removeObject:[appsToRemoveBecauseNoIcon objectAtIndex:i]];
        }
        //TODO: WHEN THE STACK IS EMPTY AFTER REMOVING ALL OF THE ICONS WITHOUT ICONS,
        //SHIT CRASHES DUE TO INDEX OUT OF BOUNDS EXCEPTION
        //TO FIX, SOMEHOW REMOVE THE STACK IF [APPSTOCOUNT COUNT] == 0
        //MAYEB DISABLE GESTURE REC IF POSSIBLE



        if (dimSpringBoard) {
            [viewToAddTo bringSubviewToFront:dimBackgroundView];
        }
        [viewToAddTo bringSubviewToFront:stackView];
        [stackView setHidden:NO];
        [stackView setUserInteractionEnabled:YES];

        if (showAnimations) {

            //NSLog(@"invertAnimationDirection: %i", invertAnimationDirection);
            if (invertAnimationDirection) {
                //down to up
                //NSLog(@"invertAnimationDirection");
                for (int i = [iconImageViewFrames count]; i --> 0; )
                {
                    //NSLog(@"%d", i);
                    float delayFactor;
                    if (cascadeIcons) {
                        delayFactor = cascadeInterval*([iconImageViewFrames count] - i);
                    } else {
                        delayFactor = 0;
                    }
                    StacksIconImageView *currentIcon = [stacksIconImageViews objectAtIndex:i];
                    //just aimate the things in from their original location
                    [UIView animateWithDuration:stackAnimationDuration
                                        delay:delayFactor
                                        options: UIViewAnimationCurveEaseOut
                                        animations:^{
                                            CGRect currentIconOrigFrame = [[iconImageViewFrames objectAtIndex:i] CGRectValue];
                                            currentIcon.center = CGPointMake(currentIconOrigFrame.origin.x + currentIconOrigFrame.size.width/2, currentIconOrigFrame.origin.y + currentIconOrigFrame.size.height/2 );
                                            //currentIcon.transform = CGAffineTransformMakeRotation(DegreesToRadians(degreeToRotateEachIcon*i));
                                        }
                                        completion:^(BOOL finished){
                                            //IF I ever want to add a bouncy animation effect, add another animation upon
                                            // completion of the above that moves it back to its original location
                                            // make sure to change the above to move it furthur to the top/bottom/left/roght than it should
                                            // so it can bounce back
                                            if (i == 0) {
                                                iconsDidFinishAnimation = YES;
                                            }
                                        }];

                }
            } else {
                //up to down
                for (unsigned int i = 0; i < [iconImageViewFrames count]; ++i)
                {
                    float delayFactor;
                    if (cascadeIcons) {
                        delayFactor = cascadeInterval*i;
                    } else {
                        delayFactor = 0;
                    }
                    StacksIconImageView *currentIcon = [stacksIconImageViews objectAtIndex:i];
                    //just aimate the things in from their original location
                    [UIView animateWithDuration:stackAnimationDuration
                                        delay:delayFactor
                                        options: UIViewAnimationCurveEaseOut
                                        animations:^{

                                            CGRect currentIconOrigFrame = [[iconImageViewFrames objectAtIndex:i] CGRectValue];
                                            currentIcon.center = CGPointMake(currentIconOrigFrame.origin.x + currentIconOrigFrame.size.width/2, currentIconOrigFrame.origin.y + currentIconOrigFrame.size.height/2 );

                                            //currentIcon.transform = CGAffineTransformMakeRotation(DegreesToRadians(degreeToRotateEachIcon*i));
                                        }
                                        completion:^(BOOL finished){
                                            //NSLog(@"Done!");
                                            if (i == [iconImageViewFrames count] - 1){
                                                iconsDidFinishAnimation = YES;
                                            }
                                        }];

                }
            }
            //finally, animate in the background.
            //stackView.alpha = stackViewOpacity;
            [UIView animateWithDuration:stackAnimationDuration
                                delay:0
                                options: UIViewAnimationCurveEaseOut
                                animations:^{
                                    stackView.alpha = stackViewOpacity;
                                }
                                completion:^(BOOL finished){
                                    //NSLog(@"Done!");
                                }];
        } else {
            iconsDidFinishAnimation = YES;
        }



        return;
    }


    if (recognizer.state == UIGestureRecognizerStateEnded) {
        // NSLog(@"Pan ENDED");
        [dimBackgroundView setHidden:YES];

        [stackView setHidden:YES];
        [stackView setUserInteractionEnabled:NO];

        //[aView.superview convertPoint:aView.frame.origin toView:aView.superview];
        CGPoint endedLocation = [recognizer locationInView:stackView];

        //see if end location intersects with rect of originalIcon. if so, launch that one

        CGRect rootIconFrame = [[iconImageViewFrames objectAtIndex:[iconImageViewFrames count]-1] CGRectValue];
        rootIconFrame.origin.y = rootIconFrame.origin.y + rootIconFrame.size.height + deltaVerticalSpacing + 15;

        // UIView *testView = [[UIView alloc] initWithFrame:rootIconFrame];
        // testView.backgroundColor = [UIColor blueColor];
        // [stackView addSubview:testView];
        //CGRectContainsPoint(<CGRect rect>, <CGPoint point>)
        //loop through contained StackIconImageView and see if ending point intersects with a rect
        for (unsigned int i = 0; i < [iconImageViewIntersectionLocations count]; ++i)
        {
            //for each StackIconImageView, grab its coordinates and see if the current location intercepts that
            //StacksIconImageView *currentIcon = [stacksIconImageViews objectAtIndex:i];
            BOOL intersects = CGRectContainsPoint([[iconImageViewIntersectionLocations objectAtIndex:i] CGRectValue], endedLocation);

            if (intersects){
                //if it intersects, grab the app it should launch and launch it somehow
                //MSHookIvar<SBIconModel *>([%c(SBIconController) sharedInstance], "_iconModel");
                SBIconModel *model = (SBIconModel *)[[%c(SBIconController) sharedInstance] model];
                SBApplicationIcon *appToLaunch = [model applicationIconForDisplayIdentifier:[appsToShow objectAtIndex:i]];
                [[%c(SBUIController) sharedInstance] launchIcon:appToLaunch];

                return;
            }

        }
        if (CGRectContainsPoint(rootIconFrame, endedLocation)) {
            SBIconModel *model = (SBIconModel *)[[%c(SBIconController) sharedInstance] model];
            SBApplicationIcon *appToLaunch = [model applicationIconForDisplayIdentifier:bundleIDForApp];
            [[%c(SBUIController) sharedInstance] launchIcon:appToLaunch];
            return;
        }

        return;

    }

    //else, pan in progress, log location in view

    //[aView.superview convertPoint:aView.frame.origin toView:nil];
    CGPoint currentLocation = [recognizer locationInView:stackView];
    //CGRectContainsPoint(<CGRect rect>, <CGPoint point>)
    //loop through contained StackIconImageView and see if ending point intersects with a rect
    //NSLog(@"Location in View: %@", NSStringFromCGPoint(currentLocation));


    //for intersection detection
    //CGPoint intersectLocation = [stackView convertPoint:currentLocation toView:stackView];

    //NSLog(@"locationIn stackView: %@", NSStringFromCGPoint(currentLocation));

    for (unsigned int i = 0; i < [stacksIconImageViews count]; ++i)
    {
        //for each StackIconImageView, grab its coordinates and see if the current location intercepts that
        //[cellView convertRect:theFrame toView:self.view]
        //CGRect testRect = [[stacksIconImageViews objectAtIndex:i] convertRect:[[stacksIconImageViews objectAtIndex:i] frame] toView:stackView];
        StacksIconImageView *currentIcon = [stacksIconImageViews objectAtIndex:i];
        //NSLog(@"rectOfImage: %@", NSStringFromCGRect([currentIcon frame]));
        BOOL intersects = CGRectContainsPoint([[iconImageViewIntersectionLocations objectAtIndex:i] CGRectValue], currentLocation);
        // NSLog(@"intersect: %@", intersects?@"YES":@"NO");
        if (!iconsDidFinishAnimation){
            break;
        }
        if (intersects){
            //NSLog(@"%i", iconsDidFinishAnimation);
            //&& !curveStacks
            if (iconPeek) {
                //move icon to side determined by rightHanded
                //if rightHanded OR stackView origin is too close to right edge of screen
                //get location of stackView in the global window
                CGRect originalFrame = [[iconImageViewFrames objectAtIndex:i] CGRectValue];
                //[aView.superview convertPoint:aView.frame.origin toView:aView.superview];
                CGRect globalLocation = [[recognizer.view superview] convertRect:stackView.frame toView:[recognizer.view superview]];
                float distanceFromLeftEdge = globalLocation.origin.x; //- currentIcon.frame.size.width;

                CGRect dockFrame = [[recognizer.view superview] frame];
                // CGRect newFrameForIconPeek;
                CGPoint newCenterForIconPeek;
                if ((distanceFromLeftEdge + (2*originalFrame.size.width)) > dockFrame.size.width) {
                    //newFrameForIconPeek = CGRectMake(originalFrame.origin.x - recognizer.view.frame.size.width, originalFrame.origin.y, originalFrame.size.width, originalFrame.size.height);
                    newCenterForIconPeek = CGPointMake((originalFrame.origin.x + (originalFrame.size.width/2)) - recognizer.view.frame.size.width, originalFrame.origin.y + originalFrame.size.height/2);
                } else if ((distanceFromLeftEdge - originalFrame.size.width) < 0) {
                    // newFrameForIconPeek = CGRectMake(originalFrame.origin.x + recognizer.view.frame.size.width, originalFrame.origin.y, originalFrame.size.width, originalFrame.size.height);
                    newCenterForIconPeek = CGPointMake((originalFrame.origin.x + (originalFrame.size.width/2)) + recognizer.view.frame.size.width, originalFrame.origin.y + originalFrame.size.height/2);
                } else if (rightHanded) {
                    // newFrameForIconPeek = CGRectMake(originalFrame.origin.x - recognizer.view.frame.size.width, originalFrame.origin.y, originalFrame.size.width, originalFrame.size.height);
                    newCenterForIconPeek = CGPointMake((originalFrame.origin.x + (originalFrame.size.width/2)) - recognizer.view.frame.size.width, originalFrame.origin.y + originalFrame.size.height/2);

                } else {
                    // newFrameForIconPeek = CGRectMake(originalFrame.origin.x + recognizer.view.frame.size.width, originalFrame.origin.y, originalFrame.size.width, originalFrame.size.height);
                    newCenterForIconPeek = CGPointMake((originalFrame.origin.x + (originalFrame.size.width/2)) + recognizer.view.frame.size.width, originalFrame.origin.y + originalFrame.size.height/2);

                }

                [UIView animateWithDuration:0.4
                                    delay:0
                                    options: UIViewAnimationCurveEaseOut
                                    animations:^{
                                        // currentIcon.frame = newFrameForIconPeek;
                                        currentIcon.center = newCenterForIconPeek;
                                    }
                                    completion:^(BOOL finished){
                                        //NSLog(@"Done!");
                                    }];

            } else {
                if (!curveStacks) {
                    currentIcon.transform = CGAffineTransformMakeScale(1.3,1.3);
                } else {
                    //highlight current icon
                    //currentIcon.layer.borderWidth = highlightThickness;
                    // currentIcon.layer.cornerRadius = highlightOpacity;
                    // currentIcon.layer.borderColor = [UIColor whiteColor].CGColor;
                    currentIcon.layer.shadowOpacity = highlightOpacity;
                    currentIcon.layer.shadowColor = [[UIColor whiteColor] CGColor];
                    currentIcon.layer.shadowOffset = CGSizeMake(0,0);
                    currentIcon.layer.shadowRadius = highlightThickness;
                }
            }
            //bring the view to the front
            [stackView bringSubviewToFront: currentIcon];
        } else {
            //does not intersect - return values to normal
            //NSLog(@"DOES NOT INTERSECT ANYTHING");
            // && !curveStacks
            if (iconPeek) {
                //this resets the icons location, which is bad for animations :(
                [UIView animateWithDuration:0.1
                                    delay:0
                                    options: UIViewAnimationCurveEaseOut
                                    animations:^{
                                        // currentIcon.frame = [[iconImageViewFrames objectAtIndex:i] CGRectValue];
                                        CGRect currentIconOrigFrame = [[iconImageViewFrames objectAtIndex:i] CGRectValue];
                                        currentIcon.center = CGPointMake(currentIconOrigFrame.origin.x + currentIconOrigFrame.size.width/2, currentIconOrigFrame.origin.y + currentIconOrigFrame.size.height/2 );

                                    }
                                    completion:^(BOOL finished){
                                        //NSLog(@"Done!");
                                    }];

            } else {
                if (!curveStacks) {
                    currentIcon.transform = CGAffineTransformMakeScale(1.0,1.0);
                } else {
                    // currentIcon.layer.borderWidth = 0;
                    currentIcon.layer.shadowOpacity = 0;
                }
            }
        }
    }








}

- (void)loadApplicationStackWithApplications:(NSMutableArray *)listOfBundleIDs forApp:(NSString *)bundleIdentifier
{
    // NSLog(@"initWithApplication: %@", [bundleIdentifier class]);
    self.bundleIDForApp = [NSString stringWithString:bundleIdentifier];
    //add self to list of stack instances so I can update them on the fly from notification callbacks
    if (!dictOfIDsAndStacks) {
        dictOfIDsAndStacks = [[NSMutableDictionary alloc] init];
    }
    [dictOfIDsAndStacks setObject:self forKey:self.bundleIDForApp];
    //NOW LOAD THE LIST OF APPS
    //grab the plist that I'll create and grab an array of appsToShow for other applications to show in the stack
    //push those IDs to appsToShowfor now, though, just uses these
    //NOTE- LOAD bundleIDs backwars so they show up correctly
    //only load the stack if there is a dictionary for it in settings
    if ([listOfBundleIDs count] > 0) {
        self.appsToShow = [listOfBundleIDs retain];
    }


}

//delegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

@end
//________________________________________________________________
//      END StacksIconStack Stuff
//________________________________________________________________


%hook SBIcon

- (void)setLocation:(int)loc
{
    // %log;
    %orig;

    if (!listOfSBIconViewInstances) {
        listOfSBIconViewInstances = [[NSMutableArray alloc] init];
    }

    // Enable multitouch
    if (self != nil) {
        //NSLog(@"self: %@", self);
        //NSLog(@"location: %d", loc);
        NSString *currentIconBundleID = nil;
        if ([self isKindOfClass:[%c(SBIconView) class]]) {
            //if is SBIconView
            currentIconBundleID = [[self icon] applicationBundleID];
        } else {
            currentIconBundleID = [self applicationBundleID];
        }

        // v  loc == 1 &&
        BOOL shouldAddGestureRec = YES;
        if (!restrictStacksToDock && loc != 1) {
            if ([[self gestureRecognizers] count] > 0) {
                for (unsigned int i = 0; i < [[self gestureRecognizers] count]; ++i)
                {
                    //for each gesture rec applied to the icon, see if it's one of mine
                    if ([[self gestureRecognizers] objectAtIndex:i] == [dictOfGestureRecognizers objectForKey:currentIconBundleID]) {
                        [[[self gestureRecognizers] objectAtIndex:i] setEnabled:NO];
                        [self removeGestureRecognizer:[[self gestureRecognizers] objectAtIndex:i]];
                        shouldAddGestureRec = NO;
                        //NSLog(@"SHOULD DISABLE GESTURE REC BUT ISN'T :(");
                    }
                }
            }
            //removed return here 129
        }


        BOOL hasMyRec = NO;
        if ([[self gestureRecognizers] count] > 0) {
            for (unsigned int i = 0; i < [[self gestureRecognizers] count]; ++i)
            {
                //for each gesture rec applied to the icon, see if it's one of mine
                if ([[self gestureRecognizers] objectAtIndex:i] == [dictOfGestureRecognizers objectForKey:currentIconBundleID]) {
                    hasMyRec = YES;

                }
            }
        }


        //narrow down gestureRecognizer to only mine by seeing if dictOfGestureRecognizers contains one of the current icon's

        //if icon isn't null, doesn't have ONE OF MY RECS, and isn't already included in my list of icons with stacks,
        //add a stack to it
        if (currentIconBundleID != nil && !hasMyRec && ![listOfSBIconViewInstances containsObject:self] && shouldAddGestureRec) {

           //if the list already exists, add those IDs to the stack
           //else, add none
            if (!stacksContents) {
                stacksContents = [NSDictionary dictionaryWithContentsOfFile:StacksContentsPath];
            }


           NSString *currentIconBundleID = nil;
           if ([self isKindOfClass:[%c(SBIconView) class]]) {
               //if is SBIconView
               currentIconBundleID = [[self icon] applicationBundleID];
           } else {
               currentIconBundleID = [self applicationBundleID];
           }
           //NSLog(@"bundleID: %@", currentIconBundleID);
           NSMutableArray *currentIconListOfIdentifiers = [[NSMutableArray alloc] init];

           //load the list of apps into currentIconListOfIdentifiers
           //NSLog(@"stacksContents: %@", stacksContents);

           for (id key in stacksContents) {
               //for each key in stacks Objects
               //NSLog(@"%@", key);
               //this line is the problem
               NSRange prefix = [key rangeOfString:[currentIconBundleID stringByAppendingString:@"-"]];
               //NSLog(@"range: %@", NSStringFromRange(prefix));
               if (prefix.location != NSNotFound ) {
                   //NSLog(@"prefix %@ found!", currentIconBundleID);
                   if ([[stacksContents objectForKey:key] boolValue]) {
                       //if true, add the corresponding bundleID to currentIconListOfIdentifiers
                       //[key substringToIndex:prefix.location];
                       NSString *idToAdd = [[key stringByReplacingOccurrencesOfString:[currentIconBundleID stringByAppendingString:@"-"] withString:@""] mutableCopy];
                       [currentIconListOfIdentifiers addObject:idToAdd];
                       //NSLog(@"should stack: %@", idToAdd);
                   }
               }
           }
           //CRASHES AFTER HERE

           //NSLog(@"got this far...");
           //if ([currentIconListOfIdentifiers count] > 0) {
           StacksIconStack *stack = [[StacksIconStack alloc] init];

           if (!dictOfGestureRecognizers) {
               dictOfGestureRecognizers = [[NSMutableDictionary alloc] init];
           }


           UIPanGestureRecognizer *panRec = [[UIPanGestureRecognizer alloc] initWithTarget:stack action:@selector(stacks_handlePan:)];
           panRec.maximumNumberOfTouches = 1;



           if ([UIPanGestureRecognizer instancesRespondToSelector:@selector(_setHysteresis:)]) {
                [panRec _setHysteresis:stackLaunchSensitivity];
           }


           if ([UIPanGestureRecognizer instancesRespondToSelector:@selector(_setCanPanHorizontally:)]) {
                [panRec _setCanPanHorizontally:NO];
           }
           //_recognizesHorizontalPanning


            if ([currentIconListOfIdentifiers count] == 0) {
               [panRec setEnabled:NO];
            }


           [self addGestureRecognizer:panRec];


           //NSLog(@"adding gestureRec: %@", panRec);
           //NSLog(@"^^^ %@", currentIconBundleID);
           [stack loadApplicationStackWithApplications:currentIconListOfIdentifiers forApp:currentIconBundleID];

           [dictOfGestureRecognizers setObject:panRec forKey:currentIconBundleID];

           [listOfSBIconViewInstances addObject:self];
           //uncommented this
           [panRec release];




        }
        //NSLog(@"");
    }
}


%end





// %hook SBFluidSlideGestureRecognizer

// - (void)touchesBegan:(struct __SBGestureContext *)arg1
// {
//     //grab this touches began arg and see If I can determine where in the view it touched
//     //then I can figure out if it intercepts with one of my uiimageviews
//     if (stackView) {
//         //if stackViewExists, set it to hidden and no user interaction
//         [stackView setHidden:YES];
//         [stackView setUserInteractionEnabled:NO];
//     }
//     %orig;
// }

// %end

%hook SBIconListView

- (void)stopJittering
{
    %log;
    %orig;
    //HERE - ONLY SET ENABLED IF THE CORRESPONDING STACK.appsToShow > 0!!
    for (id key in dictOfGestureRecognizers) {
        StacksIconStack *correspondingStack = [dictOfIDsAndStacks objectForKey:key];
        if ([correspondingStack.appsToShow count] > 0) {
            [[dictOfGestureRecognizers objectForKey:key] setEnabled:YES];
        } else {
            [[dictOfGestureRecognizers objectForKey:key] setEnabled:NO];

        }
    }
}


%end


static void stacksReloadStacks() {
    //NSLog(@"RELOAD STACKS HERE");
    NSDictionary *stacksContentsPrefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.mattcmultimedia.stacks.stacksContents.plist"];
    for (id currentBundleID in dictOfIDsAndStacks) {
        //NSLog(@"%@", currentBundleID);
        StacksIconStack *tempStack = [dictOfIDsAndStacks objectForKey:currentBundleID];
        //NSLog(@"%@", tempStack.appsToShow);
        [tempStack.appsToShow removeAllObjects];

        NSMutableArray *tempAppsToShow = [[NSMutableArray alloc] init];
        for (id key in stacksContentsPrefs) {
            //for each key in stacks Objects
            NSRange prefix = [key rangeOfString:[currentBundleID stringByAppendingString:@"-"]];
            if (prefix.location != NSNotFound ) {
                //NSLog(@"prefix %@ found!", currentBundleID);
                if ([[stacksContentsPrefs objectForKey:key] boolValue]) {
                    //if true, add the corresponding bundleID to currentIconListOfIdentifiers
                    //[key substringToIndex:prefix.location];
                    NSString *idToAdd = [[key stringByReplacingOccurrencesOfString:[currentBundleID stringByAppendingString:@"-"] withString:@""] mutableCopy];
                    [tempAppsToShow addObject:idToAdd];
                    //NSLog(@"should stack: %@", idToAdd);
                }
            }
        }
        tempStack.appsToShow = tempAppsToShow;
        // for (unsigned int i = 0; i < [dictOfGestureRecognizers count]; ++i)
        // {
        //     NSLog(@"rec: %@", (UIPanGestureRecognizer *)[dictOfGestureRecognizers objectAtIndex:i].delegate);
        // }
        UIPanGestureRecognizer *recForApp = (UIPanGestureRecognizer *)[dictOfGestureRecognizers objectForKey:currentBundleID];
        if ([tempAppsToShow count] > 0) {
            //enabled gesture rec
            [recForApp setEnabled:YES];
        } else {
            //disable gesture rec
            [recForApp setEnabled:NO];
        }

    }
    // loop through dictOfIDsAndStacks
    // for each stacks, change its listOfAppsToShow to the list from the plist
}




static void reloadPrefsNotification(CFNotificationCenterRef center,
                    void *observer,
                    CFStringRef name,
                    const void *object,
                    CFDictionaryRef userInfo) {
    stacksUpdatePreferences();
}

static void reloadStacksNotification(CFNotificationCenterRef center,
                    void *observer,
                    CFStringRef name,
                    const void *object,
                    CFDictionaryRef userInfo) {
    stacksReloadStacks();
}

%hook SBAppSwitcherController

- (void)viewDidDisappear
{
    // %log;
    %orig;
    for (id key in dictOfGestureRecognizers) {
        StacksIconStack *correspondingStack = [dictOfIDsAndStacks objectForKey:key];
        if ([correspondingStack.appsToShow count] > 0) {
            [[dictOfGestureRecognizers objectForKey:key] setEnabled:YES];
        } else {
            [[dictOfGestureRecognizers objectForKey:key] setEnabled:NO];

        }
    }
}

%end

%hook SBIconController

- (void)setIsEditing:(BOOL)isEditing
{
    // %log;
    if (isEditing) {
        //turn off my gesture recs
        for (id key in dictOfGestureRecognizers) {
            [[dictOfGestureRecognizers objectForKey:key] setEnabled:NO];
        }
    } else {
        //turn them back on
        for (id key in dictOfGestureRecognizers) {
            StacksIconStack *correspondingStack = [dictOfIDsAndStacks objectForKey:key];
            if ([correspondingStack.appsToShow count] > 0) {
                [[dictOfGestureRecognizers objectForKey:key] setEnabled:YES];
            } else {
                [[dictOfGestureRecognizers objectForKey:key] setEnabled:NO];

            }
        }
    }
    %orig;
}

%end



%ctor {

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    %init(SBIcon = objc_getClass("SBIconView") ?: objc_getClass("SBIcon"));

    stacksUpdatePreferences();
    CFNotificationCenterRef reload = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(reload, NULL, &reloadPrefsNotification,
                    CFSTR("com.mattcmultimedia.stacks/reload"), NULL, 0);

    CFNotificationCenterRef reloadStacks = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(reloadStacks, NULL, &reloadStacksNotification,
                    CFSTR("com.mattcmultimedia.stacks/reloadStacks"), NULL, 0);

    [pool drain];
}