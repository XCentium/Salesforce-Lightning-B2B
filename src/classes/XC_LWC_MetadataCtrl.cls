/**
 * @FileName: XC_LWC_MetadataCtrl
 * @Description: Controller methods for returning data to lighting web components
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       6/18/2020       Created
 *-----------------------------------------------------------  
 */
public with sharing class XC_LWC_MetadataCtrl {

    @AuraEnabled(Cacheable=true)
    public static List<ApexClass> getActiveApexClasses() {
        return XC_LWC_MetadataCtrlHelper.getActiveApexClasses();
    }

    @AuraEnabled
    public static XC_LWC_CheckoutRegistrationWrapper registerExternalService(String webstoreId, String apexClassId, String apiVersion, String serviceType) {
        XC_LWC_CheckoutRegistrationWrapper wrapper = new XC_LWC_CheckoutRegistrationWrapper(webstoreId, apexClassId, apiVersion, serviceType);

        try {
            wrapper.registerExternalService();
        } catch (Exception e) {
            System.debug(e.getMessage());
            wrapper.errorMessages.add(e.getMessage());
        }

        return wrapper;
    }

    @AuraEnabled
    public static XC_LWC_CheckoutRegistrationWrapper createStoreIntegratedService(String webstoreId, String registeredIntegrationId, String serviceType) {
        XC_LWC_CheckoutRegistrationWrapper wrapper = new XC_LWC_CheckoutRegistrationWrapper(webstoreId, registeredIntegrationId, serviceType);

        try {
            wrapper.storeIntegratedService();
        } catch (Exception e) {
            System.debug(e.getMessage());
            wrapper.errorMessages.add(e.getMessage());
        }

        return wrapper;
    }

    @AuraEnabled
    public static List<XC_LWC_CheckoutRegistrationHelper.StoreExternalService> getCheckoutExternalServices(String webstoreId) {
        try {
            return XC_LWC_CheckoutRegistrationHelper.getCheckoutExternalServices(webstoreId);
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void removeExternalService(Id storeIntegratedServiceId) {
        try {
            XC_LWC_CheckoutRegistrationHelper.removeExternalService(storeIntegratedServiceId);
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}