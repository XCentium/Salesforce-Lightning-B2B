global class PSSObjectSortByNameComparator implements PSISObjectComparator {
    
    global Integer compare(SObject record1, SObject record2){
        if(record1 == null || record1.get('Name') == null){
            if(record2 == null || record2.get('Name') == null){
                return 0;
            } else {
                return -1;
            }
        }
        if(record2 == null || record2.get('Name') == null){
            return 1;
        }
        return (''+record1.get('Name')).compareTo(''+record2.get('Name'));
    }
    
}