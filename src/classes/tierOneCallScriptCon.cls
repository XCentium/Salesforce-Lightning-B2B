public class tierOneCallScriptCon{
    private final Contact oContact;
    public Flow.Interview.GoldStandDiagnosev2 tierOneInterview {get;set;}
    public String caseSubject {set;}
    public String caseID {set;}
    public String contactID {set;}
    public String accountID {set;}
    public String caseNumber {set;} 
    public String assetID {set;}
    public String entitlementID {set;}
    public String VFPageName {set;}
    public String objectID {set;}
    public String caseType {set;}
    public String firstDim {set;}
    public String secondDim {set;}
    public String thirdDim {set;}
    public String searchString {set;}

    public tierOneCallScriptCon(ApexPages.StandardController stdController) {
        this.oContact = (Contact)stdController.getRecord();
    }

    public String getcaseType() {
        if(tierOneInterview==null) return '';
        else return tierOneInterview.varCaseType;
    }

    public String getfirstDim() {
        if (tierOneInterview==null) return '';
        else return tierOneInterview.varFirstDim;
    }
    
    public String getsecondDim() {
        if (tierOneInterview==null) return '';
        else return tierOneInterview.varSecondDim;
    }

    public String getthirdDim() {
        if (tierOneInterview==null) return '';
        else return tierOneInterview.varThirdDim;
    }

    public String getsearchString() {
        if (tierOneInterview==null) return '';
        else return tierOneInterview.varSearchString;
    }

    public String getVFPageName() {
        if(tierOneInterview==null) return '';
        else return tierOneInterview.varVFPageName;
    }
    
    public String getobjectID() {
        if(tierOneInterview==null) return '';
        else return tierOneInterview.varObjectID;
    }

    public String getcaseSubject() {
        if(tierOneInterview==null) return '';
        else return tierOneInterview.varSubject;
    }

    public String getcaseID() {
        if(tierOneInterview==null) return '';
        else return tierOneInterview.varCaseID;
    }

    public String getcontactID() {
        if(tierOneInterview==null) return '';
        else return tierOneInterview.varContactID;
    }

    public String getaccountID() {
        if(tierOneInterview==null) return '';
        else return tierOneInterview.varAccountID;
    }

    public String getcaseNumber() {
        if(tierOneInterview==null) return '';
        else return tierOneInterview.varCaseNumber;
    }

    public String getassetID() {
        if(tierOneInterview==null) return '';
        else return tierOneInterview.varAssetID;
    }
    public String getentitlementID() {
        if(tierOneInterview==null) return '';
        else return tierOneInterview.varEntitlementID;
    }

    public static testmethod void tierOneCallScriptConTests() {
        Contact oContact = [select id from Contact limit 1];
        String contactId;
        if (oContact != null){
            contactId = oContact.Id;
            ApexPages.currentPage().getParameters().put('Id',contactId);
            ApexPages.StandardController con = new ApexPages.StandardController(new Contact());
            tierOneCallScriptCon ext = new tierOneCallScriptCon(con);
            ext.getcaseType();
            ext.getVFPageName();
            ext.getobjectID();
            ext.getcaseSubject();
            ext.getcaseID();
            ext.getcontactID();
            ext.getaccountID();
            ext.getcaseNumber();
            ext.getassetID();
        }
    }
}