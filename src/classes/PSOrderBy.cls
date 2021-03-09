global class PSOrderBy implements PSSoqlable{

    global String field {get;set;}
    global Boolean ascending {get;set;}
    global Boolean descending {get{return !ascending;}}
    global Boolean nullsFirst {get;set;}
    global Boolean nullsLast {get{return !nullsFirst;}}
    private Boolean sortSet = false;
    private Boolean nullsSet = false;
	
    global PSOrderBy(String field){
        if(PSLangUtils.isBlank(field)){
        	throw new PSIllegalArgumentException('field is empty');
        }
        this.field = field;
        this.ascending();
        this.sortSet = false;
    }
    
    global PSOrderBy ascending (){ return setAscending(true); }
    global PSOrderBy descending(){ return setAscending(false);}
    global PSOrderBy nullsFirst(){ return setNullsFirst(true);}
    global PSOrderBy nullsLast (){ return setNullsFirst(false);}
    
    private PSOrderBy setAscending(Boolean ascending){
        this.ascending = ascending;
        this.sortSet = true;
        if(!this.nullsSet){
        	this.nullsFirst = this.descending;
        }
        return this;
    }
    
    private PSOrderBy setNullsFirst(Boolean nullsFirst){
        this.nullsFirst = nullsFirst;
        this.nullsSet = true;
        return this;
    }

    global String toSoql(){ return this.toSoql(null); }
    
    global String toSoql(PSSoqlOptions options){
        if(options == null){
            options = PSSoqlOptions.DEFAULT_OPTIONS;
        }
        return this.field 
           + (sortSet ? (ascending ? ' ASC' : ' DESC'): '')
           + (nullsSet ? (nullsFirst ? ' NULLS FIRST' : ' NULLS LAST') : '')
        ;
    }
    

}