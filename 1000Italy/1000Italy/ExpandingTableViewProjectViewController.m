//
//  ExpandingTableViewProjectViewController.m
//  ExpandingTableViewProject
//
//  Created by Gareth Jones on 18/07/2013.
//

#define COMMENT_LABEL_WIDTH 230
#define COMMENT_LABEL_MIN_HEIGHT 5
#define COMMENT_LABEL_PADDING 20

#import "ExpandingTableViewProjectViewController.h"
#import "CommentTableCell.h"
#import "PKRevealController.h"

@implementation ExpandingTableViewProjectViewController


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // create headerView, set frame and add a label with text title and add it to the navbar
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(50, 0, 280, 48)];
    tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 324, 48)];
    tlabel.text=self.navigationItem.title;
    
    [tlabel setText:NSLocalizedString(@"INFO", nil)];
    
    tlabel.font = [UIFont fontWithName:@"DIN-Bold" size:20];
    tlabel.textColor=[UIColor whiteColor];
    tlabel.backgroundColor = [UIColor clearColor];
    tlabel.textAlignment = UITextAlignmentCenter;
    [self.navigationController.navigationBar addSubview:tlabel];
    self.navigationItem.titleView = headerView;
        
    // left navbar button
    UIButton * leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBarButton.frame = CGRectMake(0, 0 , 44, 44);
    [leftBarButton setImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    [leftBarButton addTarget:self action:@selector(showLeftView:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:leftBarButton];
    

    //set set our selected Index to -1 to indicate no cell will be expanded
    selectedIndex = -1;
    

    //SetUpTestData with some meaningless strings
    textArray = [[NSMutableArray alloc] init];
    titleArray = [[NSMutableArray alloc] init];

    NSString *titleString;

    NSString *testString;
    
    for(int ii = 0; ii < 11; ii++)
    {
        
//        titleString = [NSString stringWithString:@"Test comment. Test comment."];
//        for (int jj = 0; jj < ii; jj++) {
//            titleString = [NSString stringWithFormat:@"%@ %@", titleString, titleString];
//        }
//        [titleString retain];
//        [titleArray addObject:testString];
        
        testString = [NSString stringWithString:@"Test comment. Test comment."];
        for (int jj = 0; jj < ii; jj++) {
            testString = [NSString stringWithFormat:@"%@ %@", testString, testString];
        }
        [testString retain];
        [textArray addObject:testString];
        
    }
}

//This just a convenience function to get the height of the label based on the comment text
-(CGFloat)getLabelHeightForIndex:(NSInteger)index
{
    CGSize maximumSize = CGSizeMake(COMMENT_LABEL_WIDTH, 10000);
    
    CGSize labelHeighSize = [[textArray objectAtIndex:index] sizeWithFont: [UIFont fontWithName:@"DIN-Bold" size:14.0f]
                                                                constrainedToSize:maximumSize
                                                                lineBreakMode:UILineBreakModeWordWrap];
    return labelHeighSize.height;
    
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [textArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.backgroundColor = customColorLightGrey;
    
    static NSString *CellIdentifier = @"customCell";
    
    CommentTableCell *cell = (CommentTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[exerciseListUITableCell alloc] init] autorelease];
        
        NSArray * topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CommentTableCell" owner:self options:nil];
        
        for(id currentObject in topLevelObjects)
        {
            if([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (CommentTableCell *)currentObject;
                break;
            }
        }        
    }
    
    if (indexPath.row == 0) {
        titleArray[0] = @" AMBASCIATA";
        cell.titleTextLabel.text = @" AMBASCIATA";
        cell.tableImage.image = [UIImage imageNamed:@"info-ambasciata@2x.png"];

        textArray[0] = @"\r\rVia Gaeta, 5 – 00185 Roma\rTel: (+39) 06 4941680/1/3\rFax: (39) 06/491031\rwww.ambrussia.com\rrusembassy@libero.it";
        
    }
    if (indexPath.row == 1) {
        
        titleArray[1] = @" NUMERI UTILI";
        cell.titleTextLabel.text = @" NUMERI UTILI";
        cell.tableImage.image = [UIImage imageNamed:@"info-tel_b@2x.png"];

        textArray[1] = @"\r\r112 • Carabinieri\r113 • Polizia di Stato\r115 • Vigili del Fuoco\r803 116 • Soccorso stradale\r118 • Medical Emergencies\r1515 • Incendi forestali\r1530 • Guardia costiera";
        
    }
    if (indexPath.row == 2) {
        titleArray[2] = @" INFORMAZIONI GENERALI";
        cell.titleTextLabel.text = @" INFORMAZIONI GENERALI";
        cell.tableImage.image = [UIImage imageNamed:@"info-info@2x.png"];

        textArray[2] = @"Telefono: prefisso 0039\rValuta: euro\rLingua: italiano.\rReligione: In maggioranza cattolica ma la Costituzione italiana garantisce la libertà di culto.\rElettricità: Voltaggio di 220 volt distribuita a corrente alternata a frequenza di 50 hertz. Le prese elettriche rispettano la normativa europea.\rAcqua: La fornitura di acqua potabile è garantita su tutto il territorio nazionale. Le acque non        potabili sono segnalate da un cartello.\rFuso Orario: Roma (CET): 21:00 (GMT+1.00) (oppure 22:00, cioè GMT+2.00, quando viene adottata l'ora estiva).";

    }
    if (indexPath.row == 3) {
        titleArray[3] = @" LINGUA";
        cell.titleTextLabel.text = @" LINGUA";
        cell.tableImage.image = [UIImage imageNamed:@"info-lingua@2x.png"];

        textArray[3] = @"\r\rItaliano. A seconda della regione si hanno accenti e dialetti diversi tra loro. Due regioni hanno una seconda lingua ufficiale: la Valle d'Aosta, in cui si parla anche francese e il Trentino Alto Adige in cui si parla anche tedesco.";
    }
    if (indexPath.row == 4) {
        titleArray[4] = @" ORARI";
        cell.titleTextLabel.text = @" ORARI";
        cell.tableImage.image = [UIImage imageNamed:@"info-orari@2x.png"];

        textArray[4] = @" COLAZIONE: Normalmente si fa colazione a partire dalle 7.00. Negli alberghi spesso c'è un orario oltre il quale non è più possibile ordinare la prima colazione (indicativamente le 10.00).\rPRANZO: l pranzo, nei ristoranti, è a partire dalle 12.30 e fino alle 14.30.\rCENA: La cena viene servita a partire dalle 19.30 fino alle 23.00.\rQuesti orari variano a seconda della zona geografica in cui ci si trova.\rORARI DEI NEGOZI: i norma gli esercizi commerciali sono aperti dal lunedì al sabato dalle 9.30 alle 12.30 e dalle 15.30 alle 19.30. Centri commerciali e grandi magazzini fanno spesso orario continuato. In diverse domeniche i negozi e gli shopping center restano aperti.\rFARMACIE: Le farmacie seguono gli orari dei negozi. Nelle grandi città ci sono farmacie        aperte 24 ore su 24. Per le emergenze le farmacie sono aperte seguendo un sistema di turni. Un calendario fuori dal negozio consente di sapere dove si trova la farmacia aperta più vicina.";
    }
    if (indexPath.row == 5) {
        titleArray[5] = @" FESTIVITÀ NAZIONALI";
        cell.titleTextLabel.text = @" FESTIVITÀ NAZIONALI";
        cell.tableImage.image = [UIImage imageNamed:@"info-feste@2x.png"];

        textArray[5] = @" In Italia il calendario delle festività nazionali è composto da 12 giorni:\r1° gennaio • Capodanno\r6 gennaio • Epifania Pasqua (la cui data varia di anno in anno)\rLunedì di Pasqua (il giorno dopo la Pasqua)\r25 aprile • Anniversario della Liberazione\r1° maggio • Festa del Lavoro\r2 giugno • Festa della Repubblica\r15 agosto • Assunzione di Maria Vergine (Ferragosto)\r1° novembre • Festa di Ognisanti (Tutti i Santi)\r8 dicembre • Immacolata Concezione\r25 dicembre • Natività di Gesù\r26 dicembre • Santo Stefano";
    }
    if (indexPath.row == 6) {
        titleArray[6] = @" METRI E DIMENSIONI";
        cell.titleTextLabel.text = @" METRI E DIMENSIONI";
        cell.tableImage.image = [UIImage imageNamed:@"info-misure@2x.png"];

        textArray[6] = @"\r\rLe dimensioni si misurano in cm. Le taglia dei vestiti femminile va, in media, dalla 38 alla 56 mentre quella maschile dalla 42 alla 60. Per le scarpe generalmente di va dal 35 al 46 per gli adulti.";
    }
    if (indexPath.row == 7) {
        titleArray[7] = @" PAGAMENTI";
        cell.titleTextLabel.text = @" PAGAMENTI";
        cell.tableImage.image = [UIImage imageNamed:@"info-valuta@2x.png"];

        textArray[7] = @"\r\rIn contanti o con le carte di credito più diffuse. I travellers’s cheque si cambiano in banca.\rMANCE: Non obbligatorie";
    }
    if (indexPath.row == 8) {
        titleArray[8] = @" CLIMA";
        cell.titleTextLabel.text = @" CLIMA";
        cell.tableImage.image = [UIImage imageNamed:@"info-meteo@2x.png"];

        textArray[8] = @"\r\rIn Italia la differenza di temperatura tra Nord, Centro e Sud può essere elevata. Riportiamo qui le tabelle della temperatura mensile media e massima di tre città d'Italia, una per fascia climatica.";
    }
    if (indexPath.row == 9) {
        titleArray[9] = @" TRANSPORTI";
        cell.titleTextLabel.text = @" TRANSPORTI";
        cell.tableImage.image = [UIImage imageNamed:@"info-trasporti@2x.png"];

        textArray[9] = @"In Italia il principale aeroporto intercontinentale è il Leonardo da Vinci di Roma. Collegamenti intercontinentali servono anche Milano. Nella penisola, oltre all’Alitalia, che è la compagnia di bandiera, operano molte compagnie aeree europee e internazionali.\rPer raggiungere l’Italia, l’autobus è in genere è l’opzione più economica, ma i servizi sono meno frequenti e decisamente meno comodi del treno. I traghetti collegano l'Italia con la Corsica, la Grecia, la Turchia, la Tunisia, Malta, l'Albania, la Croazia, la Slovenia e la Spagna.";
    }
    if (indexPath.row == 10) {
        titleArray[10] = @" ANIMALI";
        cell.titleTextLabel.text = @" ANIMALI";
        cell.tableImage.image = [UIImage imageNamed:@"info-animali@2x.png"];

        textArray[10] = @"Restrizioni per gli animali\rL'introduzione di cani, gatti e furetti al seguito dei proprietari è possibile a condizioni diverse a seconda che gli animali provengano da paesi membri dell'UE o da altri paesi.\r\rIntroduzione da paesi non appartenenti all'UE\rÈ consentita se gli animali sono muniti di un certificato di origine e sanità con i dati identificativi degli animali e dei proprietari e attestante che gli animali sono sani e sono stati sottoposti a vaccinazione antirabbica da almeno venti giorni e da non oltre 11 mesi dalla data del rilascio del certificato stesso. È vietato introdurre in Italia cani e gatti di età inferiore ai tremesi e che non sono stati sottoposti a vaccinazione antirabbica.";
    }
  
    
    cell.titleTextLabel.backgroundColor = [UIColor clearColor];

    //If this is the selected index then calculate the height of the cell based on the amount of text we have
    if(selectedIndex == indexPath.row)
    {
        CGFloat labelHeight = [self getLabelHeightForIndex:indexPath.row];
      
//        cell.titleTextLabel.frame = CGRectMake(cell.titleTextLabel.frame.origin.x,
//                                                 cell.titleTextLabel.frame.origin.y,
//                                                 cell.titleTextLabel.frame.size.width,
//                                                 labelHeight);
        
        cell.titleTextLabel.frame = CGRectMake(cell.titleTextLabel.frame.origin.x,cell.titleTextLabel.frame.origin.y,cell.titleTextLabel.frame.size.width,20);
        
        cell.commentTextLabel.frame = CGRectMake(cell.commentTextLabel.frame.origin.x,
                                                0,
                                                cell.commentTextLabel.frame.size.width, 
                                                labelHeight);
    }
    
   else {
        
    //Otherwise just return the minimum height for the label.
    cell.titleTextLabel.frame = CGRectMake(cell.titleTextLabel.frame.origin.x,cell.titleTextLabel.frame.origin.y,cell.titleTextLabel.frame.size.width,20);

    cell.titleTextLabel.font = [UIFont fontWithName:@"DIN-Bold" size:14.0f];
    cell.titleTextLabel.text = [titleArray objectAtIndex:indexPath.row];

       
    //Otherwise just return the minimum height for the label.
    cell.commentTextLabel.frame = CGRectMake(cell.commentTextLabel.frame.origin.x,
                                                35,
                                                cell.commentTextLabel.frame.size.width, 
                                                0);
    }
    
    
    cell.titleTextLabel.font = [UIFont fontWithName:@"DIN-Bold" size:14.0f];
//    cell.titleTextLabel.text = [textArray objectAtIndex:indexPath.row];
    cell.titleTextLabel.textColor = [UIColor whiteColor];

    cell.commentTextLabel.font = [UIFont fontWithName:@"DIN-Regular" size:12.0f];
    cell.commentTextLabel.text = [textArray objectAtIndex:indexPath.row];

    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //If this is the selected index we need to return the height of the cell
    //in relation to the label height otherwise we just return the minimum label height with padding
    if(selectedIndex == indexPath.row)
    {
        return [self getLabelHeightForIndex:indexPath.row] + COMMENT_LABEL_PADDING * 2;
    }
    else {
        return COMMENT_LABEL_MIN_HEIGHT + COMMENT_LABEL_PADDING * 2;
    }
}

-(NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //We only don't want to allow selection on any cells which cannot be expanded
    if([self getLabelHeightForIndex:indexPath.row] > COMMENT_LABEL_MIN_HEIGHT)
    {
        return indexPath;
    }
    else {
        return nil;
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    //The user is selecting the cell which is currently expanded
    //we want to minimize it back
    if(selectedIndex == indexPath.row)
    {
        selectedIndex = -1;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        return;
    }
    
    //First we check if a cell is already expanded.
    //If it is we want to minimize make sure it is reloaded to minimize it back
    if(selectedIndex >= 0)
    {
        NSIndexPath *previousPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
        selectedIndex = indexPath.row;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousPath] withRowAnimation:UITableViewRowAnimationFade];        
    }
    
    //Finally set the selected index to the new selection and reload it to expand
    selectedIndex = indexPath.row;
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}





#pragma mark - Left and Right menu methods

- (void)showLeftView:(id)sender
{
    if (self.navigationController.revealController.focusedController == self.navigationController.revealController.leftViewController)
    {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.frontViewController];
    }
    else
    {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
    [super dealloc];
}

@end
