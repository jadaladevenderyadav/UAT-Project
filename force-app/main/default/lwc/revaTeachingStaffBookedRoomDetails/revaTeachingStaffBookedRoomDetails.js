import { LightningElement, track } from 'lwc';
import fetchExistingQuartersDetails from '@salesforce/apex/RevaStaffQuartersRequestAndAllotment.fetchExistingQuartersDetails';
import USER_ID from '@salesforce/user/Id';

export default class RevaTeachingStaffBookedRoomDetails extends LightningElement {
    revaQuarterRequests;
    @track revaQuarterRequestId;
    @track revaQuarterRequestStatus=false;
    userId = USER_ID;
    connectedCallback() {
        this.fetchData();
    }
    dataAvl = false;
    async fetchData() {
        try {
            const objResult = await fetchExistingQuartersDetails({ userId: this.userId });
            console.log('objResult ==> ' + JSON.stringify(objResult));
            if (objResult && typeof objResult === 'object' && Object.keys(objResult).length) {
                this.revaQuarterRequests = objResult;
                this.revaQuarterRequestId = objResult.Id;
                if(objResult.Status__c == 'Room Allotted'){
                    this.revaQuarterRequestStatus = true;
                }
                console.log('revaQuarterRequestId****'+this.revaQuarterRequests.Id);
            }
            this.dataAvl = true;
        } catch (error) {
            this.dataAvl = true;
        }
    }
}