/**
 * @FileName: XC_LWC_CheckoutCtrl
 * @Description: Checkout controller methods
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       9/8/2020         Created
 *-----------------------------------------------------------  
 */
public with sharing class XC_LWC_CheckoutCtrl {

    @AuraEnabled (Cacheable=true)
    public static List<ContactPointAddress> getContactPointAddresses() {
        return XC_LWC_CheckoutCtrlHelper.getContactPointAddresses();
    }

    @AuraEnabled
    public static ContactPointAddress createContactPointAddress(String addressJSON) {
        try {
            return XC_LWC_CheckoutCtrlHelper.createContactPointAddress(addressJSON);
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}