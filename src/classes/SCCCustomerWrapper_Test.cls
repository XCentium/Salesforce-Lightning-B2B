@IsTest
public class SCCCustomerWrapper_Test {

    @TestSetup
    static void setup(){

    }

    @IsTest
    static void testSCCCustomerWrapper(){
        SCCCustomerWrapper customerWrapper = new SCCCustomerWrapper('Gender', '1');
        customerWrapper = new SCCCustomerWrapper('Gender', 'SheMale');
        customerWrapper = new SCCCustomerWrapper('myGender', 'Male');
    }

}