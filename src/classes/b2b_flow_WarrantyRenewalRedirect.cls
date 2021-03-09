public with sharing class b2b_flow_WarrantyRenewalRedirect {

    @InvocableMethod(Label='B2B Get Warranty Product URL')
    public static List<Response> doIt(List<Request> requests) {

        List<Response> responses = new List<Response>();

        for(Request request : requests) {

            Response response = fetchInfo(request.communityName, request.assetRecordId);

            responses.add(response);
        }

        return responses;

    }

    private static Response fetchInfo(String community, String recordId){

        Response response = new Response();

        String baseUrl = b2b_util_WarrantyRenewal.fetchCommunityUrl(community);
        String warrantySku = b2b_util_WarrantyRenewal.getWarrantyProduct(recordId);

        response.baseUrl = baseUrl;
        response.warrantySku = warrantySku;

        List<String> urlParts = baseUrl.split('[/]');

        String redirectUrl = 'https://' + urlParts[2] + '/' + urlParts[3] + '/ccrz__ProductDetails?sku=' + warrantySku;

        response.redirectUrl = redirectUrl;

        return response;
    }

    public class Request {

        @InvocableVariable(Required=true)
        public String assetRecordId;

        @InvocableVariable(Required=true)
        public String communityName;
    }

    public class Response {

        @InvocableVariable
        public String warrantySku;

        @InvocableVariable
        public String baseUrl;

        @InvocableVariable
        public String redirectUrl;

        public Response() {
            baseUrl = '';
            redirectUrl = '';
        }
    }

}