/**
 * Created by msobczak on 10/11/2018.
 */

public with sharing class ckz_CheckConfigSetting {

    @InvocableMethod(label='Check Config Setting')
    public static List<ConfigSettingResponse> checkConfigSettings(List<ConfigSettingRequest> requests) {

        List<ConfigSettingResponse> responses = new List<ConfigSettingResponse>();

        for(ConfigSettingRequest request : requests) {
            ConfigSettingResponse response = checkConfigSetting(request);
            responses.add(response);
        }

        return responses;

    }

    public static ConfigSettingResponse checkConfigSetting(ConfigSettingRequest request) {

        System.debug('storefront: ' + request.storefront);
        System.debug('page: ' + request.page);
        System.debug('externallySafe: ' + request.externallySafe);
        System.debug('configSetting: ' + request.configSetting);

        Map<String, Object> inputConfigData = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
                , ccrz.ccApiConfig.STORE_NAME => request.storefront
                , ccrz.ccApiConfig.PAGE_NAME => request.page
                , ccrz.ccApiConfig.USE_CACHE => TRUE
                , ccrz.ccApiConfig.EXTERNALLY_SAFE => request.externallySafe
                , ccrz.ccApiConfig.RETURN_SERIAL => FALSE
        };

        Map<String, String> configMap = (Map<String, String>) ccrz.ccAPIConfig.fetch(inputConfigData).get(ccrz.ccAPIConfig.CONFIGURATIONS);

        String configValue = configMap.get(request.configSetting);

        ConfigSettingResponse response = new ConfigSettingResponse();
        response.configSetting = request.configSetting;
        response.configValue = configValue;

        System.debug(request.configSetting + ': ' + response.configValue);

        return response;

    }

    public class ConfigSettingRequest {

        @InvocableVariable(required=true)
        public String storefront;

        @InvocableVariable(required=true)
        public String configSetting;

        @InvocableVariable(required=true)
        public String page;

        @InvocableVariable(required=true)
        public Boolean externallySafe;

    }

    public class ConfigSettingResponse {
        @InvocableVariable
        public String configSetting;

        @InvocableVariable
        public String configValue;
    }

}