({
	delete : function(component, event, helper) {
        
        let deleteArticle = component.getEvent("deleteIndex")
        
        deleteArticle.setParams({
            index: component.get('v.newsArticleIndex')
        })
        
        deleteArticle.fire()
        
		component.destroy()
	}
})