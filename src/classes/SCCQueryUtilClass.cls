/**
* Query utilization class
*
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-06
*/
public with sharing class SCCQueryUtilClass {

	// specified fields that are used in query selection
	private Set<String> queryFieldsSet;
	// specified filtering the records(where conditions)
	private String whereClause;
	// specified ordering the records(order by condition)
	private String orderByClause;
	// specified limiting the records(limit size)
	private String limitClause;
	// specified object api name that refers to records
	private String objectName;

    /**
    * Constructor of the class.
    * @return None.
    */
    public SCCQueryUtilClass() {

        this.whereClause     = '';
        this.orderByClause   = '';
        this.limitClause     = '';
        this.objectName      = '';

    }

    /**
	* This method used for taking new instnace of the class.
	* @return SCCQueryUtilClass.
	*/
    public static SCCQueryUtilClass getInstance() {

        return new SCCQueryUtilClass();

    }

    /**
	* This method used for setting the object type for query.
	* @param objectName: String.
	* @return SCCQueryUtilClass.
	*/
    public SCCQueryUtilClass setObjectName(String objectApi) {

        this.objectName = objectApi;
        return this;

    }

    /**
	* This method used for creating new instance for fields set to set up query.
	* @return SCCQueryUtilClass.
	*/
    public SCCQueryUtilClass getQueryInstance() {

        this.queryFieldsSet = new Set<String>();
        return this;

    }

    /**
	* This method used for setting up all fields of related object type.
	* @return SCCQueryUtilClass.
	*/
    public SCCQueryUtilClass setAllFields(){

        Map<String, Schema.SObjectField> fieldMap = this.getDescribeSObjectResult().fields.getMap();
        for(String s : fieldMap.keySet()) {
            if(!this.queryFieldsSet.contains(s.toLowerCase())) {
                this.queryFieldsSet.add(s.toLowerCase());
            }
        }
        return this;

    }

    /**
	* This method used for setting up related fields of related object type.
	* @param fieldSet: Set<String>.
	* @return SCCQueryUtilClass.
	*/
    public SCCQueryUtilClass setRelatedFields(Set<String> fieldSet) {

        this.queryFieldsSet = fieldSet;
        return this;

    }

    /**
	* This method used for setting up fieldset fields of related object type.
	* @param fieldSetName: String.
	* @return SCCQueryUtilClass.
	*/
    //public SCCQueryUtilClass setFieldSet(String fieldSetName) {
    //    List<Schema.FieldSetMember> fields = this.getDescribeSObjectResult().fieldSets.getMap().get(fieldSetName).getFields();
    //    for(Schema.FieldSetMember s : fields) {
    //        if(!this.queryFieldsSet.contains(s.getFieldPath().toLowerCase())) {
    //            this.queryFieldsSet.add(s.getFieldPath().toLowerCase());
    //        }
    //    }
    //    return this;
    //}

    /**
	* This method used for getting Schema.DescribeSObjectResult to get proporties of related object type.
	* @return Schema.DescribeSObjectResult.
	*/
    public Schema.DescribeSObjectResult getDescribeSObjectResult() {

        return Schema.getGlobalDescribe().get(this.objectName).getDescribe();

    }

    /**
	* This method used for setting up where clause condition of query.
	* @param clause: String
	* @return SCCQueryUtilClass.
	*/
    public SCCQueryUtilClass setClause(String clause) {

        this.whereClause = 'where ' + clause;
        return this;

    }

    /**
	* This method used for setting up where clause condition of query.
	* @param clause: String
	* @return SCCQueryUtilClass.
	*/
	public SCCQueryUtilClass setClause(String fieldApi, String operator, String condition) {

		if(!condition.contains('null')) {
			if(!this.whereClause.contains('where')) {
				this.whereClause = 'where ';
			}
			this.whereClause += fieldApi + ' ' + operator + ' ' + condition;
		}
        
		return this;

	}

    /**
	* This method used for setting up order by clause condition of query.
	* @param orderBy: String
	* @return SCCQueryUtilClass.
	*/
    public SCCQueryUtilClass setOrderBy(String orderBy) {

        this.orderByClause = 'order by ' + orderBy;
        return this;

    }

    /**
	* This method used for setting up limit clause condition of query.
	* @param limitStr: String
	* @return SCCQueryUtilClass.
	*/
    public SCCQueryUtilClass setLimit(String limitStr) {

        this.limitClause = 'limit ' + limitStr;
        return this;

    }

    /**
	* This method used for getting main query to select records.
	* @return String.
	*/
    public String getQuery() {

        List<String> queryFieldsList = new List<String>();
        queryFieldsList.addAll(this.queryFieldsSet);
        return 'select ' + String.join(queryFieldsList, ',') + ' from ' + this.objectName + ' ' + this.whereClause + ' ' + this.orderByClause + ' ' + this.limitClause;

    }

    /**
	* This method used for getting all records as sobject type.
	* @param query: String.
	* @return List<SObject>.
	*/
    public static List<SObject> getRecords(String query) {

        return Database.query(query);

    }

}