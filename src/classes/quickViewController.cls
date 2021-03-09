public class quickViewController {

    /*General TODOs: 
        * string.replaceAll('"',''); to replace all double quotes prior to displaying
        * add download link either by rest api or content type in new visualforce page
        * clean up code and debug statements
        * add tests
    */

    // Create the getter/setter for row and column counts used when parsing the CSV
    public Integer rowCount { get; set; }
    public Integer colCount { get; set; }
    
    // Create a getter/setter blob results sets from the query 
    public Blob queryELF {
        get {return queryElf;}
        set {queryElf = value;}
    } 
    
    // variable to set Export Link to disabled
   boolean isExportLinkDisabled = true; 
   
   // method to return Export Link disabled status 
   public boolean getisExportLinkDisabled()  
   {
      return isExportLinkDisabled;
    }
    
    // Query picklist values to be selected and passed in as input when the user selects the Go! button
      
    // String value for picklist input
    String plELF;

    /* Getter for the picklist value */
    public String getPlELF() { return this.plELF; }

    /* Setter for the picklist value */
    public void setPlELF(String plELF) { this.plELF = plELF; }
        
    /* Add picklist values to picklist */
    public List<SelectOption> getElfs() {
      List<SelectOption> optionList = new List<SelectOption>();
      /* Add a null option to force the user to make a selection. */
      optionList.add(new SelectOption('- None -','- None -'));
    
      /* Loop through the EventLogFile records creating a selectOption
         for each result with the record ID as the value and the Date + Type as the label 
         displayed in the selectList */
      for (EventLogFile elf : [select Id, LogDate, EventType from EventLogFile order by LogDate DESC]){
        optionList.add(new SelectOption(elf.Id, 'Date: '+elf.LogDate+' | Type: '+elf.EventType));
      }
      return optionList;     
    }
        
    // Create the object to hold the CSV results
    List<List<String>> csvELF = new List<List<String>>();
      
    // Here's where the user selects the 'Go!' button
    public pageReference Go(){      
        
        // ************* Here's where we figure out what input we have in order to construct the right query based on the WHERE condition
        
        // Create the query Blob and set it to a generic query
        Blob queryELF = [SELECT LogFile FROM EventLogFile LIMIT 1].LogFile;
        
        // Query input fields to determine if user wants to parse CSV based on Id, event type, or log date
        If (plELF != '- None -'){ //e.g. There is data in the picklist
            // After finding a log file, we should enable the export link
            isExportLinkDisabled=false; 
            queryELF = [SELECT LogFile FROM EventLogFile WHERE Id=:plELF LIMIT 1].LogFile;
         }    
        
        // TODO: add else if back in to handle when there are no values returned - currently pulls back a semi-random CSV
        /*
          else if (plET == '- None -') { // e.g. no data returned in the picklist other than the - None - row
            queryELF = [SELECT LogFile FROM EventLogFile WHERE Id=:plET LIMIT 1].LogFile;
        } 
        */
        
        // ************* Here's where we convert the query blob results to a parsed set of CSV values
        //List<List<String>> csvELF = new List<List<String>>();
        rowCount = 0;
        colCount = 0;
        
        if (queryELF != null){
            String csvString = queryELF.toString();
            csvELF = parseCSV(csvString, false);
            rowCount = csvELF.size();
            System.Debug('rowcount: ' + rowCount);
            for (List<String> row : csvELF){
                if (row.size() > colCount){
                    colCount = row.size();
                }
            }
        }
        return null;
    }
    
    // ***************************** This code is redundant with the Go() method - fix later**************
    // Here's where the user selects the 'Go!' button
    public pageReference Convert(){      
        
        // ************* Here's where we figure out what input we have in order to construct the right query based on the WHERE condition
        
        // Create the query Blob and set it to a generic query
        Blob queryELF = [SELECT LogFile FROM EventLogFile LIMIT 1].LogFile;
        
        // Query input fields to determine if user wants to parse CSV based on Id, event type, or log date
        If (plELF != '- None -'){ //e.g. There is data in the picklist
            // After finding a log file, we should enable the export link
            isExportLinkDisabled=false; 
            queryELF = [SELECT LogFile FROM EventLogFile WHERE Id=:plELF LIMIT 1].LogFile;
         }    
        
        // TODO: add else if back in to handle when there are no values returned - currently pulls back a semi-random CSV
        /*
          else if (plET == '- None -') { // e.g. no data returned in the picklist other than the - None - row
            queryELF = [SELECT LogFile FROM EventLogFile WHERE Id=:plET LIMIT 1].LogFile;
        } 
        */
        
        // ************* Here's where we convert the query blob results to a parsed set of CSV values
        //List<List<String>> csvELF = new List<List<String>>();
        rowCount = 0;
        colCount = 0;
        
        if (queryELF != null){
            String csvString = queryELF.toString();
            csvELF = parseCSV(csvString, false);
            rowCount = csvELF.size();
            System.Debug('rowcount: ' + rowCount);
            for (List<String> row : csvELF){
                if (row.size() > colCount){
                    colCount = row.size();
                }
                for(Integer i=0; i<row.size(); i++) {
                    String col= row[i];
                    // replace all double quotes in the results
                    row[i] = col.replaceAll('"','');
                    // Substitute user's name for Id where applicable
                    if(row[i].startsWith('005')) {
                        List <User> users = [select name from user where id=:row[i]];
                        If (users != null && users.size() > 0) {
                            row[i] = users[0].Name;
                        }
                    }
                    // Substitute report name for Id where applicable
                    if(row[i].startsWith('/00O')) {
                        row[i] = row[i].replaceAll('/','');
                        List <Report> reports = [select name from report where id=:row[i]];
                        If (reports != null && reports.size() > 0) {
                            row[i] = reports[0].Name;
                        }
                    } 
                }
            }
        }
        return null;
    }
    
    // ***************************************************************************************************
      
    
    // Results from query and CSV parsing are returned here
    public List<List<String>> getGoResults() {
        return csvELF;
    }
    
    /* **********************************************************************************************************
    // getResults is used for the default onLoad result set - it's hard coded to return a specific Id EventLogFile
    // Credit for this part to Eric Santiago - http://www.ericsantiago.com/eric_santiago/2011/03/upload-and-parse-csv-via-visualforce.html
    public List<List<String>> getResults() {
        List<List<String>> elfCSV = new List<List<String>>();
        rowCount = 0;
        colCount = 0;
            //Blob elfLogFile = [SELECT LogFile FROM EventLogFile WHERE eventType=:eventType LIMIT 1].LogFile;
            Blob elfLogFile = [SELECT LogFile FROM EventLogFile WHERE Id = '0ATD000000000k5OAA' LIMIT 1].LogFile;  
            //System.Debug('elfLogFile: ' + elfLogFile);          

        if (elfLogFile != null){
            String fileString = elfLogFile.toString();
            elfCSV = parseCSV(fileString, false);
            rowCount = elfCSV.size();
            for (List<String> row : elfCSV){
                if (row.size() > colCount){
                    colCount = row.size();
                }
            }
        }
        return elfCSV;
    }
    */
    // **********************************************************************************************************
    
    // parseCSV is the workhorse of this code - it parses CSVs making the viewer possible. 
    /* 
    Credit to 
    http://wiki.developerforce.com/index.php/Code_Samples#Parse_a_CSV_with_APEX
    */
    public static List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
        List<List<String>> allFields = new List<List<String>>();
    
        // uncomment the following line to replace double quote instances - beware login log line issue with Browser Type due to comma
        // contents = contents.replace('"','');
        //System.Debug('contents = ' + contents);   
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            lines = contents.split('\n'); //correction: this only accomodates windows files
            //lines = contents.split('\r'); // using carriage return accomodates windows, unix, and mac files
            //http://www.maxi-pedia.com/Line+termination+line+feed+versus+carriage+return+0d0a
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for(String line: lines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');  
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field: fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }
            
            allFields.add(cleanFields);
        }
        if (skipHeaders) allFields.remove(0);
        return allFields;       
    }
    
    // This query is used to show the Log Quick View information that is returned with the page load
    public List<EventLogFile> getLogFileInfo() {

        return [SELECT Id, LogDate, CreatedDate, EventType, LogFileLength, LogFile FROM EventLogFile ORDER BY logdate DESC];
    }  

}