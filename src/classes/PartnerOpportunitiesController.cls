public class PartnerOpportunitiesController {
    
    private final Account acc;
    
    public PartnerOpportunitiesController(ApexPages.StandardController stdController) {
    this.acc = (Account)stdController.getRecord();
    initOppties();
    }
    
    List<Opportunity> opps;
    
    public void initOppties() {
    opps = [select id,OwnerId,Owner.Name,AccountId,Account.Name,StageName,Name,Amount,CloseDate from Opportunity where PartnerAccountId = :acc.id AND IsClosed = FALSE ORDER BY Amount DESC];
    }
   
    public List<Opportunity> getopps () {
    return opps;
    }   
    
}