/**
 * @FileName: utilsCommerce
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       7/10/2020         Created
 *-----------------------------------------------------------  
 */

import addItemToCart from '@salesforce/apex/XC_LWC_CartCtrl.addItemToCart';

class UtilsCommerce {

    addItemToCart(event) {
        addItemToCart({
            productId: event.detail,
            quantity: "1"
        })
        .then(result => {
            console.log(result);
            console.log('no errors');
        })
        .catch(error => {
            this.error = error;
            console.log('errors');
        });
    }
}

export { UtilsCommerce }