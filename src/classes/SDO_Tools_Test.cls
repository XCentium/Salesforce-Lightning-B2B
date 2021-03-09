@isTest
public class SDO_Tools_Test {
    /*
        public SDO_Tools() {
            Initialize();
        }
        
        public SDO_Tools(SDOToolsHomepage sdoToolsHomepage) {
            Initialize();
        }
    */
    
    static testMethod void myTest() {
         //Need to create news, tools & wizard items
         
         SDO_News__c news1 = new SDO_News__c();
         news1.News_Content__c = 'Test content';
         news1.published_Date__c = date.today();
         insert news1;
         
         List<Sdo_Tool__c> toolList = new List<SDO_Tool__C>();
         SDO_Tool__c tool1 = new SDO_Tool__c(url__c='http://www.google.com',height__c=100, width__c=100, order__c = 1,category__c='New Tools',description__c = 'test',active__c=true,product_cloud__c = 'Sales Cloud');
         SDO_Tool__c tool2 = new SDO_Tool__c(url__c='http://www.google.com',height__c=100, width__c=100, order__c = 1,category__c='Everyday Tools',description__c = 'test',active__c=true,product_cloud__c = 'Service Cloud');
         SDO_Tool__c tool3 = new SDO_Tool__c(url__c='http://www.google.com',height__c=100, width__c=100, order__c = 1,description__c = 'test',active__c=true,product_cloud__c = 'Marketing Cloud');
         SDO_Tool__c tool4 = new SDO_Tool__c(url__c='http://www.google.com',height__c=100, width__c=100, order__c = 1,description__c = 'test',active__c=true,product_cloud__c = 'Platform');
         SDO_Tool__c tool5 = new SDO_Tool__c(url__c='http://www.google.com',height__c=100, width__c=100, order__c = 1,description__c = 'test',active__c=true,product_cloud__c = 'Analytics Cloud');
         SDO_Tool__c tool6 = new SDO_Tool__c(url__c='http://www.google.com',height__c=100, width__c=100, order__c = 1,description__c = 'test',active__c=true,product_cloud__c = 'Community Cloud');
         SDO_Tool__c tool7 = new SDO_Tool__c(url__c='http://www.google.com',height__c=100, width__c=100, order__c = 1,description__c = 'test',active__c=true,favorite__c=true,product_cloud__c = 'Other');
         toolList.add(tool1);
         toolList.add(tool2);
         toolList.add(tool3);
         toolList.add(tool4);
         toolList.add(tool5);
         toolList.add(tool6);
         toolList.add(tool7);
         insert toolList;
         
         
         Wizard__c w = new Wizard__c();
         w.name = 'TestWizard';
         insert w;
         
         Wizard_Step__c ws = new Wizard_Step__c();
         ws.name = 'teststep';
         ws.Widard__c = w.id;
         insert ws;
         
         Wizard_Step_Tool__c wsTool = new Wizard_Step_Tool__c();
         wsTool.SDO_Tool__c = tool1.id;
         wsTool.Wizard_Step__c = ws.id;
         insert wsTool;
         
         
        
         
         
         
         SDOToolsHomepage sd1 = new SDOToolsHomepage();
         SDO_Tools SDOTools = new SDO_Tools();
         SDO_Tools SDOTools2 = new SDO_Tools(sd1);
     }
}