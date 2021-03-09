global class SSEPortalConfiguration {
   
    public ApexPage vfCSS {get;set;}
    public ApexPage vfHome {get;set;}
    public ApexClass apexHome {get;set;}
    public Document htmlHeader {get;set;}
    public Document htmlFooter {get;set;}
    public Org_Template__c theTemplate {get;set;}
    public Org_Template__c userTemplate {get;set;}
    public String AllTheValues {get;set;}
    
    public SSEPortalConfiguration(ApexPages.StandardController controller) {
        
        /*User theUser = [SELECT Branding_Template__c FROM User WHERE id = :UserInfo.getUserId()];
        List<Org_Template__c> templateList = [SELECT Image_Background_Image__c, Image_Background_Position__c, Image_Background_Repeat__c, Position_Footer__c, Back_Background_G_B__c,Back_Background_G_T__c,Back_Body_G_B__c,Back_Body_G_T__c,Back_Button_G_B__c,Back_Button_G_T__c,Back_Button_H_G_B__c,Back_Button_H_G_T__c,Back_Footer_G_B__c,Back_Footer_G_T__c,Back_Header_B_G_B__c,Back_Header_B_G_T__c,Back_Header_Mid_G_B__c,Back_Header_Mid_G_T__c,Back_Header_T_G_B__c,Back_Header_T_G_T__c,Back_Navigation_Menu_H__c,Back_Navigation_Menu__c,Back_Page_Block_G_B__c,Back_Page_Block_G_T__c,Back_Page_Block_Header_G_B__c,Back_Page_Block_Header_G_T__c,Back_Page_Block_Table_Even__c,Back_Page_Block_Table_Odd__c,Back_Side_Button_G_B__c,Back_Side_Button_G_T__c,Back_Side_Button_H_G_B__c,Back_Side_Button_H_G_T__c,Back_Side_G_B__c,Back_Side_G_T__c,Back_Side_Module_G_B__c,Back_Side_Module_G_T__c,Back_Side_Module_Header_G_B__c,Back_Side_Module_Header_G_T__c,Back_Side__c,Back_Tab_A_G_B__c,Back_Tab_A_G_T__c,Back_Tab_G_B__c,Back_Tab_G_T__c,Back_Tab_H_G_B__c,Back_Tab_H_G_T__c,Component_Approvals__c,Component_Articles__c,Component_Cases__c,Component_Charts__c,Component_Entitlements__c,Component_Ideas__c,Component_Image__c,Component_Leads__c,Component_Products__c,Component_Solutions__c,ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Font_Colour_Button_H__c,Font_Colour_Button__c,Font_Colour_Main__c,Font_Colour_Navigation_Menu_H__c,Font_Colour_Navigation_Menu__c,Font_Colour_Page_Title__c,Font_Colour_Secondary_Title__c,Font_Colour_Side_Button_H__c,Font_Colour_Side_Button__c,Font_Colour_Side_Header__c,Font_Colour_Small_Information__c,Font_Colour_Tab_A__c,Font_Colour_Tab_H__c,Font_Colour_Tab__c,Font_Decoration_Button_H__c,Font_Decoration_Button__c,Font_Decoration_Main__c,Font_Decoration_Navigation_Menu_H__c,Font_Decoration_Navigation_Menu__c,Font_Decoration_Page_Title__c,Font_Decoration_Secondary_Title__c,Font_Decoration_Side_Button_H__c,Font_Decoration_Side_Button__c,Font_Decoration_Side_Header__c,Font_Decoration_Small_Information__c,Font_Decoration_Tab_A__c,Font_Decoration_Tab_H__c,Font_Decoration_Tab__c,Font_Size_Button_H__c,Font_Size_Button__c,Font_Size_Main__c,Font_Size_Navigation_Menu_H__c,Font_Size_Navigation_Menu__c,Font_Size_Page_Title__c,Font_Size_Secondary_Title__c,Font_Size_Side_Button_H__c,Font_Size_Side_Button__c,Font_Size_Side_Header__c,Font_Size_Small_Information__c,Font_Size_Tab_A__c,Font_Size_Tab_H__c,Font_Size_Tab__c,Font_Transform_Button_H__c,Font_Transform_Button__c,Font_Transform_Main__c,Font_Transform_Navigation_Menu_H__c,Font_Transform_Navigation_Menu__c,Font_Transform_Page_Title__c,Font_Transform_Secondary_Title__c,Font_Transform_Side_Button_H__c,Font_Transform_Side_Button__c,Font_Transform_Side_Header__c,Font_Transform_Small_Information__c,Font_Transform_Tab_A__c,Font_Transform_Tab_H__c,Font_Transform_Tab__c,Font_Weight_Button_H__c,Font_Weight_Button__c,Font_Weight_Main__c,Font_Weight_Navigation_Menu_H__c,Font_Weight_Navigation_Menu__c,Font_Weight_Page_Title__c,Font_Weight_Secondary_Title__c,Font_Weight_Side_Button_H__c,Font_Weight_Side_Button__c,Font_Weight_Side_Header__c,Font_Weight_Small_Information__c,Font_Weight_Tab_A__c,Font_Weight_Tab_H__c,Font_Weight_Tab__c,Id,Image_Background__c,Image_Body__c,Image_Button_H__c,Image_Button__c,Image_Footer__c,Image_Logo__c,Image_Page_Block_Header__c,Image_Slide1__c,Image_Slide2__c,Image_Slide3__c,IsDeleted,LastModifiedById,LastModifiedDate,Name,OwnerId,Position_Page__c,Position_Sidebar__c,Position_Slider__c,Position_Tabs__c,Radius_Button__c,Radius_Page_Block__c,Radius_Side_Button__c,Radius_Side_Module__c,Radius_Side__c,Radius_Tab__c,Shadow_Body__c,Shadow_Header__c,Shadow_Page_Block__c,Shadow_Side_Module__c,Shadow_Side__c FROM Org_Template__c WHERE name = :theUser.Branding_Template__c];
        if(templateList.size() > 0)
            userTemplate = templateList[0];
        else
            userTemplate = null;
        */
        AllTheValues = '';
        
        List<ApexPage> vfCSSList = [SELECT id, name FROM ApexPage WHERE Name = 'SSEPortalCSSEdit' LIMIT 1];
        if(vfCSSList.size() > 0)
            vfCSS = vfCSSList[0];
        else
            vfCSS = null;
        
        List<ApexPage> vfHomeList = [SELECT id, name FROM ApexPage WHERE Name = 'SSEPortalHome' LIMIT 1];
        if(vfHomeList.size() > 0)
            vfHome = vfHomeList[0];
        else
            vfHome = null;
        
        List<ApexClass> apexHomeList = [SELECT id, name FROM ApexClass WHERE Name = 'SSEPortalHome' LIMIT 1];
        if(apexHomeList.size() > 0)
            apexHome = apexHomeList[0];
        else
            apexHome = null;
        
        List<Document> htmlHeaderList = [SELECT id, name FROM Document WHERE Name = 'SSEPortalHeader' LIMIT 1];
        if(htmlHeaderList.size() > 0)
            htmlHeader = htmlHeaderList[0];
        else
            htmlHeader = null;
        
        List<Document> htmlFooterList = [SELECT id, name FROM Document WHERE Name = 'SSEPortalFooter' LIMIT 1];
        if(htmlFooterList.size() > 0)
            htmlFooter = htmlFooterList[0];
        else
            htmlFooter = null;
        
    }
    
    @remoteAction
    global static void saveUpdates1(String templateId,
                                    String Position_Tabs,
                                    String Position_Sidebar,            
                                    String Position_Page,       
                                    String Position_Slider,     
                                    String Back_Header_T_G_T,       
                                    String Back_Header_T_G_B,       
                                    String Back_Header_Mid_G_T,     
                                    String Back_Header_Mid_G_B,     
                                    String Back_Header_B_G_T,       
                                    String Back_Header_B_G_B,       
                                    String Back_Background_G_T,     
                                    String Back_Background_G_B,     
                                    String Back_Footer_G_T,     
                                    String Back_Footer_G_B,     
                                    String Back_Body_G_T,       
                                    String Back_Body_G_B,       
                                    String Back_Navigation_Menu,        
                                    String Back_Navigation_Menu_H,
                                    String Back_Page_Block_Header_G_T,
                                    String Back_Page_Block_Header_G_B,                                          
                                    String Back_Page_Block_Table_Odd,       
                                    String Back_Page_Block_Table_Even,      
                                    String Back_Button_G_T,     
                                    String Back_Button_G_B,     
                                    String Back_Button_H_G_T,       
                                    String Back_Button_H_G_B,       
                                    String Back_Tab_G_T,        
                                    String Back_Tab_G_B,        
                                    String Back_Tab_A_G_T,      
                                    String Back_Tab_A_G_B,      
                                    String Back_Tab_H_G_T) {
        
        Org_Template__c cssNewValues = [SELECT Id FROM Org_Template__c Where Id =: templateId];
        
        cssNewValues.Position_Tabs__c = Position_Tabs; 
        cssNewValues.Position_Sidebar__c = Position_Sidebar;
        cssNewValues.Position_Page__c = Position_Page;
        cssNewValues.Position_Slider__c = Position_Slider;
        cssNewValues.Back_Header_T_G_T__c = Back_Header_T_G_T;                               
        cssNewValues.Back_Header_T_G_B__c = Back_Header_T_G_B;
        cssNewValues.Back_Header_Mid_G_T__c = Back_Header_Mid_G_T;
        cssNewValues.Back_Header_Mid_G_B__c = Back_Header_Mid_G_B;
        cssNewValues.Back_Header_B_G_T__c = Back_Header_B_G_T;
        cssNewValues.Back_Header_B_G_B__c = Back_Header_B_G_B;
        cssNewValues.Back_Background_G_T__c = Back_Background_G_T;                                        
        cssNewValues.Back_Background_G_B__c = Back_Background_G_B;
        cssNewValues.Back_Footer_G_T__c = Back_Footer_G_T;
        cssNewValues.Back_Footer_G_B__c = Back_Footer_G_B;
        cssNewValues.Back_Body_G_T__c = Back_Body_G_T;                                
        cssNewValues.Back_Body_G_B__c = Back_Body_G_B;
        cssNewValues.Back_Navigation_Menu__c = Back_Navigation_Menu;
        cssNewValues.Back_Navigation_Menu_H__c = Back_Navigation_Menu_H;
        cssNewValues.Back_Page_Block_Header_G_T__c = Back_Page_Block_Header_G_T;
        cssNewValues.Back_Page_Block_Header_G_B__c = Back_Page_Block_Header_G_B;
        cssNewValues.Back_Page_Block_Table_Odd__c = Back_Page_Block_Table_Odd;
        cssNewValues.Back_Page_Block_Table_Even__c = Back_Page_Block_Table_Even;
        cssNewValues.Back_Button_G_T__c = Back_Button_G_T;
        cssNewValues.Back_Button_G_B__c = Back_Button_G_B;                                
        cssNewValues.Back_Button_H_G_T__c = Back_Button_H_G_T;
        cssNewValues.Back_Button_H_G_B__c = Back_Button_H_G_B;
        cssNewValues.Back_Tab_G_T__c = Back_Tab_G_T;
        cssNewValues.Back_Tab_G_B__c = Back_Tab_G_B;                                
        cssNewValues.Back_Tab_A_G_T__c = Back_Tab_A_G_T;
        cssNewValues.Back_Tab_A_G_B__c = Back_Tab_A_G_B;
        cssNewValues.Back_Tab_H_G_T__c = Back_Tab_H_G_T;                              
                                    
        upsert cssNewValues;
    }
    
    //Second 32 fields
    @remoteAction           
    global static void saveUpdates2(String templateId,
                                    String Back_Tab_H_G_B,
                                    String Back_Side_G_T,
                                    String Back_Side_G_B,
                                    String Back_Side_Button_G_T,        
                                    String Back_Side_Button_G_B,        
                                    String Back_Side_Button_H_G_T,      
                                    String Back_Side_Button_H_G_B,      
                                    String Font_Colour_Main,        
                                    String Font_Colour_Secondary_Title,     
                                    String Font_Colour_Small_Information,       
                                    String Font_Colour_Page_Title,      
                                    String Font_Colour_Side_Header,     
                                    String Font_Colour_Tab,     
                                    String Font_Colour_Tab_A,       
                                    String Font_Colour_Tab_H,       
                                    String Font_Colour_Button,      
                                    String Font_Colour_Button_H,
                                    String Font_Colour_Side_Button,
                                    String Font_Colour_Side_Button_H,
                                    String Font_Colour_Navigation_Menu,     
                                    String Font_Colour_Navigation_Menu_H,       
                                    String Font_Size_Main,      
                                    String Font_Size_Secondary_Title,       
                                    String Font_Size_Small_Information,     
                                    String Font_Size_Page_Title,        
                                    String Font_Size_Side_Header,       
                                    String Font_Size_Tab,       
                                    String Font_Size_Tab_A,         
                                    String Font_Size_Tab_H,     
                                    String Font_Size_Button,        
                                    String Font_Size_Button_H) {
        
        Org_Template__c cssNewValues = [SELECT Id FROM Org_Template__c Where Id =: templateId];

        cssNewValues.Back_Tab_H_G_B__c = Back_Tab_H_G_B; 

        cssNewValues.Back_Side_G_T__c = Back_Side_G_T;   
        cssNewValues.Back_Side_G_B__c = Back_Side_G_B;      
        cssNewValues.Back_Side_Button_G_T__c = Back_Side_Button_G_T;                                
        cssNewValues.Back_Side_Button_G_B__c = Back_Side_Button_G_B;
        cssNewValues.Back_Side_Button_H_G_T__c = Back_Side_Button_H_G_T;
        cssNewValues.Back_Side_Button_H_G_B__c = Back_Side_Button_H_G_B;
        
        cssNewValues.Font_Colour_Main__c = Font_Colour_Main;                                
        cssNewValues.Font_Colour_Secondary_Title__c = Font_Colour_Secondary_Title;
        cssNewValues.Font_Colour_Small_Information__c = Font_Colour_Small_Information;
        cssNewValues.Font_Colour_Page_Title__c = Font_Colour_Page_Title;
        cssNewValues.Font_Colour_Side_Header__c = Font_Colour_Side_Header;
        cssNewValues.Font_Colour_Tab__c = Font_Colour_Tab;
        cssNewValues.Font_Colour_Tab_A__c = Font_Colour_Tab_A;                                
        cssNewValues.Font_Colour_Tab_H__c = Font_Colour_Tab_H;                               
        cssNewValues.Font_Colour_Button__c = Font_Colour_Button;                                                                              
        cssNewValues.Font_Colour_Button_H__c = Font_Colour_Button_H;
        cssNewValues.Font_Colour_Side_Button__c = Font_Colour_Side_Button;
        cssNewValues.Font_Colour_Side_Button_H__c = Font_Colour_Side_Button_H;                                
        cssNewValues.Font_Colour_Navigation_Menu__c = Font_Colour_Navigation_Menu;
        cssNewValues.Font_Colour_Navigation_Menu_H__c = Font_Colour_Navigation_Menu_H; 
        cssNewValues.Font_Size_Main__c = Font_Size_Main;
        cssNewValues.Font_Size_Secondary_Title__c = Font_Size_Secondary_Title;
        cssNewValues.Font_Size_Small_Information__c = Font_Size_Small_Information;                                
        cssNewValues.Font_Size_Page_Title__c = Font_Size_Page_Title;
        cssNewValues.Font_Size_Side_Header__c = Font_Size_Side_Header;
        cssNewValues.Font_Size_Tab__c = Font_Size_Tab;                                
        cssNewValues.Font_Size_Tab_A__c = Font_Size_Tab_A;
        cssNewValues.Font_Size_Tab_H__c = Font_Size_Tab_H;
        cssNewValues.Font_Size_Button__c = Font_Size_Button;             
        cssNewValues.Font_Size_Button_H__c = Font_Size_Button_H;
                                        
        upsert cssNewValues;
    }
    
    //Third 32 fields
    @remoteAction                                       
    global static void saveUpdates3(String templateId,
                                    String Font_Size_Side_Button,
                                    String Font_Size_Side_Button_H,
                                    String Font_Size_Navigation_Menu,
                                    String Font_Size_Navigation_Menu_H,     
                                    String Font_Weight_Main,
                                    String Font_Weight_Secondary_Title,     
                                    String Font_Weight_Small_Information,
                                    String Font_Weight_Page_Title,          
                                    String Font_Weight_Side_Header,     
                                    String Font_Weight_Tab,  
                                    String Font_Weight_Tab_A,
                                    String Font_Weight_Tab_H,
                                    String Font_Weight_Button,
                                    String Font_Weight_Button_H,
                                    String Font_Weight_Side_Button,
                                    String Font_Weight_Side_Button_H,
                                    String Font_Weight_Navigation_Menu,
                                    String Font_Weight_Navigation_Menu_H,
                                    String Font_Transform_Main,
                                    String Font_Transform_Secondary_Title,
                                    String Font_Transform_Small_Information,
                                    String Font_Transform_Page_Title,
                                    String Font_Transform_Side_Header,
                                    String Font_Transform_Tab,
                                    String Font_Transform_Tab_A,
                                    String Font_Transform_Tab_H,
                                    String Font_Transform_Button,
                                    String Font_Transform_Button_H,
                                    String Font_Transform_Side_Button,
                                    String Font_Transform_Side_Button_H,
                                    String Font_Transform_Navigation_Menu) {
        
        Org_Template__c cssNewValues = [SELECT Id FROM Org_Template__c Where Id =: templateId];
                
        cssNewValues.Font_Size_Side_Button__c = Font_Size_Side_Button;
        cssNewValues.Font_Size_Side_Button_H__c = Font_Size_Side_Button_H;

        cssNewValues.Font_Size_Navigation_Menu__c = Font_Size_Navigation_Menu;
        cssNewValues.Font_Size_Navigation_Menu_H__c = Font_Size_Navigation_Menu_H;
        cssNewValues.Font_Weight_Main__c = Font_Weight_Main;
        cssNewValues.Font_Weight_Secondary_Title__c = Font_Weight_Secondary_Title;
        cssNewValues.Font_Weight_Small_Information__c = Font_Weight_Small_Information;                                
        cssNewValues.Font_Weight_Page_Title__c = Font_Weight_Page_Title;                                
        cssNewValues.Font_Weight_Side_Header__c = Font_Weight_Side_Header;                                
        cssNewValues.Font_Weight_Tab__c = Font_Weight_Tab;
        cssNewValues.Font_Weight_Tab_A__c = Font_Weight_Tab_A;
        cssNewValues.Font_Weight_Tab_H__c = Font_Weight_Tab_H; 
        cssNewValues.Font_Weight_Button__c = Font_Weight_Button;
        cssNewValues.Font_Weight_Button_H__c = Font_Weight_Button_H;
        cssNewValues.Font_Weight_Side_Button__c = Font_Weight_Side_Button;
        cssNewValues.Font_Weight_Side_Button_H__c = Font_Weight_Side_Button_H;
        cssNewValues.Font_Weight_Navigation_Menu__c = Font_Weight_Navigation_Menu;
        cssNewValues.Font_Weight_Navigation_Menu_H__c = Font_Weight_Navigation_Menu_H;
        cssNewValues.Font_Transform_Main__c = Font_Transform_Main;                                
        cssNewValues.Font_Transform_Secondary_Title__c = Font_Transform_Secondary_Title;
        cssNewValues.Font_Transform_Small_Information__c = Font_Transform_Small_Information;
        cssNewValues.Font_Transform_Page_Title__c = Font_Transform_Page_Title;
        cssNewValues.Font_Transform_Side_Header__c = Font_Transform_Side_Header;
        cssNewValues.Font_Transform_Tab__c = Font_Transform_Tab;
        cssNewValues.Font_Transform_Tab_A__c = Font_Transform_Tab_A;
        cssNewValues.Font_Transform_Tab_H__c = Font_Transform_Tab_H;
        cssNewValues.Font_Transform_Button__c = Font_Transform_Button;
        cssNewValues.Font_Transform_Button_H__c = Font_Transform_Button_H;
        cssNewValues.Font_Transform_Side_Button__c = Font_Transform_Side_Button;
        cssNewValues.Font_Transform_Side_Button_H__c = Font_Transform_Side_Button_H;
        cssNewValues.Font_Transform_Navigation_Menu__c = Font_Transform_Navigation_Menu;
        
        upsert cssNewValues;
    }
    
    //Fourth 32 fields
    @remoteAction                   
    global static void saveUpdates4(String templateId,
                                    String Font_Transform_Navigation_Menu_H,
                                    String Font_Decoration_Main,
                                    String Font_Decoration_Secondary_Title,
                                    String Font_Decoration_Small_Information,
                                    String Font_Decoration_Page_Title,
                                    String Font_Decoration_Side_Header,
                                    String Font_Decoration_Tab,
                                    String Font_Decoration_Tab_A,
                                    String Font_Decoration_Tab_H,
                                    String Font_Decoration_Button,
                                    String Font_Decoration_Button_H,
                                    String Font_Decoration_Side_Button,
                                    String Font_Decoration_Side_Button_H,
                                    String Font_Decoration_Navigation_Menu,
                                    String Font_Decoration_Navigation_Menu_H,
                                    String Radius_Page_Block,
                                    String Radius_Side,   
                                    String Radius_Side_Module,
                                    String Radius_Button,
                                    String Radius_Side_Button,
                                    String Radius_Tab,
                                    Boolean Image_Background,
                                    Boolean Image_Button,
                                    Boolean Image_Page_Block_Header,
                                    Boolean Image_Button_H,
                                    Boolean Shadow_Side,
                                    Boolean Shadow_Header,
                                    Boolean Shadow_Body,
                                    Boolean Shadow_Page_Block,
                                    Boolean Shadow_Side_Module,
                                    String Image_Logo) {
        System.debug('\n\n\n***************' + Image_Logo);
        Org_Template__c cssNewValues = [SELECT Id FROM Org_Template__c Where Id =: templateId];
    
        cssNewValues.Font_Transform_Navigation_Menu_H__c = Font_Transform_Navigation_Menu_H;
        cssNewValues.Font_Decoration_Main__c = Font_Decoration_Main;
        cssNewValues.Font_Decoration_Secondary_Title__c = Font_Decoration_Secondary_Title;       

        cssNewValues.Font_Decoration_Small_Information__c = Font_Decoration_Small_Information;
        cssNewValues.Font_Decoration_Page_Title__c = Font_Decoration_Page_Title;
        cssNewValues.Font_Decoration_Side_Header__c = Font_Decoration_Side_Header;                                   
        cssNewValues.Font_Decoration_Tab__c = Font_Decoration_Tab;
        cssNewValues.Font_Decoration_Tab_A__c = Font_Decoration_Tab_A;
        cssNewValues.Font_Decoration_Tab_H__c = Font_Decoration_Tab_H;
        cssNewValues.Font_Decoration_Button__c = Font_Decoration_Button;
        cssNewValues.Font_Decoration_Button_H__c = Font_Decoration_Button_H;
        cssNewValues.Font_Decoration_Side_Button__c = Font_Decoration_Side_Button;
        cssNewValues.Font_Decoration_Side_Button_H__c = Font_Decoration_Side_Button_H;
        cssNewValues.Font_Decoration_Navigation_Menu__c = Font_Decoration_Navigation_Menu;
        cssNewValues.Font_Decoration_Navigation_Menu_H__c = Font_Decoration_Navigation_Menu_H;
        cssNewValues.Radius_Page_Block__c = Radius_Page_Block; 
        cssNewValues.Radius_Side__c = Radius_Side;      
        cssNewValues.Radius_Side_Module__c = Radius_Side_Module;    
        cssNewValues.Radius_Button__c = Radius_Button;                        
        cssNewValues.Radius_Side_Button__c = Radius_Side_Button;
        cssNewValues.Radius_Tab__c = Radius_Tab;  
        cssNewValues.Image_Background__c = Image_Background;
        cssNewValues.Image_Button__c = Image_Button;
        cssNewValues.Image_Page_Block_Header__c = Image_Page_Block_Header;
        cssNewValues.Image_Button_H__c = Image_Button_H;
        cssNewValues.Shadow_Side__c  = Shadow_Side;
        cssNewValues.Shadow_Header__c = Shadow_Header;
        cssNewValues.Shadow_Body__c = Shadow_Body;
        cssNewValues.Shadow_Page_Block__c = Shadow_Page_Block;
        cssNewValues.Shadow_Side_Module__c = Shadow_Side_Module;
        cssNewValues.Image_Logo__c = Image_Logo;
        
                      
        upsert cssNewValues;
    }
    //Fifth 32 fields
    @remoteAction                   
    global static void saveUpdates5(String templateId,
                                    String Image_Footer,
                                    String Image_Slide1,
                                    String Image_Slide2,
                                    String Image_Slide3,
                                    String Image_Body,
                                    String Back_Page_Block_G_T,
                                    String Back_Page_Block_G_B,
                                    String Back_Side_Module_G_T,
                                    String Back_Side_Module_G_B,
                                    String Back_Side_Module_Header_G_B,
                                    String Back_Side_Module_Header_G_T,
                                    Boolean Component_Image,
                                    Boolean Component_Cases,
                                    Boolean Component_Products,
                                    Boolean Component_Entitlements,
                                    Boolean Component_Ideas,
                                    Boolean Component_Solutions,
                                    Boolean Component_Articles,
                                    Boolean Component_Charts,
                                    Boolean Component_Approvals,
                                    Boolean Component_Leads,
                                    String Back_Google_Chart_1,
                                    String Back_Google_Chart_2,
                                    String Back_Google_Chart_3,
                                    String Back_Google_Chart_4,
                                    String Position_Footer,
                                    String Image_Position,
                                    String Image_Repeat,
                                    String Image_Background_Image,
                                    String Name) {
        
        Org_Template__c cssNewValues = [SELECT Id, Name FROM Org_Template__c Where Id =: templateId];
        
        /*if(cssNewValues.Name != Name){
            List<User> updatedUsers = [SELECT id,name,branding_template__c,UserPermissionsJigsawProspectingUser FROM User WHERE UserPermissionsJigsawProspectingUser = false AND branding_template__c = :cssNewValues.name];
            for(User u : updatedUsers){
                u.branding_template__c = Name;
            }
            if(updatedUsers.size() > 0){
                update updatedUsers;
            }
        }*/
        
        cssNewValues.Image_Footer__c = Image_Footer;
        cssNewValues.Image_Slide1__c = Image_Slide1;
        cssNewValues.Image_Slide2__c = Image_Slide2;
        cssNewValues.Image_Slide3__c = Image_Slide3;       
        cssNewValues.Image_Body__c = Image_Body;                           
        cssNewValues.Back_Page_Block_G_T__c = Back_Page_Block_G_T;
        cssNewValues.Back_Page_Block_G_B__c = Back_Page_Block_G_B;
        cssNewValues.Back_Side_Module_G_T__c = Back_Side_Module_G_T;
        cssNewValues.Back_Side_Module_G_B__c = Back_Side_Module_G_B;
        cssNewValues.Back_Side_Module_Header_G_B__c = Back_Side_Module_Header_G_B;
        cssNewValues.Back_Side_Module_Header_G_T__c = Back_Side_Module_Header_G_T;
        cssNewValues.Component_Image__c = Component_Image;
        cssNewValues.Component_Cases__c = Component_Cases;
        cssNewValues.Component_Products__c = Component_Products;
        cssNewValues.Component_Entitlements__c = Component_Entitlements;
        cssNewValues.Component_Ideas__c = Component_Ideas;
        cssNewValues.Component_Solutions__c = Component_Solutions;
        cssNewValues.Component_Articles__c = Component_Articles;
        cssNewValues.Component_Charts__c = Component_Charts;
        cssNewValues.Component_Approvals__c = Component_Approvals;
        cssNewValues.Component_Leads__c = Component_Leads;
        cssNewValues.Back_Google_Chart_1__c = Back_Google_Chart_1;
        cssNewValues.Back_Google_Chart_2__c = Back_Google_Chart_2;
        cssNewValues.Back_Google_Chart_3__c = Back_Google_Chart_3;
        cssNewValues.Back_Google_Chart_4__c = Back_Google_Chart_4;
        cssNewValues.Position_Footer__c = Position_Footer;
        cssNewValues.Image_Background_Position__c = Image_Position;
        cssNewValues.Image_Background_Repeat__c = Image_Repeat;
        cssNewValues.Image_Background_Image__c = Image_Background_Image;
        cssNewValues.Name = Name;
                                           
        upsert cssNewValues;
    }
    
    //Save custom images
    @remoteAction
    global static String saveSSEPortalImage(String theFileName, Blob theBody){
        
        Folder portalFolder = [SELECT id, name FROM Folder WHERE name = 'SSE Portal Documents'];
        Document SSEPortalLogo = new Document(FolderId = portalFolder.id, isPublic = true, Name = theFileName, Body = theBody);
      
        insert SSEPortalLogo;

        return '/servlet/servlet.ImageServer?id=' + SSEPortalLogo.id + '&oid=' + UserInfo.getOrganizationId();

    }
    
    //Update just the logo
    @remoteAction                   
    global static void saveAndUpdateLogo(String theFileName, Blob theBody, String topGradient, String bottomGradient, String templateId) {
                
        Folder portalFolder = [SELECT id, name FROM Folder WHERE name = 'SSE Portal Documents'];
        Document SSEPortalLogo = new Document(FolderId = portalFolder.id, isPublic = true, Name = theFileName, Body = theBody);
      
        insert SSEPortalLogo;

        Org_Template__c cssNewValues = [SELECT Id, Name FROM Org_Template__c Where Id =: templateId];
  
        cssNewValues.Image_Logo__c = '/servlet/servlet.ImageServer?id=' + SSEPortalLogo.id + '&oid=' + UserInfo.getOrganizationId();                         
        cssNewValues.Back_Header_Mid_G_T__c = topGradient;
        cssNewValues.Back_Header_Mid_G_B__c = bottomGradient;
                               
        upsert cssNewValues;
    }
    
    //Clone the current template
    public PageReference cloneTemplate(){
        Org_Template__c currentTemplate = [SELECT Back_Background_G_B__c,Back_Background_G_T__c,Back_Body_G_B__c,Back_Body_G_T__c,Back_Button_G_B__c,Back_Button_G_T__c,Back_Button_H_G_B__c,Back_Button_H_G_T__c,Back_Footer_G_B__c,Back_Footer_G_T__c,Back_Google_Chart_1__c,Back_Google_Chart_2__c,Back_Google_Chart_3__c,Back_Google_Chart_4__c,Back_Header_B_G_B__c,Back_Header_B_G_T__c,Back_Header_Mid_G_B__c,Back_Header_Mid_G_T__c,Back_Header_T_G_B__c,Back_Header_T_G_T__c,Back_Navigation_Menu_H__c,Back_Navigation_Menu__c,Back_Page_Block_G_B__c,Back_Page_Block_G_T__c,Back_Page_Block_Header_G_B__c,Back_Page_Block_Header_G_T__c,Back_Page_Block_Table_Even__c,Back_Page_Block_Table_Odd__c,Back_Side_Button_G_B__c,Back_Side_Button_G_T__c,Back_Side_Button_H_G_B__c,Back_Side_Button_H_G_T__c,Back_Side_G_B__c,Back_Side_G_T__c,Back_Side_Module_G_B__c,Back_Side_Module_G_T__c,Back_Side_Module_Header_G_B__c,Back_Side_Module_Header_G_T__c,Back_Side__c,Back_Tab_A_G_B__c,Back_Tab_A_G_T__c,Back_Tab_G_B__c,Back_Tab_G_T__c,Back_Tab_H_G_B__c,Back_Tab_H_G_T__c,Component_Approvals__c,Component_Articles__c,Component_Cases__c,Component_Charts__c,Component_Entitlements__c,Component_Ideas__c,Component_Image__c,Component_Leads__c,Component_Products__c,Component_Solutions__c,ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Font_Colour_Button_H__c,Font_Colour_Button__c,Font_Colour_Main__c,Font_Colour_Navigation_Menu_H__c,Font_Colour_Navigation_Menu__c,Font_Colour_Page_Title__c,Font_Colour_Secondary_Title__c,Font_Colour_Side_Button_H__c,Font_Colour_Side_Button__c,Font_Colour_Side_Header__c,Font_Colour_Small_Information__c,Font_Colour_Tab_A__c,Font_Colour_Tab_H__c,Font_Colour_Tab__c,Font_Decoration_Button_H__c,Font_Decoration_Button__c,Font_Decoration_Main__c,Font_Decoration_Navigation_Menu_H__c,Font_Decoration_Navigation_Menu__c,Font_Decoration_Page_Title__c,Font_Decoration_Secondary_Title__c,Font_Decoration_Side_Button_H__c,Font_Decoration_Side_Button__c,Font_Decoration_Side_Header__c,Font_Decoration_Small_Information__c,Font_Decoration_Tab_A__c,Font_Decoration_Tab_H__c,Font_Decoration_Tab__c,Font_Size_Button_H__c,Font_Size_Button__c,Font_Size_Main__c,Font_Size_Navigation_Menu_H__c,Font_Size_Navigation_Menu__c,Font_Size_Page_Title__c,Font_Size_Secondary_Title__c,Font_Size_Side_Button_H__c,Font_Size_Side_Button__c,Font_Size_Side_Header__c,Font_Size_Small_Information__c,Font_Size_Tab_A__c,Font_Size_Tab_H__c,Font_Size_Tab__c,Font_Transform_Button_H__c,Font_Transform_Button__c,Font_Transform_Main__c,Font_Transform_Navigation_Menu_H__c,Font_Transform_Navigation_Menu__c,Font_Transform_Page_Title__c,Font_Transform_Secondary_Title__c,Font_Transform_Side_Button_H__c,Font_Transform_Side_Button__c,Font_Transform_Side_Header__c,Font_Transform_Small_Information__c,Font_Transform_Tab_A__c,Font_Transform_Tab_H__c,Font_Transform_Tab__c,Font_Weight_Button_H__c,Font_Weight_Button__c,Font_Weight_Main__c,Font_Weight_Navigation_Menu_H__c,Font_Weight_Navigation_Menu__c,Font_Weight_Page_Title__c,Font_Weight_Secondary_Title__c,Font_Weight_Side_Button_H__c,Font_Weight_Side_Button__c,Font_Weight_Side_Header__c,Font_Weight_Small_Information__c,Font_Weight_Tab_A__c,Font_Weight_Tab_H__c,Font_Weight_Tab__c,Id,Image_Background_Image__c,Image_Background_Position__c,Image_Background_Repeat__c,Image_Background__c,Image_Body__c,Image_Button_H__c,Image_Button__c,Image_Footer__c,Image_Logo__c,Image_Page_Block_Header__c,Image_Slide1__c,Image_Slide2__c,Image_Slide3__c,IsDeleted,LastModifiedById,LastModifiedDate,Name,OwnerId,Position_Footer__c,Position_Page__c,Position_Sidebar__c,Position_Slider__c,Position_Tabs__c,Radius_Button__c,Radius_Page_Block__c,Radius_Side_Button__c,Radius_Side_Module__c,Radius_Side__c,Radius_Tab__c,Shadow_Body__c,Shadow_Header__c,Shadow_Page_Block__c,Shadow_Side_Module__c,Shadow_Side__c,SystemModstamp FROM Org_Template__c WHERE Id=: ApexPages.currentPage().getParameters().get('id')];
        Org_Template__c newTemplate = currentTemplate.clone(false, true);
        newTemplate.name = 'Clone of ' + currentTemplate.Name;
        insert newTemplate;
        return new PageReference('/' + newTemplate.id);
    }
    
    //Delete the current template
    public PageReference deleteTemplate(){
        Org_Template__c currentTemplate = [SELECT Back_Background_G_B__c,Back_Background_G_T__c,Back_Body_G_B__c,Back_Body_G_T__c,Back_Button_G_B__c,Back_Button_G_T__c,Back_Button_H_G_B__c,Back_Button_H_G_T__c,Back_Footer_G_B__c,Back_Footer_G_T__c,Back_Google_Chart_1__c,Back_Google_Chart_2__c,Back_Google_Chart_3__c,Back_Google_Chart_4__c,Back_Header_B_G_B__c,Back_Header_B_G_T__c,Back_Header_Mid_G_B__c,Back_Header_Mid_G_T__c,Back_Header_T_G_B__c,Back_Header_T_G_T__c,Back_Navigation_Menu_H__c,Back_Navigation_Menu__c,Back_Page_Block_G_B__c,Back_Page_Block_G_T__c,Back_Page_Block_Header_G_B__c,Back_Page_Block_Header_G_T__c,Back_Page_Block_Table_Even__c,Back_Page_Block_Table_Odd__c,Back_Side_Button_G_B__c,Back_Side_Button_G_T__c,Back_Side_Button_H_G_B__c,Back_Side_Button_H_G_T__c,Back_Side_G_B__c,Back_Side_G_T__c,Back_Side_Module_G_B__c,Back_Side_Module_G_T__c,Back_Side_Module_Header_G_B__c,Back_Side_Module_Header_G_T__c,Back_Side__c,Back_Tab_A_G_B__c,Back_Tab_A_G_T__c,Back_Tab_G_B__c,Back_Tab_G_T__c,Back_Tab_H_G_B__c,Back_Tab_H_G_T__c,Component_Approvals__c,Component_Articles__c,Component_Cases__c,Component_Charts__c,Component_Entitlements__c,Component_Ideas__c,Component_Image__c,Component_Leads__c,Component_Products__c,Component_Solutions__c,ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Font_Colour_Button_H__c,Font_Colour_Button__c,Font_Colour_Main__c,Font_Colour_Navigation_Menu_H__c,Font_Colour_Navigation_Menu__c,Font_Colour_Page_Title__c,Font_Colour_Secondary_Title__c,Font_Colour_Side_Button_H__c,Font_Colour_Side_Button__c,Font_Colour_Side_Header__c,Font_Colour_Small_Information__c,Font_Colour_Tab_A__c,Font_Colour_Tab_H__c,Font_Colour_Tab__c,Font_Decoration_Button_H__c,Font_Decoration_Button__c,Font_Decoration_Main__c,Font_Decoration_Navigation_Menu_H__c,Font_Decoration_Navigation_Menu__c,Font_Decoration_Page_Title__c,Font_Decoration_Secondary_Title__c,Font_Decoration_Side_Button_H__c,Font_Decoration_Side_Button__c,Font_Decoration_Side_Header__c,Font_Decoration_Small_Information__c,Font_Decoration_Tab_A__c,Font_Decoration_Tab_H__c,Font_Decoration_Tab__c,Font_Size_Button_H__c,Font_Size_Button__c,Font_Size_Main__c,Font_Size_Navigation_Menu_H__c,Font_Size_Navigation_Menu__c,Font_Size_Page_Title__c,Font_Size_Secondary_Title__c,Font_Size_Side_Button_H__c,Font_Size_Side_Button__c,Font_Size_Side_Header__c,Font_Size_Small_Information__c,Font_Size_Tab_A__c,Font_Size_Tab_H__c,Font_Size_Tab__c,Font_Transform_Button_H__c,Font_Transform_Button__c,Font_Transform_Main__c,Font_Transform_Navigation_Menu_H__c,Font_Transform_Navigation_Menu__c,Font_Transform_Page_Title__c,Font_Transform_Secondary_Title__c,Font_Transform_Side_Button_H__c,Font_Transform_Side_Button__c,Font_Transform_Side_Header__c,Font_Transform_Small_Information__c,Font_Transform_Tab_A__c,Font_Transform_Tab_H__c,Font_Transform_Tab__c,Font_Weight_Button_H__c,Font_Weight_Button__c,Font_Weight_Main__c,Font_Weight_Navigation_Menu_H__c,Font_Weight_Navigation_Menu__c,Font_Weight_Page_Title__c,Font_Weight_Secondary_Title__c,Font_Weight_Side_Button_H__c,Font_Weight_Side_Button__c,Font_Weight_Side_Header__c,Font_Weight_Small_Information__c,Font_Weight_Tab_A__c,Font_Weight_Tab_H__c,Font_Weight_Tab__c,Id,Image_Background_Image__c,Image_Background_Position__c,Image_Background_Repeat__c,Image_Background__c,Image_Body__c,Image_Button_H__c,Image_Button__c,Image_Footer__c,Image_Logo__c,Image_Page_Block_Header__c,Image_Slide1__c,Image_Slide2__c,Image_Slide3__c,IsDeleted,LastModifiedById,LastModifiedDate,Name,OwnerId,Position_Footer__c,Position_Page__c,Position_Sidebar__c,Position_Slider__c,Position_Tabs__c,Radius_Button__c,Radius_Page_Block__c,Radius_Side_Button__c,Radius_Side_Module__c,Radius_Side__c,Radius_Tab__c,Shadow_Body__c,Shadow_Header__c,Shadow_Page_Block__c,Shadow_Side_Module__c,Shadow_Side__c,SystemModstamp FROM Org_Template__c WHERE Id=: ApexPages.currentPage().getParameters().get('id')];
        PageReference redirectURL = new PageReference('/' + (''+currentTemplate.id).substring(0, 3));
        delete currentTemplate;
        return redirectURL;
    }
    
    // Get the list fo Fields for the selected object
    @remoteAction
    global Static String getAllFields(String templateID){
        Org_Template__c o = [SELECT Back_Background_G_B__c,Back_Background_G_T__c,Back_Body_G_B__c,Back_Body_G_T__c,Back_Button_G_B__c,Back_Button_G_T__c,Back_Button_H_G_B__c,Back_Button_H_G_T__c,Back_Footer_G_B__c,Back_Footer_G_T__c,Back_Google_Chart_1__c,Back_Google_Chart_2__c,Back_Google_Chart_3__c,Back_Google_Chart_4__c,Back_Header_B_G_B__c,Back_Header_B_G_T__c,Back_Header_Mid_G_B__c,Back_Header_Mid_G_T__c,Back_Header_T_G_B__c,Back_Header_T_G_T__c,Back_Navigation_Menu_H__c,Back_Navigation_Menu__c,Back_Page_Block_G_B__c,Back_Page_Block_G_T__c,Back_Page_Block_Header_G_B__c,Back_Page_Block_Header_G_T__c,Back_Page_Block_Table_Even__c,Back_Page_Block_Table_Odd__c,Back_Side_Button_G_B__c,Back_Side_Button_G_T__c,Back_Side_Button_H_G_B__c,Back_Side_Button_H_G_T__c,Back_Side_G_B__c,Back_Side_G_T__c,Back_Side_Module_G_B__c,Back_Side_Module_G_T__c,Back_Side_Module_Header_G_B__c,Back_Side_Module_Header_G_T__c,Back_Side__c,Back_Tab_A_G_B__c,Back_Tab_A_G_T__c,Back_Tab_G_B__c,Back_Tab_G_T__c,Back_Tab_H_G_B__c,Back_Tab_H_G_T__c,Component_Approvals__c,Component_Articles__c,Component_Cases__c,Component_Charts__c,Component_Entitlements__c,Component_Ideas__c,Component_Image__c,Component_Leads__c,Component_Products__c,Component_Solutions__c,ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Font_Colour_Button_H__c,Font_Colour_Button__c,Font_Colour_Main__c,Font_Colour_Navigation_Menu_H__c,Font_Colour_Navigation_Menu__c,Font_Colour_Page_Title__c,Font_Colour_Secondary_Title__c,Font_Colour_Side_Button_H__c,Font_Colour_Side_Button__c,Font_Colour_Side_Header__c,Font_Colour_Small_Information__c,Font_Colour_Tab_A__c,Font_Colour_Tab_H__c,Font_Colour_Tab__c,Font_Decoration_Button_H__c,Font_Decoration_Button__c,Font_Decoration_Main__c,Font_Decoration_Navigation_Menu_H__c,Font_Decoration_Navigation_Menu__c,Font_Decoration_Page_Title__c,Font_Decoration_Secondary_Title__c,Font_Decoration_Side_Button_H__c,Font_Decoration_Side_Button__c,Font_Decoration_Side_Header__c,Font_Decoration_Small_Information__c,Font_Decoration_Tab_A__c,Font_Decoration_Tab_H__c,Font_Decoration_Tab__c,Font_Size_Button_H__c,Font_Size_Button__c,Font_Size_Main__c,Font_Size_Navigation_Menu_H__c,Font_Size_Navigation_Menu__c,Font_Size_Page_Title__c,Font_Size_Secondary_Title__c,Font_Size_Side_Button_H__c,Font_Size_Side_Button__c,Font_Size_Side_Header__c,Font_Size_Small_Information__c,Font_Size_Tab_A__c,Font_Size_Tab_H__c,Font_Size_Tab__c,Font_Transform_Button_H__c,Font_Transform_Button__c,Font_Transform_Main__c,Font_Transform_Navigation_Menu_H__c,Font_Transform_Navigation_Menu__c,Font_Transform_Page_Title__c,Font_Transform_Secondary_Title__c,Font_Transform_Side_Button_H__c,Font_Transform_Side_Button__c,Font_Transform_Side_Header__c,Font_Transform_Small_Information__c,Font_Transform_Tab_A__c,Font_Transform_Tab_H__c,Font_Transform_Tab__c,Font_Weight_Button_H__c,Font_Weight_Button__c,Font_Weight_Main__c,Font_Weight_Navigation_Menu_H__c,Font_Weight_Navigation_Menu__c,Font_Weight_Page_Title__c,Font_Weight_Secondary_Title__c,Font_Weight_Side_Button_H__c,Font_Weight_Side_Button__c,Font_Weight_Side_Header__c,Font_Weight_Small_Information__c,Font_Weight_Tab_A__c,Font_Weight_Tab_H__c,Font_Weight_Tab__c,Id,Image_Background_Image__c,Image_Background_Position__c,Image_Background_Repeat__c,Image_Background__c,Image_Body__c,Image_Button_H__c,Image_Button__c,Image_Footer__c,Image_Logo__c,Image_Page_Block_Header__c,Image_Slide1__c,Image_Slide2__c,Image_Slide3__c,IsDeleted,LastModifiedById,LastModifiedDate,Name,OwnerId,Position_Footer__c,Position_Page__c,Position_Sidebar__c,Position_Slider__c,Position_Tabs__c,Radius_Button__c,Radius_Page_Block__c,Radius_Side_Button__c,Radius_Side_Module__c,Radius_Side__c,Radius_Tab__c,Shadow_Body__c,Shadow_Header__c,Shadow_Page_Block__c,Shadow_Side_Module__c,Shadow_Side__c,SystemModstamp FROM Org_Template__c WHERE Id=: templateID];
        String megaStringFieldLabel = 'Back Background Gradient Bottom,Back Background Gradient Top,Back Body Gradient Bottom,Back Body Gradient Top,Back Button Gradient Bottom,Back Button Gradient Top,Back Button Hover Gradient Bottom,Back Button Hover Gradient Top,Back Footer Gradient Bottom,Back Footer Gradient Top,Back Google Chart 1,Back Google Chart 2,Back Google Chart 3,Back Google Chart 4,Back Header Bottom Gradient Bottom,Back Header Bottom Gradient Top,Back Header Mid Gradient Bottom,Back Header Mid Gradient Top,Back Header Top Gradient Bottom,Back Header Top Gradient Top,Back Navigation Menu,Back Navigation Menu Hover,Back Page Block Gradient Bottom,Back Page Block Gradient Top,Back Page Block Header Gradient Bottom,Back Page Block Header Gradient Top,Back Page Block Table Even,Back Page Block Table Odd,Back Side,Back Side Button Gradient Bottom,Back Side Button Gradient Top,Back Side Button Hover Gradient Bottom,Back Side Button Hover Gradient Top,Back Side Gradient Bottom,Back Side Gradient Top,Back Side Module Gradient Bottom,Back Side Module Gradient Top,Back Side Module Header Gradient Bottom,Back Side Module Header Gradient Top,Back Tab Active Gradient Bottom,Back Tab Active Gradient Top,Back Tab Gradient Bottom,Back Tab Gradient Top,Back Tab Hover Gradient Bottom,Back Tab Hover Gradient Top,Component Approvals,Component Articles,Component Cases,Component Charts,Component Entitlements,Component Ideas,Component Image,Component Leads,Component Products,Component Solutions,Created By ID,Created Date,Deleted,Font Colour Button,Font Colour Button Hover,Font Colour Main,Font Colour Navigation Menu,Font Colour Navigation Menu Hover,Font Colour Page Title,Font Colour Secondary Title,Font Colour Side Button,Font Colour Side Button Hover,Font Colour Side Header,Font Colour Small Information,Font Colour Tab,Font Colour Tab Active,Font Colour Tab Hover,Font Decoration Button,Font Decoration Button Hover,Font Decoration Main,Font Decoration Navigation Menu,Font Decoration Navigation Menu Hover,Font Decoration Page Title,Font Decoration Secondary Title,Font Decoration Side Button,Font Decoration Side Button Hover,Font Decoration Side Header,Font Decoration Small Information,Font Decoration Tab,Font Decoration Tab Active,Font Decoration Tab Hover,Font Size Button,Font Size Button Hover,Font Size Main,Font Size Navigation Menu,Font Size Navigation Menu Hover,Font Size Page Title,Font Size Secondary Title,Font Size Side Button,Font Size Side Button Hover,Font Size Side Header,Font Size Small Information,Font Size Tab,Font Size Tab Active,Font Size Tab Hover,Font Transform Button,Font Transform Button Hover,Font Transform Main,Font Transform Navigation Menu,Font Transform Navigation Menu Hover,Font Transform Page Title,Font Transform Secondary Title,Font Transform Side Button,Font Transform Side Button Hover,Font Transform Side Header,Font Transform Small Information,Font Transform Tab,Font Transform Tab Active,Font Transform Tab Hover,Font Weight Button,Font Weight Button Hover,Font Weight Main,Font Weight Navigation Menu,Font Weight Navigation Menu Hover,Font Weight Page Title,Font Weight Secondary Title,Font Weight Side Button,Font Weight Side Button Hover,Font Weight Side Header,Font Weight Small Information,Font Weight Tab,Font Weight Tab Active,Font Weight Tab Hover,Image Background,Image Background Image,Image Background Position,Image Background Repeat,Image Body,Image Button,Image Button Hover,Image Footer,Image Logo,Image Page Block Header,Image Slide1,Image Slide2,Image Slide3,Last Modified By ID,Last Modified Date,Owner ID,Position Footer,Position Page,Position Sidebar,Position Slider,Position Tabs,Radius Button,Radius Page Block,Radius Side,Radius Side Button,Radius Side Module,Radius Tab,Received Connection ID,Record ID,Sent Connection ID,Shadow Body,Shadow Header,Shadow Page Block,Shadow Side,Shadow Side Module,Template Name\n';
        String megaStringFieldValues = '\"' + o.Back_Background_G_B__c+'\",\"'+o.Back_Background_G_T__c+'\",\"'+o.Back_Body_G_B__c+'\",\"'+o.Back_Body_G_T__c+'\",\"'+o.Back_Button_G_B__c+'\",\"'+o.Back_Button_G_T__c+'\",\"'+o.Back_Button_H_G_B__c+'\",\"'+o.Back_Button_H_G_T__c+'\",\"'+o.Back_Footer_G_B__c+'\",\"'+o.Back_Footer_G_T__c+'\",\"'+o.Back_Google_Chart_1__c+'\",\"'+o.Back_Google_Chart_2__c+'\",\"'+o.Back_Google_Chart_3__c+'\",\"'+o.Back_Google_Chart_4__c+'\",\"'+o.Back_Header_B_G_B__c+'\",\"'+o.Back_Header_B_G_T__c+'\",\"'+o.Back_Header_Mid_G_B__c+'\",\"'+o.Back_Header_Mid_G_T__c+'\",\"'+o.Back_Header_T_G_B__c+'\",\"'+o.Back_Header_T_G_T__c+'\",\"'+o.Back_Navigation_Menu__c+'\",\"'+o.Back_Navigation_Menu_H__c+'\",\"'+o.Back_Page_Block_G_B__c+'\",\"'+o.Back_Page_Block_G_T__c+'\",\"'+o.Back_Page_Block_Header_G_B__c+'\",\"'+o.Back_Page_Block_Header_G_T__c+'\",\"'+o.Back_Page_Block_Table_Even__c+'\",\"'+o.Back_Page_Block_Table_Odd__c+'\",\"'+o.Back_Side__c+'\",\"'+o.Back_Side_Button_G_B__c+'\",\"'+o.Back_Side_Button_G_T__c+'\",\"'+o.Back_Side_Button_H_G_B__c+'\",\"'+o.Back_Side_Button_H_G_T__c+'\",\"'+o.Back_Side_G_B__c+'\",\"'+o.Back_Side_G_T__c+'\",\"'+o.Back_Side_Module_G_B__c+'\",\"'+o.Back_Side_Module_G_T__c+'\",\"'+o.Back_Side_Module_Header_G_B__c+'\",\"'+o.Back_Side_Module_Header_G_T__c+'\",\"'+o.Back_Tab_A_G_B__c+'\",\"'+o.Back_Tab_A_G_T__c+'\",\"'+o.Back_Tab_G_B__c+'\",\"'+o.Back_Tab_G_T__c+'\",\"'+o.Back_Tab_H_G_B__c+'\",\"'+o.Back_Tab_H_G_T__c+'\",\"'+o.Component_Approvals__c+'\",\"'+o.Component_Articles__c+'\",\"'+o.Component_Cases__c+'\",\"'+o.Component_Charts__c+'\",\"'+o.Component_Entitlements__c+'\",\"'+o.Component_Ideas__c+'\",\"'+o.Component_Image__c+'\",\"'+o.Component_Leads__c+'\",\"'+o.Component_Products__c+'\",\"'+o.Component_Solutions__c+'\",\"'+o.CreatedById+'\",\"'+o.CreatedDate+'\",\"'+o.IsDeleted+'\",\"'+o.Font_Colour_Button__c+'\",\"'+o.Font_Colour_Button_H__c+'\",\"'+o.Font_Colour_Main__c+'\",\"'+o.Font_Colour_Navigation_Menu__c+'\",\"'+o.Font_Colour_Navigation_Menu_H__c+'\",\"'+o.Font_Colour_Page_Title__c+'\",\"'+o.Font_Colour_Secondary_Title__c+'\",\"'+o.Font_Colour_Side_Button__c+'\",\"'+o.Font_Colour_Side_Button_H__c+'\",\"'+o.Font_Colour_Side_Header__c+'\",\"'+o.Font_Colour_Small_Information__c+'\",\"'+o.Font_Colour_Tab__c+'\",\"'+o.Font_Colour_Tab_A__c+'\",\"'+o.Font_Colour_Tab_H__c+'\",\"'+o.Font_Decoration_Button__c+'\",\"'+o.Font_Decoration_Button_H__c+'\",\"'+o.Font_Decoration_Main__c+'\",\"'+o.Font_Decoration_Navigation_Menu__c+'\",\"'+o.Font_Decoration_Navigation_Menu_H__c+'\",\"'+o.Font_Decoration_Page_Title__c+'\",\"'+o.Font_Decoration_Secondary_Title__c+'\",\"'+o.Font_Decoration_Side_Button__c+'\",\"'+o.Font_Decoration_Side_Button_H__c+'\",\"'+o.Font_Decoration_Side_Header__c+'\",\"'+o.Font_Decoration_Small_Information__c+'\",\"'+o.Font_Decoration_Tab__c+'\",\"'+o.Font_Decoration_Tab_A__c+'\",\"'+o.Font_Decoration_Tab_H__c+'\",\"'+o.Font_Size_Button__c+'\",\"'+o.Font_Size_Button_H__c+'\",\"'+o.Font_Size_Main__c+'\",\"'+o.Font_Size_Navigation_Menu__c+'\",\"'+o.Font_Size_Navigation_Menu_H__c+'\",\"'+o.Font_Size_Page_Title__c+'\",\"'+o.Font_Size_Secondary_Title__c+'\",\"'+o.Font_Size_Side_Button__c+'\",\"'+o.Font_Size_Side_Button_H__c+'\",\"'+o.Font_Size_Side_Header__c+'\",\"'+o.Font_Size_Small_Information__c+'\",\"'+o.Font_Size_Tab__c+'\",\"'+o.Font_Size_Tab_A__c+'\",\"'+o.Font_Size_Tab_H__c+'\",\"'+o.Font_Transform_Button__c+'\",\"'+o.Font_Transform_Button_H__c+'\",\"'+o.Font_Transform_Main__c+'\",\"'+o.Font_Transform_Navigation_Menu__c+'\",\"'+o.Font_Transform_Navigation_Menu_H__c+'\",\"'+o.Font_Transform_Page_Title__c+'\",\"'+o.Font_Transform_Secondary_Title__c+'\",\"'+o.Font_Transform_Side_Button__c+'\",\"'+o.Font_Transform_Side_Button_H__c+'\",\"'+o.Font_Transform_Side_Header__c+'\",\"'+o.Font_Transform_Small_Information__c+'\",\"'+o.Font_Transform_Tab__c+'\",\"'+o.Font_Transform_Tab_A__c+'\",\"'+o.Font_Transform_Tab_H__c+'\",\"'+o.Font_Weight_Button__c+'\",\"'+o.Font_Weight_Button_H__c+'\",\"'+o.Font_Weight_Main__c+'\",\"'+o.Font_Weight_Navigation_Menu__c+'\",\"'+o.Font_Weight_Navigation_Menu_H__c+'\",\"'+o.Font_Weight_Page_Title__c+'\",\"'+o.Font_Weight_Secondary_Title__c+'\",\"'+o.Font_Weight_Side_Button__c+'\",\"'+o.Font_Weight_Side_Button_H__c+'\",\"'+o.Font_Weight_Side_Header__c+'\",\"'+o.Font_Weight_Small_Information__c+'\",\"'+o.Font_Weight_Tab__c+'\",\"'+o.Font_Weight_Tab_A__c+'\",\"'+o.Font_Weight_Tab_H__c+'\",\"'+o.Image_Background__c+'\",\"'+o.Image_Background_Image__c+'\",\"'+o.Image_Background_Position__c+'\",\"'+o.Image_Background_Repeat__c+'\",\"'+o.Image_Body__c+'\",\"'+o.Image_Button__c+'\",\"'+o.Image_Button_H__c+'\",\"'+o.Image_Footer__c+'\",\"'+o.Image_Logo__c+'\",\"'+o.Image_Page_Block_Header__c+'\",\"'+o.Image_Slide1__c+'\",\"'+o.Image_Slide2__c+'\",\"'+o.Image_Slide3__c+'\",\"'+o.LastModifiedById+'\",\"'+o.LastModifiedDate+'\",\"'+o.OwnerId+'\",\"'+o.Position_Footer__c+'\",\"'+o.Position_Page__c+'\",\"'+o.Position_Sidebar__c+'\",\"'+o.Position_Slider__c+'\",\"'+o.Position_Tabs__c+'\",\"'+o.Radius_Button__c+'\",\"'+o.Radius_Page_Block__c+'\",\"'+o.Radius_Side__c+'\",\"'+o.Radius_Side_Button__c+'\",\"'+o.Radius_Side_Module__c+'\",\"'+o.Radius_Tab__c+'\",\"'+o.ConnectionReceivedId+'\",\"'+o.Id+'\",\"'+o.ConnectionSentId+'\",\"'+o.Shadow_Body__c+'\",\"'+o.Shadow_Header__c+'\",\"'+o.Shadow_Page_Block__c+'\",\"'+o.Shadow_Side__c+'\",\"'+o.Shadow_Side_Module__c+'\",\"'+o.Name+'\"';
        return megaStringFieldLabel + megaStringFieldValues;
    }
    
    //Test method
    public static testmethod void testSSEPortalConfiguration() {
        SSEPortalConfiguration controller = new SSEPortalConfiguration(new ApexPages.StandardController(new Org_Template__c()));
        Org_Template__c newTemplate = new Org_Template__c();
        insert newTemplate;
        SSEPortalConfiguration.saveSSEPortalImage('Test', null);
        SSEPortalConfiguration.saveUpdates1(''+newTemplate.id,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','');
        SSEPortalConfiguration.saveUpdates2(''+newTemplate.id,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','');
        SSEPortalConfiguration.saveUpdates3(''+newTemplate.id,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','');
        SSEPortalConfiguration.saveUpdates4(''+newTemplate.id,'','','','','','','','','','','','','','','','','','','','','',true,true,true,true,true,true,true,true,true,'');
        SSEPortalConfiguration.saveUpdates5(''+newTemplate.id,'','','','','','','','','','','',true,true,true,true,true,true,true,true,true,true,'','','','','','','','','');
    }
}