global without sharing class FOEncryptionHelper {

    @InvocableMethod(label='Encrypt Fulfillment Order' description='Method to Encrypt Fulfillment Order Record Id')
    global static List<FOResult> encryptFORecordId(List<FORequest> requestList) 
    {
        
        List<FOResult> foResultList = new List<FOResult>();
        for(FORequest foreq : requestList)
        {
            FOResult fores = new FOResult();
            
            String userIdQuery = (System.Test.isRunningTest()) ? System.UserInfo.getUserId() : Label.FO_Guest_User_Id;
            
            User u = [SELECT Id FROM User WHERE Id = :userIdQuery LIMIT 1];
            Id userId = u.Id;
            String plainToken = foreq.recordId + '|' + foreq.orderNumber;
            String encryptedToken = ued.UserCryptoHelper.doEncrypt(plainToken, userId);
            encryptedToken = System.EncodingUtil.urlEncode(encryptedToken, 'UTF-8');
            FulfillmentOrder fo = new FulfillmentOrder();
            fo.Id = foreq.recordId;
            fo.Encrypted_Record_Id__c = encryptedToken;
            update fo;
            fores.result = 'success';
            
            foResultList.add(fores);
        }

        return foResultList;

    }

global class FORequest 
{
    @InvocableVariable(required=true)
    global String recordId;

    @InvocableVariable(required=true)
    global String orderNumber;

}

global class FOResult
{
    @InvocableVariable
    global String result;
}

}