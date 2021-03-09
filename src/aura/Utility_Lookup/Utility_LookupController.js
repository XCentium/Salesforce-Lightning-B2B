({
    handleLookup : function(component, event, helper) {
        let isRunning = component.get('v.isRunning')
        let searchTerm = component.get('v.searchTerm')

        if(searchTerm.length > 2 && !isRunning){
            component.set('v.isRunning', true)
            console.log(component.get('v.lookupObject'), component.get('v.lookupField'), component.get('v.searchTerm'), component.get('v.filters'));
            helper.sendRequest(component,'c.getLookup',{
                lookupObject: component.get('v.lookupObject'),
                lookupField: component.get('v.lookupField'),
                searchTerm: component.get('v.searchTerm'),
                filters: component.get('v.filters')
            }, function(component, lookupResults){
                let lookupValues = []
                let lookupField = component.get('v.lookupField')
                
                lookupResults.map(function(lookupResult){
                    lookupValues.push({
                        value: lookupResult['Id'],
                        label: lookupResult[lookupField]
                    })
                })
                console.log('lookupValues',lookupValues)
                component.set('v.lookupValues',lookupValues)
                component.set('v.isShowing', true)
                setTimeout($A.getCallback(function(){
                    component.set('v.isRunning', false)
                }), 250)
            })
        }
    },
    handleLookupSelect : function(component, event, helper){
        let target = event.target
        let label = target.getAttribute('data-label')
        let value = target.getAttribute('data-value')
        
        component.set('v.boundValue', value)
        component.set('v.searchTerm', label)
        component.set('v.isShowing', false)
    },
    clear: function(component){
        component.set('v.boundValue', '')
        component.set('v.searchTerm', '')
        component.set('v.isRunning', false)
        component.set('v.isShowing', false)
    }
})