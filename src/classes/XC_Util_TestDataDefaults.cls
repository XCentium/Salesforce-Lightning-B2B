/**
 * @FileName: XC_Util_TestDataDefaults
 * @Description: Field defaults for constructing test data by object type
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       11/1/2019         Created
 *-----------------------------------------------------------  
 */
public inherited sharing class XC_Util_TestDataDefaults {

    // Use the FieldDefaults interface to set up values you want to default in for all objects.
    public interface FieldDefaults {
        Map<String, Object> getFieldDefaults();
    }

    // Fields that must be incremented (ie. unique) when creating lists of sobjects
    public static Map<String, List<String>> incrementFieldMap = new Map<String, List<String>> {
            'Account' => new List<String>{'Name'},
            'Contact' => new List<String>{'LastName', 'Email'},
            'Case' => new List<String>{'Subject'},
            'User' => new List<String>{'LastName'},
            'Product2' => new List<String>{'Name'}
    };

    /*
     * ===============================
     * STANDARD OBJECT DEFAULT CLASSES
     * ===============================
     */

    public class AccountDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                    'Name' => XC_Util_Apex.generateRandomString(),
                    'Phone' => XC_Util_Apex.generateRandomPhoneNumber(),
                    'BillingStreet' => XC_Util_Apex.generateRandomString(),
                    'BillingCity' => XC_Util_Apex.generateRandomString(),
                    'BillingState' => XC_Util_Apex.generateRandomString(2),
                    'BillingPostalCode' => 'A1A1A1',
                    'BillingCountry' => XC_Util_Apex.generateRandomString(),
                    'ShippingStreet' => XC_Util_Apex.generateRandomString(),
                    'ShippingCity' => XC_Util_Apex.generateRandomString(),
                    'ShippingState' => XC_Util_Apex.generateRandomString(2),
                    'ShippingPostalCode' => 'A1A1A1',
                    'ShippingCountry' => XC_Util_Apex.generateRandomString()
            };
        }
    }

    public class ContactDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                    'FirstName' => XC_Util_Apex.generateRandomString(),
                    'LastName' => XC_Util_Apex.generateRandomString(),
                    'Email' => XC_Util_Apex.generateRandomEmail()
            };
        }
    }

    public class Product2Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                    'Name' => XC_Util_Apex.generateRandomString(),
                    'IsActive' => true
            };
        }
    }

    public class ProductCatalogDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                    'Name' => XC_Util_Apex.generateRandomString()
            };
        }
    }

    public class ProductCategoryDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                    'Name' => XC_Util_Apex.generateRandomString()
            };
        }
    }

    public class ProductCategoryProductDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {};
        }
    }

    public class WebStoreDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                    'Name' => XC_Util_Apex.generateRandomString()
            };
        }
    }

    public class WebStoreCatalogDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {};
        }
    }

    /*
     * ===============================
     * CUSTOM OBJECT DEFAULT CLASSES
     * ===============================
     */

    /*
     * ===============================
     * CUSTOM SETTING DEFAULT CLASSES
     * ===============================
     */
}