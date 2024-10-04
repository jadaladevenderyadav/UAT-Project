import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import STUDENTPORTALICONS from '@salesforce/resourceUrl/NTS_Portal_Static_Resources';
import checkIfMessAdmin from '@salesforce/apex/RevaMealBookingController.checkIfMessAdmin';
import checkIfGuestHouseManager from '@salesforce/apex/RevaGuestHouseController.checkIfGuestHouseManager';
import isCaseOwner from '@salesforce/apex/CaseController.isCaseOwner';
import hasExistingHostelRequest from '@salesforce/apex/RevaHostelRequestController.hasExistingHostelRequest';
 
 
const baseImageUrl = `${STUDENTPORTALICONS}/NTS_Portal_Static_Resources/NTS_Icons/`;
 
export default class RevInfraSupportHomeMenuTile extends NavigationMixin(LightningElement) {
    @track menuList = [];
 
    connectedCallback() {
        this.initializeMenu();
    }
 
    async initializeMenu() {
        try {
            const hasRevaMessPermission = await checkIfMessAdmin();
            const hasGuestHouseManager = await checkIfGuestHouseManager();
            const hasCaseOwner = await isCaseOwner();
            const hasHostelrequest = await hasExistingHostelRequest();

            const allMenuItems = [
                {
                    Id: 'InfraSupportRequest',
                    headingName: 'INFRA SUPPORT REQUEST',
                    url: `${basePath}/infra-support-request`,
                    imageUrl: `${baseImageUrl}infra-support-request.png`,
                    body: {
                        item1: {
                            headingText: 'Request ID',
                            headingValue: 'N/A'
                        },
                        item2: {
                            headingText: 'Infra ID',
                            headingValue: 'N/A'
                        },
                    }
                },
                /*{
                    Id: 'HostelSupportRequest',
                    headingName: 'HOSTEL SUPPORT REQUEST',
                    url: `${basePath}/hostel-support-request`,
                    imageUrl: `${baseImageUrl}hostel-support-request.png`,
                    body: {
                        item1: {
                            headingText: 'Support ID',
                            headingValue: 'N/A'
                        },
                        item2: {
                            headingText: 'Support Status',
                            headingValue: 'N/A'
                        }
                    }
                },*/
                {
                    Id: 'GuestHouseBooking',
                    headingName: 'GUEST HOUSE BOOKING',
                    url: `${basePath}/guest-house-booking`,
                    imageUrl: `${baseImageUrl}guest-house-booking.png`,
                    body: {
                        item1: {
                            headingText: 'Support ID',
                            headingValue: 'N/A'
                        },
                        item2: {
                            headingText: 'Support Status',
                            headingValue: 'N/A'
                        }
                    }
                },
                /*{
                    Id: 'MealBooking',
                    headingName: 'MEAL BOOKING',
                    url: `${basePath}/meal-booking`,
                    imageUrl: `${baseImageUrl}book-meals.png`,
                    body: {
                        item1: {
                            headingText: 'Support ID',
                            headingValue: 'N/A'
                        },
                        item2: {
                            headingText: 'Support Status',
                            headingValue: 'N/A'
                        }
                    }
                },*/
                {
                    Id: 'EventHallBooking',
                    headingName: 'EVENT HALL BOOKING',
                    url: `${basePath}/event-hall-booking`,
                    imageUrl: `${baseImageUrl}event-hall-booking.png`,
                    body: {
                       item1: {
                         headingText: 'Support ID',
                        headingValue: 'N/A'
                        },
                        item2: {
                            headingText: 'Support Status',
                            headingValue: 'N/A'
                        }
                    }
               }
 
            ];
 
            if (hasRevaMessPermission) {
                console.log('Adding RevaMessManagement tile');
                allMenuItems.push({
                    Id: 'RevaMessManagement',
                    headingName: 'REVA MESS MANAGEMENT',
                    url: `${basePath}/reva-mess-management`,
                    imageUrl: `${baseImageUrl}book-meals.png`,
                    body: {
                        item1: {
                            headingText: 'Support ID',
                            headingValue: 'N/A'
                        },
                        item2: {
                            headingText: 'Support Status',
                            headingValue: 'N/A'
                        }
                    }
                });
            }
            if (hasGuestHouseManager) {
                console.log('Adding GuestHouse Booking tile');
                allMenuItems.push({
                    Id: 'RevaGuestHouseRequests',
                    headingName: 'REVA GUEST HOUSE REQUESTS',
                    url: `${basePath}/reva-guest-house-requests`,
                    imageUrl: `${baseImageUrl}guest-house-booking.png`,
                    body: {
                        item1: {
                            headingText: 'Support ID',
                            headingValue: 'N/A'
                        },
                        item2: {
                            headingText: 'Support Status',
                            headingValue: 'N/A'
                        }
                    }
                });
            }

            /*************/
            if (hasCaseOwner) {
                console.log('checking whether caseowner or not');
                allMenuItems.push({
                    Id: 'HostelSupportRequest',
                    headingName: 'HOSTEL SUPPORT REQUEST',
                    url: `${basePath}/hostel-support-request`,
                    imageUrl: `${baseImageUrl}hostel-support-request.png`,
                    body: {
                        item1: {
                            headingText: 'Support ID',
                            headingValue: 'N/A'
                        },
                        item2: {
                            headingText: 'Support Status',
                            headingValue: 'N/A'
                        }
                    }
                });
            }
            /********** */
            /***********************/
            if (hasHostelrequest || hasRevaMessPermission) {
                console.log('checking whether HostelRequest is there or not');
                allMenuItems.push({
                    Id: 'MealBooking',
                    headingName: 'MEAL BOOKING',
                    url: `${basePath}/meal-booking`,
                    imageUrl: `${baseImageUrl}book-meals.png`,
                    body: {
                        item1: {
                            headingText: 'Support ID',
                            headingValue: 'N/A'
                        },
                        item2: {
                            headingText: 'Support Status',
                            headingValue: 'N/A'
                        }
                    }
                });
            }
            /**********************/
 
            this.menuList = allMenuItems;
 
        } catch (error) {
            console.error('Error checking permission:', error);
        }
    }
}