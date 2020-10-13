/**
 * @FileName: XC_LWC_CheckoutWrappers
 * @Description: Wrapper classes for storefront checkout
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       9/8/2020         Created
 *-----------------------------------------------------------  
 */
public inherited sharing class XC_LWC_CheckoutWrappers {

    public class AddressWrapper {
        public String name;
        public String street;
        public String city;
        public String state;
        public String postalCode;
        public String country;
    }
}