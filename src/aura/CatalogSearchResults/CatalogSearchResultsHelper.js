({
    prepareView : function(cmp,helper){
       //Prepare DataModel for dataTable
       var queryData=cmp.get('v.dataQueryResult');
       var dataTableData=[];
       for (var i=0;i<queryData.length;i++){
           var line = queryData[i].record;
           if (cmp.get('v.objectName').toLowerCase()=='product2'){
             queryData[i].record.UnitPrice=queryData[i].UnitPrice;
           }
           dataTableData.push(line);
       }
      cmp.set("v.dataTableData",dataTableData);  
	  console.log(dataTableData);          
        
     //Prepare DataModel for Tiles Display Mode
        
       var view={};
       var tilesData=[]; 
      
      var queryCols=cmp.get('v.colsQueryResult');
      console.log(queryCols);
        
     for (var i=0;i<queryData.length;i++){
           var Cells={};
           for (var j=0;j<queryCols.length;j++){
               Cells['F'+(j+1)]={desc :  queryCols[j],
                   			 value : queryData[i].record[queryCols[j].fieldName]};
           }
           Cells.Id=queryData[i].record['Id'];
           if (cmp.get('v.objectName').toLowerCase()=='product2'){
           Cells.Price= {desc : {fieldName:'UnitPrice',type:'currency',label:$A.get('$Label.c.Catalog_Price'),typeAttributes: {currencyCode: cmp.get('v.defaultCurrency')}},
               				value : queryData[i].UnitPrice};
           var imgFieldValue = helper.objKeysToLowerCase(queryData[i].record)[cmp.get('v.imageField').toLowerCase()];    
           Cells.Image= helper.prepareImageLink(cmp,imgFieldValue);     
           }
           tilesData.push(Cells);
      }    
		console.log(tilesData);
        cmp.set("v.tilesData",tilesData);
    },
    
    objKeysToLowerCase : function (obj){
    var key, keys = Object.keys(obj);
    var n = keys.length;
    var newobj={}
    while (n--) {
      key = keys[n];
      newobj[key.toLowerCase()] = obj[key];
    }
    return newobj;    
    },
    
    prepareImageLink : function (cmp,str){
       var prefix = '';
       if (cmp.get('v.isCommunity')) prefix=cmp.get('v.communityPrefix');
       if ((str==null) || (str.length < 5)) return $A.get('$Resource.ProductCatalogNoPic');
       if (str.toLowerCase().includes("http://") || str.toLowerCase().includes('https://')) return str;
       if (str.startsWith('/')) return str; 
       if (str.startsWith("069")) return prefix+'/sfc/servlet.shepherd/document/download/'+str;
       if (str.startsWith("015")) return prefix+'/servlet/servlet.FileDownload?file='+str;
       return $A.get('$Resource.ProductCatalogNoPic'); 
    }, 
    
    prepareSOQLClauses : function (component){
        var filterTree=component.get('v.filterTree');
        
        var rootWhereClause= this.computeSOQLWhereClause(filterTree.rootObjectFilters,filterTree.type);
        var pbeWhereClause = this.computeSOQLWhereClause(filterTree.pbeFilters,filterTree.type);
       
        var pricebookId=component.get('v.pricebookId');
        if (component.get('v.objectName')=="Product2") {
            var PriceFilterClause = 'id in (select Product2id from PricebookEntry';
            var PricebookIdClause = (pricebookId!=null && pricebookId.length>14) ? ' Pricebook2Id = \''+pricebookId+'\' ':'';
            
            var clauseCount = 0;
            if (PricebookIdClause.length > 10) {
                PriceFilterClause+=(clauseCount==0)?' where ':' and ';
                clauseCount++;
                PriceFilterClause+=PricebookIdClause;
            }
            if (component.get('v.activeProductsOnly')) {
                PriceFilterClause+=(clauseCount==0)?' where ':' and ';
                clauseCount++;
                PriceFilterClause+=' isActive=true ';
            }
            if (pbeWhereClause.length > 2) {
                PriceFilterClause+=(clauseCount==0)?' where ':' and ';
                clauseCount++;
                PriceFilterClause+=pbeWhereClause;
            }
            
            
            PriceFilterClause+=')';
           
            if (rootWhereClause.length > 3) {
             rootWhereClause = '('+rootWhereClause+') AND '+'('+PriceFilterClause+')';
            } 
            else rootWhereClause=PriceFilterClause ;
        }
        
        component.set('v.rootWhereClause',rootWhereClause);
        component.set('v.pbeWhereClause',pbeWhereClause);
        
        component.set('v.queryOffset',0);
        
    },
    
	computeSOQLWhereClause : function(section,rootType) {
        var whereClause='';
		for (var i = 0; i < section.length; i++) {
            if (section[i].enabled) {
                if (whereClause.length > 3) whereClause+=' '+rootType+' ';
                var subWhereClause='( ';
				for (var j = 0; j < section[i].filters.length; j++) {
                    if (section[i].filters[j].enabled) {
                        if (subWhereClause.length > 3) subWhereClause+=' '+section[i].type+' ';
                        subWhereClause+=' '+section[i].filters[j].field+' ';
                        subWhereClause+=' '+section[i].filters[j].operator+' ';
                        subWhereClause+=' '+section[i].filters[j].value+' ';
                    }
                }
                subWhereClause+=' ) ';
                whereClause+=subWhereClause;
            }
        }
      return whereClause;  
	},
    
    queryProducts : function (cmp,helper) {
        var action = cmp.get("c.getProducts");
        action.setParams({ sObjectName : cmp.get('v.objectName'),
                           fields : cmp.get('v.fields')+','+cmp.get('v.imageField'),
                           rootWhereClause : cmp.get('v.rootWhereClause'),
                           orderByField:cmp.get('v.orderBy.selectedField'),
                           orderByDir:cmp.get('v.orderBy.selectedDirection'),
                           queryLimit : parseInt(cmp.get('v.queryLimit')),
                           queryOffset : cmp.get('v.queryOffset')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                console.log(result);
                cmp.set('v.dataQueryResult',result.records);
                cmp.set('v.pagination',result.pagination);
                helper.prepareView(cmp,helper);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },
    
    queryColumns : function (cmp,helper) {
    	//getFieldsDesc(String objName, String fields)
     	var action = cmp.get("c.getFieldsDesc");
        action.setParams({ objName : cmp.get('v.objectName'),
                           fields : cmp.get('v.fields') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result=response.getReturnValue();
                var resultJSON=JSON.stringify(result);
                resultJSON=resultJSON.replace(new RegExp('\"fieldType\":','g'),'\"type\":');
                result=JSON.parse(resultJSON);
				cmp.set("v.defaultCurrency",result.defaultCurrencyCode);
                cmp.set("v.colsQueryResult",result.fields);
                cmp.set('v.isCommunity',result.isCommunity);
                cmp.set('v.communityPrefix',result.communityPrefix);
                if (cmp.get('v.objectName').toLowerCase()=='product2'){
                    result.fields.push({fieldName:'UnitPrice',type:'currency',label:$A.get('$Label.c.Catalog_Price'),typeAttributes: {currencyCode: result.defaultCurrencyCode}});                    
          		}
                result.fields.push({label: $A.get('$Label.c.Catalog_action'), type: 'button', initialWidth: 135, typeAttributes: { label: $A.get("$Label.c.Catalog_Select"), name: 'main_button', title: 'Click on main button'}});
                
                this.initOrderBy(cmp,result.fields);
                
              	//restore columns width if columns width found in browser cache (local storage). 
               	result.fields =  this.restoreColumnWidths(result.fields); 
              
                cmp.set('v.dataTableCols',result.fields);
                this.prepareSOQLClauses(cmp);
                this.queryProducts(cmp,helper);
                console.log(result);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
	},
    
   	storeColumnWidths: function (widths) {
        localStorage.setItem('dataTableRowWidths', JSON.stringify(widths));
    },
    getColumnWidths: function () {
        var widths = localStorage.getItem('dataTableRowWidths');

        try {
            widths = JSON.parse(widths);
        } catch(e) {
            return [];
        }
        return Array.isArray(widths) ? widths : [];
    },
    
    restoreColumnWidths: function (columns) {
         var columnsWidths = this.getColumnWidths();
         if (columnsWidths.length === columns.length) {
              return columns.map(function (col, index) {
                 	return Object.assign(col, { initialWidth: columnsWidths[index] });
                    });
        } else return columns;
    },
    initOrderBy: function (cmp,fieldsDesc) {
        var orderBy={};
        orderBy.options = fieldsDesc.map(function (curr, index) {
            return Object.assign({}, { label: curr.label },{ value: curr.fieldName });
        }).filter(function(line) {
            if (line.value==null) return false; // skip
            return true;
        });
     
       orderBy.selectedField= (orderBy.options != null) ? orderBy.options[0].value:  null;
       orderBy.selectedDirection='ASC';
       cmp.set('v.orderBy',orderBy);
       console.log('orderBy');
       console.log(orderBy);  
    },
    tilesSwitch : function (cmp,event){
        cmp.set('v.tableSelected',false);
        cmp.set('v.tilesSelected',true);
        cmp.set('v.displayMode','tiles');
    },
    tableSwitch : function (cmp,event){
        cmp.set('v.tableSelected',true);
        cmp.set('v.tilesSelected',false);
        cmp.set('v.displayMode','table');
    }
    
})