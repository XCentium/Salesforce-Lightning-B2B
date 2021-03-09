public with sharing class CatalogConfiguration {

    Transient Document CatalogBackgroundImage {get;set;}
    Public Catalog_Template__c myCatalogTemplate {get;set;}
    Public Catalog_Template__c myExistingCatalogTemplate {get;set;}
    Public transient Blob b {get;set;}
    Public Integer bSize {get;set;}

    public CatalogConfiguration() {
        initialize();
    }
    
    public PageReference initialize() {
        if(!Catalog_Template__c.sObjectType.getDescribe().isCreateable()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
            return null;
        }
        //Check for Template Record, if NULL Create new Catalog Template with values from brander
        Integer TemplateCheck = [SELECT count() FROM Catalog_Template__c WHERE Name = 'Catalog Template 1'];
        bSize = 0;
        if(TemplateCheck == 0) {
            // No Template exists, so make one
            myCatalogTemplate = new Catalog_Template__c();
            myCatalogTemplate.Name = 'Catalog Template 1';
            // We made a new Template
        } else {
            // Template exists, so grab it to edit
            myCatalogTemplate = [SELECT Id, Title_Text__c, Title_Text_Color__c, Title_Text_Size__c, Subtitle_Text__c, Subtitle_Text_Color__c, Subtitle_Text_Size__c, Category_Text_Color__c, Header_Left_Text_Color__c, Header_Right_Text_Color__c FROM Catalog_Template__c WHERE Name = 'Catalog Template 1' LIMIT 1];
            // We have the existing Template
        }
        return null;
    }
    
    public PageReference saveTemplate() {
        if(!Catalog_Template__c.sObjectType.getDescribe().isCreateable()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
            return null;
        }
        upsert myCatalogTemplate;
        return null;
    }

    public PageReference saveFile() {
        if(!Document.sObjectType.getDescribe().isAccessible()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
            return null;
        }
        //update the Document named Catalog_BG
        if (bSize > 0) {
            System.debug('DOCUMENT: The blob had size > 0 - so we are updating CatalogBackgroundImage.');
            CatalogBackgroundImage = [SELECT Body FROM Document WHERE name = 'Catalog_BG' LIMIT 1];
            // We have the background document
            CatalogBackgroundImage.Body = b;
            update CatalogBackgroundImage;
        } else { 
            // DOCUMENT: No file was uploaded - so do not update CatalogBackgroundImage
        }
        return null;
    }
}