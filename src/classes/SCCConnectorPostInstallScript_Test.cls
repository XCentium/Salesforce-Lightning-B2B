@IsTest
public class SCCConnectorPostInstallScript_Test  {
    @TestSetup static void setup() {
        SCCConnectorPostInstallScript.insertCustomSettingsData();
    }

    @IsTest
    static void test_method_one() {
        List<ContactFieldMapping__c> contactFieldMappings = ContactFieldMapping__c.getAll().values();
        System.assert(!contactFieldMappings.isEmpty());
    }
}