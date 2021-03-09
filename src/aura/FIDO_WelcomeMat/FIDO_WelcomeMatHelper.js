({
	calculateWelcome : function(component, event, helper,initialvalue) {
		var BrandCompleted = component.get("v.BrandCompleted");
        var PersonaCompleted = component.get("v.PersonaCompleted");
        var SolutionsCompleted = component.get("v.SolutionsCompleted");
        var ResourcesCompleted = component.get("v.ResourcesCompleted");
        var PartnersCompleted = component.get("v.PartnersCompleted");
        var VideosCompleted = component.get("v.VideosCompleted");
        var SetupCompleted = component.get("v.SetupCompleted");
        var FeaturesCompleted = component.get("v.FeaturesCompleted");
        
        var firsttotal = (BrandCompleted + PersonaCompleted + SolutionsCompleted + ResourcesCompleted + PartnersCompleted  + SetupCompleted + FeaturesCompleted + VideosCompleted);
        var percenttotal = (((BrandCompleted + PersonaCompleted + SolutionsCompleted + ResourcesCompleted + PartnersCompleted  + SetupCompleted + FeaturesCompleted + VideosCompleted)/8) * 100);
        component.set("v.CompetedTotal",firsttotal);
        component.set("v.CompetedTotalPercent",percenttotal);
	}
})