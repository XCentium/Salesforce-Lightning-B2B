global class Rider_GenerateServiceReportURL 
{
    @InvocableMethod(label='Rider - Generate Service Report URL')
    public static List<String> getURL(List<String> saID) 
    {
        string contentVersionID = '';
        string srURL = '';
        for (string strSAID : saID)
        {
            try
            {
                List<ServiceReport> objReports = [SELECT ContentVersionDocumentId FROM ServiceReport where parentID =: strSAID AND IsDeleted =: false ORDER BY CreatedDate DESC];
                if (objReports == null || objReports.size() == 0)
                {
                    return new List<String>{srURL};
                        }
                contentVersionID = objReports[0].ContentVersionDocumentId;
                
                //Get the SA
                ServiceAppointment objSA = [SELECT ID, OwnerId, Rider_ServiceReport_URL__c FROM ServiceAppointment WHERE ID=: strSAID LIMIT 1];
                
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
                    dist.PreferencesExpires	= false;
                    dist.PreferencesLinkLatestVersion = true;
                    dist.PreferencesNotifyOnVisit = false;
                    dist.PreferencesNotifyRndtnComplete	= false;
                    dist.PreferencesPasswordRequired = false;
                    insert dist;
                    
                    //refresh the dist
                    List<ContentDistribution> chkDist2 = [SELECT ID, DistributionPublicUrl FROM ContentDistribution WHERE id =: dist.Id];
                    srURL = chkDist2[0].DistributionPublicUrl;
                }
                else
                {
                    srURL = chkDist[0].DistributionPublicUrl;
                }
                objsa.Rider_ServiceReport_URL__c = srURL;
                update objsa;
                break;
            }
            catch (Exception ex)
            {
                
            }
        }
        return new List<String>{srURL};
            }
}