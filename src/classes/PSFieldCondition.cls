global class PSFieldCondition implements PSCondition{
    
    private static final PSOperator EQUALS                    = PSOperator.EQUALS;
    private static final PSOperator NOT_EQUALS                = PSOperator.NOT_EQUALS;
    private static final PSOperator LESS_THAN                 = PSOperator.LESS_THAN;
    private static final PSOperator LESS_THAN_OR_EQUAL_TO     = PSOperator.LESS_THAN_OR_EQUAL_TO;
    private static final PSOperator GREATER_THAN              = PSOperator.GREATER_THAN;
    private static final PSOperator GREATER_THAN_OR_EQUAL_TO  = PSOperator.GREATER_THAN_OR_EQUAL_TO;
    private static final PSOperator LIKEX                     = PSOperator.LIKEX;
    private static final PSOperator INX                       = PSOperator.INX;
    private static final PSOperator NOT_IN                    = PSOperator.NOT_IN;

    private static final PSOperator DEFAULT_OPERATOR        = EQUALS;
    
    global String   field       { get; private set; }
    global PSOperator operator  { get; private set; }
    global Object   value       { get; private set; }
    
    global PSFieldCondition(){}    
    
    global PSFieldCondition(String field){
        this.field(field);
    }
    
    global PSFieldCondition(String field, Object value){
        this(field, DEFAULT_OPERATOR, value);
    }
    
    global PSFieldCondition(String field, PSOperator operator, Object value){
        this.field(field);
        if(operator!= null){
            this.setOperation(operator,value);
        }
    }

    global PSFieldCondition field(String field){
    	if(PSLangUtils.isBlank(field)){
    		throw new PSIllegalArgumentException('illegal argument:  field is empty');
    	}
        this.field = PSLangUtils.trim(field);
        return this;
    }
 
    global PSFieldCondition equals              (Object value){ return setOperation(EQUALS                  ,value); }
    global PSFieldCondition notEquals           (Object value){ return setOperation(NOT_EQUALS              ,value); }
    global PSFieldCondition lessThan            (Object value){ return setOperation(LESS_THAN               ,value); }
    global PSFieldCondition lessThanOrEqualTo   (Object value){ return setOperation(LESS_THAN_OR_EQUAL_TO   ,value); }
    global PSFieldCondition greaterThan         (Object value){ return setOperation(GREATER_THAN            ,value); }
    global PSFieldCondition greaterThanOrEqualTo(Object value){ return setOperation(GREATER_THAN_OR_EQUAL_TO,value); }
    global PSFieldCondition likex               (Object value){ return setOperation(LIKEX                   ,value); }
    global PSFieldCondition inx                 (Object value){ return setOperation(INX                     ,value); }
    global PSFieldCondition notIn               (Object value){ return setOperation(NOT_IN                  ,value); }
    
    private PSFieldCondition setOperation(PSOperator operator, Object value){
        if( operatorToString(operator) == null){
            throw new PSIllegalArgumentException('illegal operator: ' + operator);
        }
        this.operator = operator;
        this.value = value;
        return this;
    }

    global String toSoql(){ return this.toSoql(null); }
    
    global String toSoql(PSSoqlOptions options){
    	if(options == null){
    		options = PSSoqlOptions.DEFAULT_OPTIONS;
    	}
    	Object manipulated = value;
    	if(    manipulated != null 
    	       && manipulated instanceof String 
               && operator == LIKEX
    	       && options.wildcardStringsInLikeOperators){ 
            manipulated = PSLangUtils.ensureStringStartsEndsWithChar( ((String)manipulated),'%');
    	}
    	return field + ' ' + operatorToString(operator) + ' ' + PSSoqlUtils.toLiteral(manipulated,options);
    }
    
    global static String operatorToString(PSOperator op){
    	String returnValue = null;
        if(     op == EQUALS)                   { returnValue = '='; }       
        else if(op == NOT_EQUALS)               { returnValue = '!='; }       
        else if(op == LESS_THAN)                { returnValue = '<'; }       
        else if(op == LESS_THAN_OR_EQUAL_TO)    { returnValue = '<='; }       
        else if(op == GREATER_THAN)             { returnValue = '>'; }       
        else if(op == GREATER_THAN_OR_EQUAL_TO) { returnValue = '>='; }       
        else if(op == LIKEX)                    { returnValue = 'like'; }
        else if(op == INX)                    	{ returnValue = 'IN'; }
        else if(op == NOT_IN)                   { returnValue = 'NOT IN'; }

        return returnValue;
    }
    
}