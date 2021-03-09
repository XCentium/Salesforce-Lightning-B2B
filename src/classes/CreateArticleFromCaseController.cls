//This class controls the "Create Article from Case" action on Cases.  Added to the SDO in April 2016, updated in May 2018.

global with sharing class CreateArticleFromCaseController {
public CreateArticleFromCaseController(ApexPages.StandardController controller) {}

   @remoteAction
   global static void createArticle(String caseId){
   Case c = [SELECT Subject, Description FROM CASE WHERE Id =: caseId];

    String subject = String.valueof(c.Subject);
    String sText = subject.replaceAll( '\\s+', '-');
    String specialChars = '&|^|@|?|.|/|*|$|!|=|+|"|`|~|[|]|{|}|<|>|€|£|(|)|\'|,|';
    for(integer i=0; i<specialChars.split('|').size(); i++)
      sText = sText.replace(specialChars.split('|')[i], '');

     Knowledge__kav a = new Knowledge__kav(
          Title = c.Subject,
          Summary = c.Description,
          FAQ_Answer__c = c.Description,          
          URLName = sText
      );

      insert a;

      a = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :a.Id];

      KbManagement.PublishingService.publishArticle(a.KnowledgeArticleId, true);

      FeedItem fi = new FeedItem();
        fi.Body = 'A new article has been created and added to the Knowledge Base.';                
        fi.ParentId = caseId;

        insert fi;
  }
}