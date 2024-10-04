import { LightningElement, api, wire } from 'lwc';
import getAllInterviews from '@salesforce/apex/RPL_InterviewHandler.getAllInterviews';

export default class Rpl_InterviewResults extends LightningElement {

    contactId;
    data;
    @api isResult;
    @api studentRegDriveId;
    isInterviewAvailable;

    columns = [
        { label: 'Interview Name', fieldName: 'interviewName' },
        { label: 'Interview Time', fieldName: 'interviewTime', type: 'date-time'},
        { label: 'Interview Round', fieldName: 'round', type : 'number', 
            cellAttributes : {
                alignment: 'center'
            }},
        {
            label: 'Result',
            type: 'button',
            initialWidth: 135,
            cellAttributes:{
                alignment: 'center'
            },
            typeAttributes: {
                label: { fieldName: 'result' },
                name: 'apply',
                title: '',
                disabled: false,
                value: { fieldName: 'result' },
                variant: { fieldName: 'variant' },
            },
        },
    ];

    @wire(getAllInterviews, { studentRegDriveId: '$studentRegDriveId' })
    wiredInterviews({ error, data }) {
        console.log('Inside Child ' +this.studentRegDriveId);
        if (data) {
            const { interviewList, studentRegistrationDrive } = data;

            // Determine if the student has failed
            const isFailed = studentRegistrationDrive.Rpl_Is_Failed__c;

            //Determine if the result is out
            const isResultOut = studentRegistrationDrive.Rpl_Is_Result_Out__c;

            // Map the interviewList to a new array with modified button attributes
            this.data = interviewList.map((interview, index) => {
                // Determine result based on conditions
                const result = !isResultOut && index === interviewList.length - 1 ? 'Pending' : isFailed && index === interviewList.length - 1 ? 'Fail' : 'Pass';

                // Determine variant based on result
                const variant = result === 'Fail' ? 'destructive' : result==='Pass'? 'success': 'neutral';

                // Create a new object with modified attributes
                return {
                    id: interview.Id,
                    interviewName: interview.Name,
                    //interviewTime: interview.Rpl_Interview_Time__c,
                    round: interview.Rpl_Round_Number__c,
                    result: result,
                    variant: variant,
                     interviewTime: new Intl.DateTimeFormat('en-US', {
                        year: 'numeric',
                        month: 'short',
                        day: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit',
                    }).format(new Date(interview.Rpl_Interview_Time__c))  
                };
            });
            console.log('INTERVIEW RESULT DATA '+this.data);
            this.isResult = true;
            this.isInterviewAvailable = (this.data.length > 0) ? true :false;
            // Now, this.data contains the transformed data for rendering in the Lightning Datatable
            console.log(JSON.stringify(this.data));
        } else if (error) {
            console.error(JSON.stringify(error));
        }
    }
   

    handleClickBack(){       
            const event = new CustomEvent('clickback');
            this.dispatchEvent(event);    
    }
}