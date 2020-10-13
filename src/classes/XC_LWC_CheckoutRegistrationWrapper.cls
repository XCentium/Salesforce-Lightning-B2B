/**
 * @FileName: XC_LWC_CheckoutRegistrationWrapper
 * @Description: Wrapper class for creating checkout registration services
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       6/25/2020         Created
 *-----------------------------------------------------------  
 */
public with sharing class XC_LWC_CheckoutRegistrationWrapper {
    public String webstoreId;
    public String apexClassId;
    public Decimal apiVersion;
    public String serviceType;
    public String devName;
    public String prefixedName;
    public String storeIntegratedServiceId;

    @AuraEnabled public String registeredIntegrationId;
    @AuraEnabled public List<String> messages;
    @AuraEnabled public List<String> errorMessages;

    public XC_LWC_CheckoutRegistrationWrapper(String webstoreId, String apexClassId, String apiVersion, String serviceType) {
        this.webstoreId = webstoreId;
        this.apexClassId = apexClassId;
        this.apiVersion = Decimal.valueOf(apiVersion);
        this.serviceType = serviceType;
        this.messages = new List<String>();
        this.errorMessages = new List<String>();

        setRegistrationParameters();
    }

    public XC_LWC_CheckoutRegistrationWrapper(String webstoreId, String registeredIntegrationId, String serviceType) {
        this.webstoreId = webstoreId;
        this.registeredIntegrationId = registeredIntegrationId;
        this.serviceType = serviceType;
        this.messages = new List<String>();
        this.errorMessages = new List<String>();

        setRegistrationParameters();
    }

    private void setRegistrationParameters() {
        this.devName = XC_Util_Constants.CHECKOUT_EXTERNAL_SERVICE_TYPES.get(this.serviceType);
        this.prefixedName = this.serviceType + '__' + this.devName;
    }

    public void registerExternalService() {
        try {
            RegisteredExternalService registeredExternalService = Database.query(
                    'SELECT Id FROM RegisteredExternalService ' +
                    'WHERE ExternalServiceProviderId = :apexClassId ' +
                    'AND DeveloperName = :devName ' +
                    'AND ExternalServiceProviderType = :serviceType ' +
                    'LIMIT 1'
            );

            this.registeredIntegrationId = registeredExternalService.Id;
            this.messages.add('Registered External Service: FOUND ' + this.registeredIntegrationId);
        } catch (QueryException q) {
            RegisteredExternalService registeredExternalService = new RegisteredExternalService(
                    DeveloperName = this.devName,
                    MasterLabel = this.devName,
                    ExternalServiceProviderId = apexClassId,
                    ExternalServiceProviderType = this.serviceType
            );

            insert registeredExternalService;

            this.registeredIntegrationId = registeredExternalService.Id;
            this.messages.add('Registered External Service: INSERTED ' + this.registeredIntegrationId);
        }
    }

    public void storeIntegratedService() {
        // locate and map in StoreIntegratedService
        try {
            StoreIntegratedService storeIntegratedService = Database.query(
                    'SELECT Id FROM StoreIntegratedService ' +
                    'WHERE Integration = :prefixedName ' +
                    'AND ServiceProviderType = :serviceType ' +
                    'AND StoreId = :webstoreId ' +
                    'LIMIT 1'
            );

            this.storeIntegratedServiceId = storeIntegratedService.Id;
            this.messages.add('Store Integrated Service: FOUND ' + this.storeIntegratedServiceId);
        } catch (QueryException q) {
            StoreIntegratedService storeIntegratedService = new StoreIntegratedService(
                    Integration = this.prefixedName,
                    ServiceProviderType = this.serviceType,
                    StoreId = this.webstoreId
            );
            insert storeIntegratedService;

            this.storeIntegratedServiceId = storeIntegratedService.Id;
            this.messages.add('Store Integrated Service: INSERTED ' + this.storeIntegratedServiceId);
        }
    }
}