public class SDO_QuotaEdit{
    public string pod {get;set;}
    public string chrisy {get;set;}
    
    public SDO_QuotaEdit(){
        String ss_Pod = URL.getSalesforceBaseUrl().getHost();
        Integer idx = ss_Pod.indexOf('.', 0);
        if(idx != -1) { pod = ss_Pod.subString(0,idx); }
        chrisy='https://editquotas.'+pod+'.visual.force.com/apex/QuotaEdit?isdtp=vw';
    } 
}