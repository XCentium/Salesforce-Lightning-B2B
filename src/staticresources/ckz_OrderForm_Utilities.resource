// ckz_OrderForm_Utilities
window.util = (function() {

    var orderFormOptions = [
                               {'label': 'New Cart', 'value': 'newcart'},
                               {'label': 'Edit Cart', 'value': 'cart'},
                               {'label': 'New Wish List', 'value': 'newwish'},
                               {'label': 'Edit Wish List', 'value': 'wish'},
                               {'label': 'Copy Order', 'value': 'order'}
                               ];

    var componentLabels = {
                               'wishListsTableHeader' : 'Wish lists',
                               'addToCart' : 'Add to Cart',
                               'addToWishList' : 'Add to Wish List',
                               'newWishListNameLabel' : 'Wish List Name',
                               'newWishListName' : 'New Wish List',
                               'createCart' : 'Create Cart',
                               'createWish' : 'Create',
                               'updateCart' : 'Update Cart',
                               'updateWish' : 'Update',
                               'reloadCart' : 'Reload Cart',
                               'reloadWish' : 'Reload',
                               'productFilter' : 'Filter Products',
                               'productSearch' : 'Product Search'
                           };

    return {
      getLabel: function (key) {
        
		if(componentLabels[key]) {
			return componentLabels[key];
		}
		else {
			return key;
		}
      },

      getOptions: function () {
         return orderFormOptions;
      },

      decodeHtml: function(html) {
          var txt = document.createElement("textarea");
          txt.innerHTML = html;
          return txt.value;
      },
    createAttrsObj: function(component) {
        var attrs = {};

        attrs.contactId = component.get("v.contactId");
        attrs.userId = component.get("v.userId");
        attrs.accountId = component.get("v.accountId");
        attrs.locale = component.get("v.locale");
        attrs.selectedStorefront = component.get("v.selectedStorefront");
        attrs.selectedOrder = component.get("v.selectedOrder");
        attrs.selectedOrderId = component.get("v.selectedOrderId");
        attrs.cartId = component.get("v.cartId");
        attrs.cartEncryptedId = component.get("v.cartEncryptedId");
        attrs.orderType = component.get("v.orderType");
        attrs.currencyCode = component.get("v.currencyCode");
        attrs.selectedObjectName = component.get("v.selectedObjectName");
        attrs.recordId = component.get('v.recordId');
        attrs.userName = component.get('v.userName');
        attrs.accountGroupName = component.get('v.accountGroupName');
        attrs.accountName = component.get('v.accountName');
        attrs.orderItems = component.get('v.orderItems');
        attrs.useCardLayout = component.get('v.useCardLayout');
        attrs.wishListName = component.get('v.wishListName');
        attrs.newCartFirstScreenChoice = component.get('v.newCartFirstScreenChoice');

        return attrs;
    }

  };
}());