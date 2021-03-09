@IsTest
public class TestEinsteinBuilderMegaController {
    public static testMethod void testGetContactStuffWithoutFactorFieldsField() {
        Contact contactToCreate = new Contact(lastname='testing',firstname='apex');
		
        insert contactToCreate;
        String retJson = EinsteinBuilderMegaController.getObjectData(contactToCreate.Id,'Contact','MailingCity','FirstName,LastName,MailingState','');
        
        System.assert(retJson.contains('testing'));
    }
    
    public static testMethod void testGetContactStuffWithFactorFieldsField() {
        Contact contactToCreate = new Contact(lastname='testing',firstname='apex',MailingState='NY',Description='FirstName,LastName,MailingState');
		
        insert contactToCreate;
        String retJson = EinsteinBuilderMegaController.getObjectData(contactToCreate.Id,'Contact','MailingCity','','Description');
        
        System.debug(retJson);
        
        System.assert(retJson.contains('testing'));
        System.assert(retJson.contains('MailingState'));
    }
    
    public static testMethod void testGetContactStuffWithNoFactorFields() {
        Contact contactToCreate = new Contact(lastname='testing',firstname='apex',MailingState='NY',Description='FirstName,LastName,MailingState');
		
        insert contactToCreate;
        String retJson = EinsteinBuilderMegaController.getObjectData(contactToCreate.Id,'Contact','MailingState','','');
        
        System.debug(retJson);
    }
    
    public static testMethod void testGetFieldLabels() {
        String retJson = EinsteinBuilderMegaController.getFieldLabels('Contact');
        
        System.assert(retJson.contains('FirstName'));
    }
}