global class PSSoqlOptions {

    global static PSSoqlOptions DEFAULT_OPTIONS = new PSSoqlOptions();
     
    global Boolean escapeSingleQuotes {get;set;}
    global Boolean wildcardStringsInLikeOperators {get;set;}
	
    global PSSoqlOptions(){
    	escapeSingleQuotes();
    	doNotWildcardStringsInLikeOperators();
    }
    
    global PSSoqlOptions wildcardStringsInLikeOperators(){
        this.wildcardStringsInLikeOperators = true;
        return this;
    }
    
    global PSSoqlOptions doNotWildcardStringsInLikeOperators(){
        this.wildcardStringsInLikeOperators = false;
        return this;
    }
    
    global PSSoqlOptions escapeSingleQuotes(){
        this.escapeSingleQuotes = true;
        return this;
    }
    
    global PSSoqlOptions doNotEscapeSingleQuotes(){
        this.escapeSingleQuotes = false;
        return this;
    }
    
}