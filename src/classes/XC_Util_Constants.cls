/**
 * @FileName: XC_Util_Constants
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       7/14/2020         Created
 *-----------------------------------------------------------  
 */
public with sharing class XC_Util_Constants {
    public static final Map<String,String> CHECKOUT_EXTERNAL_SERVICE_TYPES = new Map<String,String>{
            'Inventory' => 'CHECK_INVENTORY',
            'Shipping' => 'COMPUTE_SHIPPING',
            'Price' => 'COMPUTE_PRICE',
            'Tax' => 'COMPUTE_TAXES'
    };
}