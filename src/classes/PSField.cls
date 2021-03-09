public class PSField  
{
    public static final String TYPE_ADDRESS = 'address';
    public static final String TYPE_BOOLEAN = 'boolean';
    public static final String TYPE_CURRENCY = 'currency';
    public static final String TYPE_DATE = 'date';
    public static final String TYPE_DATETIME = 'datetime';
    public static final String TYPE_DOUBLE = 'double';
    public static final String TYPE_EMAIL = 'email';
    public static final String TYPE_LOCATION = 'location';
    public static final String TYPE_MULTIPICKLIST = 'multipicklist';
    public static final String TYPE_PERCENT = 'percent';
    public static final String TYPE_PICKLIST = 'picklist';
    public static final String TYPE_PHONE = 'phone';
    public static final String TYPE_REFERENCE = 'reference';
    public static final String TYPE_STRING = 'string';
    public static final String TYPE_TEXTAREA = 'textarea';
    public static final String TYPE_URL = 'url';
    public static final String TYPE_UNKNOWN = 'unknown';
    
    public PSField() 
    {
        ftype = TYPE_UNKNOWN;
        name = null;
        label = null;
        value = null;
        referenceTo = null;
        relationshipName = null;
        options = new List<PicklistOption>();
        wildcard = false;
        configOptions = new Map<String, String>();
    }
    
    public String ftype {get; set;}
    public String label {get; set;}
    public String name {get; set;}
    public String value {get; set;}
    public String referenceTo {get; set;}
    public String relationshipName {get; set;}
    public List<PicklistOption> options {get; set;}
    public Boolean wildcard {get; set;}
    public Map<String, String> configOptions {get; set;}
    
    public void addOption(String label, String value)
    {
        if (options == null) options = new List<PicklistOption>();
        options.add(new PicklistOption(label, value));
    }
    
    public void addConfigOption(String name, String value)
    {
        if (configOptions == null) configOptions = new Map<String, String>();
        configOptions.put(name, value);
    }
    
    public void setConfigOptions(Map<String, String> config)
    {
        if (configOptions == null) configOptions = new Map<String, String>();
        configOptions = config;
    }
    
    public class PicklistOption 
    {
        String label {get; set;}
        String value {get; set;}
        
        public PicklistOption(String l, String v)
        {
            label = l;
            value = v;
        }
    }
}