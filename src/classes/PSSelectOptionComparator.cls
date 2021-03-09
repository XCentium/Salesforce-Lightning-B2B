global class PSSelectOptionComparator implements PSObjectComparator{
	
	global Boolean sortDescending{get;set;}
	global Boolean sortAscending{get{return !sortDescending;}}
	global Boolean sortOnLabel{get;set;}
	global Boolean sortOnValue{get{return !sortOnLabel;}}
	
	global PSSelectOptionComparator(){
		this(true,true);
	}

	global PSSelectOptionComparator(Boolean sortDescending){
		this(sortDescending,true);
	}

	global PSSelectOptionComparator(Boolean sortDescending, Boolean sortOnLabel){
		this.sortDescending = sortDescending;
		this.sortOnLabel = sortOnLabel;
	}

	global Integer compare(Object object1, Object object2){
        if(object1==null){
            return sortDescending ? -1 : 1;
        } else if(object2==null){
            return sortDescending ? 1 : -1;
        }
		if(		!(object1 instanceof PSSelectOptionWrapper) 
        	|| 	!(object2 instanceof PSSelectOptionWrapper)){
        	throw new PSIllegalArgumentException('Invalid type');
        }
        SelectOption o1 = ((PSSelectOptionWrapper)object1).selectOption;
        SelectOption o2 = ((PSSelectOptionWrapper)object2).selectOption;
        String s1 = sortOnLabel ? o1.getLabel() : o1.getValue(); 
        String s2 = sortOnLabel ? o2.getLabel() : o2.getValue(); 
    	if(s1 < s2){ 
    		return sortDescending ? -1 : 1; 
    	} else if(s1 == s2){ 
    		return 0; 
    	} else { 
    		return sortDescending ? 1 : -1; 
    	} 
    }

	global static List<SelectOption> sort(List<SelectOption> theList){
		return sort(theList,true);
	}

	global static List<SelectOption> sort(List<SelectOption> theList, Boolean sortDescending){
		return sort(theList,sortDescending,true);
	}	
	
	global static List<SelectOption> sort(List<SelectOption> theList, Boolean sortDescending, Boolean sortOnLabel){
		if(theList != null && theList.size() > 0){
			//convert to wrapper list
			List<PSSelectOptionWrapper> wrapperList = new List<PSSelectOptionWrapper>();
			for(SelectOption option : theList){
				wrapperList.add(new PSSelectOptionWrapper(option));
			}
			//sort
			wrapperList = (List<PSSelectOptionWrapper>) PSLangUtils.qsort(wrapperList, new PSSelectOptionComparator(sortDescending,sortOnLabel));
			//convert back
			theList.clear();
			for(PSSelectOptionWrapper wrapper : wrapperList){
				theList.add(wrapper.selectOption);
			}
		}
		return theList;
	}
		
    
}