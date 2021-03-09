public class GEF_KnowledgeContainer {
    @AuraEnabled
    public boolean attached {get; set;}
    @AuraEnabled
    public KnowledgeArticleVersion KnowledgeArticle {get; set;}
    
    public GEF_KnowledgeContainer() {        
    }
    
    public GEF_KnowledgeContainer(KnowledgeArticleVersion KnowledgeArticle) {
        this.attached = false;
        this.KnowledgeArticle = KnowledgeArticle;
    }
    
    public GEF_KnowledgeContainer(KnowledgeArticleVersion KnowledgeArticle, boolean attached) {
        this.attached = attached;
        this.KnowledgeArticle = KnowledgeArticle;
    }
}