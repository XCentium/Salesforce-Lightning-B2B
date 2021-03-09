global class DemoConfiguratorAddPermSet {
    global class PermSet {
        @InvocableVariable
        global String PermSetToAdd;
    }
    global class PermResponse {
        @InvocableVariable
        global Boolean Status;
    }
    /** ADD A PERMISSION SET ASSIGNED TO THE ADMIN USER ***/
    @InvocableMethod(label='SetPermSet' description='Demo Configurator V2 | Add or Remove a Permission Set from Admin User')
    global static List<PermResponse> DemoConfiguratorV2ADDPermSet(List<PermSet> PermInputs) {
        List<PermResponse> responses = new List<PermResponse>();
        for(PermSet perminput : PermInputs) {
            RCGIDO_DataFix.AssignPermissionSet(perminput.PermSetToAdd,'Admin');
            PermResponse response = new PermResponse();
            response.Status = true;
            responses.add(response);
        }
        return responses;
    }
}