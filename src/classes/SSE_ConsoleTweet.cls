public with sharing class SSE_ConsoleTweet {
    public String sitesURL {get;set;}
    private final Case thisCase;
    public SocialPost socialPost {get; set;}
    Contact con;        // contact for this case
    SocialPersona sp;   // social persona for contact on case
    String caseId;
    String name;
    
    public boolean cantTweet {get;set;}
    public Integer stringLength {get;set;}

    public SSE_ConsoleTweet(ApexPages.StandardController controller) {
        //sitesURL = 'http://sdo-demo-main-13c5e6534b5.force.com';
        caseId = ApexPages.CurrentPage().getparameters().get('id');
        thisCase = [SELECT id, contactId, AccountId, contact.name, Account.name FROM Case WHERE id =: caseId limit 1];
        socialPost = new SocialPost();
        cantTweet = true;
        stringLength = 0;
        List<SocialPersona> personas;

        try {
            personas = [SELECT Name, id FROM SocialPersona WHERE parentId =: thisCase.ContactId AND Provider =: 'Twitter' limit 1];

            // person account
            if (personas.size() == 0) {
                System.debug('hi');
                System.debug('account id is: ' + thisCase.accountId);
                personas = [SELECT Name, id FROM SocialPersona WHERE parentId =: thisCase.AccountId AND Provider =: 'Twitter' limit 1];
                name = thisCase.Account.name;
            } else {
                name = thisCase.Contact.name;
            }

            if (personas.size() != 0) {
                sp = personas[0];
                cantTweet = false;
                socialPost.parentid = thisCase.id;
                socialPost.headline = 'tweet ' + name;
                socialPost.name = 'tweet ' + name;
                socialPost.content = '@'+sp.name + ' ';
                socialPost.personaid = sp.id;
                stringLength = socialPost.content.length();
            }

        } catch (exception e) {}
    }
    
    /***** save post and post to twitter if a handle is in lauren's social persona *****/
    public void saveMyCase(){
        System.debug('content is: ' + socialPost.content);
        if (socialPost.content == '' || socialPost.content == ' ' || socialPost.content == null) {
            System.debug('Text not input so tweet not sent.');
            return;
        }
        
        try {
            postToTwitter();
        } catch(exception e) {
            System.debug('publishing post failed - \n' + e);
        }
        try {
            insert socialPost;
        } catch(exception e) {
            System.debug('exception when trying to save post - \n' + e);
        }
        
        socialPost = new socialPost();
        socialPost.parentid = thisCase.id;
        socialPost.headline = 'tweet ' + name;
        socialPost.name = 'tweet ' + name;
        socialPost.content = '@'+sp.name + ' ';
        socialPost.personaid = sp.id;
        stringLength = socialPost.content.length();
    }
    
    public boolean postToTwitter() {
        String method = 'POST';         // http method
        String bodyString = encode(socialPost.content); // status msg aka request body
        
        // build http request
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint('https://api.twitter.com/1.1/statuses/update.json');
        req.setHeader('Connection', 'close');
        req.setHeader('User-Agent', 'OAuth gem v0.4.4');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Host', 'api.twitter.com');
        req.setBody('status=' + bodyString);
        System.debug('body is: ' + req.getBody());
        
        // build parameter map
        Map<String, String> params = new Map<String, String>();
        params.put('oauth_nonce', String.valueOf(Crypto.getRandomLong()));
        params.put('oauth_timestamp', String.valueOf(DateTime.now().getTime()/1000));
        params.put('oauth_version', '1.0');
        params.put('oauth_signature_method', 'HMAC-SHA1');
        params.put('oauth_token', '1095901237-0OBLhxltDN2QYfx3NJWiLqsMDlOoP5KjvKltwNP');
        params.put('oauth_consumer_key', 'JkTghuYPeEARafAIxIeh8g');
        
        String baseString = buildBaseString(params, req, bodyString);
        
        // get signature
        Blob sig =  Crypto.generateMac('HmacSHA1', Blob.valueOf(baseString), Blob.valueOf('hBjh6ldbtchX7PqGGKcr5Q8GTxTveCML8vQO5hYEqU'+'&'+ 'aM9bKteMV26oeFW4FoSEmOqMmJtjCnQCiBdCDZ1lg'));
        String signature = EncodingUtil.urlEncode(EncodingUtil.base64encode(sig), 'UTF-8');
        System.debug('signature: ' + signature);
        
        // add signature to param list
        params.put('oauth_signature', signature);
        
        // build auth string for header
        List<String> keys = new List<String>();
        keys.addAll(params.keySet());
        keys.sort();
        String auth = 'OAuth ';
        auth = auth + keys.get(0) + '="'+params.get(keys.get(0)) + '"';
        for (Integer i=1; i < keys.size(); i++) {
            auth = auth + ', '+ keys.get(i) + '="'+params.get(keys.get(i)) + '"';
        }
        req.setHeader('Authorization', auth);
        System.debug('auth string: ' + auth);
        
        // send http request
        Http http = new Http();
        HTTPResponse response = http.send(req);
        System.debug('HTTP response: ' + response.toString());
        System.debug('HTTP response body: ' + response.getBody());
        return false;
    }
    
    /***** build base string for signature *****/
    private String buildBaseString(Map<String, String> paramMap, HttpRequest req, String bodyString) {
        Map<String, String> params = paramMap.clone();
        params.put('status', bodyString);
        
        // list of parameter keys
        List<String> keys = new List<String>();
        keys.addAll(params.keySet());
        keys.sort();
        
        // build basestring
        String baseString = keys.get(0) + '=' + params.get(keys.get(0));
        
        for (Integer i=1; i<keys.size(); i++) {
            baseString = baseString + '&' + keys.get(i) + '=' + params.get(keys.get(i));
        }
        System.debug('param string: ' + baseString);
        
        baseString = req.getMethod().toUpperCase() + '&' + EncodingUtil.urlEncode(req.getEndpoint(), 'UTF-8') + '&' + EncodingUtil.urlEncode(baseString, 'UTF-8');
        System.debug('base string: ' + baseString);
        
        return baseString;
    }

    /****** url encode string and replace + with %20 ********/
    public String encode(String s) {
        return EncodingUtil.urlEncode(s, 'UTF-8').replace('+', '%20');
    }
    
    /*
    public void addArticle() {
        KnowledgeArticleVersion kav;
        List<CaseArticle> cas = [SELECT KnowledgeArticleId FROM CaseArticle WHERE CaseId =: caseId];
        String baseURL = ' ' + sitesURL + '/PKB2/articles/';
        String buildURL = '';
        
        for (CaseArticle ca: cas) {
            kav = [SELECT id, urlName, ArticleType, title FROM KnowledgeArticleVersion WHERE KnowledgeArticleId =: ca.KnowledgeArticleId AND publishStatus =: 'Online' limit 1];
            if (kav != null) {
                buildURL = baseURL + kav.ArticleType.removeEnd('__kav') + '/' + kav.UrlName;
                articleList.add(buildURL);
            }
            kav = null;
            buildURL = '';
        }
        
        if (articleList.size() > 0) {
            socialPost.content += articleList.get(0);
            stringLength = socialPost.content.length();
        }
    }
    */
}