import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class MenuItemSelector extends LightningElement {
    @api menuType;
    @api picklistValuesFromParent = {};
     searchKey = '';
    @track filteredPicklistValues = [];
    @track picklistValues = [];
    @track selectedValues = [];
    @api startTime;
    @api endTime;
    @track errorMessage = '';

    connectedCallback() {
         this.picklistValues = this.picklistValuesFromParent[this.menuType];  
    }

    handleSearch(event) {
        this.searchKey = event.target.value.toLowerCase();
        if (this.searchKey) {
            this.filteredPicklistValues = this.picklistValues.filter(value =>
                value.toLowerCase().includes(this.searchKey)
            );
        } else {
            this.filteredPicklistValues = [];
        }
    }

    handleSelect(event) {
        const selectedValue = event.target.label;
        if (!this.selectedValues.includes(selectedValue)) {
            this.selectedValues = [...this.selectedValues, selectedValue];
            this.dispatchSelectionChangeEvent();
            this.clearSearch(); 
        }
    } 

    dispatchSelectionChangeEvent() {
        this.dispatchEvent(new CustomEvent('selectionchange', {
            detail: {
                menuType: this.menuType,
                selectedItems: this.selectedValues,
                startTime: this.startTime,
                endTime: this.endTime
            }
        }));
    }

    handleStartTimeChange(event) {
        this.startTime = event.target.value;
        if (this.validateTimes()) {
            this.dispatchSelectionChangeEvent();
        }
    }

    handleEndTimeChange(event) {
        this.endTime = event.target.value;
        if (this.validateTimes()) {
            this.dispatchSelectionChangeEvent();
        }
    }

    validateTimes() {
        if (this.startTime && this.endTime && this.endTime <= this.startTime) {
            this.showToast('Error', 'End time should be greater than Start time', 'error');
            return false;
        }
        return true;
    }

    handleRemove(event) {
        const valueToRemove = event.currentTarget.dataset.value;
        this.selectedValues = this.selectedValues.filter(value => value !== valueToRemove);
        this.dispatchEvent(new CustomEvent('selectionchange', {
            detail: { menuType: this.menuType, selectedItems: this.selectedValues }
        }));
    }

    clearSearch() {
        this.searchKey = '';
        this.filteredPicklistValues = [];
    }
    @api
    resetValues() {
        this.selectedValues = [];
        this.startTime = '';
        this.endTime = '';
        this.clearSearch(); 
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

}