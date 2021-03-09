global class PSNotCondition implements PSNestableCondition{
    
    global PSCondition condition {get;private set;}
    
    private String PSNotCondition {get;set;} 
    
    global PSNotCondition(){
        this(null);
    }
    
    global PSNotCondition(PSCondition c){
        add(c);
    }
    
    global PSNestableCondition add(PSCondition c){
    	this.condition = c;
        return this;
    }
    
    global String toSoql(){ return this.toSoql(null); }
    
    global String toSoql(PSSoqlOptions options){
        if(options == null){
            options = PSSoqlOptions.DEFAULT_OPTIONS;
        }
        String soql = '';
        if(condition != null){
        	soql += 'NOT(' + condition.toSoql(options) + ')';
        }
        return soql;
    }
    
}