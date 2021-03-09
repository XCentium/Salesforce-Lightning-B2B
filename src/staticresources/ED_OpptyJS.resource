
(function(){

	function round(value, precision) {
		let multiplier = Math.pow(10, precision || 0);
		return Math.round(value * multiplier) / multiplier;
	}

	function formatDate(inputDate) {
		let date = new Date(inputDate);
		if (!isNaN(date.getTime()) ){
			return date.getMonth() + 1 + '/' + date.getDate() + '/' + date.getFullYear();
		}
	}

	function populateTable(input = 'No recommendations detected') {
		let inputArr;
		if(input.charAt(1)=='p'){
			inputArr = input.split('<p>');
		} else {
			inputArr = input.split('<br>');
		}

		let outputHTML = "";

		for (let i = 0; i < inputArr.length; ++i) {
			let score, desc, color = 'slds-text-color_error';
			let cleanStr = inputArr[i].replace(/%/g,'').replace(/__c/g,'').replace(/_/g,' ').replace('+ ','+').replace('- ','-').trim();
			cleanStr = cleanStr.replace(/\b[a-z]/g,function(f){return f.toUpperCase();});

            // handle format of other smaller phrases
            if(cleanStr.indexOf('other smaller') > 0) {
            	score = cleanStr.substr(0,1) + ' ' + cleanStr.substr(cleanStr.lastIndexOf(' '));
            	desc = cleanStr.substr(1,cleanStr.lastIndexOf(' '));
            } else if(cleanStr.startsWith('From The Baseline') > 0){
            	score = cleanStr.split(',')[1].replace('+','+ ').replace('-','- ').replace(' + ','+').replace(' - ','-');
            	desc = cleanStr.split(',')[0]
            } else {
            	score = cleanStr.substr(0, cleanStr.indexOf(' ')).replace('+','+ ').replace('-','- ');
            	desc = cleanStr.substr(cleanStr.indexOf(' ') + 1).replace('Because','').replace('If You Change','Change');
            }
            
			if(score.startsWith('+')) color = 'slds-text-color_success';
            if(score.startsWith('N')){
            	outputHTML += '<div class="slds-truncate slds-text-body_regular slds-m-vertical_xx-small slds-text-color_weak" title="'  + desc + '">' + score + ' ' + desc + '</div>'
            	document.getElementsByClassName('meetingButton')[0].style.display = 'none';
            } else if (score.startsWith('+') || score.startsWith('-') ){
            	outputHTML += '<div class="slds-item_label ac-sdd-left-col slds-truncate slds-text-body_regular slds-m-vertical_xx-small ' + color + '">' + score + '</div>';
            	outputHTML += '<div class="slds-item_detail ac-sdd-right-col slds-truncate slds-text-body_regular slds-m-vertical_xx-small slds-text-color_weak" title="' + desc + '">' + desc + '</div>'
            }
        }
        return outputHTML;
    }

    window.myUtil = {
		populateTable: populateTable,
		round: round,
		formatDate: formatDate
	}
})();
