import { LightningElement, wire } from 'lwc';
import getContacts from '@salesforce/apex/FetchCampusRecData.getContacts';
import STUDENTPORTALICONS from '@salesforce/resourceUrl/SR_STUDENTPORTALASSETS';
const PAGE_SIZE = 4;
// const baseImageUrl = `${STUDENTPORTALICONS}/StudentPortalAssests/Icons/Profile-Menu-Icons/`;
const baseImageUrl = `${STUDENTPORTALICONS}/StudentPortalAssests/Icons/Navigation-Icons/`;
const baseImageUrlmale = `${STUDENTPORTALICONS}/StudentPortalAssests/Icons/Profile-Menu-Icons/`;
export default class RevStdNoticeBoard extends LightningElement {

    contacts = [];
    displayedContacts = [];
    currentPage = 1;
    showButtonIconUrl = `${baseImageUrl}show.png`;
    hideButtonIconUrl = `${baseImageUrl}hide.png`;
    nextButtonIconUrl = `${baseImageUrl}next.png`;
    previousButtonIconUrl = `${baseImageUrl}previous.png`;
    userIconUrl = `${baseImageUrlmale}male.png`;

    @wire(getContacts)
    wiredContacts({ error, data }) {
        if (data) {
            this.contacts = data;
            this.displayedContacts = this.getContactsForPage(this.currentPage);
        } else if (error) {
            // Handle error
        }
    }
    getContactsForPage(page) {
        const startIndex = (page - 1) * PAGE_SIZE;
        const endIndex = startIndex + PAGE_SIZE;
        return this.contacts.slice(startIndex, endIndex);
    }
    get isFirstPage() {
        return this.currentPage === 1;
    }
    get isLastPage() {
        return this.currentPage >= Math.ceil(this.contacts.length / PAGE_SIZE);
    }
    nextPage() {
        if (!this.isLastPage) {
            this.currentPage++;
            this.displayedContacts = this.getContactsForPage(this.currentPage);
        }
    }
    previousPage() {
        if (!this.isFirstPage) {
            this.currentPage--;
            this.displayedContacts = this.getContactsForPage(this.currentPage);
        }
    }
}