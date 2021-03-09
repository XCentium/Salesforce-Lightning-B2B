public with sharing class LoadDashboardQueueable implements Queueable, Database.AllowsCallouts {
    
    private Double apiVersion;
    private String sessionId;
    private String folderId;
    private WaveApplicationDashboard dashboardToLoad;
    private Map<String, WaveApplicationDataset> datasetsMap;
    private Map<String, WaveApplicationDashboard> dashboardsMap;
    private WaveApplicationImage refImages;
    private Map<String, String> imgMappingToContent;

    public LoadDashboardQueueable(WaveApplicationDashboard dashboard, Map<String, WaveApplicationDataset> datasetsMap, Map<String, WaveApplicationDashboard> dashboarsMap, WaveApplicationImage refImages, Map<String, String> imgMappingToContent, String folderId, Double apiVersion, String sessionId) {
        this.dashboardToLoad = dashboard;
		this.sessionId = sessionId;
        this.apiVersion = apiVersion;
        this.folderId = folderId;
        this.datasetsMap = datasetsMap;
        this.dashboardsMap = dashboarsMap;
        this.refImages = refImages;
        this.imgMappingToContent = imgMappingToContent;
    }

    public void execute(QueueableContext context) {
        // Get the dashboard json template. How to generate it? From Chrome's debugger console, network tab to see what is sent when you save a dashboard
        HttpResponse resJson = WaveConfiguratorUtils.httpGetCallout(this.dashboardToLoad.jsonUrl);
        String dashboardJsonToSend = resJson.getBody();
        dashboardJsonToSend = dashboardJsonToSend.replace('{#FolderId}', this.folderId);
        dashboardJsonToSend = dashboardJsonToSend.replace('{#DashboardName}', this.dashboardToLoad.nameToSave);
        
        if (this.dashboardToLoad.referencedDatasets != null) {
            for (String datasetName : this.dashboardToLoad.referencedDatasets) {
                if (this.datasetsMap.containsKey(datasetName)) {
                    WaveApplicationDataset ds = this.datasetsMap.get(datasetName);
                    dashboardJsonToSend = dashboardJsonToSend.replace('{#' + datasetName + '}', ds.nameToSave);
                }
            }   
        }

        if (this.dashboardToLoad.referencedDashboards != null) {        
            for (String dashName : this.dashboardToLoad.referencedDashboards) {
                if (this.dashboardsMap.containsKey(dashName)) {
                    WaveApplicationDashboard dash = this.dashboardsMap.get(dashName);
                    dashboardJsonToSend = dashboardJsonToSend.replace('{#' + dashName + '}', dash.nameToSave);
                }
            }
        }

        if (this.dashboardToLoad.referencedImages != null && this.refImages != null) {
            
            String imgType = this.refImages.type;            

            for (String imgName : this.dashboardToLoad.referencedImages) {
                String key = imgName + '.' + imgType; // PathOnClient
                if (this.imgMappingToContent.containsKey(key)) {
                    String contentDocId = this.imgMappingToContent.get(key);
                    dashboardJsonToSend = dashboardJsonToSend.replace('{#' + imgName + '}', contentDocId);
                }
            }
        }

        // Find if there exists dashboard
        List<Lens> lstDashboards = [SELECT Id FROM Lens WHERE Type = 'dashboard' AND DeveloperName = :this.dashboardToLoad.nameToSave AND IsDeleted = false];
        String dashboardId = '';
        
        if (lstDashboards.size() > 0) {
            // Create new one with distinct name, or overwrite exising?
            Lens orgDashboard = lstDashboards.get(0);
            dashboardId = orgDashboard.Id;
        }
        
        // Dashboard create or update?
        // https://developer.salesforce.com/docs/atlas.en-us.bi_dev_guide_rest.meta/bi_dev_guide_rest/bi_resources_dashboards_id.htm
        HTTPResponse res = null;
        if (String.isBlank(dashboardId)) {
            // Create
            res = WaveConfiguratorUtils.httpCallout('/services/data/v' + apiVersion + '/wave/dashboards', 'POST', true, dashboardJsonToSend);
        }
        else {
            // Update
            res = WaveConfiguratorUtils.httpCallout('/services/data/v' + apiVersion + '/wave/dashboards/' + dashboardId + '?_HttpMethod=PATCH', 'POST', true, dashboardJsonToSend);
        }

        if(!WaveConfiguratorUtils.checkStatus(res)){
            if(res.getBody().containsIgnoreCase('errorCode')){
                List<RestApiErrorResponse> r = (List<RestApiErrorResponse>)JSON.deserialize(res.getBody(), List<RestApiErrorResponse>.class);
                throw new WaveConfiguratorException('There was an error in the attempt to save the: ' + this.dashboardToLoad.name + ' dashboard. Cause: ' + r.get(0).message + '.');
            }
            throw new WaveConfiguratorException('There was an error in the attempt to save the: ' + this.dashboardToLoad.name + ' dashboard.');
        }
    }
}