@isTest
public class GEF_WorkOrderKnowledgeTestClass {
    static testMethod void GEF_WorkOrderKnowledgeTestClass() {
        test.startTest();
        Account acc = new Account();
        acc.Name = 'testName';
        insert acc;
        
        Contact cc = new Contact();
        cc.LastName  = 'TestLastName';
        cc.FirstName  = 'TestFirstName';
        cc.AccountId = acc.id;
        insert cc;
        
        WorkOrder wo = new WorkOrder();
        wo.AccountId = acc.id;
        wo.ContactId = cc.id;
        wo.Subject = 'TestWorkOrder';
        
        String RecTypeId= [select Id from RecordType where (Name='Person Accounts') and (SobjectType='Account')].Id;
        Account pacc = new Account();
        pacc.RecordTypeId = RecTypeId;
        pacc.FirstName = 'TestFirstName';
        pacc.LastName = 'TestLastName';
        insert pacc;
        
        /*Case ca = new Case();
        ca.status ='new';
        ca.AccountId = acc.id;
        ca.ContactId = cc.id;
        ca.Subject = 'TestCase';
        insert ca;*/
        
        /*Customer_Survey__c cs = new Customer_Survey__c();
        cs.Case__c = ca.id;
        cs.Contact__c = cc.id;
        cs.Question_1__c = '7 - Strongly Agree';
        cs.Question_2__c = '5 - Very Satisfied';
        cs.Question_3__c = '10 - Extremely Likely';
        cs.Question_4__c = 'Yes';
        insert cs;*/
        
        
        GEF_KnowledgeClass.searchknowledgeArticles('test', '5', wo.id, 'User Language');
        GEF_KnowledgeClass.searchknowledgeArticles('test', '5', wo.id, 'en_US');
        GEF_KnowledgeClass.getSuggestedArticles('5', wo.id);
        GEF_KnowledgeClass.getAllArticles(5, wo.id);
        List<KnowledgeArticleVersion> kavList = [SELECT id FROM KnowledgeArticleVersion LIMIT 1];
        if (!kavList.isEmpty()) {        
	        GEF_KnowledgeClass.attachArticleToObject(wo.id, kavList[0].id);
    	    GEF_KnowledgeClass.detachArticleToObject(wo.id, kavList[0].id);
        } else {
            GEF_KnowledgeClass.attachArticleToObject(wo.id, '1MP0O000000L0anWAC');
    	    GEF_KnowledgeClass.detachArticleToObject(wo.id, '1MP0O000000L0anWAC');
        }
        
        test.stopTest();
    }
}