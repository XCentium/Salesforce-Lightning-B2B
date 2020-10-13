/**
 * @FileName: XC_Util_ApexTest
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       8/16/2020         Created
 *-----------------------------------------------------------  
 */
@IsTest
private class XC_Util_ApexTest {

    @IsTest
    static void filterOnFieldChange() {
        Map<Id,SObject> objects1 = new Map<Id,SObject>(XC_Util_TestData.createSObjectList(new Account(), 2, true));
        Map<Id,SObject> objects2 = new Map<Id,SObject>(XC_Util_TestData.createSObjectList(new Account(), 2, true));

        List<SObject> hasNotChanged;
        List<SObject> hasChanged;

        Test.startTest();
        hasNotChanged = XC_Util_Apex.filterOnFieldChange(objects1.values(), objects1, 'Name');
        hasChanged = XC_Util_Apex.filterOnFieldChange(objects1.values(), objects2, 'Name');
        Test.stopTest();

        System.assert(hasNotChanged.isEmpty(), 'Name fields should not be different');
        System.assert(!hasChanged.isEmpty(), 'Name fields should be different');
    }

    @IsTest
    static void fieldChanged() {
        List<SObject> objects = XC_Util_TestData.createSObjectList(new Account(), 2);

        Boolean hasNotChanged;
        Boolean hasChanged;

        Test.startTest();
        hasNotChanged = XC_Util_Apex.fieldChanged(objects[0], objects[0], 'Name');
        hasChanged = XC_Util_Apex.fieldChanged(objects[0], objects[1], 'Name');
        Test.stopTest();

        System.assertEquals(false, hasNotChanged, 'Name field should not be different');
        System.assert(hasChanged, 'Name field should be different');
    }

    @IsTest
    static void writeToTargetRecord() {
        SObject acc = XC_Util_TestData.createSObject(new Account());
        SObject con = XC_Util_TestData.createSObject(new Contact());
        Map<String,String> fieldMapping = new Map<String,String>{'LastName' => 'Name'};

        Test.startTest();
        XC_Util_Apex.writeToTargetRecord(acc, con, fieldMapping);
        Test.stopTest();

        System.assertEquals(acc.get('Name'), con.get('LastName'), 'Account name should equal Contact last name');
    }

    @IsTest
    static void convertListToMap() {
        List<SObject> objects = XC_Util_TestData.createSObjectList(new Account(), 2);

        Test.startTest();
        Map<String,SObject> objectsByName = (Map<String,SObject>) JSON.deserialize(
                XC_Util_Apex.convertListToMap(objects, 'Name', false),
                Map<String,SObject>.class
        );
        Test.stopTest();

        System.assertNotEquals(null, objectsByName.get(String.valueOf(objects[0].get('Name'))), 'Name fields should be used as map keys');
    }

    @IsTest
    static void convertListToMapListValues() {
        List<SObject> objects = XC_Util_TestData.createSObjectList(new Account(), 2);

        Test.startTest();
        Map<String,List<SObject>> objectsByName = (Map<String,List<SObject>>) JSON.deserialize(
                XC_Util_Apex.convertListToMap(objects, 'Name'),
                Map<String,List<SObject>>.class
        );
        Test.stopTest();

        System.assertNotEquals(null, objectsByName.get(String.valueOf(objects[0].get('Name'))), 'Name fields should be used as map keys');
    }

    @IsTest
    static void getFieldPicklistValues() {
        Test.startTest();
        List<XC_Util_Apex.OptionWrapper> picklistValues = XC_Util_Apex.getFieldPicklistValues('Account', 'Type', true);
        Test.stopTest();

        System.assert(!picklistValues.isEmpty());
    }

    @IsTest
    static void getFieldValue() {
        SObject object1 = XC_Util_TestData.createSObject(new Account(), true);
        SObject object2 = XC_Util_TestData.createSObject(new Account(
                ParentId = (Id) object1.get('Id')
        ), true);

        SObject object2After = [SELECT Id, Parent.Name FROM Account WHERE Id = :(Id) object2.get('Id')];

        Test.startTest();
        String fieldValue = (String) XC_Util_Apex.getFieldValue(object2After, 'Parent.Name');
        Test.stopTest();

        System.assertEquals((String) object1.get('Name'), fieldValue);
    }

    @IsTest
    static void getIdsFromField() {
        List<SObject> objects = XC_Util_TestData.createSObjectList(new Account(), 25, true);

        Test.startTest();
        Set<Id> accountIds = XC_Util_Apex.getIdsFromField(objects, 'Id');
        Test.stopTest();

        System.assertEquals(25, accountIds.size());
    }
}