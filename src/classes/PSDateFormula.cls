global class PSDateFormula implements PSSoqlable{

    private String literal = null;
    
    global String toSoql(){ return this.toSoql(PSSoqlOptions.DEFAULT_OPTIONS); }
    
    global String toSoql(final PSSoqlOptions options){
    	if(PSLangUtils.isBlank(literal)){
    		throw new PSIllegalStateException();
    	}
    	return literal;
    }

    global PSDateFormula yesterdayx(){ this.literal = 'YESTERDAY'; return this;}
    global PSDateFormula todayx(){     this.literal = 'TODAY'; return this;}
    global PSDateFormula tomorrowx(){  this.literal = 'TOMORROW'; return this;}
    global PSDateFormula thisx(PSUnitOfTime unit){
    	if(unit == PSUnitOfTime.Day){
    		return todayx();
    	} 
    	this.literal = 'THIS_' + unitToLabel(unit); 
    	return this;
    }

    global PSDateFormula last90Days(){ return last(90,PSUnitOfTime.Day); }
    global PSDateFormula next90Days(){ return next(90,PSUnitOfTime.Day); }

    global PSDateFormula last(PSUnitOfTime unit){ return last(1,unit); }
    global PSDateFormula next(PSUnitOfTime unit){ return next(1,unit); }
    
    global PSDateFormula last(Integer n, PSUnitOfTime unit){ this.literal = 'LAST_' + toUnitAndAmount(n,unit); return this;}
    global PSDateFormula next(Integer n, PSUnitOfTime unit){ this.literal = 'NEXT_' + toUnitAndAmount(n,unit); return this;}
    
    private String toUnitAndAmount(Integer n, PSUnitOfTime unit){
    	String unitAndAmount = '';
    	if(n < 0){
            throw new PSIllegalArgumentException('n cannot be negative');
    	} else if(n == 90 && unit == PSUnitOfTime.Day){
        	unitAndAmount += '90_' + unitToLabel(PSUnitOfTime.Day) + 'S'; 
        } else if(n == 1 && unit != PSUnitOfTime.Day){
            unitAndAmount += unitToLabel(unit);
        } else if(unit == PSUnitOfTime.Week || unit == PSUnitOfTime.Month){
        	throw new PSIllegalArgumentException('N_WEEKS and N_MONTHS are not supported');
        } else {
            unitAndAmount += 'N_' + unitToLabel(unit) + 'S:' + n;
        }
        return unitAndAmount;
    }
    
    private static String unitToLabel(PSUnitOfTime unit){
    	String label = '';
        if(     unit == PSUnitOfTime.Day){           label = 'DAY';            }
        else if(unit == PSUnitOfTime.Week){          label = 'WEEK';           }
        else if(unit == PSUnitOfTime.Month){         label = 'MONTH';         }
        else if(unit == PSUnitOfTime.Quarter){       label = 'QUARTER';        } 
        else if(unit == PSUnitOfTime.FiscalQuarter){ label = 'FISCAL_QUARTER'; }
        else if(unit == PSUnitOfTime.Year){          label = 'YEAR';           }
        else if(unit == PSUnitOfTime.FiscalYear){    label = 'FISCAL_YEAR';    }  
        return label;
    }
    

}