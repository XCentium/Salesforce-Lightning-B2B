global class PSSoqlBuilder {
    private Set<Object>     selectx     = null;
    private String          fromx       = null;
    private PSCondition     wherex      = null;
    private List<PSOrderBy> orderByx    = null;
    private String          groupByx    = null;
    private Integer         limitx      = null;
    
    global PSSoqlBuilder selectx(String field)
    { 
        return addToSelect(field);
    }
    
    global PSSoqlBuilder selectx(PSSoqlField field)
    { 
        return addToSelect(field);
    }

    global PSSoqlBuilder selectx(List<Object> fields){ 
        return selectx(PSLangUtils.listToSet(fields));
    }
    
    global PSSoqlBuilder selectx(Set<Object> fields){ 
        if(fields != null && fields.size() > 0){
            for(Object field : fields){
                addToSelect(field);
            }
        }
        return this;
    }
    private PSSoqlBuilder addToSelect(Object field)
    {
        if(field == null){
            throw new PSIllegalArgumentException('null field');
        }
        if(field instanceof String || field instanceof PSSoqlField){
            if(selectx == null){
                selectx = new Set<Object>();
            }
            selectx.add(field);
        } else {
            throw new PSIllegalArgumentException('Invalid field type.  A field must be either a String, PSSoqlField, or PSSoqlBuilder.');
        }
        return this;
    }  
    
    global String toSoql()
    { 
        return this.toSoql(null); 
    }
    
    global String toSoql(PSSoqlOptions options)
    {
        if(PSLangUtils.isBlank(fromx)){
            throw new PSIllegalStateException('Illegal state!  You must invoke fromx() with valid object name before invoking toSoql().');
        }
        Boolean isFirst = true;
        
        String soql = 'SELECT ';
        
        
        if(selectx == null){
            selectx = new Set<Object>();
        }
        
        if (selectx.size() <= 0)
        {
            selectx.add('id');
        }
        
        String distinctField = null;
        Map<String,String> distinctFields = new Map<String,String>();
        for(Object value : selectx){
            if(value instanceof PSSoqlField){
                distinctField = ((PSSoqlField)value).toSoql(options);
            } else if(value instanceof PSSoqlBuilder){
                distinctField = '(' + ((PSSoqlBuilder)value).toSoql(options) + ')';
            } else {
                distinctField = ''+value;
            }
            distinctField = PSLangUtils.trim(distinctField);
            distinctFields.put(PSLangUtils.lowerCase(distinctField),distinctField);
        }
        soql += PSLangUtils.joinStrings(distinctFields.values(),',');
        
        
        soql += ' FROM ' + fromx;
        if(wherex != null)
        {
            soql += ' WHERE ' + wherex.toSoql(options);
        }
        
        if(groupByx != null && groupByx != ''){
           soql += ' GROUP BY ' + groupByx + ' ';
        }
        
        if(orderByx != null && orderByx.size() > 0){
            isFirst = true;
            for(PSOrderBy orderBy : orderByx){
                if(orderBy == null){
                    continue;
                }
                if(isFirst){  
                    isFirst = false;
                    soql += ' ORDER BY ';
                } else {
                    soql += ', ';
                }
                soql += orderBy.toSoql(options);
            }
        }
        if(limitx != null){
            soql += ' LIMIT ' + limitx;
        }
        return soql;
    }
    
    global PSSoqlBuilder fromx(String fromx){
        this.fromx = fromx; 
        return this;
    }
    
    global PSSoqlBuilder wherex(PSCondition wherex){ 
        this.wherex = wherex;
        return this;
    }
    
    global PSSoqlBuilder orderByx(PSOrderBy orderByx){ 
        if(this.orderByx == null){
            this.orderByx = new List<PSOrderBy>();
        }
        this.orderByx.add(orderByx);
        return this;
    }
    
    global PSSoqlBuilder orderByx(List<PSOrderBy> orderByx){ 
        if(orderByx != null && orderByx.size() > 0){
            for(PSOrderBy field : orderByx){
                orderByx(field);
            }
        }
        return this;
    }
    global PSSoqlBuilder limitx(Integer limitx){
        this.limitx = limitx; 
        return this;
    }    
    
    global PSSoqlBuilder groupByx(String groupByx){
        this.groupByx = groupByx; 
        return this;
    }
}