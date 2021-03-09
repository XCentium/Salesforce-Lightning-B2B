public class QSR_Menu {

    @AuraEnabled 
    public static List<IDO_Menu_Categories__c> getMenuCategories(Boolean isFeatured) {
        List<IDO_Menu_Categories__c> CategoryList;
        if(isFeatured == True){
            CategoryList = [Select Name,Id,Description__c,Image__c, Order__c from IDO_Menu_Categories__c WHERE isActive__c = true AND isFeatured__c = true]; 
        }else{
            CategoryList = [Select Name,Id,Description__c,Image__c, Order__c from IDO_Menu_Categories__c WHERE isActive__c = true]; 
        }
        return CategoryList; 
    }
    @AuraEnabled 
    public static List<IDO_Menu_Item__c> getMenuItems(Boolean isFeatured) {
        List<IDO_Menu_Item__c> ItemList;
        if(isFeatured == True){
            ItemList = [Select Name,Id,Description__c,Image__c, Order__c, Menu_Category__c  from IDO_Menu_Item__c WHERE isActive__c = true AND isFeatured__c = true]; 
        }else{
            ItemList = [Select Name,Id,Description__c,Image__c, Order__c, Menu_Category__c  from IDO_Menu_Item__c WHERE isActive__c = true]; 
        }
        
        return ItemList; 
    }
    
}