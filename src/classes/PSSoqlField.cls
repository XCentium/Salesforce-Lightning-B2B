global class PSSoqlField implements PSSoqlable{

    private String name;
    private Boolean toLabelx;
    
    global PSSoqlField(String name){
        this.name = name;
        this.toLabelx = false;
    }

    global PSSoqlField toLabelx(){
        this.toLabelx = true;
        return this;
    }

    global String toSoql(){ return this.toSoql(null); }
    
    global String toSoql(PSSoqlOptions options){
        if(options == null){
            options = PSSoqlOptions.DEFAULT_OPTIONS;
        }
    	return (toLabelx ? 'toLabel(' : '') + name + (toLabelx ? ')' : '');
    }
    
}