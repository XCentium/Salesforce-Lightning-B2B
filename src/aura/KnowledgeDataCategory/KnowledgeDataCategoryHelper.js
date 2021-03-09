({
    hasClass : function(element, class_name){
	    return (element.className.indexOf(class_name) > -1);
	},
    toggleSubcategories: function(clicked_elem, helper){
        if(helper.hasClass( clicked_elem , 'category-item') || helper.hasClass( clicked_elem , 'current-item')){
            clicked_elem = clicked_elem.srcElement ? clicked_elem.srcElement.parentNode : clicked_elem.parentNode;
        }
        var children = clicked_elem.childNodes;
        var filter_item_overlay = null;
        for (var i=0; i < children.length; i++) {
            if (helper.hasClass( children[i] , 'filter-item-overlay') ) {
                filter_item_overlay = children[i];
                break;
            }
        }
        var hidden_class = 'hidden';
        if( helper.hasClass( filter_item_overlay, hidden_class ) ){
            $A.util.removeClass(filter_item_overlay, hidden_class);
        }else{
            $A.util.addClass(filter_item_overlay, hidden_class);
        }
    },
    hideOtherSubcategories: function(clicked_elem, helper){
        if(helper.hasClass( clicked_elem , 'category-item') || helper.hasClass( clicked_elem , 'current-item')){
            clicked_elem = clicked_elem.srcElement ? clicked_elem.srcElement.parentNode : clicked_elem.parentNode;
        }

        var children1 = clicked_elem.srcElement ? clicked_elem.srcElement.parentNode.childNodes : clicked_elem.parentNode.childNodes;
        for(var i=0; i<children1.length; i++){
            if(children1[i].id != clicked_elem.id){
                children2 = children1[i].childNodes;
                for(var j=0; j<children2.length; j++){
                    if (helper.hasClass( children2[j] , 'filter-item-overlay') ) {
				        $A.util.addClass(children2[j], 'hidden');
                    }
                }
            }
        }
    },
    hideAllSubcategories: function(){
        var overlay_arr = document.getElementsByClassName('filter-item-overlay');
        for(var i=0; i<overlay_arr.length; i++){
			$A.util.addClass(overlay_arr[i], 'hidden');
        }
    },
    showCurrentItem : function(clicked_elem, helper) {
        var selected_subcategory = clicked_elem.dataset.subcategoryName;
        var selected_category_api = clicked_elem.dataset.categoryApiName;
        var selected_subcategory_api = clicked_elem.dataset.subcategoryApiName;

        var parent = helper.getFilterItemElem(clicked_elem);
        var children = parent.childNodes;
        for(var i=0; i<children.length; i++){
            if (helper.hasClass( children[i] , 'current-item') ) {
                helper.setCurrentItemValue( children[i], selected_subcategory, selected_category_api, selected_subcategory_api);
				$A.util.removeClass( children[i], 'hidden');
            }
            if (helper.hasClass( children[i], 'category-item') ){
				$A.util.addClass( children[i], 'hidden');
            }
        }
	},
    setCurrentItemValue : function(elem, text, category_api, subcategory_api){
		elem.innerHTML = text;
        elem.dataset.categoryApiName = category_api;
        elem.dataset.subcategoryApiName = subcategory_api;
    },
    getFilterItemElem : function(clicked_elem){
        return document.getElementById('filter_item_' + clicked_elem.dataset.categoryApiName);
    },
    hideCurrentItem : function(clicked_elem, helper){
        var parent = helper.getFilterItemElem(clicked_elem);
        var children = parent.childNodes;
        for(var i=0; i<children.length; i++){
            if (helper.hasClass( children[i] , 'current-item') ) {
                helper.setCurrentItemValue( children[i], '', '', '');
                $A.util.addClass( children[i], 'hidden');
            }
            if (helper.hasClass( children[i], 'category-item') ){
				$A.util.removeClass( children[i], 'hidden');
            }
        }
    },
    getSelectedDataCategories : function(helper){
        var data_category_arr = [];
        var current_item_arr = document.getElementsByClassName('current-item');
        for(var i=0; i<current_item_arr.length; i++){
            if(current_item_arr[i].dataset.categoryApiName){
                data_category_arr.push({
                    parent_api: current_item_arr[i].dataset.categoryApiName,
                    api_name:  current_item_arr[i].dataset.subcategoryApiName
                });
            }
        }
        return data_category_arr;
    }
})