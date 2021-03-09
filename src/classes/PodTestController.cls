public with sharing class PodTestController {
    public String ss_Pod {get;set;}
    public String ff_Pod {get;set;}
    
    public PodTestController() {
        ss_Pod = URL.getSalesforceBaseUrl().getHost();
        Integer idx = ss_Pod.indexOf('.', 0);
        if(idx != -1) { ss_Pod = ss_Pod.subString(0,idx); }
        
        try {
            String referer = ApexPages.currentPage().getHeaders().get('Referer');
            ff_pod = referer.substring(8, 11);
        } catch(Exception e) {
            ff_pod = e.getMessage();
        }
    }
}