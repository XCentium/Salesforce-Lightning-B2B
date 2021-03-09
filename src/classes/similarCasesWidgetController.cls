public class similarCasesWidgetController {
    private List<Id> caseIDs;
    public List<Case> oSimilarCases {get; set;}
    public String caseID {get;set;}
    
    public similarCasesWidgetController() {
        caseID = ApexPages.currentPage().getParameters().get('id');
        if (caseID > ''){
            // Returns at most 4 most similar cases found for the given case id.
            caseIDs = SupportPredictiveService.findSimilarCases(caseID);
            oSimilarCases = [SELECT Id, Priority, Description, Origin, CaseNumber, Status, Subject, LastModifiedDate, Asset.Name
                             FROM Case
                             WHERE Id IN :caseIDs
                             ORDER BY LastModifiedDate DESC];
            /*
            SELECT Id,ArticleLanguage,ArticleVersionNumber,IsDeleted,IsSharedByEmail,KnowledgeArticleId
            FROM CaseArticle
            WHERE CaseId = ''
            */
        }
    }
    public List<Case> getSimilarCases() {
        return oSimilarCases;
    }
}