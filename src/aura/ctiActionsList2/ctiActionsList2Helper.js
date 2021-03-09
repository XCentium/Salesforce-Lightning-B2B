({
	setup_flowItems : function(component, event, data) {
		var urlItems = [];
		var Label1 = data['/lightningDuringURLActions/Label1'];
		var Url1 = data['/lightningDuringURLActions/Url1'];
		var Label2 = data['/lightningDuringURLActions/Label2'];
		var Url2 = data['/lightningDuringURLActions/Url2'];
		var Label3 = data['/lightningDuringURLActions/Label3'];
		var Url3 = data['/lightningDuringURLActions/Url3'];
		var Label4 = data['/lightningDuringURLActions/Label4'];
		var Url4 = data['/lightningDuringURLActions/Url4'];

		if(Label1 != null && Label1 != '' && Url1 != null && Url1 != '') {
			urlItems.push({ theLabel: Label1, theValue: Url1 });
		}
		if(Label2 != null && Label2 != '' && Url2 != null && Url2!= '') {
			urlItems.push({ theLabel: Label2, theValue: Url2 });
		}
		if(Label3 != null && Label3 != '' && Url3 != null && Url3 != '') {
			urlItems.push({ theLabel: Label3, theValue: Url3 });
		}
		if(Label4 != null && Label4 != '' && Url4 != null && Url4 != '') {
			urlItems.push({ theLabel: Label4, theValue: Url4 });
		}

		component.set('v.urlItems', urlItems);
	}

})