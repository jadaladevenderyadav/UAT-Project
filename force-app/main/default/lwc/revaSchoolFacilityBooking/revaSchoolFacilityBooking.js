// ligthning default imports
import { LightningElement, track, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
// Apex methods or controllers imports
import saveFacilityRequest from "@salesforce/apex/revaSchoolFacilityBookingController.saveFacilityRequest";
import getTimeValues from "@salesforce/apex/revaSchoolFacilityBookingController.getTimeValues";
import getEventFacilities from "@salesforce/apex/revaSchoolFacilityBookingController.getEventFacilities";
import getLabFacilities from "@salesforce/apex/revaSchoolFacilityBookingController.getLabFacilities";
import getCourseScedules from "@salesforce/apex/revaSchoolFacilityBookingController.getCourseScedules";
import getAllTimeSlots from "@salesforce/apex/revaSchoolFacilityBookingController.getAllTimeSlots";
import getFilteredFacilities from "@salesforce/apex/revaSchoolFacilityBookingController.getFilteredFacilities"

export default class RevaFacilityRequest extends NavigationMixin(LightningElement) {
  // @api recordId;
  @track recordId;
  @track selectedBuildingName;
  @track selectedFacilityName;
  @track selectedFacilityType;
  @track selectedRoomName;
  @track selectedRoomNum;
  @track selectedStartDate;
  @track selectedEndDate;
  @track selectedStartTime;
  @track selcetedEndTime;
  @track bookingReason;
  @track today = new Date();
  @track timeOptions = [];
  @track selectedStartTime;
  @track selectedEndTime;
  @track start_date;
  @track end_date;
  @track range;
  @track selectedTime;
  @track selectedTimeValues = [];
  @track endtimeOptions = [];
  @track startTimeOptions = [];
  @track filteredEndTimeSlots = [];
  @track filteredStartTimeSlots = [];
  @track facilityNameOptions = [];
  @track facilityEventTypeOptions = [];
  @track facilityBuildingNameOptions = [];
  @track facilityFloorOptions = [];
  @track facilityRoomNumOptions = [];
  @track facilityCapacityOption=[];
  @track additionalFacility;
  @track isLab=false;
  @track isfacilityTpe=false;
  @track eventValue='Event Venues';
  @track courseStartTime;
  @track courseEndTime;
  @track courseDate;
  @track isAmenitiesRequired=false;
  @track descriptions;
  @track capacity;
  @track isCapacity=false;
  @track selecetedAccountName='';
  @track selectedapproverName='';
  @track selectedApproverNumber;
 @track facilityLabTypeOptions=[];
 @track IAExamHall=false;
 @track approverEmailId;

  @track additionalAmenitiesOptions=[{ label:'Chair',value:'Chair'}, {label:'Water Bottle',value:'Water Bottle'},{label:'Others',value:'Others'}]

// connected call back
async connectedCallback() {
  const urlParams = new URLSearchParams(window.location.search);
  this.recordId = urlParams.get("recordId");

  if (this.recordId !== null || undefined || '') {
    this.isLab=true;
  } else {
    this.genericCondition=false;

  }
  await this.getEventFacilities();
  await this.getLabFacilities();
  await this.getCourseScedules();
  await this.getTimeDetails();
  await this.getEndTimeSlots();
  await this.getFilteredFacilities(this.eventValue );  

let startTimeOptionTimes = this.startTimeOptions.map(option => this.extractTime(option.label));
this.filteredStartTimeSlots = this.timeOptions.filter(option => !startTimeOptionTimes.includes(this.extractTime(option.label)));

let endTimeOptionValues = this.endtimeOptions.map(option => this.extractTime(option.label));
this.filteredEndTimeSlots = this.timeOptions.filter(option => !endTimeOptionValues.includes(this.extractTime(option.label)));

}
 extractTime(label) {
  return label.split(' ')[0];
}

  // time function
  async getTimeDetails() {
    try {
      const res = await getTimeValues();
      if (!Array.isArray(res)) {
        throw new Error("Invalid response format for time values");
      }
      const filteredTimeOptions = res.filter(
        (time) => !this.selectedTimeValues?.includes(time?.Name)
      );
      this.timeOptions = filteredTimeOptions.map((time) => ({
        label: time.Name,
        value: time.Name,
      }));
    } catch (error) {
      console.error("Error in getTimeDetails:", error.message);
    }
  }

  // endtime slots fetching from Apex level
  async getEndTimeSlots() {
    try {
      const res = await getAllTimeSlots();
      this.endtimeOptions = res.map((item, ind) => ({
        label: this.formatTime(item.End_Time__c),
        value: item.Id,
      }));

      this.startTimeOptions =res.map((item, ind) => ({
        label: this.formatTime(item.Start_Time__c),
        value: item.Id,
      }));

    } catch (err) {
      console.log("error in endtimeOptions -->", err);
    }
  }

// time formatting from ex:4600000 to 1:30 AM/PM
  formatTime(milliseconds) {
    if (!milliseconds || isNaN(milliseconds)) {
        return ''; 
    }
    const date = new Date(milliseconds);
    let hours = date.getUTCHours();
    const minutes = date.getUTCMinutes();
    let ampm = hours >= 12 ? 'PM' : 'AM';
    
    // Convert hours from 24-hour format to 12-hour format
    hours = hours % 12;
    hours = hours ? hours : 12; 
    const formattedTime = `${hours.toString().padStart(2, "0")}:${minutes.toString().padStart(2, "0")} ${ampm}`;  
    return formattedTime;
}

get computedPlaceholder() {
  return this.capacity ? this.capacity[0] : '';
}

  // input field value change handler
  async handleChange(event) {
    const { name, value } = event.target;
    switch (name) {
      case "facilityType":
        this.selectedFacilityType = value;
        this.selectedBuildingName = null;
        this.selectedRoomName = null;
        this.selectedFacilityName = null;
        this.isfacilityTpe = value === "Event Venues";
        switch (value) {
            case "Event Venues":
              console.log('valuess--->',value)
                this.isfacilityTpe=true;
                this.selectedFacilityType = 'Event Venues'; 
                this.isLab=false;
                await this.getFilteredFacilities(this.recordId,'Event Venues' ,this.selectedBuildingName, this.selectedRoomName,this.selectedFacilityName)
                break;
            case "Classroom":
              this.isfacilityTpe=false;
              this.selectedFacilityType = value; 
                        await this.getFilteredFacilities(this.recordId,'Classroom',this.selectedBuildingName, this.selectedRoomName,this.selectedFacilityName);  
                break;
            case "Laboratory":
              this.isfacilityTpe=false;
              this.selectedFacilityType = value; 
                        await this.getFilteredFacilities(this.recordId,'Laboratory',this.selectedBuildingName, this.selectedRoomName,this.selectedFacilityName);  
                break;
              
            default:
                break;
        }
        break;

      case "buildingNameName":
        console.log('at building switch loop ---->',this.selectedFacilityType)
        this.selectedBuildingName = value;
        this.selectedRoomName = undefined;
        this.selectedRoomNum= undefined;
        this.facilityRoomNumOptions=[];
        await this.getFilteredFacilities(this.recordId,this.selectedFacilityType ? this.selectedFacilityType : this.eventValue , value, this.selectedRoomName, this.selectedFacilityName);
        break;

      case "floorNumber":
        this.facilityRoomNumOptions=[];
        this.selectedRoomName = value;
        await this.getFilteredFacilities(this.recordId,this.selectedFacilityType?this.selectedFacilityType:this.eventValue , this.selectedBuildingName, value,this.selectedFacilityName);
        break;
        
      case "roomNum":
        this.selectedRoomNum = value;
      await this.getFilteredFacilities(this.recordId,this.selectedFacilityType?this.selectedFacilityType :this.eventValue  , this.selectedBuildingName, this.selectedRoomName,value);

        break;
      case "facilityName":
        this.selectedFacilityName = value;
      //await this.getFilteredFacilities(this.recordId,this.selectedFacilityType?this.selectedFacilityType :this.eventValue  , this.selectedBuildingName, this.selectedRoomName,this.selectedRoomNum);

        this.isCapacity=true;
        break;
     
      case "startdate":
        if (new Date(value) < new Date().setHours(0,0,0,0)) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Start date cannot be in the past.',
                    variant: 'error',
                })
            );
            this.selectedStartDate = '';
        } else if (this.selectedEndDate && new Date(value) > new Date(this.selectedEndDate).setHours(0,0,0,0)) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Start date cannot be after end date.',
                    variant: 'error',
                })
            );
            this.selectedStartDate = '';
        } else {
            this.selectedStartDate = value;
        }
        break;
    
      case "enddate":
        if (new Date(value) < new Date().setHours(0,0,0,0)) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'End date cannot be in the past.',
                    variant: 'error',
                })
            );
            this.selectedEndDate = '';
        } else if (this.selectedStartDate && new Date(value) < new Date(this.selectedStartDate).setHours(0,0,0,0)) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'End date cannot be before start date.',
                    variant: 'error',
                })
            );
            this.selectedEndDate = '';
        } else {
            this.selectedEndDate = value;
        }
        break;
    
      case "endTime":
          
          if (this.selectedStartDate !== this.selectedEndDate && this.selectedStartTime === value) {
              // If start date is not equal to end date, end time can be the same as start time
              this.selectedEndTime = value;
          } else if (this.selectedStartDate === this.selectedEndDate && this.selectedStartTime && this.selectedStartTime === value) {

              // Validation: End time cannot be the same as the start time
              this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'End time cannot be the same as the start time.',
                    variant: 'error',
                })
            );
            this.selectedEndTime = '';
            
          } else if (this.selectedStartDate === this.selectedEndDate && this.selectedStartTime && this.selectedStartTime > value) {
              // Validation: End time should not be less than the start time
             
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error',
                      message: 'End time should not be less than the start time.',
                      variant: 'error',
                  })
              );
              this.selectedEndTime = '';
          } else {
              this.selectedEndTime = value;
          }
          break;
      
      case "startTime":
          if (this.selectedEndDate !== this.selectedStartDate && this.selectedEndTime && this.selectedEndTime === value) {
              // If start date is not equal to end date, start time can be the same as end time
              this.selectedStartTime = value;
          } else if (this.selectedEndTime && this.selectedEndTime === value) {
              // Validation: Start time cannot be the same as the end time
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error',
                      message: 'Start time cannot be the same as the end time.',
                      variant: 'error',
                  })
              );
              this.selectedStartTime = ''; // Clear selectedStartTime
          } else if (this.selectedEndTime && this.selectedEndTime < value) {
              // Validation: Start time should not be greater than the end time
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error',
                      message: 'Start time should not be greater than the end time.',
                      variant: 'error',
                  })
              );
              this.selectedStartTime = ''; // Clear selectedStartTime
          } else {
              // Update selectedStartTime only when validation conditions are not met
              this.selectedStartTime = value;
          }
          break;

      case "Reason":
        this.bookingReason = value;
        break;
      
      case "additionalFacility":
        this.additionalFacility = value;
        if(value === 'Others'){
          
          this.isAmenitiesRequired=true;
        }
        break;
      case "Others":
          console.log('value--->',value)
          this.descriptions=value;
                    // await this.getFilteredFacilities('Laboratory');  
            break;
      case "Capacity":
        console.log('value--->',value)
        this.capacity=value;
                  // await this.getFilteredFacilities('Laboratory');  
          break;

      case "iaExamHall":
        this.selectedFacilityType='Classroom';
        this.IAExamHall=true;
              break;
      default:
              break;
          }
   
}

  // Falitity name fetching
  async getEventFacilities() {
    try {
      const res = await getEventFacilities();
    // Facility type name

      const responseData = res.map((facility, ind) => ({
        label: facility.hed__Facility_Type__c ? facility.hed__Facility_Type__c : 'NA',
        value: facility.hed__Facility_Type__c ? facility.hed__Facility_Type__c : 'NA', 
      }));

      const uniqueFacilityOptionsSet = new Set(
        responseData.map(JSON.stringify)
      );
      this.facilityEventTypeOptions = Array.from(uniqueFacilityOptionsSet).map(
        JSON.parse
      );
    } catch (err) {
      console.log("error in facility -->", err);
    }
  }
    // Falitity name fetching
    async getLabFacilities() {
      try {
        const res = await getLabFacilities({accountId:this.recordId});
      // Facility type name
 
        const responseData = res.map((facility, ind) => ({
          label: facility.hed__Facility_Type__c ? facility.hed__Facility_Type__c : 'NA',
          value: facility.hed__Facility_Type__c ? facility.hed__Facility_Type__c : 'NA', 
        }));
        const uniqueFacilityOptionsSet = new Set(
          responseData.map(JSON.stringify)
        );
        this.facilityLabTypeOptions = Array.from(uniqueFacilityOptionsSet).map(
          JSON.parse
        );
      } catch (err) {
        console.log("error in facility -->", err);
      }
    }


 // Filtered facility details
 async getFilteredFacilities(accountId, facilityType, buildingName, floorNumber ,facilityName) {

    console.log('facilitype L1---->',accountId,facilityType,buildingName, floorNumber ,facilityName);
    try {
      const res = await getFilteredFacilities({accountId:this.recordId,facilityType:facilityType, buildingName:buildingName, floorNumber:floorNumber , facilityName:facilityName});
      // name

    if(facilityType !== null && buildingName === null && floorNumber === null && facilityName === null){
        // building name
        console.log('facilitype L2---->',facilityType,buildingName, floorNumber ,facilityName);

        const facilityBlockData = res.map((facility, ind) => ({
          label: facility.Block__c ? facility.Block__c : 'NA',
          value: facility.Block__c ? facility.Block__c : 'NA' ,
          }));
        const facilityBuildingNameOptionsSet = new Set(
          facilityBlockData.map(JSON.stringify)
        );
      this.facilityBuildingNameOptions = Array.from(facilityBuildingNameOptionsSet).map(
        JSON.parse
      );
    }

    if(facilityType !== undefined && buildingName !== undefined && floorNumber === undefined && facilityName === null ){
      console.log('facilitype L3---->',facilityType,buildingName, floorNumber ,facilityName);

    // floor
          const facilityFloorData = res.map((facility, ind) => ({
          label: facility.Floor__c ? facility.Floor__c : 'NA',
          value: facility.Floor__c ? facility.Floor__c : 'NA' ,
          }));
          const facilityFloorOptionsSet = new Set(
            facilityFloorData.map(JSON.stringify)
          );
          this.facilityFloorOptions = Array.from(facilityFloorOptionsSet).map(
            JSON.parse
          );

    }

    if(facilityType !== null && buildingName !== null && floorNumber !== null && facilityName === null){
      console.log('facilitype L4---->',facilityType,buildingName, floorNumber ,facilityName);

      // room number
          const facilityRoomData = res.map((facility, ind) => ({
          label: facility.Room__c ? facility.Room__c : 'NA',
          value: facility.Room__c ? facility.Room__c : 'NA',
          }));
          const facilityRoomNumOptionsSet = new Set(
            facilityRoomData.map(JSON.stringify)
          );
          this.facilityRoomNumOptions = Array.from(facilityRoomNumOptionsSet).map(
            JSON.parse
          );

          const facilityNameData = res.map((facility, ind) => {
            return ({
              label: facility.Name ? facility.Name :'NA',
              value: facility.Name ? facility.Name :'NA',
            })
          });

          // type
          const facilityNameOptionssSet = new Set(
            facilityNameData.map(JSON.stringify)
          );
          this.facilityNameOptions = Array.from(facilityNameOptionssSet).map(
            JSON.parse
          );

    }
    if(facilityType !== null && buildingName !== null && floorNumber !== null && facilityName !== null){
      console.log('facilitype L5---->',facilityType,buildingName, floorNumber ,facilityName);

      

          const facilityNameData = res.map((facility, ind) => {
            return ({
              label: facility.Name ? facility.Name :'NA',
              value: facility.Name ? facility.Name :'NA',
            })
          });

          // type
          const facilityNameOptionssSet = new Set(
            facilityNameData.map(JSON.stringify)
          );
          this.facilityNameOptions = Array.from(facilityNameOptionssSet).map(
            JSON.parse
          );

    }

          const capacityOptions = res.map((facility,ind)=>({
            label: facility.hed__Capacity__c ? facility.hed__Capacity__c : 0,
            value: facility.hed__Capacity__c ? facility.hed__Capacity__c : 0,
          }));
          const facilitycapacityOptionsSet = new Set(
            capacityOptions.map(JSON.stringify)
          );
          this.facilityCapacityOption = Array.from(facilitycapacityOptionsSet).map(
            JSON.parse
          );
          this.capacity = this.facilityCapacityOption.map((e)=>e.label) ? this.facilityCapacityOption.map((e)=>e.label): 0;

          const approverEmail = res.map((facility,ind)=>({
            label: facility.ApproversEmail__c ? facility.ApproversEmail__c : 0,
            value: facility.ApproversEmail__c ? facility.ApproversEmail__c : 0,
          }));
          const facilitycApproverEmail = new Set(
            capacityOptions.map(JSON.stringify)
          );
          this.facilityCapacityOption = Array.from(facilitycApproverEmail).map(
            JSON.parse
          );
          this.approverEmailId = this.facilityCapacityOption.map((e)=>e.label) ? this.facilityCapacityOption.map((e)=>e.label): 0;
          console.log('approverEmailId --- > ',this.approverEmailId);
         

        } catch (err) {
          console.log("error in facility -->", err);
        }
  }
  
  // course time details
  
  async getCourseScedules(){
    await getCourseScedules({recordId:this.recordId}).then((res)=>{
      console.log('res of course offering schedule ---->' ,res);
      res.map((e,ind)=>{
        this.courseStartTime=this.formatTime(e.hed__Start_Time__c),
        this.courseEndTime=this.formatTime(e.hed__End_Time__c),
        this.courseDate=e.Date__c
      })
            return '';
    }).catch((err)=>{
      console.log('error at course result',err)
    })
  }

  // handle save
  @track facilityTypes;
  async handleSave(event) {


   console.log('course time',this.courseStartTime , this.courseEndTime)
    const fields = 
      {
        buildingName: this.selectedBuildingName,
        facilityName: this.selectedFacilityName ? this.selectedFacilityName:'',
        facilityType : (this.IAExamHall === true) ? 'IA Exam Hall' : (this.selectedFacilityType ? this.selectedFacilityType : (this.facilityTypes ? this.facilityTypes : this.eventValue)),
 // facilityType: this.selectedFacilityType ? this.selectedFacilityType : this.facilityTypes ? this.facilityTypes : this.eventValue,
        floorNumber: this.selectedRoomName,
        roomNumber: this.selectedRoomNum,
        startDate: this.selectedStartDate ? this.selectedStartDate: this.courseDate,
        endDate: this.selectedEndDate ? this.selectedEndDate:this.courseDate,
        startTime: this.selectedStartTime ? this.selectedStartTime: this.courseStartTime,
        endTime: this.selectedEndTime ? this.selectedEndTime : this.courseEndTime,
        facilityReason: this.bookingReason ? this.bookingReason : 'NA',
        additionalFacility:this.additionalFacility ? this.additionalFacility : 'NA' ,
        capacity:this.capacity[0]? this.capacity[0]:0,
        description:this.descriptions ? this.descriptions:'NA',
        IAExamHall:this.IAExamHall ? this.IAExamHall : false,
        approverEmailId:this.approverEmailId ? this.approverEmailId[0] : 'NA@gmail.com'
      };

      console.log('fields--->',JSON.stringify(fields));
    try {

console.log('selectedFacilityName bef---->',this.selectedFacilityName);

      const res = await saveFacilityRequest({
        selectedFields: JSON.stringify(fields), courseOfferingId:this.recordId
      });
console.log('selectedFacilityName aft---->',this.selectedFacilityName)
  
      if (res === 'Success') {
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Success',
                  message: 'Facility booked successfully.',
                  variant: 'success',
              })
          );  
            this.handleCancelClick();

      } else {
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: res, // Display the error message from the response
                  variant: 'error',
              })
          );
      }
  } catch (err) {
      let errorMessage = err.body ? err.body.message : err.message || 'Unknown error';
      console.log('errorMessage',errorMessage)
      this.dispatchEvent(
          new ShowToastEvent({
              title: 'Error',
              message: errorMessage,
              variant: 'error',
          })
      );
  }
  }

  handleCancelClick() {
    this.selectedBuildingName = [];
    this.selectedFacilityName = [];
    this.selectedFacilityType = [];
    this.selectedRoomName = [];
    this.selectedRoomNum = [];
    this.selectedStartDate = [];
    this.selectedEndDate = [];
    this.selectedStartTime = [];
    this.selectedEndTime = [];
    this.bookingReason = [];
    this.additionalFacility = [];
    this.endtimeOptions = [];
    this.startTimeOptions = [];
    this.filteredEndTimeSlots = [];
    this.filteredStartTimeSlots = [];
    this.facilityNameOptions = [];
    this.facilityEventTypeOptions = [];
    this.facilityBuildingNameOptions = [];
    this.facilityFloorOptions = [];
    this.facilityRoomNumOptions = [];
    this.facilityCapacityOption=[];

    if (this.recordId !== null && this.recordId !== '' && this.recordId !== undefined) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.recordId,
                objectApiName: "hed__Course_Offering_Schedule__c",
                actionName: "view",
            },
        });
    } else {
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "Facility_Request__c",
                actionName: "list",
            },
        });
    }
}

}