public class CaseSuggestedKnowledgeClass {
    private final Case oCase;
    public String catFilter;
    public string kbList{get;set;}
    public string cId;
    
    public CaseSuggestedKnowledgeClass(ApexPages.StandardController stdController) {
      cId = Apexpages.currentPage().getParameters().get('id');
      if(cId > ''){
          this.oCase = [Select (Select CaseId, KnowledgeArticleId From CaseArticles),
                 c.Asset.Product2Id,
                               c.Asset.Product2.Family,
                               c.Asset.Product2.Name,
//                               c.Asset.Product2.Vendor__c,
//                               c.Asset.Product2.Operating_System__c,
                               c.Asset.AccountId,
//                               c.Asset.Account.Customer_Type__c,
                               c.Asset.Id,
                               c.Subject
                        From Case c
                        Where c.Id = :cId];
/*
          if(oCase.Asset.Product2.Operating_System__c != null)
              catFilter = 'Product_Type:' + oCase.Asset.Product2.Operating_System__c.replace(' ', '_');
*/
          if(oCase.Asset.Product2.Family != null){
              if(catFilter!=null)
                  catFilter = catFilter + ',Product_Type:' + oCase.Asset.Product2.Family;
              else
                  catFilter = 'Product_Type:' + oCase.Asset.Product2.Family;
          }
/*
          if(oCase.Asset.Product2.Vendor__c != null){
              if(catFilter!=null)
                  catFilter = catFilter + ',Vendor:' + oCase.Asset.Product2.Vendor__c.replace(' ', '_');
              else
                  catFilter = 'Vendor:' + oCase.Asset.Product2.Vendor__c.replace(' ', '_');
          }
*/
/*
          if(oCase.Asset.Account.Customer_Type__c != null){
              if(catFilter!=null)
                  catFilter = catFilter + ',Customer_Type:' + oCase.Asset.Account.Customer_Type__c.replace(' ', '_');
              else
                  catFilter = 'Customer_Type:' + oCase.Asset.Account.Customer_Type__c.replace(' ', '_');
          }
*/
      }
    }
    public Case getCase() {
        return oCase;
    }
    private Case c{ 
        get { return getCase(); }
        set; 
    }
    public String getcatFilter() {
        return catFilter;
    }
    
    public void attachToCase(){
        if(kbList == null || kbList == '')
            return;
        List<String> artIDs = kbList.substring(0, kbList.length()-1).split(',');
        
        for(String id : artIDs)
        {
            CaseArticle ca = new CaseArticle();
            ca.CaseId = cId;
            ca.KnowledgeArticleId = id;
            insert ca;
        }
    }
    
  // test methods
  static testMethod void testCaseSuggestedKnowledgeClass() {
    Case oCase = new Case(Origin='Phone',AccountId='001C000000sP4r7',AssetId='02iC0000001xHdz');
    database.insert(oCase);
    String caseId;
    caseId = oCase.Id;
    ApexPages.currentPage().getParameters().put('Id', caseId);
    ApexPages.currentPage().getParameters().put('subject', 'Test subject');
    ApexPages.StandardController con = new ApexPages.StandardController(new Case());
    CaseSuggestedKnowledgeClass ext = new CaseSuggestedKnowledgeClass(con);
    ext.getCase();
    ext.getcatFilter();
    System.debug('TESTS ENDED');
  }
}