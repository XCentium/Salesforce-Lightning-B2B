({
	doInit : function(component, event, helper) {
        component.set('v.mapMarkers', [
            {
                location: {
                    'Street': component.get('v.GmapAddress'),
                    'City': component.get('v.GmapCity'),
                    'State': component.get('v.GmapState'),
                    'PostalCode': component.get('v.GmapPostalCode'),
                    'Country': component.get('v.GmapCountry')
                },
                title: component.get('v.GmapAddress') + ', ' + component.get('v.GmapCity') + ' ' + component.get('v.GmapState') + ' ' + component.get('v.GmapPostalCode') + ', ' + component.get('v.GmapCountry')
            }
        ]);
        component.set('v.zoomLevel', 16);
	}
})