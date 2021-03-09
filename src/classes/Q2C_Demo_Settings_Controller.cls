public class Q2C_Demo_Settings_Controller {

    public Q2C_Demo_Settings__c settings { get; set; }
    public Date StartDate { get; set; }
    public Date EndDate { get; set; }
    public Integer NumRecords { get; set; }
    public Contract Cont { get; set; }
    public User myUser { get; set; }
    public Set<String> qIDReturn { get; set; }
    public PackageLicense sbqqInfo { get; set; }
    public PackageLicense sbaaInfo { get; set; }
    public PackageLicense blngInfo { get; set; }
    public Organization org { get; set; }
    public List<SBQQ__CustomAction__c> CustomActions { get; set; }

    public Q2C_Demo_Settings_Controller() {
        settings = Q2C_Demo_Settings__c.getOrgDefaults();
        org = [SELECT TrialExpirationDate, OrganizationType, Name, LanguageLocaleKey, Id, CreatedDate, InstanceName FROM Organization];
        sbqqInfo = [SELECT CreatedDate,ExpirationDate,Id,Status FROM PackageLicense WHERE NamespacePrefix = 'SBQQ'];
        sbaaInfo = [SELECT CreatedDate,ExpirationDate,Id,Status FROM PackageLicense WHERE NamespacePrefix = 'sbaa'];
        blngInfo = [SELECT CreatedDate,ExpirationDate,Id,Status FROM PackageLicense WHERE NamespacePrefix = 'blng'];
        Id myuserid = UserInfo.getUserId();
        myUser = [SELECT TimeZoneSidKey,Email, ProfileId FROM User WHERE Id = :myuserid];
        CustomActions = [SELECT Id, Name, SBQQ__Active__c, SBQQ__Page__c, SBQQ__Location__c FROM SBQQ__CustomAction__c WHERE SBQQ__Active__c = False];
    }

    public PageReference SaveSettings() {
        update CustomActions;
        updateCustomSettings();
        updateTemplates();
        this.CustomActions = [SELECT Id, Name, SBQQ__Active__c, SBQQ__Page__c, SBQQ__Location__c FROM SBQQ__CustomAction__c WHERE SBQQ__Active__c = False];
        return ApexPages.currentPage();
    }

    public PageReference SaveMyUser() {

        update myUser;
        return ApexPages.currentPage();
    }

    public PageReference initBill() {
        Q2CinitBilling.initBill();
        //if(UserInfo.getUserId() != '0056A000000bDxi'){
            settings.InitBill__c = true;
            settings.BaseURL__c= [SELECT UrlPathPrefix, Subdomain FROM Site WHERE Name = 'checkout' LIMIT 1].Subdomain + '.force.com/checkout?id='; 
        //}
        updateCustomSettings();
        return ApexPages.currentPage();
    }

    public PageReference DefaultTerms() {
        CleanOrg.DefaultTerms();
        return ApexPages.currentPage();
    }
    
    public PageReference HT3() {
        CleanOrg.HT3();
        return ApexPages.currentPage();
    }
    
    public PageReference DeleteTerms() {
        CleanOrg.ClearTerms();
        return ApexPages.currentPage();
    }

    public PageReference Clear() {
        CleanOrg.ClearRecords();
        return ApexPages.currentPage();
    }

    public PageReference ClearProds() {
        CleanOrg.ClearProducts();
        return ApexPages.currentPage();
    }

    public PageReference profServ() {
        CleanOrg.profServ();
        return ApexPages.currentPage();
    }
    public PageReference Blast() {
        settings.DataCannon_Trigger_Disabler__c = true;
        updateCustomSettings();
        Q2C_DataCannon3.copyQuote(settings.Master_Quote__c, settings.Reporting_Start_Date__c, settings.Reporting_End_Date__c, settings.Number_of_Records__c.intValue(), settings.Randomize_Quantity__c, settings.Randomize_Term__c, settings.Randomize_Discounts__c);
        settings.DataCannon_Trigger_Disabler__c = false;
        updateCustomSettings();
        System.debug('qIDReturn = ' + qIDReturn);
        return ApexPages.currentPage();
    }
    public PageReference UpdateApprovers() {
        updateCustomSettings();
        //updateUsers();
        return ApexPages.currentPage();
    }
    public PageReference CloseRedirect() {
        return new PageReference('/home/home.jsp');
    }

    public PageReference updateOrgInfo() {
        Organization org = [SELECT Name, Street, City, State, PostalCode, Country, Phone, Fax FROM Organization LIMIT 1];
        settings.Company_Name__c = org.Name;
        settings.Company_Street__c = org.Street;
        settings.Company_City__c = org.City;
        settings.Company_State__c = org.State;
        settings.Company_Postal_Code__c = org.PostalCode;
        settings.Company_Phone__c = org.Phone;
        settings.Company_Fax__c = org.Fax;
        updateCustomSettings();
        //update org;'
        return ApexPages.currentPage();
    }

    private Boolean updateCustomSettings() {
        try {
            update settings;

        } catch (Exception e) {
            return false;
        }
        return true;
    }

    private Boolean updateTemplates() {
        List<SBQQ__QuoteTemplate__c> templates = new List<SBQQ__QuoteTemplate__c>();
        templates = [SELECT Id, Company_Image_Height__c, Company_Image_Width__c, Company_Image_URL__c, Company_Primary_Color__c, SBQQ__CompanyName__c, SBQQ__CompanySlogan__c, SBQQ__CompanyStreet__c, SBQQ__CompanyCity__c, SBQQ__CompanyState__c, SBQQ__CompanyPostalCode__c, SBQQ__CompanyCountry__c, SBQQ__CompanyPhone__c, SBQQ__CompanyFax__c, SBQQ__CompanyEmail__c FROM SBQQ__QuoteTemplate__c];

        for (SBQQ__QuoteTemplate__c template : templates) {
            template.Company_Image_Height__c = settings.Company_Image_Height__c;
            template.Company_Image_Width__c = settings.Company_Image_Width__c;
            template.Company_Primary_Color__c = settings.Company_Primary_Color__c;
            template.SBQQ__GroupShadingColor__c = settings.Company_Primary_Color__c;
            template.SBQQ__ShadingColor__c = settings.Company_Primary_Color__c;
            template.Company_Image_URL__c = settings.Company_Image_URL__c;
            template.SBQQ__CompanyName__c = settings.Company_Name__c;
            template.SBQQ__CompanySlogan__c = settings.Company_Slogan__c;
            template.SBQQ__CompanyStreet__c = settings.Company_Street__c;
            template.SBQQ__CompanyCity__c = settings.Company_City__c;
            template.SBQQ__CompanyState__c = settings.Company_State__c;
            template.SBQQ__CompanyPostalCode__c = settings.Company_Postal_Code__c;
            template.SBQQ__CompanyCountry__c = settings.Company_Country__c;
            template.SBQQ__CompanyPhone__c = settings.Company_Phone__c;
            template.SBQQ__CompanyFax__c = settings.Company_Fax__c;
            template.SBQQ__CompanyEmail__c = settings.Company_Email__c;
        }
        update templates;
        return true;
    }
    /**private Boolean updateUsers() {
        List<User> approvers = new List<User>();
        approvers = [SELECT Id, Email, IsActive FROM User WHERE Approver__c = True];

        for (User approver : approvers) {
            approver.Email = settings.Approver_Email__c;
            System.setPassword(approver.Id, settings.Password__c);
        }
        update approvers;
        return true;
    }**/
}