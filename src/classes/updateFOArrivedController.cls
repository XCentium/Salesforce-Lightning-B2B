public without sharing class updateFOArrivedController {
    
    @AuraEnabled
    public static String updateFO(String encryptedToken) 
    {
        String result = '';
        try {
            encryptedToken = System.EncodingUtil.urlDecode(encryptedToken, 'UTF-8');
            String decryptedToken = ued.UserCryptoHelper.doDecrypt(encryptedToken);
            String recordId = decryptedToken.split('\\|')[0];
            String orderNumber = decryptedToken.split('\\|')[1];

            FulfillmentOrder fo = [SELECT Id FROM FulfillmentOrder WHERE Id = :recordId AND OrderSummary.OrderNumber = :orderNumber LIMIT 1];
            fo.Status = 'Customer Arrived';
            update fo;
            
            result = 'success';

        } catch(Exception e) {
            result = 'error: ' + e;
        }

        return result;
    }
}