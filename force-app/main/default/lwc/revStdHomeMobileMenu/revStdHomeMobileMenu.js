import { LightningElement, wire, track } from 'lwc';
import getProfileSpecificNavigationMenuItems from '@salesforce/apex/SP_SideMenuController.getProfileSpecificNavigationMenuItems';
import STUDENTPORTALASSETS from '@salesforce/resourceUrl/SR_STUDENTPORTALASSETS';
import basePath from '@salesforce/community/basePath';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const NAVIGATIONSICONS = `${STUDENTPORTALASSETS}/StudentPortalAssests/Icons/Navigation-Icons/`;
export default class RevStdHomeMobileMenu extends NavigationMixin(LightningElement) {
    @track menuItems = [];

    @wire(getProfileSpecificNavigationMenuItems)
    wiredMenuItems({ error, data }) {
        if (data) {
            this.menuItems = data.filter(item => item.Label !== 'Examination') // Exclude items with label 'Examination'
            .map(item => {
                if (item.Label === 'Assessment') {
                    return {
                        ...item,
                        Label: 'Examination',
                        imageUrl: this.formatLabelToFilename('examination'),
                        target: '/examination'
                    };
                } else {
                    return {
                        ...item,
                        imageUrl: this.formatLabelToFilename(item.Label)
                    };
                }
            });
        } else if (error) {
            this.showErrorToast(error.body.message);
        }
    }

    formatLabelToFilename(label) {
        let filename = label === 'Mentor/Mentee' ? 'mentor-or-mentee.png' : `${label.replace(/\s+/g, '-').toLowerCase()}.png`;
        console.log('filename=> '+`${NAVIGATIONSICONS}${filename}`);
        return `${NAVIGATIONSICONS}${filename}`;
    }

    handleButtonClick(event) {
        let relativePath = event.currentTarget.dataset.value;
        console.log('relativePath=> '+`${relativePath}`);
        if (relativePath === 'Case') {
            relativePath = `/case/${relativePath}`;
        }
        if(relativePath == '/display-ia-marks')
        {
            relativePath = '/examination'
        }

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `${basePath}${relativePath}`

            }
        });

    }

    //Error Notification
    showErrorToast(errorMessage) {

        const event = new ShowToastEvent({
            title: 'Error',
            message: errorMessage,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}