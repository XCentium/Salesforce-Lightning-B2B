function updateCategoryField() {
    var tooshort = false;
    var keywordValue = "";
    $$(".keywordField").each(
        function(keywordField) {
            keywordValue = keywordField.getValue().replace(/^\s\s*/, '').replace(/\s\s*$/, '');
            keywordField.setValue(keywordValue);
            if (keywordValue.length==1) {
                alert("Error: Please enter a search string at least 2 characters long.");
                tooshort = true;
                keywordField.focus();
            }
        }
    );


    if (tooshort) {
        return false;
    }

    $$(".categoryHiddenInputField").each(
        function(categoryField) {
            categoryField.setValue($('categorySelect').getValue());
         }
    );
    return true;
}

function clearKeyword() {
    var clearOK= false;
    $$(".keywordField").each(
        function(keywordField) {
            if (keywordField.getValue()!='') {
                keywordField.clear();
                  clearOK = true;
              }
         }
    );
    return clearOK;
}


function submitEnter(event)  {
    var keycode;
    if (window.event) keycode = window.event.keyCode;
    else if (event) keycode = event.which;
    else return true;

    if (keycode == 13) {
        if (updateCategoryField())
            searchJs();
        return false;
    }
    return true;
}