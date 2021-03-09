global class PSDecimalRange{

    private Decimal min;
    private Decimal max;
    
    global PSDecimalRange(Decimal number1){
        if(number1 == null){
            throw new PSIllegalArgumentException('illegal argument: null number');
        }
        min = max = number1;
    } 
    global PSDecimalRange(Decimal number1, Decimal number2){
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
    
    global Decimal max(){ return max; }
    global Decimal min(){ return min;}
    global String toAString(){ return '[' + min + ',' + max + ']'; }
    global Boolean contains(Decimal value){ return min <= value && value <= max; }
    global Boolean contains(PSDecimalRange value){ return min <= value.min() && value.max() <= max; }
    global Boolean overlaps(PSDecimalRange value){ return min <= value.max() && value.min() <= max; }

}