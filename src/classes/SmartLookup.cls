public class SmartLookup {
	
	public Integer columnNumber {get; set; }
    public String SObjectType {get; set; }
    public String targetField {get; set; }
    public Set<String> plainTextValues {get; set; }
    public Map<String, String> replaceValues {get; set; }

    public SmartLookup(){
        this.plainTextValues = new Set<String>();
        this.replaceValues = new Map<String, String>();
    }
    
    public SmartLookup (Integer colNum, String objType) {
        this.columnNumber = colNum;
        this.SObjectType = objType;
        this.plainTextValues = new Set<String>();
        this.replaceValues = new Map<String, String>();
    }
}