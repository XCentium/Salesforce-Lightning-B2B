public with sharing class GEF_KnowledgeClass {
    
    @AuraEnabled
    public static List<Search.SuggestionResult> searchAllArticles(String searchText, String language, Integer nbResult) {
        Search.SuggestionResults suggestionResults = NULL;
        Search.SuggestionOption options = new Search.SuggestionOption();
        Search.KnowledgeSuggestionFilter filters = new Search.KnowledgeSuggestionFilter();
        
        filters.setLanguage(language);
        filters.setPublishStatus('Online');
        options.setFilter(filters);
        options.setLimit(nbResult);
        suggestionResults = Search.suggest(searchText, 'KnowledgeArticleVersion', options);
        
        return suggestionResults.getSuggestionResults();
    }
    
    @AuraEnabled
    public static List<GEF_KnowledgeContainer> searchknowledgeArticles(String searchInput, String nbResult, String recordId, String language) {
        Integer nbResultInt = Integer.valueOf(nbResult);
        List<Search.SuggestionResult> suggestionResults = NULL;
        List<Id> knowledgeArticleIds = new List<Id>();
        List<KnowledgeArticleVersion> knowledgeArticles = new List<KnowledgeArticleVersion>();
        List<GEF_KnowledgeContainer> kcList = new List<GEF_KnowledgeContainer>();
        String userLanguage = UserInfo.getLanguage();
        
        if (searchInput.length() > 2) {
            if (language == 'User Language')
                suggestionResults = searchAllArticles(searchInput, userLanguage, nbResultInt);
            else
                suggestionResults = searchAllArticles(searchInput, language, nbResultInt);
            for (Search.SuggestionResult suggestionResult : suggestionResults) {
                knowledgeArticleIds.add(((KnowledgeArticleVersion) suggestionResult.getSObject()).id);
            }  
            knowledgeArticles = [SELECT id, title, summary, publishStatus, LastPublishedDate, ArticleNumber
                                 FROM KnowledgeArticleVersion 
                                 WHERE Id IN :knowledgeArticleIds AND
                                 publishStatus = 'Online'
                                 ORDER BY Title
                                 LIMIT :nbResultInt];
            for (KnowledgeArticleVersion knowledgeArticle : knowledgeArticles) {
                GEF_KnowledgeContainer kc = new GEF_KnowledgeContainer(knowledgeArticle);
                
                kc.attached = (([SELECT COUNT() FROM LinkedArticle 
                                 WHERE KnowledgeArticleVersionId = :kc.KnowledgeArticle.id AND
                                 LinkedEntityId = :recordId]) > 0);
                kcList.add(kc);
            }
        }
        return kcList;
    }
    
    @AuraEnabled
    public static List<GEF_KnowledgeContainer> getNonAttachedArticles(Integer nbResult, List<Id> attachedListIds) {
        List<GEF_KnowledgeContainer> kcList = new List<GEF_KnowledgeContainer>();
        List<KnowledgeArticleVersion> kavList = new List<KnowledgeArticleVersion>();
        
        kavList = [SELECT id, title, summary, publishStatus, LastPublishedDate, ArticleNumber
                   FROM KnowledgeArticleVersion 
                   WHERE Id NOT IN :attachedListIds AND
                   publishStatus = 'Online'
                   ORDER BY LastPublishedDate DESC
                   LIMIT :nbResult];
        for (KnowledgeArticleVersion kav : kavList) {
            kcList.add(new GEF_KnowledgeContainer(kav, false));
        }
        return kcList;
    }
    
    @AuraEnabled
    public static List<GEF_KnowledgeContainer> getArticles(Integer nbResult, String recordId) {
        List<GEF_KnowledgeContainer> kcList = new List<GEF_KnowledgeContainer>();
        List<LinkedArticle> LinkedArticles = [SELECT id, KnowledgeArticleVersionId FROM LinkedArticle WHERE LinkedEntityId = :recordId];
        List<Id> attachedArticleIds = new List<Id>();
        List<KnowledgeArticleVersion> attachedArticles = new List<KnowledgeArticleVersion>();
        
        for(LinkedArticle LinkedArticle : LinkedArticles) {
            attachedArticleIds.add(LinkedArticle.KnowledgeArticleVersionId);
        }
        
        attachedArticles = [SELECT id, title, Summary, publishStatus, LastPublishedDate, ArticleNumber 
                            FROM KnowledgeArticleVersion 
                            WHERE id IN :attachedArticleIds AND
                            publishStatus = 'Online'
                            ORDER BY KnowledgeArticleVersion.title
                            LIMIT :nbResult];
        for (KnowledgeArticleVersion attachedArticle : attachedArticles) {
            kcList.add(new GEF_KnowledgeContainer(attachedArticle, true));
        }
        kcList.addAll(getNonAttachedArticles(nbResult - kcList.size(), attachedArticleIds));
        return kcList;
    }
    
    @AuraEnabled
    public static List<GEF_KnowledgeContainer> getAllArticles(Integer nbResult, String recordId) {
        List<GEF_KnowledgeContainer> kcList = new List<GEF_KnowledgeContainer>();
        List<KnowledgeArticleVersion> kavList = new List<KnowledgeArticleVersion>();
        
        kavList = [SELECT id, title, summary, publishStatus, LastPublishedDate, ArticleNumber
                   FROM KnowledgeArticleVersion 
                   WHERE publishStatus = 'Online'
                   ORDER BY LastPublishedDate DESC
                   LIMIT :nbResult];
        for (KnowledgeArticleVersion kav : kavList) {
            GEF_KnowledgeContainer kc = new GEF_KnowledgeContainer(kav);

            kc.attached = (([SELECT COUNT() FROM LinkedArticle 
                             WHERE KnowledgeArticleVersionId = :kav.id AND
                             LinkedEntityId = :recordId]) > 0);
            kcList.add(kc);
        }
        return kcList;
    }
    
    @AuraEnabled
    public static List<GEF_KnowledgeContainer> getSuggestedArticles(String nbResult, String recordId) {
        Integer nbResultInt = Integer.valueOf(nbResult);
        List<GEF_KnowledgeContainer> kcList = getArticles(nbResultInt, recordId);
        
        return kcList;
    }
    
    @AuraEnabled
    public static void attachArticleToObject(String recordId, String KnowledgeArticleVersionId) {
        LinkedArticle la = new LinkedArticle();
        if (KnowledgeArticleVersionId != NULL) {
            KnowledgeArticleVersion kav = NULL;
            List<KnowledgeArticleVersion> kavList = [SELECT id, Title, KnowledgeArticleId, ArticleTotalViewCount, Language
                                                     FROM KnowledgeArticleVersion 
                                                     WHERE id = :KnowledgeArticleVersionId Limit 1];
            if (!kavList.isEmpty())
                kav = kavList[0];
            if (kav != NULL) {
                la.Name = kav.Title;
                la.KnowledgeArticleVersionId = kav.Id;
                la.KnowledgeArticleId = kav.KnowledgeArticleId;
                la.LinkedEntityId = recordId;
                insert la;
            }
        }
    }
    
    @AuraEnabled
    public static void detachArticleToObject(String recordId, String KnowledgeArticleVersionId) {
        if (KnowledgeArticleVersionId != NULL) {
            List<LinkedArticle> laList = [SELECT id 
                                          FROM LinkedArticle 
                                          WHERE KnowledgeArticleVersionId = :KnowledgeArticleVersionId AND
                                          LinkedEntityId = :recordId];
            
            if (!laList.isEmpty())
                delete laList;
        }
    }
}