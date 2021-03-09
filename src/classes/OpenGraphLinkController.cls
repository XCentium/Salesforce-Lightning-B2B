global without sharing class OpenGraphLinkController {
    
    global String title {get;set;}
    global String description {get;set;}
    global String url {get;set;}
    global String imageUrl {get;set;}
    global String type {get;set;}
    
    global String redirectUri {get;set;}
    
    global OpenGraphLinkController(){
        String recordId = ApexPages.currentPage().getParameters().get('recordId');
        System.debug(recordId);
        
        //Cases
        if(recordId.startsWith('500')){
            Case c = [Select Id, Subject, Description, OpenGraph_Image__c, OpenGraph_Url__c, OpenGraph_Type__c From Case Where Id = :recordId];
            System.debug(c);
            title = c.Subject;
            description = c.Description;
            url = c.OpenGraph_Url__c;
            imageUrl = c.OpenGraph_Image__c;
            type = c.OpenGraph_Type__c;
        }
        
        //KnowledgeArticleVersions
        if(recordId.startsWith('ka')){
            Knowledge__kav kav = [Select Id, Title, Chat_Answer__c, OpenGraph_Image__c, OpenGraph_Url__c, OpenGraph_Type__c From Knowledge__kav Where Id = :recordId];
            System.debug(kav);
            title = kav.Title;
            description = kav.Chat_Answer__c;
            url = kav.OpenGraph_Url__c;
            imageUrl = kav.OpenGraph_Image__c;
            type = kav.OpenGraph_Type__c;
        }
    }
    
    @RemoteAction
    global static String getNetworkUrl(String pathPrefix){
        Network consumerCommunity = [Select Id From Network Where UrlPathPrefix = :pathPrefix Limit 1];
        String networkURL = ConnectApi.Communities.getCommunity(consumerCommunity.Id).siteUrl;
        System.debug(networkURL);
        return networkURL;
    }
}