public class SCCAddressController {

    @AuraEnabled
    public static Map<String, String> getCountryList(){
        Map<String, String> countryMap = new Map<String, String>();
		countryMap.put('US', 'United States');
        return countryMap;
    }

}