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
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@end

@implementation InstrumentViewController

BOOL recording = NO;
BOOL keyboardIsShown = NO;
int numUploads = 0;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

    keyboardIsShown = NO;
    //make contentSize bigger than your scrollSize (you will need to figure out for your own use case)
    CGSize scrollContentSize = CGSizeMake(320, 502);
    self.scrollView.contentSize = scrollContentSize;
    [self.scrollView setScrollEnabled:YES];
    self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.uploadButton addGestureRecognizer:longPress];
    [self writeToTextFile:self.instrument];

}

/**
 * This function changes the upload button text if it is linked or not
 */
-(void) viewWillAppear:(BOOL)animated{
    if([[DBSession sharedSession] isLinked]){
        [self.uploadButton setTitle:@"Upload" forState:UIControlStateNormal];
    }else{
        [self.uploadButton setTitle:@"Dropbox" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 * This function saves a instrument to core data
 */
-(void)saveInstrument{
    NSError *error;
    _instrument.name = self.nameTextField.text;
    _instrument.key = self.keyTextField.text;
    _instrument.notes = self.notesTextView.text;
    _instrument.lyrics = self.lyricsTextView.text;
    if(![self.managedObjectContext save:&error]){
        NSLog(@"Error: %@", error);
    }
}

/**
 * This function records a sound when the record button is clicked
 */
- (IBAction)recordButtonClicked:(id)sender {
    recording = !recording;
    if (recording) {
        [self.recordButton setTitle:@"Stop recording" forState:UIControlStateNormal];
    }else{
        [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
    }
    [self.recorder record];
}

/**
 * This function plays a sound when the play button is clicked
 */
- (IBAction)playButtonClicked:(id)sender {
    [self.recorder play];
}

/**
 * This function links or uploads files when the dropbox/upload button is clicked
 */
- (IBAction)dropBoxClicked:(id)sender {
    //if not linked
    if (![[DBSession sharedSession] isLinked]) {
		[[DBSession sharedSession] linkFromController:self];
    } else { // if linked
        [self uploadProject];
    }
}

/**
 * This function unlinks dropbox when the upload button registers a long press
 */
- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    if([[DBSession sharedSession] isLinked]){
        [[DBSession sharedSession] unlinkAll];
        [self.uploadButton setTitle:@"Dropbox" forState:UIControlStateNormal];
    }
}


/**
 * This function returns a DBRestclient instance which can be used to upload files
 */
- (DBRestClient *)restClient {
    if (!_restClient) {
        _restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

/**
 * This function uploads all files of a soundnote to the linked dropbox account
 */
-(void) uploadProject{
    if(numUploads == 0){
        SoundNote *soundNote = (SoundNote *) _instrument.soundNote;
        NSString *destDir = [[NSString alloc] initWithFormat:@"/%@", soundNote.name];
        
        for(Instruments *instrument in soundNote.instruments){
            NSString *filename = [[NSString alloc] initWithFormat:@"%@.m4a", instrument.soundFile];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@/%@", soundNote.name, filename]];
            
            [[self restClient] uploadFile:filename toPath:destDir
                            withParentRev:nil fromPath:dataPath];
            numUploads++;
            
            filename= [[NSString alloc] initWithFormat:@"%@.txt", instrument.name];
            dataPath = [documentsDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@/%@", soundNote.name, filename]];

            
            [[self restClient] uploadFile:filename toPath:destDir
                            withParentRev:nil fromPath:dataPath];
            numUploads++;
            
        }
        [self.uploadButton setTitle:@"Uploading..." forState:UIControlStateNormal];
        [self.uploadButton setEnabled:NO];
    }
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    numUploads--;
    if(numUploads == 0){
        [self.uploadButton setTitle:@"Upload" forState:UIControlStateNormal];
        [self.uploadButton setEnabled:YES];
        [[[UIAlertView alloc]
          initWithTitle:@"Upload succesfull" message:@"project has been uploaded successfull!"
          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
         show];
    }

}

/**
 * This function is called when something goes wrong with uploading
 */
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    numUploads--;
    if(numUploads == 0){
        [self.uploadButton setTitle:@"Upload" forState:UIControlStateNormal];
        [self.uploadButton setEnabled:YES];
    }
}

#pragma mark - textfield stuff

/**
 * This function removes the keyboard when editing is done
 */
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

/**
 * This function saves all data when editing is done
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self writeToTextFile:self.instrument];
    [self saveInstrument];
    return YES;
}

/**
 * This function is called when a textview is stopped editing, it moves the position of the scrollview down
 */
-(void) textViewDidEndEditing:(UITextView *)textView{
    CGPoint bottomOffset = CGPointMake(0, -50);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
    [textView resignFirstResponder];
}

/**
 * this function removes the keyboard from the screen and saves the instrument
 */
-(void)dismissKeyboard {
    [self.nameTextField resignFirstResponder];
    [self.keyTextField resignFirstResponder];
    [self.lyricsTextView resignFirstResponder];
    [self.notesTextView resignFirstResponder];
    [self writeToTextFile:self.instrument];
    [self saveInstrument];
}


/**
 * This function writes all the properties of an instrument to a .txt file
 */
-(void) writeToTextFile:(Instruments *)instrument{
    SoundNote *soundNote = (SoundNote *) instrument.soundNote;
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/%@/%@.txt",
                          documentsDirectory, soundNote.name, instrument.name];
    //create content - four lines of text
    NSString *content = [[NSString alloc] initWithFormat:@"%@\n%@\n%@\n%@\n", instrument.name, instrument.key, instrument.lyrics, instrument.notes];//save content to the documents directory
    NSError *error = nil;
    [content writeToFile:fileName
              atomically:NO
                encoding:NSStringEncodingConversionAllowLossy
                   error:&error];
    
}

@end
