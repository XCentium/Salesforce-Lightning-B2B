public with sharing class SDO_LoginAs {

    public String n {get;set;}
    
    public PageReference loginStringServiceAgent() {
        n =  ApexPages.currentPage().getParameters().get('name');
        User u = [Select ID, UserName From User Where Name =: n Limit 1];        
        String loginString = 'https://login.salesforce.com';
        String pwd = 'salesforce1';
        if(u != null) { 
            loginString += '?un=' + u.UserName;
            loginString += '&pw=' + pwd;
        }      
        return new PageReference(loginString);
    }
    
    /*
    public String getloginStringServiceAgentStr() {
        User u = [Select ID, UserName From User Where Name = 'Tim Service*' Limit 1];        
        String loginString = 'http://login.salesforce.com';
        String pwd = 'salesforce1';
        if(u != null) { 
            loginString += '?un=' + u.UserName;
            loginString += '&pw=' + pwd;
        }      
        return loginString;
    }
    */
}