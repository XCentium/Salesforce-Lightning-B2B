global class PSSetCondition implements PSCondition{
    
    private static final PSOperator INCLUDES  = PSOperator.INCLUDES;
    private static final PSOperator EXCLUDES  = PSOperator.EXCLUDES;
    private static final PSOperator INX       = PSOperator.INX;
    private static final PSOperator NOT_IN    = PSOperator.NOT_IN;

    global String       field    {get; private set;}
    global PSOperator     operator {get; private set;}
    global List<Object> values   {get; private set;}
    global PSSoqlBuilder  builder  {get; private set;}
    
    global PSSetCondition(){}
    
    global PSSetCondition(String field){
        this.field(field);
    }
    
    global PSSetCondition(String field, PSOperator operator, List<Object> values){
        this.field(field);
        this.setOperation(operator,values);
    }
    
    global PSSetCondition(String field, PSOperator operator, PSSoqlBuilder builder){
        this.field(field);
        this.setOperation(operator,builder);
    }
    
    global PSSetCondition field(String field){
        if(PSLangUtils.isBlank(field)){
            throw new PSIllegalArgumentException('illegal argument:  field is empty');
        }
        this.field = PSLangUtils.trim(field);
    	return this;
    }
    
    global PSSetCondition includes(List<Object> values){ return setOperation(INCLUDES,values); }
    global PSSetCondition excludes(List<Object> values){ return setOperation(EXCLUDES,values); }
    global PSSetCondition inx     (List<Object> values){ return setOperation(INX,     values); }
    global PSSetCondition notIn   (List<Object> values){ return setOperation(NOT_IN,  values); }

    global PSSetCondition includes(PSSoqlBuilder builder){ return setOperation(INCLUDES,builder); }
    global PSSetCondition excludes(PSSoqlBuilder builder){ return setOperation(EXCLUDES,builder); }
    global PSSetCondition inx     (PSSoqlBuilder builder){ return setOperation(INX,     builder); }
    global PSSetCondition notIn   (PSSoqlBuilder builder){ return setOperation(NOT_IN,  builder); }

    private PSSetCondition setOperation(PSOperator operator, List<Object> values){
        if(values == null || values.size() <= 0){
            throw new PSIllegalArgumentException('illegal argument:  values is empty');
        }
        this.values = values;
        return setOperator(operator);
    }

    private PSSetCondition setOperation(PSOperator operator, PSSoqlBuilder builder){
        if(builder == null){
            throw new PSIllegalArgumentException('illegal argument:  builder is null');
        }
        this.builder = builder;
        return setOperator(operator);
    }
    
    private PSSetCondition setOperator(PSOperator operator){
        if(operatorToString(operator) == null){
            throw new PSIllegalArgumentException('illegal operator: ' + operator);
        }
        this.operator = operator;
        return this;
    }

    global String toSoql(){ return this.toSoql(null); }
    
    global String toSoql(PSSoqlOptions options){
        if(options == null){
            options = PSSoqlOptions.DEFAULT_OPTIONS;
        }
        if(this.operator== null){
        	throw new PSIllegalStateException(
        	   'Illegal state!  One of the following operations must be invoked on SetCondition prior to invoke toSoql(): (includes|excludes|inn|notIn)');
        }
        return field 
            + ' ' 
            + operatorToString(operator) 
            + ' (' 
            + (builder == null ? PSLangUtils.joinArray(PSSoqlUtils.toLiteral(this.values),',') : builder.toSoql(options)) 
            + ')'; 
    }

    global static String operatorToString(PSOperator operator){
        String returnValue = null;
        if(operator == INCLUDES){ returnValue = 'INCLUDES'; }       
        else if(operator == EXCLUDES){ returnValue = 'EXCLUDES'; }       
        else if(operator == INX){ returnValue = 'IN'; }       
        else if(operator == NOT_IN){ returnValue = 'NOT IN'; }       
        return returnValue;
    }

}