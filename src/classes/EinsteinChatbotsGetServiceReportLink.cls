global class EinsteinChatbotsGetServiceReportLink 
{
    @InvocableMethod(label='Einstein Chatbots - Get Service Report Link' description='Returns a link to the Service Report .pdf file')
    global static List<String> getSReport(List<ServiceAppointment> requests) 
    {
        List<string> results = new List<string>();
        
        For (ServiceAppointment objSA : requests)
        {
            if (objSA != null && String.IsNotBlank(objSA.id))
            {
                //See if there is a Service Report
                string contentVersionID = '';
                
                List<ServiceReport> objReports = [SELECT ContentVersionDocumentId FROM ServiceReport where parentID =: objSA.Id AND IsDeleted =: false ORDER BY CreatedDate DESC];
                if (objReports == null || objReports.size() == 0)
                {
                    return new List<string>{'null'};
                }
                contentVersionID = objReports[0].ContentVersionDocumentId;
                
                //Check to make sure it's not shared already
                List<ContentDistribution> chkDist = [SELECT ID, DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId =: contentVersionID];
                
                if (chkDist == null || chkDist.size() == 0)
                {
                    //insert the document distribution
                    ContentDistribution dist = new ContentDistribution();
                    dist.ContentVersionId = contentVersionID;
                    dist.Name = contentVersionID;
                    dist.OwnerId = objSA.OwnerId;
                    dist.PreferencesAllowOriginalDownload = true;
                    dist.PreferencesAllowPDFDownload = false;
                    dist.PreferencesAllowViewInBrowser = true;
                    dist.PreferencesExpires  = false;
                    dist.PreferencesLinkLatestVersion = true;
                    dist.PreferencesNotifyOnVisit = false;
                    dist.PreferencesNotifyRndtnComplete  = false;
                    dist.PreferencesPasswordRequired = false;
                    insert dist;
                    
                    //refresh the dist
                    List<ContentDistribution> chkDist2 = [SELECT ID, DistributionPublicUrl FROM ContentDistribution WHERE id =: dist.Id];
                    results.add(chkDist2[0].DistributionPublicUrl);
                }
                else
                {
                    results.add(chkDist[0].DistributionPublicUrl);
                }
                return results;
            }
            break;
        }
        
        return new List<string>{'null'};
    }
}