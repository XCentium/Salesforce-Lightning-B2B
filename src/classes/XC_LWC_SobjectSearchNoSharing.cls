/*
 * @FileName: XC_LWC_SobjectSearchNoSharing
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       9/17/2020         Created
 *-----------------------------------------------------------  
 */
public without sharing class XC_LWC_SobjectSearchNoSharing {

    public static Search.SearchResults searchSOSL(String query) {
        return Search.find(query);
    }

    public static List<SObject> searchSOQL(String query) {
        return Database.query(query);
    }
}