global class EinsteinChatbotsWifiArticle {
    global class KnowledgeArticleTitleRequest {
         @InvocableVariable
        global string category;
         
         @InvocableVariable
         global String queryString;
    }      
    
    global class KnowledgeArticleTitleResult {
        @InvocableVariable
        global String KnowledgeTitle;
        
        @InvocableVariable
        global String ChatAnswer;
    }
       
    @InvocableMethod(label='Einstein Chatbots - Search Wifi Knowledge Articles' description='Returns a list of Wifi Knowledge Articles for provided Data Category and Search String')
    global static List<List<Knowledge__kav >> fetchKnowledgeArticleSearchAndFilter(List<KnowledgeArticleTitleRequest> queryParams) {
        List<List<Knowledge__kav >> results = new List<List<Knowledge__kav >>();
        for(KnowledgeArticleTitleRequest param : queryParams) {
            results.add(fetchKnowledgeArticle('wifi'));                         
        }
        return results;

    }    
    
    public static List<SObject> fetchKnowledgeArticle(string searchQuery) {
        KnowledgeArticleTitleResult result = new KnowledgeArticleTitleResult();    
        string searchString = 'FIND \'' + searchQuery + '*\' IN ALL FIELDS RETURNING Knowledge__kav  (ID, Title,Chat_Answer__c,Linked_Article__c , UrlName, KnowledgeArticleId)  limit 3';
        system.debug(searchString);
        List<List<SObject>> catdata = Search.query(searchString); 
  
        return catdata[0];
    }
}