@IsTest
public class FacebookHandlerTest {
    
    private static Auth.UserData data {get;set;}
    
    @IsTest(SeeAllData=true)
    public static void testSaveAndUpdateUser(){
        
        User testUser = [SELECT Id from User where Name = 'Elliot Executive' LIMIT 1];
        
        Map<String, String> attributeMap = new Map<String, String>();
        
        String email = generateRandomString(5)+'@test.com';
        
        attributeMap.put('picture','{data={is_silhouette=false, url=}}');
        attributeMap.put('id','11111111111111');
        attributeMap.put('email',email);
        //attributeMap.put('friends', '{summary={total_count=1}, data=[{}], paging={}}');
        //
        data = new Auth.UserData(null, generateRandomString(5), generateRandomString(5), null, email,null,null,null,'Facebook',null,attributeMap);
        
        System.runAs(testUser) {
            FacebookHandler fbHandler = new FacebookHandler();
            
            User user = fbHandler.createUser(null, data);
            
            System.assertEquals(email, user.email);
            
            //create user again to test branch
            fbHandler.createUser(null, data);
            
            System.assertEquals(email, user.email);
            
            fbHandler.updateUser(user.Id, null, data);
            
            System.assertEquals(email, user.email);
        }
    }
    
    @IsTest
    public static void testGetImage(){
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        FacebookHandler fbHandler = new FacebookHandler();
        Blob b = fbHandler.getImage('https://test.photo.com');
        System.assertEquals('StringToBlob', b.toString());
        
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }    
}