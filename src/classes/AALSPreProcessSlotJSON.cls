public class AALSPreProcessSlotJSON 
//**** this is a copy of Chris Gilmore's class but customized to meet some specific needs of anonymous scheduling
{
    @InvocableMethod(label='PreProcess LS JSON' description='This will pre-process Lightning Scheduler Slot JSON to render in the GilmoreLabs Slot Picker')
    public static List<String> getSlotPickerJSON(List<LSPreProcessIN> requests) 
    {
        List<String> strResults = new List<String>();
        String strResult = '[';
        
        List<ID> territoryIDs = new List<ID>();
        List<ID> resourceIDs = new List<ID>();
        
        for(LSPreProcessIN request : requests)
        {
            List<Object> i = (List<object>)JSON.deserializeUntyped(request.inputJSON) ;

            
            //first loop through to get all the IDs
            for (Object o : i) 
            {
                Map<String, Object> slot = (Map<String, Object>) o;
                String strTerritoryId = (String)slot.get('territoryId');
                territoryIDs.add(strTerritoryId);
                
               
                    
                        resourceIDs.add((string)slot.get('resources'));
                    
                
            }
            
            //Get all the resource names and territory names
            Map<Id, ServiceTerritory> objTs = new Map<Id, ServiceTerritory>([Select ID, Name from ServiceTerritory WHERE ID IN: territoryIDs]);
            Map<Id, ServiceResource> objSRs = new Map<Id, ServiceResource>([Select ID, Name, RelatedRecord.Smallphotourl from ServiceResource WHERE ID IN: resourceIDs]);
            
            //Now loop to set all the variables
            for (Object o : i) 
            {
                Map<String, Object> slot = (Map<String, Object>) o;
//                String strStartTime  = (String)slot.get('startTime');
                  long lngStartTime = (Long)slot.get('startTime');
//                datetime dtStart = (datetime)json.deserialize('"' + strStartTime + '"', datetime.class);
                datetime dtStart = datetime.newinstance(lngStartTime);
                
//                String strEndTime  = (String)slot.get('endTime');
                  long lngEndTime = (Long)slot.get('endTime');
                datetime dtEnd = datetime.newinstance(lngEndTime);
                
                String strTerritoryId = (String)slot.get('territoryId');
                String strTerritoryName = objTs.get(strTerritoryId).Name;
                
                List<Object> lstResourceIDs;
                String strResourceNames = '';
                String htmlResourceImages = '';
                
                    lstResourceIDs = new List<Object>{slot.get('resources')};
                    for (Object currentResourceID : lstResourceIDs)
                    {
                        resourceIDs.add((string)currentResourceID);
                        strResourceNames += objSRs.get((string)currentResourceID).Name + ', ';
                        htmlResourceImages += '<img src=\\"' + objSRs.get((string)currentResourceID).RelatedRecord.Smallphotourl + '\\" style=\\"border-radius: 50px;border: solid;border-width: 1px;height:60px;\\" />';
                    }
                    strResourceNames = strResourceNames.removeEnd(', ');
                
                
                String currentDisplayText = request.displayTemplate;
                
                //Now merge in fields
                currentDisplayText = currentDisplayText.replace('{territory}', strTerritoryName);
                currentDisplayText = currentDisplayText.replace('{resources}', strResourceNames);
                currentDisplayText = currentDisplayText.replace('{resourceImages}', htmlResourceImages);
                currentDisplayText = currentDisplayText.replace('{startTime}', dtStart.format('EEE, MMM d, h:mm a'));
                currentDisplayText = currentDisplayText.replace('{endTime}', dtEnd.format('h:mm a'));
                strResult += '{"id":"' + (string) slot.get('id') + '", "timestamp":' + dtStart.getTime() + ',"displaytext":"' + currentDisplayText + '"},';               
//                strResult += '{"id":"' + strTerritoryId + '_' + dtStart.getTime() + '_' + (lstResourceIDs != null ? string.join(lstResourceIDs,'_') : '') + '", "timestamp":' + dtStart.getTime() + ',"displaytext":"' + currentDisplayText + '"},';
            }
        }
        
        strResults.add(strResult.removeEnd(',') + ']');
        return strResults;
    }
    
    
    public Class LSPreProcessIN
    {
        @InvocableVariable
        public String inputJSON;
        @InvocableVariable
        public String displayTemplate;
        
    }
}
/* Chris Albanese - Chris Gilmore's orginal code is below
public class GilmoreLabs_LSPreProcessSlotJSON 
{
    @InvocableMethod(label='PreProcess LS JSON' description='This will pre-process Lightning Scheduler Slot JSON to render in the GilmoreLabs Slot Picker')
    public static List<String> getSlotPickerJSON(List<LSPreProcessIN> requests) 
    {
        List<String> strResults = new List<String>();
        String strResult = '[';
        
        List<ID> territoryIDs = new List<ID>();
        List<ID> resourceIDs = new List<ID>();
        
        for(LSPreProcessIN request : requests)
        {
            boolean candidateJSON = false;
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(request.inputJSON);
            List<Object> i;
            if(m.get('candidates') != null)
            {
                i = (List<Object>)m.get('candidates');
                candidateJSON = true;
            }
            else
            {
                i = (List<Object>)m.get('timeSlots');
            }
            
            //first loop through to get all the IDs
            for (Object o : i) 
            {
                Map<String, Object> slot = (Map<String, Object>) o;
                String strTerritoryId = (String)slot.get('territoryId');
                territoryIDs.add(strTerritoryId);
                
                if (candidateJSON)
                {
                    List<Object> lstResourceIDs = (List<Object>)slot.get('resources');
                    for (Object currentResourceID : lstResourceIDs)
                    {
                        resourceIDs.add((string)currentResourceID);
                    }
                }
            }
            
            //Get all the resource names and territory names
            Map<Id, ServiceTerritory> objTs = new Map<Id, ServiceTerritory>([Select ID, Name from ServiceTerritory WHERE ID IN: territoryIDs]);
            Map<Id, ServiceResource> objSRs = new Map<Id, ServiceResource>([Select ID, Name, RelatedRecord.Smallphotourl from ServiceResource WHERE ID IN: resourceIDs]);
            
            //Now loop to set all the variables
            for (Object o : i) 
            {
                Map<String, Object> slot = (Map<String, Object>) o;
                String strStartTime  = (String)slot.get('startTime');
                datetime dtStart = (datetime)json.deserialize('"' + strStartTime + '"', datetime.class);
                
                String strEndTime  = (String)slot.get('endTime');
                datetime dtEnd = (datetime)json.deserialize('"' + strEndTime + '"', datetime.class);
                
                String strTerritoryId = (String)slot.get('territoryId');
                String strTerritoryName = objTs.get(strTerritoryId).Name;
                
                List<Object> lstResourceIDs;
                String strResourceNames = '';
                String htmlResourceImages = '';
                if (candidateJSON)
                {
                    lstResourceIDs = (List<Object>)slot.get('resources');
                    for (Object currentResourceID : lstResourceIDs)
                    {
                        resourceIDs.add((string)currentResourceID);
                        strResourceNames += objSRs.get((string)currentResourceID).Name + ', ';
                        htmlResourceImages += '<img src=\\"' + objSRs.get((string)currentResourceID).RelatedRecord.Smallphotourl + '\\" style=\\"border-radius: 50px;border: solid;border-width: 1px;height:60px;\\" />';
                    }
                    strResourceNames = strResourceNames.removeEnd(', ');
                }
                
                String currentDisplayText = request.displayTemplate;
                
                //Now merge in fields
                currentDisplayText = currentDisplayText.replace('{territory}', strTerritoryName);
                currentDisplayText = currentDisplayText.replace('{resources}', strResourceNames);
                currentDisplayText = currentDisplayText.replace('{resourceImages}', htmlResourceImages);
                currentDisplayText = currentDisplayText.replace('{startTime}', dtStart.format('EEE, MMM d, h:mm a'));
                currentDisplayText = currentDisplayText.replace('{endTime}', dtEnd.format('h:mm a'));
                
                strResult += '{"id":"' + strTerritoryId + '_' + dtStart.getTime() + '_' + (lstResourceIDs != null ? string.join(lstResourceIDs,'_') : '') + '", "timestamp":' + dtStart.getTime() + ',"displaytext":"' + currentDisplayText + '"},';
            }
        }
        
        strResults.add(strResult.removeEnd(',') + ']');
        return strResults;
    }
    
    
    public Class LSPreProcessIN
    {
        @InvocableVariable
        public String inputJSON;
        @InvocableVariable
        public String displayTemplate;
        
    }
} */