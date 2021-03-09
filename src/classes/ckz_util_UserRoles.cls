global without sharing class ckz_util_UserRoles {

    global static ckz_bean_UserRoles getUserRoles(Id contactId){
        ckz_bean_UserRoles userRolesBean = new ckz_bean_UserRoles();
        Contact contact = [SELECT ckz_Budget_Administrator__c, ckz_Budget_Can_Order__c, ckz_Budget_Requires_Approval__c, ckz_Budget_Limit__c
        FROM Contact
        WHERE Id =: contactId];

        userRolesBean.isAdmin = contact.ckz_Budget_Administrator__c;
        userRolesBean.canOrder = contact.ckz_Budget_Can_Order__c;
        userRolesBean.requiresApproval = contact.ckz_Budget_Requires_Approval__c;
        userRolesBean.budgetLimit = contact.ckz_Budget_Limit__c;

        return userRolesBean;
    }

}