public class DiagnoseIssueKBFrameClass {
    private final Contact oContact;
    public String catFilter;
    public String subject;
    
    public DiagnoseIssueKBFrameClass(ApexPages.StandardController stdController) {
        String cId;
        cId = ApexPages.currentPage().getParameters().get('Id');

        this.oContact = [Select
                            c.AccountId
                         From Contact c
                         Where c.Id = :cId];

    }
   
    public Contact getContact() {
        return oContact;
    }
    private Contact c{ 
        get { return getContact(); }
        set; 
    }
    
    public String getcatFilter() {
        catFilter = 'Product_Type:'+ApexPages.currentPage().getParameters().get('dim1');
        catFilter = catFilter + ', Product_Version:'+ ApexPages.currentPage().getParameters().get('dim2');
        catFilter = catFilter + ', Support_Options:'+  ApexPages.currentPage().getParameters().get('dim3');
        return catFilter;
    }
    
    public String getsubject() {
        return ApexPages.currentPage().getParameters().get('subject');
    }

    public String getfirstDim(){
        return ApexPages.currentPage().getParameters().get('dim1');
    }

    public String getsecondDim(){
        return ApexPages.currentPage().getParameters().get('dim2');
    }

    public String getthirdDim(){
        return ApexPages.currentPage().getParameters().get('dim3');
    }
}