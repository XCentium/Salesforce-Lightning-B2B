public class PSSoqlBuilderHelper
{


public static PSOperator convertStringToFieldOperator(String s) {
    
    if(s == 'EQUALS') return PSOperator.EQUALS;
    if(s == 'NOT_EQUALS') return PSOperator.NOT_EQUALS;
    if(s == 'LESS_THAN') return PSOperator.LESS_THAN;
    if(s == 'LESS_THAN_OR_EQUAL_TO') return PSOperator.LESS_THAN_OR_EQUAL_TO;
    if(s == 'GREATER_THAN') return PSOperator.GREATER_THAN;
    if(s == 'GREATER_THAN_OR_EQUAL_TO') return PSOperator.GREATER_THAN_OR_EQUAL_TO;
    
    /* Not using at the moment
    if(s == 'LIKEX') return PSOperator.LIKEX;
    if(s == 'INCLUDES') return PSOperator.INCLUDES;
    if(s == 'EXCLUDES') return PSOperator.EXCLUDES;
    if(s == 'INX') return PSOperator.INX;
    if(s == 'NOT_IN') return PSOperator.NOT_IN;
    */
    return null;
    
}

public static PSUnitOfTime convertStringToUnitOfTime(String s) {
    
    if(s == 'Today') return PSUnitOfTime.Day;
    if(s == 'This Week') return PSUnitOfTime.Week;
    if(s == 'This Month') return PSUnitOfTime.Month;
    if(s == 'This (Calendar) Quarter') return PSUnitOfTime.Quarter;
    if(s == 'This (Calendar) Year') return PSUnitOfTime.Year;

    return null;
    
}


public static PSDateFormula convertStringToPSDateFormula(String s) {
    
    if(s == 'Today') return new PSDateFormula().thisx(PSUnitOfTime.Day);
    if(s == 'This Week') return new PSDateFormula().thisx(PSUnitOfTime.Week);
    if(s == 'This Month') return new PSDateFormula().thisx(PSUnitOfTime.Month); 
    if(s == 'This (Calendar) Quarter') return new PSDateFormula().thisx(PSUnitOfTime.Quarter);
    if(s == 'This (Calendar) Year') return new PSDateFormula().thisx(PSUnitOfTime.Year);
    if(s == 'This (Fiscal) Quarter') return new PSDateFormula().thisx(PSUnitOfTime.FiscalQuarter);
    if(s == 'This (Fiscal) Year') return new PSDateFormula().thisx(PSUnitOfTime.FiscalYear);

    if(s == 'Yesterday') return new PSDateFormula().last(PSUnitOfTime.Day);
    if(s == 'Last Week') return new PSDateFormula().last(PSUnitOfTime.Week);
    if(s == 'Last Month') return new PSDateFormula().last(PSUnitOfTime.Month);
    if(s == 'Last (Calendar) Quarter') return new PSDateFormula().last(PSUnitOfTime.Quarter);
    if(s == 'Last (Calendar) Year') return new PSDateFormula().last(PSUnitOfTime.Year);
    if(s == 'Last (Fiscal) Quarter') return new PSDateFormula().last(PSUnitOfTime.FiscalQuarter);
    if(s == 'Last (Fiscal) Year') return new PSDateFormula().last(PSUnitOfTime.FiscalYear);

    if(s == 'TODAY') return new PSDateFormula().thisx(PSUnitOfTime.Day);
    if(s == 'THIS_WEEK') return new PSDateFormula().thisx(PSUnitOfTime.Week);
    if(s == 'THIS_MONTH') return new PSDateFormula().thisx(PSUnitOfTime.Month); 
    if(s == 'THIS_QUARTER') return new PSDateFormula().thisx(PSUnitOfTime.Quarter);
    if(s == 'THIS_YEAR') return new PSDateFormula().thisx(PSUnitOfTime.Year);
    if(s == 'THIS_FISCAL_QUARTER') return new PSDateFormula().thisx(PSUnitOfTime.FiscalQuarter);
    if(s == 'THIS_FISCAL_YEAR') return new PSDateFormula().thisx(PSUnitOfTime.FiscalYear);
    if(s == 'YESTERDAY') return new PSDateFormula().last(PSUnitOfTime.Day);
    if(s == 'LAST_WEEK') return new PSDateFormula().last(PSUnitOfTime.Week);
    if(s == 'LAST_MONTH') return new PSDateFormula().last(PSUnitOfTime.Month);
    if(s == 'LAST_90_DAYS') return new PSDateFormula().last90Days();
    if(s == 'LAST_QUARTER') return new PSDateFormula().last(PSUnitOfTime.Quarter);
    if(s == 'LAST_YEAR') return new PSDateFormula().last(PSUnitOfTime.Year);
    if(s == 'LAST_FISCAL_QUARTER') return new PSDateFormula().last(PSUnitOfTime.FiscalQuarter);
    if(s == 'LAST_FISCAL_YEAR') return new PSDateFormula().last(PSUnitOfTime.FiscalYear);
    if(s == 'TOMORROW') return new PSDateFormula().next(PSUnitOfTime.Day);
    if(s == 'NEXT_WEEK') return new PSDateFormula().next(PSUnitOfTime.Week);
    if(s == 'NEXT_MONTH') return new PSDateFormula().next(PSUnitOfTime.Month);
    if(s == 'NEXT_90_DAYS') return new PSDateFormula().next90Days();
    if(s == 'NEXT_QUARTER') return new PSDateFormula().next(PSUnitOfTime.Quarter);
    if(s == 'NEXT_YEAR') return new PSDateFormula().next(PSUnitOfTime.Year);
    if(s == 'NEXT_FISCAL_QUARTER') return new PSDateFormula().next(PSUnitOfTime.FiscalQuarter);
    if(s == 'NEXT_FISCAL_YEAR') return new PSDateFormula().next(PSUnitOfTime.FiscalYear);
    
    return null;
    
}

}