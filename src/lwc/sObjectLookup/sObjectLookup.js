/**
 * @FileName: sObjectLookup
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       9/17/2020         Created
 *-----------------------------------------------------------  
 */

import { LightningElement, api } from 'lwc';
import executeSearch from '@salesforce/apex/XC_LWC_SobjectSearchCtrl.executeSearch';

export default class SObjectLookup extends LightningElement {
    @api label = 'Search';
    @api placeholder = 'Search...';
    @api searchString;
    @api fieldsByObject;
    @api queryFilters;
    @api comparisonField;
    @api displayFields;
    @api resultLimit = 10;
    @api searchSoql = false;
    @api noSharing = false;
    @api overrideResults = false;
    @api disabled = false;

    isLoading = false;
    hideResults = true;
    isError = false;
    message;
    searchResults;
    selectedResult;

    get name() {
        return label.replace(' ', '');
    }

    get showResults() {
        return !this.hideResults && (this.searchResults || this.message) && !this.overrideResults;
    }

    search(event) {
        this.searchString = event.target.value;

        if (!this.searchString || this.searchString.length < 2) {
            this.clearResults();
            return;
        }

        this.isLoading = true;

        let criteria = {
            "searchString" : this.searchString,
            "fieldsByObject" : this.fieldsByObject,
            "queryFilters" : this.queryFilters,
            "comparisonField" : this.comparisonField,
            "displayFields" : this.displayFields,
            "resultLimit" : this.resultLimit,
            "searchSOQL" : this.searchSoql,
            "noSharing" : this.noSharing
        };

        executeSearch({
            criteriaJSON : JSON.stringify(criteria)
        })
        .then(result => {
            let results = JSON.parse(result);

            if (results.length > 0) {
                this.message = '';
                this.hideResults = false;
            }
            else {
                this.hideResults = true;
                this.setMessage('No results found', false);
            }

            this.searchResults = JSON.parse(result);
            this.isLoading = false;
            this.dispatchResults();
        })
        .catch(error => {
            this.setMessage(this.getErrorMessage(error), true);
            this.searchResults = null;
            this.hideResults = true;
            this.isLoading = false;
        });
    }

    dispatchResults() {
        if (this.overrideResults) {
            this.dispatchEvent(new CustomEvent("results", {detail : this.searchResults}));
        }
    }

    focus() {
        this.hideResults = false;
        this.setMessage('', false);
    }

    select(event) {
        let selectedValue = event.detail;

        this.selectedResult = selectedValue.record;
        this.searchString = selectedValue.displayValue;
        this.clearResults();

        this.dispatchEvent(new CustomEvent("select", {detail : this.selectedResult}));
    }

    clearResults() {
        this.hideResults = true;
        this.searchResults = null;
        this.setMessage('', false);
        this.dispatchResults();
    }

    setMessage(message, isError) {
        this.message = message;
        this.isError = isError;
    }

    getErrorMessage(error) {
        return error.body ? error.body.message : JSON.stringify(error);
    }

    @api reset() {
        this.searchString = '';
        this.clearResults();
    }
}