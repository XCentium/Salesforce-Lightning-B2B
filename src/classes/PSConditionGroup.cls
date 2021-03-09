global abstract class PSConditionGroup implements PSNestableCondition{
    
    global List<PSCondition> conditions {get;private set;}
    
    private String separator {get;set;} 
    
    public PSConditionGroup(String separator){
        this.separator = separator;
        this.conditions = new List<PSCondition>();
    }
    
    global PSNestableCondition add(PSCondition c){
        if(c != null){
            this.conditions.add(c);
        }
        return this;
    }
    
    global String toSoql(){ return this.toSoql(null); }
    
    global String toSoql(PSSoqlOptions options){
    	if(options == null){
    		options = PSSoqlOptions.DEFAULT_OPTIONS;
    	}
        String soql = '';
        if(conditions.size() == 1){
            return conditions.get(0).toSoql(options);
        } else if(conditions.size() > 1){
        	Boolean hasOpenParenBeenAdded = false;
        	String additionalSoql = null;
        	for(PSCondition condition : conditions){
        		additionalSoql = condition.toSoql(options);
        		if(PSLangUtils.isBlank(additionalSoql)){
        			continue;
        		}
        		if(hasOpenParenBeenAdded){
                    soql += ' ' + separator + ' ';
        		} else {
                    soql = '(';
                    hasOpenParenBeenAdded = true;
        		}
                soql += additionalSoql;
        	}
            if(hasOpenParenBeenAdded){
                soql += ')';
            }
        }
        return soql;
    }
    
}