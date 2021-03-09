({
    VERBOSE: true,
    renderPanel : function(component, params) {
        let self = this;
        component.set('v.showSpinner', true);
        
        if(self.VERBOSE) console.log('Rendering ' + params.type, JSON.stringify(params.attributes));
        
        if (params.toast) {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(params.toast);
            toastEvent.fire();
        }
        
        if ( params.type ) {
            $A.createComponent(params.type, params.attributes, function(newPanel) {
                if (component.isValid()) {
                    component.set('v.body', [ newPanel ]);
                    self.hideSpinner(component)
                }
            });
        } else {
            self.hideSpinner(component)
        }
    },
    showSpinner: function(component){
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            try{
            	component.set('v.showSpinner', true);
                resolve();
            } catch(err){
                reject(err);
            }
            
        }))
    },
    hideSpinner: function(component){
        let self = this;
        return new Promise($A.getCallback(function(resolve,reject){
            try{
            	component.set('v.showSpinner', false);
                resolve();
            } catch(err){
                reject(err);
            }
            
        }))
    }
})