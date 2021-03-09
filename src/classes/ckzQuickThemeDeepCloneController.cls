public with sharing class ckzQuickThemeDeepCloneController {

    public ckzQuickThemeDeepCloneController() {

    }

    @AuraEnabled public static Map<String, Object> fetchCurrentQuickThemeInfo(Id recordId) {
        System.debug('---- begin getCurrentQuickThemeInfo');

        Map<String, Object> responseMap = new Map<String, Object>();

        Quick_Theme__c qt = getQuickThemeInfo (recordId);

        if(qt != null) {
            responseMap.put('name', qt.Name);
        }

        return responseMap;
    }

    @AuraEnabled
    public static Map<String, Object> cloneQuickTheme(Id currentQuickThemeId, String newQuickThemeName) {

        System.debug('---- begin cloneQuickTheme');

        System.debug('currentQuickThemeId: ' + currentQuickThemeId);
        System.debug('newQuickThemeName: ' + newQuickThemeName);

        Map<String, Object> responseMap = new Map<String, Object>();

        Savepoint sp = Database.setSavepoint();

        try {

            Boolean found = checkQuickThemeName(newQuickThemeName);

            if(found) {
                throw new CustomException('New Quick Theme name already exists');
            }

            Id newObjId = cloneQuickThemeObj(currentQuickThemeId, newQuickThemeName, responseMap);

            cloneQuickThemeElements(newObjId, currentQuickThemeId, responseMap);

            responseMap.put('qtCloneSuccessful', true);
            responseMap.put('qtCloneMsg', 'Quick Theme successfully cloned');

        }
        catch (Exception e) {
            System.debug('rolling back cart transactions');
            Database.rollback(sp);

            responseMap.put('qtCloneSuccessful', false);
            responseMap.put('qtCloneErrMsg', e.getMessage());
        }

        System.debug('---- end cloneQuickTheme');

        return responseMap;

    }

    private static Id cloneQuickThemeObj(Id currentQuickThemeId, String newQuickThemeName, Map<String, Object> responseMap) {

        System.debug('---- begin cloneQuickThemeObj');

        Id newObjId = null;

        List<Quick_Theme__c> qtList = [Select Id, Name
        ,Active__c
        ,CC_Account_Group__c
        ,Comments__c
        ,Custom_CSS__c
        ,Font_Family__c
        ,Footer_Logo_Height__c
        ,Footer_Logo_URL__c
        ,Footer_Logo_Width__c
        ,For_Anonymous_Users__c
        ,Header_Logo_Display_Preference__c
        ,Import_Font__c
        ,Logo_Height__c
        ,Logo_URL__c
        ,Logo_Width__c
        ,Storefront__c
        ,Use_Header_Logo_in_Footer__c
        ,Favicon_Url__c
        ,Override_Logo_Size_Unit__c
        ,Footer_Override_Logo_Size_Unit__c
         from Quick_Theme__c where Id = :currentQuickThemeId];

        if(qtList == null || qtList.size() <= 0) {
            throw new CustomException('Current Quick Theme not found');
        }

        Quick_Theme__c qtObj = qtList.get(0);

        Quick_Theme__c newObj = qtObj.clone(false, false, false, false);

        newObj.Name = newQuickThemeName;

        insert newObj;

        newObjId = newObj.Id;

        System.debug('---- exit cloneQuickThemeObj');

        return newObjId;

    }

    private static void cloneQuickThemeElements(Id newObjId, Id currObjId, Map<String, Object> responseMap) {

        System.debug('---- begin cloneQuickThemeElements');

        Integer tot = 0;

        List<Quick_Theme_Element__c> newQTEList = new List<Quick_Theme_Element__c>();

        List<Quick_Theme_Element__c> currentQTEList = [Select Id, Name 
            ,Active__c
            ,Background_Color__c
            ,Border__c
            ,Comments__c
            ,Link_State__c
            ,Text_Color__c
            ,Text_Decoration__c
            ,Text_Font_Weight__c
            ,Text_Size__c
            ,Type__c
            from Quick_Theme_Element__c where Quick_Theme__c = :currObjId
        ];

        if(currentQTEList == null || currentQTEList.size() <= 0) {
            return;
        }

        for(Quick_Theme_Element__c currObj : currentQTEList) {
            Quick_Theme_Element__c newObj = currObj.clone(false, false, false, false);
            newObj.Quick_Theme__c = newObjId;

            newQTEList.add(newObj);
        }

        if(newQTEList.size() > 0) {

            System.debug('tot quick theme elements to clone = ' + tot);

            tot = newQTEList.size();
            insert newQTEList;
        }

        responseMap.put('qtElementsClonedMsg', tot + ' Quick Theme elements cloned');

        System.debug('---- exit cloneQuickThemeElements');

    }

    private static Boolean checkQuickThemeName (String quickThemeName) {

        Boolean found = false;

        List<Quick_Theme__c> qtList = [Select Id, Name from Quick_Theme__c where Name = :quickThemeName];

        if(qtList != null && qtList.size() > 0) {
            found = true;
        }

        return found;

    }

    private static Quick_Theme__c getQuickThemeInfo (Id recordId) {

        Quick_Theme__c qt = null;

        List<Quick_Theme__c> qtList = [Select Id, Name from Quick_Theme__c where Id = :recordId];

        if(qtList != null && qtList.size() > 0) {
            qt = qtList.get(0);
        }

        return qt;

    }

    public class CustomException extends Exception {}

}