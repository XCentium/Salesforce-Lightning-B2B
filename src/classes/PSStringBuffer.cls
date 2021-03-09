global class PSStringBuffer {

    private String theString;
    
    global PSStringBuffer(){
        this('');
    }
    
    global PSStringBuffer(String str){
        theString = str;
    }

    global PSStringBuffer(Decimal d){
        theString = '' + d;
    }
    
    global PSStringBuffer(Double d){
        theString = '' + d;
    }
    
    global PSStringBuffer(Long l){
        theString = '' + l;
    }
    
    global PSStringBuffer(Integer i){
        theString = '' + i;
    }
    
    global PSStringBuffer(Blob b){
        theString = '' + b;
    }
    
    global PSStringBuffer(Boolean b){
        theString = '' + b;
    }
    
    global PSStringBuffer(Date d){
        theString = '' + d;
    }
    
    global PSStringBuffer(Datetime d){
        theString = '' + d;
    }
    
    global PSStringBuffer(ID id){
        theString = '' + id;
    }
    
    global PSStringBuffer(Time t){
        theString = '' + t;
    }

    global PSStringBuffer append(String str){
        theString += str; return this;    
    }

    global PSStringBuffer append(Decimal d){
        theString += d;    return this;
    }
    
    global PSStringBuffer append(Double d){
        theString += d;    return this;
    }
    
    global PSStringBuffer append(Long l){
        theString += l;    return this;
    }
    
    global PSStringBuffer append(Integer i){
        theString += i;    return this;
    }
    
    global PSStringBuffer append(Blob b){
        theString += b;    return this;
    }
    
    global PSStringBuffer append(Boolean b){
        theString += b;    return this;
    }
    
    global PSStringBuffer append(Date d){
        theString += d;    return this;
    }
    
    global PSStringBuffer append(Datetime d){
        theString += d;    return this;
    }
    
    global PSStringBuffer append(ID id){
        theString += id; return this;
    }
    
    global PSStringBuffer append(Time t){
        theString += t;    return this;
    }

    global String toStr(){
        return theString;
    }
}