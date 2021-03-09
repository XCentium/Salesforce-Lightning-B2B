global class EinsteinChatbotsSearchArticlesSNIPPET {
     global class KnowledgeArticleTitleRequest {
         @InvocableVariable
        global string category;
         
         @InvocableVariable
         global String queryString;
    }      
    
    
    
    @InvocableMethod(label='Einstein Chatbots - Search Knowledge Articles WITH SNIPPET' description='Returns a list of Knowledge Articles (using WITH SNIPPET arguement instead of Chat_Answer__c) for provided Data Category and Search String')
    global static List<List<Knowledge__kav>> fetchKnowledgeArticleSearchAndFilter(List<KnowledgeArticleTitleRequest> queryParams) {
        List<List<Knowledge__kav>> results = new List<List<Knowledge__kav>>();
        for(KnowledgeArticleTitleRequest param : queryParams) {
            results.add(fetchKnowledgeArticle(param.category, param.queryString));                         
        }
        return results;

    }    
    
    public static List<Knowledge__kav> fetchKnowledgeArticle(string category, string searchQuery) {
          
        category = String.join(category.split(' '), '_') + '__c';
        category = category == 'All__c' ? 'below ' + category :  'above ' + category;
        string searchString = 'FIND \'' + searchQuery + '\' IN ALL FIELDS RETURNING Knowledge__kav (ID, Title,Chat_Answer__c,chatsnippet__c, UrlName, KnowledgeArticleId) WITH DATA CATEGORY Product__c '+ category +' WITH SNIPPET (target_length=120) limit 3';
        
        Search.SearchResults searchresults = search.find( searchString);
        List<Search.SearchResult> articlelist = searchResults.get('Knowledge__kav'); 
        
        
        list<Knowledge__kav> result = new list<Knowledge__kav>{};
        string siteUrl;
        for(ConnectApi.Community c :ConnectApi.Communities.getCommunities().communities){
            if(c.urlpathprefix == 'consumer') siteUrl = c.siteUrl;    
        }
        
        for(Search.SearchResult article : articlelist){
            Knowledge__kav faq  = (Knowledge__kav) article.getSObject();
            //faq.chatsnippet__c = article.getSnippet();
            
            //TODO: create a class w/ invocable variables and return that
            //instead of reassigning fields on the sObject
            //if(faq.chatsnippet__c != null) {
            //    faq.chatsnippet__c = faq.chatsnippet__c.replaceAll('(</mark>|<mark>)', '');
            //}else{
            //    faq.chatsnippet__c = faq.Title;
            //}
            
            string articleUrl = siteUrl + '/s/article/' + faq.UrlName;
            
            //TODO: create a class w/ invocable variables and return that
            //instead of reassigning fields on the sObject
            faq.UrlName = EinsteinChatbotsURLShortener.shortenUrl(articleUrl);
            //system.debug(faq.chatsnippet__c);
            result.add(faq);
        }
        
        return result;
    }
}