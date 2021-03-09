public with sharing class ConsoleDBLookup {

    public Console_Dashboard__c dbStorage {get; set;}
   
    public string currentDBId {get;set;}
    
    public List<Dashboard> dbs{get; set;}
    
    public ConsoleDBLookup() {
        
        dbStorage = Console_Dashboard__c.getOrgDefaults();
        currentDBId = dbStorage.DashboardId__c;
    }
    
    public List<SelectOption> getDashboards() {
        List<SelectOption> options = new List<SelectOption>();
        
        dbs = [SELECT title, id from Dashboard];
        options.add(new SelectOption('','Select a Dashboard'));   
        
        for(Dashboard db:  dbs) {
            options.add(new SelectOption(db.Id,db.title));
        }
        return options;
    }
    
    public PageReference setSelectedId() {
        
        dbStorage.DashboardId__c = currentDBId;
        
        upsert dbStorage;
        return null;
        
    }
    
    public PageReference edit(){
        dbStorage.DashboardId__c = null;
        upsert dbStorage;
        
        PageReference thisPage = ApexPages.currentPage();
        thisPage.setRedirect(true);
        return thisPage;
        
    }
   
}