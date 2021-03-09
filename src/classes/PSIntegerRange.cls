global class PSIntegerRange {

    private Integer min;
    private Integer max;
    
    global PSIntegerRange(Integer number1){
    	if(number1 == null){
    		throw new PSIllegalArgumentException('illegal argument: null number');
    	}
        min = max = number1;
    } 
    global PSIntegerRange(Integer number1, Integer number2){
        if(number1 == null || number2 == null){
            throw new PSIllegalArgumentException('illegal argument: null number');
        }
        if(number1 < number2){
            min = number1;
            max = number2;    
        } else {
            min = number2;
            max = number1;    
        }
    }
    
    global Integer max(){ return max; }
    global Integer min(){ return min;}
    global String toAString(){ return '[' + min + ',' + max + ']'; }
    global Boolean contains(Integer value){ return min <= value && value <= max; }
    global Boolean contains(PSIntegerRange value){ return min <= value.min() && value.max() <= max; }
    global Boolean overlaps(PSIntegerRange value){ return min <= value.max() && value.min() <= max; }

}