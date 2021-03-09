public with sharing class ChatterIdLookup {

    public string currentChatterId {get;set;}
    
    public Chatter_Marquee__c chatterStorage {get; set;}
    
    public List<CollaborationGroup> chatterGroups{get; set;}
    
    public ChatterIdLookup(){
        chatterStorage = Chatter_Marquee__c.getOrgDefaults();
        currentChatterId = chatterStorage.ChatterId__c;
        
    }
    
    public List<SelectOption> getGroups() {
        List<SelectOption> options = new List<SelectOption>();
        
        chatterGroups = [SELECT name, id from CollaborationGroup];
        options.add(new SelectOption('','Select a Chatter Group'));   
        
        for(CollaborationGroup cg:  chatterGroups) {
            options.add(new SelectOption(cg.Id,cg.Name));
        }
        return options;
    }
    
    public PageReference setSelectedId(){
        chatterStorage.ChatterId__c = currentChatterId ;
        upsert chatterStorage;
        return null;
    }
    
    public PageReference edit(){
    
        chatterStorage.ChatterId__c = null;
        upsert chatterStorage;
        
        PageReference thisPage = ApexPages.currentPage();
        thisPage.setRedirect(true);
        return thisPage;
    }
}