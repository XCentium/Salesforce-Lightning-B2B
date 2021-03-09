/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see https://opensource.org/licenses/BSD-3-Clause
 * 
 * With inspiration and base code from Unnoficial SF: https://unofficialsf.com/load-web-page/
 */
 ({
    invoke : function(component, event, helper) {
        return new Promise(function(resolve, reject) {        
            
            var url = component.get("v.url");
            var mode = component.get("v.mode");
            var target = '_blank';
            var features = '';
//            alert(mode);
            switch (mode) {
                case 'replace':
                    target = '_self';
                    break;
                case 'newWindow':
                    features = features + 'height=100';
                    break;
                default:
                    break;
            }
    
            // window.open( url, target, features );
            location.replace( url, target, features );
            resolve();
               
        });
    }
})