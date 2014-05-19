//
//  InstrumentViewController.m
//  SoundNotes
//
//  Created by Rick Slot on 10/05/14.
//  Copyright (c) 2014 Rick Slot. All rights reserved.
//

#import "InstrumentViewController.h"
#import "SoundRecorder.h"
#import "SoundNote.h"
#define kOFFSET_FOR_KEYBOARD 160.0

@interface InstrumentViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *keyTextField;
@property (weak, nonatomic) IBOutlet UITextView *lyricsTextView;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;

@property (nonatomic, strong) SoundRecorder *recorder;

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@end

@implementation InstrumentViewController

BOOL recording = NO;
BOOL keyboardIsShown = NO;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title  = _instrument.name;
    
    self.nameTextField.text = _instrument.name;
    self.keyTextField.text = _instrument.key;
    self.lyricsTextView.text = _instrument.lyrics;
    self.notesTextView.text = _instrument.notes;
    
    [self.nameTextField setReturnKeyType:UIReturnKeyDone];
    self.nameTextField.delegate = self;
    
    [self.keyTextField setReturnKeyType:UIReturnKeyDone];
    self.keyTextField.delegate = self;
    
    self.lyricsTextView.delegate = self;
    self.notesTextView.delegate = self;
    
    SoundNote *soundNote = (SoundNote *) _instrument.soundNote;
    self.recorder = [[SoundRecorder alloc]initWithFolderName:soundNote.name fileName:_instrument.soundFile];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    keyboardIsShown = NO;
    //make contentSize bigger than your scrollSize (you will need to figure out for your own use case)
    CGSize scrollContentSize = CGSizeMake(320, 1000);
    self.scrollView.contentSize = scrollContentSize;
    self.scrollView.pagingEnabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)saveInstrument{
    NSError *error;
    if(![self.managedObjectContext save:&error]){
        NSLog(@"Error: %@", error);
    }
}

- (IBAction)recordButtonClicked:(id)sender {
    recording = !recording;
    if (recording) {
        [self.recordButton setTitle:@"Stop recording" forState:UIControlStateNormal];
    }else{
        [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
    }
    [self.recorder record];
}
- (IBAction)playButtonClicked:(id)sender {
    [self.recorder play];
}

- (IBAction)dropBoxClicked:(id)sender {
    NSLog(@"dropbox clicked");
    if (![[DBSession sharedSession] isLinked]) {
        NSLog(@"linked!");
		[[DBSession sharedSession] linkFromController:self];
    } else {
        [[DBSession sharedSession] unlinkAll];
        NSLog(@"unlinked!");
    }

}

- (DBRestClient *)restClient {
    if (!_restClient) {
        _restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}
- (IBAction)uploadButtonClicked:(id)sender {
    [self uploadProject];
}

-(void) uploadProject{
    SoundNote *soundNote = (SoundNote *) _instrument.soundNote;
    NSString *destDir = [[NSString alloc] initWithFormat:@"/%@", soundNote.name];
    
    for(Instruments *instrument in soundNote.instruments){
        NSString *filename = [[NSString alloc] initWithFormat:@"%@.m4a", instrument.soundFile];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@/%@", soundNote.name, filename]];
        
        [[self restClient] uploadFile:filename toPath:destDir
                        withParentRev:nil fromPath:dataPath];
        
    }

    
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
}

#pragma mark - textfield stuff

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    _instrument.name = self.nameTextField.text;
    _instrument.key = self.keyTextField.text;
    _instrument.notes = self.notesTextView.text;
    _instrument.lyrics = self.lyricsTextView.text;
    [self saveInstrument];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
}

-(void)dismissKeyboard {
    [self.nameTextField resignFirstResponder];
    [self.keyTextField resignFirstResponder];
    [self.lyricsTextView resignFirstResponder];
    [self.notesTextView resignFirstResponder];
}

- (void)keyboardWillHide:(NSNotification *)n
{
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    // resize the scrollview
    CGRect viewFrame = self.scrollView.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.size.height += 320;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.scrollView setFrame:viewFrame];
    [UIView commitAnimations];
    
    keyboardIsShown = NO;
}

- (void)keyboardWillShow:(NSNotification *)n
{
    // This is an ivar I'm using to ensure that we do not do the frame size adjustment on the `UIScrollView` if the keyboard is already shown.  This can happen if the user, after fixing editing a `UITextField`, scrolls the resized `UIScrollView` to another `UITextField` and attempts to edit the next `UITextField`.  If we were to resize the `UIScrollView` again, it would be disastrous.  NOTE: The keyboard notification will fire even when the keyboard is already shown.
    if (keyboardIsShown) {
        return;
    }
    
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // resize the noteView
    CGRect viewFrame = self.scrollView.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.size.height -= 320;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.scrollView setFrame:viewFrame];
    [UIView commitAnimations];
    keyboardIsShown = YES;
}



@end
