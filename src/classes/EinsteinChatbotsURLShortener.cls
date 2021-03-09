global class EinsteinChatbotsURLShortener {

    public static string shortenUrl(String longUrl) {
        string baseUrl = 'https://api-ssl.bitly.com/v3/shorten?access_token=<YOUR BITLY TOKEN HERE>&format=txt&longUrl=';
        string endpoint = baseUrl + longUrl;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            return response.getBody();
        }else{
            return 'The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus();
        }

    }
    
}