/*
 * Modified & Cloned from APEX Class SDO_Tools
 * @author Sameer Singhvi & Trevor Scott
 * @version 1.0
 * @changeSet Redesigned wCategory & condensed code.
 */
public with sharing class SDO_Tools {
    
    public List<wCategory> category_list {get;set;}
    public List<Wizard__c> wList {get;set;}
    public Wizard__c toolsWizard {get;set;}
    public Map<String,List<Wizard_Step_Tool__c>> wizardStepId_ToolsList_Map {get;set;}

    public list<SDO_Tool__c> tools {get;set;}
    public list<SDO_Tool__c> toolsTiles {get;set;}

    public list<SDO_Tool__c> salesTools {get;set;}
    public list<SDO_Tool__c> serviceTools {get;set;}
    public list<SDO_Tool__c> marketingTools {get;set;}
    public list<SDO_Tool__c> platformTools {get;set;}
    public list<SDO_Tool__c> analyticsTools {get;set;}
    public list<SDO_Tool__c> communityTools {get;set;}
    public list<SDO_Tool__c> otherTools {get;set;}

    public list<SDO_Tool__c> favorites {get;set;}
    public Map<String,String> pageNameMap {get;set;}

    public List<SDO_News__c> news {Get;set;}
    
    public SDO_Tools() {
        Initialize();
    }
    
    public SDO_Tools(SDOToolsHomepage sdoToolsHomepage) {
        Initialize();
    }

    public void Initialize() {
       news = [SELECT Id,Name,News_Content__c,News_Item_Image__c,OwnerId,Published_Date__c,Showcase_Link__c FROM SDO_News__c ORDER BY Published_Date__c DESC NULLS FIRST];
        

        //initialize the wizard
        toolsWizard = [select 
                        (select id,Page_Content_Name__c, step_order__c,name,description__c from wizard_steps__r order by step_order__c asc)
                        id from wizard__c limit 1];
        wizardStepId_ToolsList_Map = new Map<String,List<Wizard_Step_Tool__c>>();
        for(Wizard_step__c ws : toolsWizard.wizard_steps__r) {
           List<Wizard_Step_Tool__c>  wstList = [select id,name, instructions__c,Advanced_Information__c, sdo_tool__c,sdo_tool__r.Advanced_Information__c, sdo_tool__r.name, sdo_tool__r.description__c, sdo_tool__r.instructions__c, tool_order__c, wizard_step__c from wizard_step_tool__c where wizard_Step__c =: ws.id order by tool_order__c];
           wizardStepId_ToolsList_Map.put(ws.id,wstList);
           pageNameMap = new Map<String,String>();
           if(ws.Page_Content_Name__c != null) {
              pageNameMap.put(ws.Page_Content_Name__c,ws.Page_Content_Name__c);
           }
        }
        tools = [Select Id, Name,active__c,product_Cloud__c, url__c,fa_icon_name__c,description__c,instructions__c,Advanced_Information__c, pop_new_window__c, height__c, width__c 
                              From SDO_Tool__c
                              Where active__c = true
                              Order by name asc]; 
        toolsTiles = [Select Id, Name,active__c,product_Cloud__c, url__c,fa_icon_name__c,description__c,instructions__c,Advanced_Information__c, pop_new_window__c, height__c, width__c 
                              From SDO_Tool__c
                              Where active__c = true
                              Order by product_Cloud__c];
        salesTools = [Select Id, Name,active__c,product_Cloud__c, url__c,fa_icon_name__c,description__c,instructions__c,Advanced_Information__c, pop_new_window__c, height__c, width__c 
                              From SDO_Tool__c
                              Where active__c = true
                              AND product_cloud__c = 'Sales Cloud'
                              Order by name asc];
        serviceTools = [Select Id, Name,active__c,product_Cloud__c, url__c,fa_icon_name__c,description__c,instructions__c,Advanced_Information__c, pop_new_window__c, height__c, width__c 
                              From SDO_Tool__c
                              Where active__c = true
                              AND product_cloud__c = 'Service Cloud'
                              Order by name asc];
        marketingTools = [Select Id, Name,active__c,product_Cloud__c, url__c,fa_icon_name__c,description__c,instructions__c,Advanced_Information__c, pop_new_window__c, height__c, width__c 
                              From SDO_Tool__c
                              Where active__c = true
                              AND product_cloud__c = 'Marketing Cloud'
                              Order by name asc];
        platformTools = [Select Id, Name,active__c,product_Cloud__c, url__c,fa_icon_name__c,description__c,instructions__c,Advanced_Information__c, pop_new_window__c, height__c, width__c 
                              From SDO_Tool__c
                              Where active__c = true
                              AND product_cloud__c = 'Platform'
                              Order by name asc];                                                                                          
        analyticsTools = [Select Id, Name,active__c,product_Cloud__c, url__c,fa_icon_name__c,description__c,instructions__c,Advanced_Information__c, pop_new_window__c, height__c, width__c 
                              From SDO_Tool__c
                              Where active__c = true
                              AND product_cloud__c = 'Analytics Cloud'
                              Order by name asc];
        communityTools = [Select Id, Name,active__c,product_Cloud__c, url__c,fa_icon_name__c,description__c,instructions__c,Advanced_Information__c, pop_new_window__c, height__c, width__c 
                              From SDO_Tool__c
                              Where active__c = true
                              AND product_cloud__c = 'Community Cloud'
                              Order by name asc];
        otherTools = [Select Id, Name,active__c,product_Cloud__c, url__c,fa_icon_name__c,description__c,instructions__c,Advanced_Information__c, pop_new_window__c, height__c, width__c 
                              From SDO_Tool__c
                              Where active__c = true
                              AND product_cloud__c = 'Other'
                              Order by name asc];
        favorites = [Select Id, Name,active__c,favorite__c, url__c,fa_icon_name__c,description__c,Advanced_Information__c,instructions__c, pop_new_window__c, height__c, width__c 
                              From SDO_Tool__c
                              Where active__c = true and favorite__c = true
                              Order by name asc]; 
        
        /* Initialize variables */
        category_list = new List<wCategory>();

        /* Grab all possible picklist values for SDO_Tool__c.Category__c and create a new wCategory */
        for(Schema.PicklistEntry cat : SDO_Tool__c.Category__c.getDescribe().getPicklistValues())
            category_list.add(new wCategory(cat.getValue()));
    }
    
    /* Represents a Category * it's tools for SideNavBar */
    public class wCategory {
        public String category_title {get;set;}
        public List<SDO_Tool__c> category_tools {get;set;}
         
        public wCategory(String title) {
            category_title = title;
            category_tools = [Select Id, Name, url__c,description__c,instructions__c, pop_new_window__c, height__c, width__c 
                              From SDO_Tool__c
                              Where category__c = :category_title 
                              Order by order__c asc];                                         

            /* Modify url__c for each SDO_Tool__c from relative to direct link */
            String s = (ApexPages.Currentpage() == null) ? 'https://na1.salesforce.com/apex/sdo_tools' : ApexPages.currentPage().getUrl();
            s = (s == null) ? 'https://na1.salesforce.com/apex/sdo_tools' : s.substring(0, s.indexOf('/'));

            for(SDO_Tool__c t : category_tools) {
                if(t.url__c.contains('http')) {
                    continue;
                } 
                t.url__c = (t.url__c.contains('/apex/')) ? s + t.url__c : s + '/apex/' + t.url__c;
                t.url__c = (t.url__c.contains('?')) ? t.url__c + '&isdtp=vw' : t.url__c + '?isdtp=vw';
            }
        }
    }    
}