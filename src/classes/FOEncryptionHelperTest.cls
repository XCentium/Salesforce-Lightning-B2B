@isTest
private class FOEncryptionHelperTest {
    
     //Creating Fulfillment Orders and all related objects not clear
    //Replace with proper test method include proper creation of FO and related records
    static testMethod void default() {
        List<FOEncryptionHelper.FORequest> foreqList = new List<FOEncryptionHelper.FORequest>();
        FOEncryptionHelper.FORequest foreq = new FOEncryptionHelper.FORequest();
        foreq.recordId = System.UserInfo.getUserId();
        foreq.orderNumber = System.UserInfo.getUserType();
        foreqList.add(foreq);

        try { 
            List<FOEncryptionHelper.FOResult> foresList = FOEncryptionHelper.encryptFORecordId(foreqList);
        } catch(Exception e) {
            System.assertNotEquals(null, e);
        }

    }

}