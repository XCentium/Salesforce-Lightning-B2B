public with sharing class localDataLoad {

    public List<dataPack> dPack{get;set;}
    public List<record> extractedData{get;set;}
    public boolean completed{get;set;}
    public boolean ind{get;set;}
    
    public class dataPack{
        public StaticResource packFile {get;set;}
        public boolean selected{get;set;}
        public string name{get;set;}
        
        
        
        public dataPack(){
            packFile = new StaticResource();
        }
        
        public dataPack(StaticResource sr){
            packFile = [select name, body from StaticResource where id = :sr.id];
            selected = false;
            name = packfile.name.substring(packfile.name.indexOf('_')+1);
        }
        
    }
    
    public List<dataPack>getlPack(){
        List<dataPack> lPack = new List<datapack>();
        for(datapack dp : dPack)
            if(dp.packfile.name.contains('_lang_')) //dp_lang_name
                {
                    dp.name = dp.packfile.name.substring(8);
                    lpack.add(dp);
                }
        return lPack;
    }
    
    public List<dataPack>getvPack(){
        List<dataPack> lPack = new List<datapack>();
        for(datapack dp : dPack)
            if(dp.packfile.name.contains('_vert_'))
            {
                dp.name = dp.packfile.name.substring(8);
                lpack.add(dp);
            }
        return lPack;
    }
    
    public List<dataPack>getoPack(){
        List<dataPack> lPack = new List<datapack>();
        for(datapack dp : dPack)
            if(dp.packfile.name.contains('_other_'))
            {
                dp.name = dp.packfile.name.substring(9);
                lpack.add(dp);
            }
        return lPack;
    }
    
    public List<dataPack>getelangpack(){
        List<datapack> lPack = new List<datapack>();
        for(datapack dp : dPack)
            if(dp.packfile.name.contains('_elang_'))
            {
                dp.name = dp.packfile.name.substring(9);
                lpack.add(dp);
            }
        return lPack;
    }
    
    public localDataLoad(apexpages.Standardcontroller stdController){
        dPack = new List<dataPack>();
        extractedData = new List<record>();
        List<StaticResource> packList = [select id, name from StaticResource];
        for(StaticResource sr : packList)
        {
            if((sr.name.length() > 3) && (sr.name.contains('dp_')))
                dPack.add(new DataPack(sr));
        }
        completed = false;
        ind = false;
    }
    

    
    
    public StaticResource getPack(){
        StaticResource selectedFile = null;
        for(datapack dp : dPack)
        {
            if(dp.selected)
            {
                selectedFile = dp.packFile;
            } 
        }
            if(selectedFile == null)
                return null;
            else
                return selectedFile;
                
    }
    
    public class record{
        public List<string> fields{get;set;}
        public string recCode{get;set;}
        public string objCode{get;set;}
        public boolean proc{get;set;}
        
        public record(){
            fields = new List<string>();
            recCode = '';
            objCode = '';
            proc = false;   
        } 
        
        public record(record copy){
            fields = copy.fields;
            recCode = copy.recCode;
            objCode = copy.objCode;
            proc = false;
        }
        
        public record(string recordRaw){
            proc = false; 
            //fields = recordRaw.split(',');
            recordRaw = recordRaw.substring(0, recordRaw.length());
            
            //fields = recordSplitter(recordRaw);
            fields = localDataLoad.cleanAndSplitRecords(recordRaw, ',');
            
            //now we need to strip all fields of quotes
            for(string f : fields)
            {
                f = f.replaceAll('"', '');
            }
            
            recCode = fields.get(0); //this is the externalID field.
            //objCode = recCode.substring(0, recCode.indexOf('.')); //this gives the tablename OR -1 (meta row indicator)
            if (recCode.indexOf('.') == -1) //meta row
                objCode = recCode;
            else
                objCode = recCode.substring(0, recCode.indexOf('.'));   
            
            if (objCode == recCode)
            {
                
                //string clean = fields[fields.size()-1];
                //clean = clean.substring(1, clean.length());
                //fields[fields.size()-1] = clean;
                //system.assert(false, '-' + objCode +'-'+ recCode+'-');
            }
            for(string f : fields){
                    //f = f.trim();
                    f = f.replaceAll('DBLQT', '""');
            }
            
        }
    
}
    
    public static List<string> cleanAndSplitRecords(string allData, string delim)
    {
        
        allData = allData.replaceAll(',"""',',"DBLQT').replaceAll('""",','DBLQT",');
        allData = allData.replaceAll('""','DBLQT');
        
        List<string> records = new List<string>();
        string currentRecord ='';
        boolean inQuotes = false;
        integer i=0;
        
        while(i<allData.length())
        {
            
            if((allData.substring(i,i+1) == '"') && (inQuotes==false)) //turn on quoted mode
            {
                inQuotes = true;
            }
            else if((allData.substring(i,i+1) == '"') && (inQuotes==true)) //turn off quoted mode
            {
                
                inQuotes = false;
            }
            
            if(alldata.substring(i,i+1) == delim)
            {
                if (inQuotes)
                {
                    currentRecord += alldata.substring(i,i+1);
                }
                else
                {
                    if(delim == ',')
                        {currentRecord = currentRecord.replaceAll('"', '');
                        currentRecord = currentRecord.replaceAll('DBLQT', '"');}
                    
                    records.add(currentRecord);
                    currentRecord = ''; 
                }
            }
            else
            {
                currentRecord += alldata.substring(i, i+1);
                if(delim == ',' && i==allData.length()-1) records.add(currentRecord);
            }
            i++;
        }
        return records;
        
        
    }

    
    public pageReference translateThat(){
        StaticResource selectedFile = getPack();
            if(selectedFile == null)
                return null;//new pageReference('https://na1.salesforce.com/home/home.jsp'); // none selected
                
        //convert pack into usable information 
        extractedData = extractData(selectedFile);// we are good at this point. All are records (objects with stringlist for fields)

        
        //enterTheDatapack(extractedData);
        returnOfTheDatapack(extractedData);

        completed = true;
        
        //return new pageReference('/home/home.jsp');
        return null;
    }
    
    
    
    public List<record> extractData(StaticResource selectedFile){
        //end result is a list of strings
        List<record> recordList = new List<record>();
        blob rawData = selectedFile.Body;
        
        integer buffer = 0; //starting index, increment to 1 if hostile character is found in first position
        boolean flag = false;
        while (flag != true)
        {
        if(EncodingUtil.convertToHex(Blob.valueof(rawData.toString().substring(buffer,buffer+1))) == 'efbbbf')
            //system.assert(false, 'UTF-8');
            buffer++;
            
        else if(EncodingUtil.convertToHex(Blob.valueof(rawData.toString().substring(buffer,buffer+1))) == 'efbfbd')
            buffer++;
        
        else
            flag = true;
        }
                        
        
        string totalDestruction = rawData.toString().substring(buffer);
        //system.assert(false, totalDestruction);
        //List<string> recordStrings = totalDestruction.split('\n');
        List<string> recordStrings = cleanAndSplitRecords(totalDestruction, '\n');
        //List<string> recordStrings = splitRecordAwesome(totalDestruction);
        
        for(string recordRaw:recordStrings)
        {
            
            recordList.add(new record(recordRaw));
        }
        
        return recordList;
    }

    public void enterTheDatapack(List<record> data)
    {
        //loop through data list, create list of tablenames from metadata rows
        
        integer k = 0;
        string oldRecCode ='';
        for(record d : data)
        {
            
            if(d.recCode == d.objCode) // if a meta row
            {
              //genericSequel(data, d.recCode, d.objCode); //call the generalized updater
              buddyComedy(data, d.recCode, d.objCode);
              data = cleanList(data);
              k++;
            }
            
        }
        //system.assert(false, 'we are calling gs ' + k + ' times');
        
    }
    
    public void returnOfTheDatapack(List<record> data)
    {
        string oldObjCode = '';
        List<List<record>> listofLists = new List<List<record>>();
        List<record> insertList = new List<record>();
        integer i = 0;
        
        for(record d: data)
        {
            
            if(d.recCode == d.objCode) //if this is meta row
            {
                
                if(d.objCode != oldObjCode) //if this is not the same object again (shouldn't be)
                {
                    if (insertList.size()>0)
                        listofLists.add(insertList); //put old list into list of lists
                    insertList = new List<record>(); //create a new list
                    insertList.add(d);
                    oldObjCode = d.objCode;
                    i++;
                }
            }
            else //not meta row
            {
                insertList.add(d);
            }
        }
        listofLists.add(insertList);
        //should now have x lists of y records where x = no of objects y = no of records
        integer j = 0;
        for(List<record> lr: listofLists)
        {//for each list in data
            enterTheDatapack(lr);
            j++;
            
        }
        

    }
    
private List<record> cleanList(List<record> data){
    integer i = 0;
    List<record> newList = new List<record>();
    while(i < data.size())
    {
        if(data.get(i).proc == false)
        {
            newList.add(data.get(i));
        }
        i++;
    }
    return newList;
}
    
private void procPAccount(List<record>data){
    List<SObject> sOld = [select id, external_id__pc from Account where external_id__pc != ''];
    string extID = '';
    integer i = 0;
    boolean metaFound = false;
    record MetaData = new record();
    integer j = 0;
    
    for(record item : data)
    {
        if((metaFound) && (item.objCode =='PAccount'))
        {
            
            for(SObject so : sOld)
            {
                extID = (string)so.get('External_ID__pc');
                if((extID == item.recCode))
                {
                    
                    i=0; //there are records matching item.recCode.
                    for(string f : item.fields) //for each string f in fields
                    {
                        if(i>0)
                        {
                            if(i<metadata.fields.size())
                            {
                                if(metadata.fields.get(i) != '')
                                    so.put(metadata.fields.get(i), f);
                            }
                                
                        }
                        i++;
                    }
                    j++;
                }
            }
        }
        else if(item.recCode == 'PAccount')
        {
            item.proc = true;
            metafound = true;
            metadata = new record(item);
        }
        
    }
    //system.assert(false, j);
    update sOld;
}
    
public void buddyComedy(List<record> data, string tablename, string objID){ //Optimize this - change the so updating to a list of SObjects.
    record MetaData = new record();
    integer i = 0;
    integer x = 0;
    string extID = '';
    List<SObject> SOld;
    boolean metaFound = false; //flag whether metadata record is filled in yet
    //loop through and locate desired metadata row.
    //loop through each record, //match to list of itemsToUpdate
        //loop through columns, taking name from metadata record, value from active record to sobj
        //update sobj
    if(tablename == 'PAccount')
    {
        procPAccount(data);
        return;
    }
    else if(tablename == 'Contact')
    {
        SOld = database.query('select id, external_id__c from ' + tablename + ' where External_ID__c != \'\' and IsPersonAccount = false');
    }
    else{
        
        sOld = database.query('select id, external_id__c from ' + tablename + ' where External_ID__c != \'\''); 
    }
    
    
    //List<SObject> sOld = Database.query('select id, external_id__c from ' + tablename + ' where External_ID__c != \'\'');
        //get old/current list of items, build updated list, update the updated list
    
    for(record item : data) //loop through the records(rows) from data(csv content)
    {   
        if((metaFound) && (item.objCode == tablename) && (item.proc == false)) //if the metarow is already loaded in and this is record for our target object
        {
            for(SObject so : sOld) //for each row, loop through the possible sobjects
            {
                extID = (string)so.get('External_ID__c');
                if((extID == item.recCode)) //if the so external_id field matches the rec code (we have liftoff)
                {
                    //LIFTOFF
                    i=0;
                    for(string f : item.fields) //loop through fields
                    {
                        if(i>0)
                            {
                                if(i < metaData.fields.size()){
                                    if(metaData.fields.get(i) != '')
                                        so.put(metaData.fields.get(i), f);
                                }
                            }
                        i++;                            
                    }
                    
                }
            }   
        }
        else if(item.recCode == tableName)
        {
            metafound = true;
            metadata = new record(item);
        }
        x++;
    }
    
    
    update sOld;
}
    

    /*  Begin graveyard of craptastical methods
    
            public List<string> splitRecordAwesome(string totalDestruction)
{
        //loop through string char by char
        //if quote, act cool
        //if quote agian, stop acting cool
        //if \n, RUN FOO        
        List<string> records = new List<string>();
        string currentField = '';
        List<string> chars = new List<string>();
        boolean inQuotes = false;
        integer i = 0;
        string temp;
        
        while(i < totalDestruction.length()) //walk through and create chars and fields
        {
            if(totalDestruction.substring(i, i+1) == '\n') //if char is a comma
            { 
                if(inQuotes) //if this is encapsulated
                {
                    currentField += totalDestruction.substring(i,i+1); //add return char to fieldVal as normal                                      
                }
                else //Not incapsulated? end of a record son!
                {
                    if(currentField.substring(0,11) == 'Account.008')
                        system.assert(false, currentField);
                    records.add(string.valueOf(currentField)); //Add the value of the field to the fields list (IF STRING NOT EMPTY)
                    currentField = ''; //Start the field from scratch again.
                }
            }
            else if(totalDestruction.substring(i,i+1) == '"') //if char is a quote
            {
                if((i+1 != totalDestruction.length()) && (totalDestruction.substring(i+1, i+2) == '"')) //if not last character and next char isn't a "(escape)
                {
                    currentField += totalDestruction.substring(i,i+2); //add the normal quote into the field value
                    i+=2;
                }
                else if(inQuotes) //This is the end of an encapsulated area
                {
                    inQuotes = false; //mark that the area is ending, so that the next char (,) will be picked up properly.
                }
                else //not escape quote, not in quotes, this is a beginning of encapsulated data
                {
                    inQuotes = true; //mark that area is beginning so next comma (before ") will be picked up properly.
                }
            }
            else //Any other non-sepcial character
            {
                currentField += totalDestruction.substring(i,i+1); // add to fieldVal
            }
            i++; //advance index.
        }
        
        return records;
    }
    
    public List<string> recordSplitter(string record)
{
        List<string> fields = new List<string>();
        string currentField = '';
        List<string> chars = new List<string>();
        boolean inQuotes = false;
        integer i = 0;
        string temp;
        
        
                
        while(i < record.length()) //walk through and create chars and fields
        {
            if(record.substring(i, i+1) == ',') //if char is a comma
            { 
                if(inQuotes) //if this is encapsulated
                {
                    currentField += record.substring(i,i+1); //add comma char to fieldVal as normal                                     
                }
                else //Not incapsulated? end of a field son!
                {
                    fields.add(string.valueOf(currentField)); //Add the value of the field to the fields list (IF STRING NOT EMPTY)
                    currentField = ''; //Start the field from scratch again.
                }
            }
            else if(record.substring(i,i+1) == '"') //if char is a quote
            {
                
                if((i+1 != record.length()) && (record.substring(i+1, i+2) == '"')) //if not last character and next char isn't a "(escape)
                {
                    i++; //skip over the escape quote
                    currentField += record.substring(i,i+1); //add the normal quote into the field value
                }
                else if(inQuotes) //This is the end of an encapsulated area
                {
                    inQuotes = false; //mark that the area is ending, so that the next char (,) will be picked up properly.
                }
                else //not escape quote, not in quotes, this is a beginning of encapsulated data
                {
                    inQuotes = true; //mark that area is beginning so next comma (before ") will be picked up properly.
                }
            }
            else //Any other non-sepcial character
            {
                currentField += record.substring(i,i+1); // add to fieldVal
            }
            i++; //advance index.
        }


        return fields;
    }
    
public void genericSequel(List<record> data, string tablename, string objID){ //DO NOT EDIT. WORKING FOR TEST AU CASE UP TO ~50 RECORDS DUE TO DML LIMITER
    record MetaData;
    integer i = 0;
    boolean metaFound = false; //flag whether metadata record is filled in yet
    //loop through and locate desired metadata row.
    //loop through each record, //match to list of itemsToUpdate
        //loop through columns, taking name from metadata record, value from active record to sobj
        //update sobj
    
    for(record item : data) //loop through the records(rows) from data(csv content)
    {
        if((metaFound) && (item.objCode == objID)) //if metadata row already recovered
        {
            string recCode = item.recCode;
        //match to list of itemsToUpdate
            SObject so = Database.query('select id from ' + tablename + ' where External_ID__c = :recCode');
            //system.assert(false, 'select id from ' + tablename + ' where Extid = ' + recCode);
            i = 0;
            
            for(string f : item.fields)
            {
                
                if(i>0)
                {
                    so.put(metaData.fields.get(i), f);
                }
                i++;
                //update so;
            }
            update so;
        //loop through columns, taking name from metadata record, value from active record to sobj
        //update sobj
        }
        //else if(item.recCode.substring(0,7) == objID+'SSE') //metadata not found yet, is this where we parked our car?
        else if(item.recCode == tableName)
        {
            
            //fill in metadata object
            metafound = true;
            //metadata = item;
            metadata = new record(item);
        }
        
    }
}*/

}