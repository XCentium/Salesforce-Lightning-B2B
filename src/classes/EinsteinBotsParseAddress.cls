global with sharing class EinsteinBotsParseAddress {
    @InvocableMethod(label='Einstein Bots - Parse Address' description='Parses the Street, City, State and Postal Code from a String')
    global static List<parsedAddressFields> getAddressSubStrings(List<String> thisAddressList) {
        List<parsedAddressFields> results = new List<parsedAddressFields>();
        for (String thisAddress : thisAddressList) {
            if (thisAddress.length() > 0 && String.IsNotBlank(thisAddress)){ 
                try{
                    List<String> parsedAddress = thisAddress.split(',');
                    if (parsedAddress.size() == 3) {
                        List<String> thisStateAndPostalCode = (parsedAddress[2].trim().split(' '));
                        parsedAddress[2] = thisStateAndPostalCode[0];
                        parsedAddress.add(thisStateAndPostalCode[1]);
                    }
                    parsedAddressFields result = new parsedAddressFields();
                    result.Street = parsedAddress[0].trim();
                    result.City = parsedAddress[1].trim();
                    result.State = parsedAddress[2].trim();
                    result.PostalCode = parsedAddress[3].trim();
                    results.add(result);
                    return results;
                    
                } catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }                
            }
   		}
        
        return new List<parsedAddressFields>();
    }
    
    global class parsedAddressFields
    {
        @InvocableVariable(required=false)
        global String Street;
        @InvocableVariable(required=false)
        global String City;
        @InvocableVariable(required=false)
        global String State;
        @InvocableVariable(required=false)
        global String PostalCode;
    }
}