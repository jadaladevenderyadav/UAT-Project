import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContacts from '@salesforce/apex/rve_IAExamApproval.getContacts';
import updateContacts from '@salesforce/apex/rve_IAExamApproval.updateContacts';

export default class RveIAExamApproval extends LightningElement {
    @track contacts = [];
    @track selectedContacts = [];
    @track comments = '';
    @track isVerticalHead = false;
    selectAllChecked = false;
    showSelectedContacts = false;
    ifContacts = true;
    originalContacts = [];
    searchTerm = '';

    @wire(getContacts)
    wiredContacts({ error, data }) {
        if (data) {
            console.log('data>>',data)
            this.originalContacts = data.contacts.map(contact => ({
                ...contact,
                Program_Batch_Name: contact.Program_Batch__r ? contact.Program_Batch__r.Name : ''
            }));
            this.isVerticalHead = data.isVerticalHead;
            this.filterContacts();
        } else if (error) {
        }
    }

    handleSearch(event) {
        this.searchTerm = event.target.value.toLowerCase();
        this.filterContacts();
        this.selectedContacts = [];
    }

    filterContacts() {
        this.contacts = this.originalContacts.filter(contact =>
            contact.Name.toLowerCase().includes(this.searchTerm) ||
            contact.SRN_Number__c.toLowerCase().includes(this.searchTerm) ||
            contact.Program_Batch_Name.toLowerCase().includes(this.searchTerm)
        );
    }

    handleCheckboxChange(event) {
        const contactId = event.target.dataset.id;
        const checked = event.target.checked;
        if (checked) {
            const selectedContact = this.contacts.find(contact => contact.Id === contactId);
            this.selectedContacts.push({ ...selectedContact });
        } else {
            this.selectedContacts = this.selectedContacts.filter(contact => contact.Id !== contactId);
        }
    }

    selectAllCheckboxChange(event) {
        const checked = event.target.checked;
        this.selectAllChecked = checked;
        if (checked) {
            this.selectedContacts = [...this.contacts];
        } else {
            this.selectedContacts = [];
        }
    }

    handleNext() {
        this.showSelectedContacts = true;
        this.ifContacts = false;
    }

    handlePrevious() {
        this.showSelectedContacts = false;
        this.ifContacts = true;
        this.selectedContacts = [];
        this.contacts = this.originalContacts.map(contact => ({
            ...contact,
            checked: this.selectedContacts.some(selectedContact => selectedContact.Id === contact.Id)
        }));
    }

    handleCommentChange(event) {
        const contactId = event.target.dataset.id;
        const comment = event.target.value;
        this.selectedContacts = this.selectedContacts.map(contact => {
            if (contact.Id === contactId) {
                contact.Comment = comment;
            }
            return contact;
        });
    }

    handleSave() {
        const updatedContacts = this.selectedContacts.map(contact => ({
            Id: contact.Id,
               Exam_Approval__c: true,
               Date_of_Approval__c: new Date(),
               Description: contact.Comment,
               Checking_Eligibility_for_Exam__c : 'Eligible',
        }));

        updateContacts({ contacts: updatedContacts })
            .then(() => {
                this.showToast('Success', 'Contacts updated successfully', 'success');
            })
            .catch(error => {
                this.showToast('Error', 'Error updating contacts', 'error');
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
        window.location.reload();
        this.showSelectedContacts = false;
        this.ifContacts = true;
        this.selectedContacts = [];
    }

     get isNextButtonDisabled() {
        return this.selectedContacts.length === 0 || this.isVerticalHead;
    }
}