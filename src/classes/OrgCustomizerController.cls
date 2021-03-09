public class OrgCustomizerController {
    public Organization theOrganization {get;set;}
    public Account[] theAccounts {get;set;}
    public Contact[] theContacts {get;set;}
    public List<mProduct> theProducts {get;set;}
    public Campaign[] theCampaigns {get;set;}
    public User[] theUsers {get;set;}
    public CollaborationGroup[] theGroupsInternal {get;set;}
    public CollaborationGroup[] theGroupsExternal {get;set;}
    public superCase[] theCases {get;set;}
    
    public String message {get;set;}
    public boolean showMessage {get;set;}
    
    public List<SelectOption> caseTypes {get;set;}
    public String selectedCaseType {get;set;}
    
    public OrgCustomizerController() {
        theOrganization = [Select Name From Organization limit 1];
        theAccounts = [Select Website, Name, EDY_ORGCUSTOM__Old_Name__c, isPersonAccount From Account where EDY_ORGCUSTOM__DB__c = true];
        theContacts = [Select Name, Email, Title, EDY_ORGCUSTOM__Old_Title__c from Contact where EDY_ORGCUSTOM__DB__c = true];
        
        theProducts = new List<mProduct>();
        for(Product2 p : [Select Name, External_ID__c, ID_for_Org_Customizer__c, Description, Product_Image__c, purl__c, EDY_ORGCUSTOM__Old_Name__c, Id from Product2 where EDY_ORGCUSTOM__DB__c = true] ) {
            theProducts.add(new mProduct(p));
        }
        
        
        theCampaigns = [Select Name, StartDate, EndDate, EDY_ORGCUSTOM__Old_Name__c, Id from Campaign where EDY_ORGCUSTOM__DB__c = true];
        theUsers = [select FirstName, LastName, Title, Email, EDY_ORGCUSTOM__Old_First_Name__c, EDY_ORGCUSTOM__Old_Last_Name__c from User where EDY_ORGCUSTOM__DB__c = true];
        theGroupsInternal = [Select Name, Id, NetworkId, Description, SmallPhotoUrl, Network.Name From CollaborationGroup Where NetworkId = null];
        theGroupsExternal = [Select Name, Id, NetworkId, Description, SmallPhotoUrl, Network.Name From CollaborationGroup Where NetworkId != null ORDER BY NetworkId ASC NULLS FIRST];

        setupCasesSolutions();
        CaseSelectListInit();
    }

    private void CaseSelectListInit()
    {
        List<RecordType> rt = [select Id, name, SobjectType 
                               from RecordType
                               where SobjectType = 'Case'];
        caseTypes = new List<SelectOption>();
        for(RecordType r : rt)
            caseTypes.add(new SelectOption(r.Id,r.Name));
    }
    
    ////////SAVE BUTTON ACTIONS//////////
    
    
    public void updateOrganization(){
        //update theOrganization;
    }
    
    public void updateAccounts(){
        update theAccounts;
        String[] aIDs = new String[]{};
        for(Account a : theAccounts){
            aIDs.add(a.Id);
        }

        User[] allUsers = [select AccountName__c,AccountId,CompanyName from User];
        
        for(User u : allUsers){
            u.CompanyName = u.AccountName__c;
        }
        update allUsers;

        Opportunity[] allOpps = [select id, name, amount, Account.Name from Opportunity where Accountid in :aIDs]; 
        
        for(Opportunity o : allOpps){
            Decimal DecOppty = (o.Amount != null) ? o.Amount : 0;
            String astName = o.Name;
            Boolean NameHasAst = astName.endsWith('*');
            
            
            String OpptyName = o.Account.Name+' - ';
            if (o.amount > 1000000){
                   DecOppty = DecOppty/1000000;
                   DecOppty = DecOppty.setScale(0);
                   
                   OpptyName += DecOppty+''+'M';
                   
                        if (NameHasAst == true){
                            OpptyName += '*';   
                        }
                    
                    
                    
                }else if (o.amount > 1000){
                    DecOppty = DecOppty/1000;
                    DecOppty = DecOppty.setScale(0);
                    
                    
                    OpptyName += DecOppty+''+'K';
                    
                        if (NameHasAst == true){
                            OpptyName += '*';   
                        }
                    
                    
                }else {
                    
                    OpptyName = OpptyName + DecOppty.setScale(0);
                    if (NameHasAst == true){
                    OpptyName += '*';   
                    }
                    
            }
            o.Name = OpptyName;
            
        } 
        
        update allOpps;
        message='Accounts and Opportunities have been saved! ';
        showMessage();
    }
    
    public void updateContacts(){
        update theContacts;
        
        message='Contacts have been saved! ';
        showMessage();
    }
    
    //chris huang add may 21, 2013
    public void removeImages(){
        for(mProduct p : theProducts){
                p.p.External_ID__c = '';
                update p.p;
        }
    }
    //end chris huang add
    
    public void updateProducts(){
        for(mProduct p : theProducts){
            update p.p;
        }
        Asset[] allAssets = new Asset[]{};
        for(mProduct p : theProducts){
            for(Asset a : [select Name from Asset where Product2Id =: p.p.Id]){
                a.Name = p.p.Name;
                allAssets.add(a);                
            }
        }
        update allAssets;
        
        message='Products and Assets have been saved! ';
        showMessage();
    }    
        
    public void updateCampaigns(){
        update theCampaigns;
        message='Campaigns have been saved! ';
        showMessage();
        
        
    }
    
    public void updateUsers(){
        update theUsers;
        message='Users have been saved! ';
        showMessage();
        
        
    }
    
    public void updateCases(){
        Case[] updateCases = new Case[]{};
        Solution[] updateSolutions = new Solution[]{};
        
        for(superCase item : theCases){
            updateCases.add(item.theCase);
            updateSolutions.add(item.theSolution);  
        }
        //objec CaseSolution Tracks SOlutions
        
        
        
        update updateCases;
        update updateSolutions;
        message='Cases and Solutions have been saved! ';
        showMessage(); 
        
        
    }
        
    public void updateGroups(){
        update theGroupsInternal;
        update theGroupsExternal;
        message='Group Names have been saved! ';
        showMessage();
    }   
    
    
    //////RESET BUTTON ACTIONS//////////
    public void resetAccounts(){
        String[] aIDs = new String[]{};
        for(Account a : theAccounts){
            aIDs.add(a.Id);
            a.Name = a.EDY_ORGCUSTOM__Old_Name__c;
            
        }
        update theAccounts;
        
        Opportunity[] allOpps = [select id, name, amount, Account.EDY_ORGCUSTOM__Old_Name__c from Opportunity where Accountid in :aIDs]; 
        
        for(Opportunity o : allOpps){
            Decimal DecOppty = o.Amount;
            String astName = o.Name;
            Boolean NameHasAst = astName.endsWith('*');
            
            
            String OpptyName = o.Account.EDY_ORGCUSTOM__Old_Name__c+' - ';
            if (o.amount > 1000000){
                   DecOppty = DecOppty.setScale(0);
                   DecOppty = DecOppty/1000000;
                   OpptyName += DecOppty+''+'M';
                   
                        if (NameHasAst == true){
                    OpptyName += '*';   
                    }
                    
                    
                    
                }else if (o.amount > 1000){
                     DecOppty = DecOppty.setScale(0);
                    DecOppty = DecOppty/1000;
                    OpptyName += DecOppty+''+'K';
                    
                        if (NameHasAst == true){
                    OpptyName += '*';   
                    }
                    
                    
                }else {
                    OpptyName = OpptyName + DecOppty.setScale(0);
                    
                        if (NameHasAst == true){
                    OpptyName += '*';   
                    }
                    
            }
            o.Name = OpptyName;
            
        } 
        
        update allOpps;
        
        update theAccounts;
        message='Accounts and Opportunities have been reset to the old values. ';
        showMessage();
    }
    
    public void resetContacts(){
        for(Contact cont : theContacts){
            cont.Title = cont.EDY_ORGCUSTOM__Old_Title__c;
        }
        update theContacts;
        message='Contact titles have been reset!';
        showMessage();
        
    } 
    
    public void resetProducts(){
        
        for(mProduct p : theProducts) {
            if(!String.isBlank(p.p.EDY_ORGCUSTOM__Old_Name__c))
                p.p.Name = p.p.EDY_ORGCUSTOM__Old_Name__c;  
        }
        
        Asset[] allAssets = new Asset[]{};
        for(mProduct p : theProducts){
            for(Asset a : [select Name from Asset where Product2Id =: p.p.Id]) {
                if(!String.isBlank(p.p.EDY_ORGCUSTOM__Old_Name__c)) {
                    a.Name = p.p.EDY_ORGCUSTOM__Old_Name__c;
                    allAssets.add(a);
                }
            }
        }
        
        for(mProduct p : theProducts) {
            update p.p;
        }        
     
        update allAssets;
        
        message='Product and Asset names have been reset!';
        showMessage();
            
    }
    
    public void resetCampaigns(){
        for(Campaign camp : theCampaigns){
            camp.Name = camp.EDY_ORGCUSTOM__Old_Name__c;
        }
        
        update theCampaigns;
        message='Campaign names have been reset!';
        showMessage();
            
    }
    
    public void resetUsers(){
        for(User usr : theUsers){
            usr.FirstName = usr.EDY_ORGCUSTOM__Old_First_Name__c;
            usr.LastName = usr.EDY_ORGCUSTOM__Old_Last_Name__c;
        }
        
        update theUsers;
        message='User first names and last names have been reset!';
        showMessage();
    }
    
    public void noMessage(){  showMessage=false;  }
    public void showMessage(){ showMessage = true; }    
    
    public void setupCasesSolutions(){
        
        theCases = new superCase[]{};
        
        for(Case theCase : [select Subject, EDY_ORGCUSTOM__Old_Subject__c,Org_Cust_Case_ID__c, EDY_ORGCUSTOM__Old_Description__c, CaseNumber, Description From Case where EDY_ORGCUSTOM__DB__c = true]){
            for(Solution theSolution : [Select SolutionNumber, SolutionNote, SolutionName, Org_Cust_Case_ID__c, EDY_ORGCUSTOM__Old_SolutionNote__c, EDY_ORGCUSTOM__Old_SolutionName__c From Solution where EDY_ORGCUSTOM__DB__c = true]){
                if(theSolution.Org_Cust_Case_ID__c == theCase.Org_Cust_Case_ID__c){
                    theCases.add(new superCase(theCase, theSolution));
                }
            }//end Solution for     
        }//end Case for
    }
    
    public void changeAllCaseType()
    {
        List<Case> cases = [select id, RecordTypeId from Case];
        for(Case c : cases)
        {
            c.RecordTypeId = selectedCaseType;
        }
        update cases;
    }     
    
    public class superCase{
        public Case theCase {get;set;}
        public Solution theSolution {get;set;}
        public superCase (Case cas, Solution sol){
            theCase = cas;
            theSolution = sol;
        }
    }
    
    public class mProduct {
        public Product2 p {get;set;}
        public boolean updated {get;set;}
        
        public mProduct(Product2 pr) {
            this.p = pr;
            updated = (p.purl__c.indexOf('http') > -1) ? true : false;
        }        
    }
}