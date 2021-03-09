({
	getArticles : function(component, page) {
        page = page || 1;
        var action = component.get("c.searchAll");
		action.setParams({
      		"searchKey": component.get("v.searchKey"),
            "pageNumber": page
    	});
    	action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            component.set("v.articles", result.articles);
            component.set("v.page", result.page);
            component.set("v.total", result.total);
            component.set("v.pages", Math.ceil(result.total/5));
    	});
    	$A.enqueueAction(action);
	}
})