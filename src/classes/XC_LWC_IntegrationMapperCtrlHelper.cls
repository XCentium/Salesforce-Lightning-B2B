/**
 * @FileName: XC_LWC_IntegrationMapperCtrlHelper
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       7/14/2020         Created
 *-----------------------------------------------------------  
 */
public with sharing class XC_LWC_IntegrationMapperCtrlHelper {

    public static List<StoreExternalService> getCheckoutExternalServices(String webstoreId) {
        List<StoreExternalService> externalServices = new List<StoreExternalService>();

        List<StoreIntegratedService> storeIntegratedServices = [
                SELECT Id, Integration, ServiceProviderType FROM StoreIntegratedService
                WHERE StoreId = :webstoreId
                AND ServiceProviderType != 'Flow'
        ];

        if (storeIntegratedServices.isEmpty()) return externalServices;

        Map<String,StoreIntegratedService> integratedServicesMap = new Map<String,StoreIntegratedService>();

        for (StoreIntegratedService sis : storeIntegratedServices) {
            integratedServicesMap.put(sis.Integration, sis);
        }

        List<RegisteredExternalService> registeredExternalServices = [
                SELECT Id, DeveloperName, ExternalServiceProviderId, ExternalServiceProvider.Name, ExternalServiceProviderType
                FROM RegisteredExternalService
        ];

        Map<String,RegisteredExternalService> registeredExternalServicesMap = new Map<String,RegisteredExternalService>();

        for (RegisteredExternalService res : registeredExternalServices) {
            registeredExternalServicesMap.put(res.ExternalServiceProviderType + '__' + res.DeveloperName, res);
        }

        for (String integratedServiceId : integratedServicesMap.keySet()) {
            StoreIntegratedService storeIntegratedService = integratedServicesMap.get(integratedServiceId);
            RegisteredExternalService registeredExternalService = registeredExternalServicesMap.get(integratedServiceId);

            StoreExternalService externalService = new StoreExternalService();
            externalService.serviceType = storeIntegratedService.ServiceProviderType;
            externalService.apexClassName = registeredExternalService.ExternalServiceProvider.Name;
            externalService.storeIntegratedServiceId = storeIntegratedService.Id;

            externalServices.add(externalService);
        }

        return externalServices;
    }

    public static void removeExternalService(Id storeIntegratedServiceId) {
        delete new StoreIntegratedService(Id = storeIntegratedServiceId);
    }

    public class StoreExternalService {
        @AuraEnabled public String serviceType;
        @AuraEnabled public String apexClassName;
        @AuraEnabled public Id storeIntegratedServiceId;
    }
}