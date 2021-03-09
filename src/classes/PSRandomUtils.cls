global class PSRandomUtils {
	
	private static final PSIntegerRange BINARY_RANGE = new PSIntegerRange(0,1);
	
    global static Boolean nextBoolean(){
        return nextInteger(BINARY_RANGE,true) == 1;
    }

    global static Integer nextInteger(){
        return nextInteger(PSLangUtils.MAX_INTEGER_RANGE,true);
    }

    global static Integer nextInteger(Integer max){
        return nextInteger(new PSIntegerRange(0,Math.abs(max)),true);
    }
    
    global static Integer nextInteger(Integer max, Boolean inclusive){
        return nextInteger(new PSIntegerRange(0,Math.abs(max)),inclusive);
    }
    
    global static Integer nextInteger(Integer min, Integer max){
        return nextInteger(new PSIntegerRange(min,max),true);
    }

    global static Integer nextInteger(Integer min, Integer max, Boolean inclusive){
        return nextInteger(new PSIntegerRange(min,max),inclusive);
    }

    global static Integer nextInteger(PSIntegerRange range){
        return nextInteger(range,true);
    }
    
    global static Integer nextInteger(PSIntegerRange range, Boolean inclusive){
        if(range == null){
            return null;
        }
        if(inclusive && (range.max() - range.min()) <= 0){
            return range.min();
        }
        if(!inclusive && (range.max() - range.min()) <= 2){
            return range.min();
        }
        return (Integer) (
            Math.round(
                Math.floor(
                    Math.random()
                    * ((range.max()-range.min()+(inclusive ? 1 : -1)))
                )
            ) 
            + range.min()
            + (inclusive ? 0 : 1)
        );
    }
    
    global static Long nextLong(){
        return nextLong(PSLangUtils.MAX_LONG_RANGE,true);
    }

    global static Long nextLong(Long max){
        return nextLong(new PSLongRange(0,Math.abs(max)),true);
    }
    
    global static Long nextLong(Long max, Boolean inclusive){
        return nextLong(new PSLongRange(0,Math.abs(max)),inclusive);
    }
    
    global static Long nextLong(Long min, Long max){
        return nextLong(new PSLongRange(min,max),true);
    }

    global static Long nextLong(Long min, Long max, Boolean inclusive){
        return nextLong(new PSLongRange(min,max),inclusive);
    }

    global static Long nextLong(PSLongRange range){
        return nextLong(range,true);
    }
    
    global static Long nextLong(PSLongRange range, Boolean inclusive){
        if(range == null){
            return null;
        }
        if(inclusive && (range.max() - range.min()) <= 0){
            return range.min();
        }
        if(!inclusive && (range.max() - range.min()) <= 2){
            return range.min();
        }
        return 
            Math.round(
                Math.floor(
                    Math.random()
                    * ((range.max()-range.min()+(inclusive ? 1 : -1)))
                )
            ) 
            + range.min()
            + (inclusive ? 0 : 1);
    }
    
    
}