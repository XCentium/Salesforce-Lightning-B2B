public class CompositeSmartLookup {
    
    public String SObjectType {get; set; } // Destination object from which we will retrieve the Id
    public String LookupFieldName {get; set; } // Field name in source object that will contain the lookup Id
    public List<String> TargetFields {get; set; } // List of field names that make the composite key used to lookup in destination object
    public List<Integer> TargetFieldsIndexes {get; set; } // List of indexes of fields (in CSV row) that make the composite key used to lookup in destination object
    public Map<String, Set<String>> TargetFieldsValues {get; set; } // Map of <String, Set<String>>. Key: Field name that make the composite key, Value: Set of all field values in CSV batch 
    public List<String> RetrievedIds {get; set; } // List of Ids retrieved from destination object, item 0 in list corresponds to row 0 in batch and so on

    public CompositeSmartLookup() {
        this.TargetFields = new List<String>();
        this.TargetFieldsIndexes = new List<Integer>();        
        this.TargetFieldsValues = new Map<String, Set<String>>();
        this.RetrievedIds = new List<String>();
    }
}