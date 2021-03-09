public abstract class SDOSiteController {
    private static final String PAGE_PREFIX = '/apex';

    public static final String PAGE_HOME = 'Site_SiteHome';
    public static final String PAGE_PRODUCT = 'Site_KnowledgeHome';
    public static final String PAGE_SEARCH = 'Site_KnowledgeSearch';

    public static final String URL_HOME = PAGE_PREFIX + '/' + PAGE_HOME;
    public static final String URL_PRODUCT = PAGE_PREFIX + '/' + PAGE_PRODUCT;
    public static final String URL_SEARCH = PAGE_PREFIX + '/' + PAGE_SEARCH;

    public static final String ARTICLE_TYPE_PARAMETER_NAME = 't';
    public static final String CATEGORY_PARAMETER_NAME = 'c';
    public static final String KEYWORD_PARAMETER_NAME = 'k';
    public static final String PAGE_NUMBER_PARAMETER_NAME = 'p';
    public static final String ARTICLE_TYPE_LABEL_PARAMETER_NAME = 'l';

   public static PKBSiteSetup__c siteSetup { get; set; }
   public String showComponentTitle { get; set;}
   public String allComponentTitle { get; set;}
   public String allTabTitle { get; set; }
   public String showTabTitle { get; set; }
   
   public String PPortalID { get; set; }
   public String CPortalID { get; set; }
   public String OrgID { get; set; }
   public String Pod { get; set; }
   public String PortalCSS { get; set; }
   
   public String siteName { get; set; }
   public boolean showW2L { get; set; }
   public boolean showW2C { get; set; }
   public boolean showAll { get; set; }
   
   public Organization theOrg { get; set; }
   
   
   public SDOSiteController(){
        allComponentTitle = '.CPLogin, .PPLogin, .kbMostPopularArticles, .kb2Categories, .CPSignUp, .PPSignUp, .W2L, .W2C, .siteLogin,';
        showComponentTitle = '';
        
        allTabTitle = '#HomeTab, #Knowledge, #Community, #ContactUs, #Customers, #Partners, #Answers,';
        showTabTitle='';
        
        if (siteSetup == null) {
                try {
                    siteName = Site.getName();
                    if (siteName == null || siteName.length()==0) {
                        siteName = 'TestPKBSiteSetup';
                    }
                    siteSetup = [
                       SELECT PKBSiteName__c, RootCategoryName__c, CategoryGroupName__c, CacheMaxAge__c,
                       Category1Description__c, Category2Description__c, Category3Description__c,
                       Category4Description__c, Category5Description__c, Category6Description__c,
                       HomeAdText__c, HomeAdTitle__c, Knowledge_Search__c, Customer_Portal_Login_Link__c,
                       Customer_Portal_Login__c, Partner_Portal_Login_URL__c, Partner_Portal_Login__c,
                       Most_Popular_Articles__c, Knowledge_Categories__c, Customer_Portal_Sign_Up__c,
                       Partner_Portal_Sign_Up__c, W2L__c, Web_to_Case__c, Tabs__c, Portal_Branding__c, Site_Login__c
                       FROM PKBSiteSetup__c
                       WHERE PKBSiteName__c = :siteName ];
       
                } catch (QueryException  e) {
                    // can't throw an exception here in order to prevent tests from failing before creating an PKB Site Setup
                    siteSetup = new PKBSiteSetup__c();
                }
          }
          manageContactUsPage();
          createShowCSSTitle();
          populatePortalIDs();
          connectPortalCSS();
          createTabCSSTitle();
                
          showComponentTitle += '.done';
          allComponentTitle += '.done';
          showTabTitle += '#done';
          allTabTitle += '#done';
            
    }
        
        
   
   public void createTabCSSTitle(){
        String allTabs = siteSetup.Tabs__c;
        String[] TabItems = allTabs.split(';',-2);

        for (string theTab : TabItems){
            
            if (theTab == 'Home'){
                showTabTitle += '#Home,';
            }
            if (theTab =='Knowledge'){
                showTabTitle += '#Knowledge,';
            }
            if (theTab == 'Community (Ideas)'){
                showTabTitle += '#Community,';
            }
            if (theTab == 'Contact us'){
                showTabTitle += '#ContactUs,';
            }
            if (theTab == 'Customers (Tab to Site)'){
                showTabTitle += '#Customers,';
            }
            if (theTab == 'Partners (Tab to Site)'){
                showTabTitle += '#Partners,';
            }           
            if (theTab == 'Answers'){
                showTabTitle += '#Answers,';
            }
        }
    
    
   }
   public void manageContactUsPage(){
    String contactUsAttribute;
       try{
         contactUsAttribute=  System.CurrentPageReference().GetParameters().Get('cuA');
        }catch (Exception e){
         contactUsAttribute = null;
        }    
            if(contactUsAttribute != null && contactUsAttribute != ''){ 
                if(contactUsAttribute == 'w2l'){
                    showAll = false;
                    showW2l = true;
                    showW2c = false;
                }else if (contactUsAttribute == 'w2c'){
                    showAll = false;
                    showW2l = false;
                    showW2c = true;
                }
                
            }else{
                    theOrg = [Select Street, State, PostalCode, Phone, Name, City From Organization limit 1];
                    
                    showAll = true;
                    showW2l = false;
                    showW2c = false;
            }
                
        
   }
   public void createShowCSSTitle(){
    
    if(siteSetup.Customer_Portal_Login__c){
       showComponentTitle += '.CPLogin, ';  
    }
    if(siteSetup.Partner_Portal_Login__c){
       showComponentTitle += '.PPLogin, ';  
    }
    if(siteSetup.Most_Popular_Articles__c){
        showComponentTitle += '.kbMostPopularArticles, ';
    }
    if(siteSetup.Knowledge_Categories__c){
        showComponentTitle += '.kb2Categories, ';
    }
     if(siteSetup.Customer_Portal_Sign_Up__c){
        showComponentTitle += '.CPSignUp, ';
    }
     if(siteSetup.Partner_Portal_Sign_Up__c){
        showComponentTitle += '.PPSignUp, ';
    }
     if(siteSetup.W2L__c){
        showComponentTitle += '.W2L, ';
    }
    if(siteSetup.Web_to_Case__c){
        showComponentTitle += '.W2C, ';
    }
    if(siteSetup.Site_Login__c){
        showComponentTitle += '.siteLogin, ';
    }
   }
   
   public void connectPortalCSS(){
    if (siteSetup.Portal_Branding__c != '' && siteSetup.Portal_Branding__c != null){
        PortalCSS = 'https://'+Pod+'.salesforce.com/sCSS/17.0/9999999999999/PortalDefault/'+OrgID+'/'+siteSetup.Portal_Branding__c;
    }
    
   }
   
   public void populatePortalIDs(){
    
        
        if (siteSetup.Customer_Portal_Login_Link__c != ''  && siteSetup.Customer_Portal_Login_Link__c != null){
            
            String PortalURL = '';
            String orgAttribute = 'orgId=';
            String portalAttribute = 'portalId=';
            
            PortalURL = siteSetup.Customer_Portal_Login_Link__c;
            
            Integer portalResult =  PortalURL.indexOf(portalAttribute, 0);
            Integer orgResult =  PortalURL.indexOf(orgAttribute, 0);
            
            portalResult += 9;
            orgResult += 6;
            
            CPortalID = PortalURL.subString (portalResult, portalResult+= 15);
            OrgID = UserInfo.GetOrganizationId();
            
            Pod = PortalURL.subString(8,11);
            Pod.Trim();
            
        }   
        
        if (siteSetup.Partner_Portal_Login_URL__c != ''  && siteSetup.Partner_Portal_Login_URL__c != null){
            
            String PortalURL = '';
            String orgAttribute = 'orgId=';
            String portalAttribute = 'portalId=';
            
            PortalURL = siteSetup.Partner_Portal_Login_URL__c;
            
            Integer portalResult =  PortalURL.indexOf(portalAttribute, 0);
            Integer orgResult =  PortalURL.indexOf(orgAttribute, 0);
            
            portalResult += 9;
            orgResult += 6;
            
            PPortalID = PortalURL.subString (portalResult, portalResult+= 15);
            OrgID = UserInfo.GetOrganizationId();
            
            Pod = PortalURL.subString(8,11);
            Pod.Trim();
            
        }   
   
   }  
   

   
    public String categoryParameterName {
        get {
            return CATEGORY_PARAMETER_NAME;
        }
    }

    public String keywordParameterName {
        get {
            return KEYWORD_PARAMETER_NAME;
        }
    }

    public String articleTypeParameterName {
        get {
            return ARTICLE_TYPE_PARAMETER_NAME;
        }
    }

    public String articleTypeLabelParameterName {
        get {
            return ARTICLE_TYPE_LABEL_PARAMETER_NAME;
        }
    }

    public String pageNumberParameterName {
        get {
            return PAGE_NUMBER_PARAMETER_NAME;
        }
    }



    protected String paramByParamId(String paramId, String defaultValue) {
        if (ApexPages.currentPage().getParameters() == null) {
            return defaultValue;
        } else {
            String value = ApexPages.currentPage().getParameters().get(paramId);
            return (value == null) ? defaultValue : value;
        }
    }

    protected Integer paramByParamId(String paramId, Integer defaultValue) {
        if (ApexPages.currentPage().getParameters() == null) {
            return defaultValue;
        } else {

            String value = ApexPages.currentPage().getParameters().get(paramId);
            return (value == null) ? defaultValue : Integer.valueOf(value);
        }
    }

    public Integer currentPageNumber {
        get {
            if (currentPageNumber == null) {
                currentPageNumber = paramByParamId(PAGE_NUMBER_PARAMETER_NAME, 1);
            }
            return currentPageNumber;
        }
        set;
    }

    public String currentCategory {
        get {
            if (currentCategory == null) {
                currentCategory = paramByParamId(CATEGORY_PARAMETER_NAME, getRootCategoryName());
            }
            return currentCategory;
        }
        set;
    }

    public String currentArticleType {
        get {
            if (currentArticleType == null) {
                currentArticleType = paramByParamId(ARTICLE_TYPE_PARAMETER_NAME, '');
            }
            return currentArticleType;
        }
        set;
    }

    public String currentArticleTypeLabel {
        get {
            if (currentArticleTypeLabel == null) {
                currentArticleTypeLabel = paramByParamId(ARTICLE_TYPE_LABEL_PARAMETER_NAME, '');
            }
            return currentArticleTypeLabel;
        }
        set;
    }

    public String currentKeyword {
        get {
            if (currentKeyword == null) {
                currentKeyword = paramByParamId(KEYWORD_PARAMETER_NAME, '');
            }
            return currentKeyword;
        }
        set;
    }

    private String[] categoryDescriptions;

    public String[] getCategoryDescriptions() {
        if (categoryDescriptions == null) {
            categoryDescriptions = new String[]{};
            categoryDescriptions.add(siteSetup.category1Description__c == null ? '' : siteSetup.category1Description__c);
            categoryDescriptions.add(siteSetup.category2Description__c == null ? '' : siteSetup.category2Description__c);
            categoryDescriptions.add(siteSetup.category3Description__c == null ? '' : siteSetup.category3Description__c);
            categoryDescriptions.add(siteSetup.category4Description__c == null ? '' : siteSetup.category4Description__c);
            categoryDescriptions.add(siteSetup.category5Description__c == null ? '' : siteSetup.category5Description__c);
            categoryDescriptions.add(siteSetup.category6Description__c == null ? '' : siteSetup.category6Description__c);
        }
        return categoryDescriptions;
    }

    public String getHomeAdTitle() {
        return siteSetup.HomeAdTitle__c == null ? '' : siteSetup.HomeAdTitle__c;
    }

    public String getHomeAdText() {
        return siteSetup.HomeAdText__c == null ? '' : siteSetup.HomeAdText__c;
    }

    public String getRootCategoryName() {
        return siteSetup.RootCategoryName__c == null ? '' : siteSetup.RootCategoryName__c;
    }

    public String getCategoryGroupName() {
        return siteSetup.CategoryGroupName__c == null ? '' : siteSetup.CategoryGroupName__c;
    }

    public Long getCacheMaxAge() {
        return siteSetup.CacheMaxAge__c == null ? 0 : Math.roundToLong(siteSetup.CacheMaxAge__c);
    }


    public String getHomeUrl() {
        return URL_HOME;
    }

    public String getProductUrl() {
        return URL_PRODUCT;
    }

    public String getSearchUrl() {
        return URL_SEARCH;
    }

    public String getHomePage() {
        return PAGE_HOME;
    }

    public String getProductPage() {
        return PAGE_PRODUCT;
    }

    public String getSearchPage() {
        return PAGE_SEARCH;
    }

    public String getPage(String url) {
        if (url.contains('?')) {
            Integer i = url.indexOf('?');
            url = url.substring(0, i);
        }
        while (url.endsWith('/')) {
            url = url.substring(0, url.length()-1);
        }
        if (url.contains('/')) {
            Integer i = url.lastIndexOf('/');
            url = url.substring(i+1);
        }
        return url;
    }


    public PageReference currentPageReference {
        get {
            if (currentPageReference == null) {
                currentPageReference = ApexPages.currentPage();
            }
            return currentPageReference;
        }
        set;
    }

    public String currentPage {
        get {
                if (currentPage == null) {
                    currentPage = getPage(currentPageReference.getUrl());
                }
                return currentPage;
            }
            set;
    }

    public Boolean isPage(String pageName) {
        return currentPage.toLowerCase() == (pageName.toLowerCase());
    }

    public Boolean getIsHomePage() {
        return isPage(PAGE_HOME);
    }

    public Boolean getIsProductPage() {
        return isPage(PAGE_PRODUCT);
    }

    public Boolean getIsSearchPage() {
        return isPage(PAGE_SEARCH);
    }

    public Boolean getIsExternalPage() {
        return !(getIsHomePage() || getIsProductPage() || getIsSearchPage());
    }


   public PageReference doSearch() {
        if (currentKeyword.length()<2) {
            return cleanKeyword();
        }
        PageReference pg = new PageReference(getSearchUrl());
        pg.getParameters().put(KEYWORD_PARAMETER_NAME, currentKeyword);
        pg.getParameters().put(CATEGORY_PARAMETER_NAME, currentCategory);
        if (getIsExternalPage()) {
            pg.setRedirect(true);
        }
        return pg;
   }


   public PageReference cleanKeyword() {
        PageReference pg = new PageReference(getProductUrl());
        pg.getParameters().put(CATEGORY_PARAMETER_NAME, currentCategory);
        pg.getParameters().put(KEYWORD_PARAMETER_NAME, '');
        currentKeyword = '';
        if (getIsExternalPage()) {
            pg.setRedirect(true);
        }
        return pg;
   }

//    permissionsviewknowledge is no longer used by salesforce
//    public Boolean getCanUserSeeKnowledge() {
//        return [select permissionsviewknowledge from profile where id = :UserInfo.getProfileId()].permissionsviewknowledge;
//    }

}