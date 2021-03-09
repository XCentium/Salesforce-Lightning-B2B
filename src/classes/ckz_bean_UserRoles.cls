global without sharing class ckz_bean_UserRoles {

    global Boolean isAdmin{get;set;}
    global Boolean canOrder{get;set;}
    global Boolean requiresApproval{get;set;}
    global Decimal budgetLimit{get;set;}
    global String firstName{get;set;}
    global String lastName{get; set;}
    global String contactId{get; set;}
    global String canOrderChecked{get{return canOrder ? 'checked' : '';}}
    global String requiresApprovalChecked{get{return requiresApproval ? 'checked' : '';}}

    global ckz_bean_UserRoles(){
        isAdmin = false;
        canOrder = false;
        requiresApproval = true;
        budgetLimit = 0;
    }
}