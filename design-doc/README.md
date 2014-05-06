Design doc
==============

##Core data:
###Entitys:
####SoundNote
- name : String
- updated : String
- Relationship 1 to many instruments : Instrument

####Instruments
- key : String
- lyrics : String
- name : String
- notes : String
- soundFile : String


##Classess
Model classes for the core data entitys can be generated



###MainTableViewController

```Objective-C


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)viewDidLoad;
/* get results with core data */
-(NSFetchedResultsController *) fetchedResultsController;

/* check if content is changed */
-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller;

/* check if content will be changed */
-(void) controllerWillChangeContent:(NSFetchedResultsController *)controller;

/* handle changed object */
-(void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;

/* Check if section is changed */
-(void) controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type;

/* gets all SoundNotes from core data */
-(void) fetchResults;

/* Tableview methods */
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

/* show instruments view */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
```


###InstrumentsTableViewController
This class has the same methods as the maintableviewcontroller, except that everything that is loaded is instrument specifix and not soundnote.

```Objective-C
@property (nonatomic, strong) SoundRecorder *soundRecorder;
@property (nonatomic, strong) SoundNote *soundNote;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
```

###SoundRecorder
This class is used to record and play sounds

```Objective-C

-(void) recordAndSaveSoundToPath:(NSString *) soundpath;
-(void) playSoundFromPath:(NSString *) soundpath;
```



