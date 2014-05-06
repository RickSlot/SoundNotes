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



