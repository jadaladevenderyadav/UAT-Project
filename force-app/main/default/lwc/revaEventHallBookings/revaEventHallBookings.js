// ligthning default imports
import { LightningElement, track, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import basePath from '@salesforce/community/basePath';
// Apex methods or controllers imports
import saveFacilityRequest from "@salesforce/apex/revaFacilityRequestBookingController.saveFacilityRequest";
import getTimeValues from "@salesforce/apex/revaFacilityRequestBookingController.getTimeValues";
import getEventFacilities from "@salesforce/apex/revaFacilityRequestBookingController.getEventFacilities";
import getLabFacilities from "@salesforce/apex/revaFacilityRequestBookingController.getLabFacilities";
import getCourseScedules from "@salesforce/apex/revaFacilityRequestBookingController.getCourseScedules";
import getAllTimeSlots from "@salesforce/apex/revaFacilityRequestBookingController.getAllTimeSlots";
import getFilteredFacilities from "@salesforce/apex/revaFacilityRequestBookingController.getFilteredFacilities"
import getAminities from "@salesforce/apex/revaFacilityRequestBookingController.getAminities"
import getAdditionalAmenities from "@salesforce/apex/revaFacilityRequestBookingController.getAdditionalAmenities";



export default class RevaEventHallBooking extends NavigationMixin(LightningElement) {
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
  @track selectedEndTime;
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
  @track additionalFacility2;
  @track isLab=false;
  @track isfacilityTpe=false;
  @api isDisabled = false;
  @api isLoading = false;
  @track eventValue='Event Venues';
  @track courseStartTime;
  @track courseEndTime;
  @track courseDate;
  @track isAmenitiesRequired=false;
  @track descriptions;
  @track quantityOfAdditionalAmenities;
  @track capacity;
  @track isCapacity=false;
  @track selecetedAccountName='';
  @track selectedapproverName='';
  @track selectedApproverNumber;
 @track facilityLabTypeOptions=[];
 @track IAExamHall= false;
 @track isStartDate =false;
 @track isEndDate= false;
  cancelFromSave = false;
  @track selectedValues = [];
  @track selectedValues2 = []; 
  @track facilityId;
  // @track additionalAmenitiesOptions=[{label:'Others',value:'Others'}]
  @track additionalAmenitiesOptions=[]
  @track additionalAmenitiesOptions2=[];


// connected call back
async connectedCallback() {
  this.addRow();
  const urlParams = new URLSearchParams(window.location.search);
  this.recordId = urlParams.get("recordId");
  this.isDisabled = true;
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
  await this.getFilteredFacilities(this.recordId,this.eventValue );  

  let startTimeOptionTimes = this.startTimeOptions.map(option => this.extractTime(option.label));
  //Commented this line to skip the filtering on start time for event hall booking
  //this.filteredStartTimeSlots = this.timeOptions.filter(option => !startTimeOptionTimes.includes(this.extractTime(option.label)));
  this.filteredStartTimeSlots = this.timeOptions;
  let endTimeOptionValues = this.endtimeOptions.map(option => this.extractTime(option.label));
  //Commented this line to skip the filtering on end time for event hall booking
  //this.filteredEndTimeSlots = this.timeOptions.filter(option => !endTimeOptionValues.includes(this.extractTime(option.label)));
  this.filteredEndTimeSlots = this.timeOptions;

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

convertToMinutes(timeStr) {
  // Extract hours, minutes, and period (AM/PM)
  let [time, period] = timeStr.split(' ');
  let [hours, minutes] = time.split(':').map(Number);

  // Convert hours to 24-hour format
  if (period === 'PM' && hours !== 12) {
      hours += 12;
  } else if (period === 'AM' && hours === 12) {
      hours = 0;
  }

  // Calculate total minutes
  let totalMinutes = (hours * 60) + minutes;

  return totalMinutes;
}

 // Output: Total minutes: 30

get computedPlaceholder() {
  return this.capacity ? this.capacity[0] : '';
}

// input field value change handler
async handleChange(event) {
  const { name, value, dataset } = event.target;
  const rowId = dataset.id;
  switch (name) {
      case "facilityType":
          this.selectedFacilityType = value; 
          this.selectedBuildingName = null;
          this.selectedRoomName = null;
          this.selectedFacilityName = null;
          this.isfacilityTpe = value === "Event Venues";
          switch (value) {
              case "Event Venues":
                  console.log('valuess--->', value)
                  this.isfacilityTpe = true;
                  this.selectedFacilityType = 'Event Venues';
                  this.isLab = false;
                  await this.getFilteredFacilities(this.recordId, 'Event Venues', this.selectedBuildingName, this.selectedRoomName, this.selectedFacilityName,this.selectedStartDate,this.selectedEndDate,this.selectedEndTime,this.selectedStartTime);
                  break;
              case "Classroom":
                  this.isfacilityTpe = false;
                  this.selectedFacilityType = value;
                  await this.getFilteredFacilities(this.recordId, 'Classroom', this.selectedBuildingName, this.selectedRoomName, this.selectedFacilityName,this.selectedStartDate,this.selectedEndDate,this.selectedEndTime,this.selectedStartTime);
                  break;
              case "Laboratory":
                  this.isfacilityTpe = false;
                  this.selectedFacilityType = value;
                  await this.getFilteredFacilities(this.recordId, 'Laboratory', this.selectedBuildingName, this.selectedRoomName, this.selectedFacilityName,this.selectedStartDate,this.selectedEndDate,this.selectedEndTime,this.selectedStartTime);
                  break;
              default:
                  break;
          }
          break;

      case "buildingNameName":
          console.log('at building switch loop ---->', this.selectedFacilityType);
          this.selectedBuildingName = value;
          this.selectedRoomName = undefined;
          this.selectedRoomNum = undefined;
          this.selectedFacilityName = null;
          this.facilityRoomNumOptions = [];
          await this.getFilteredFacilities(this.recordId, this.selectedFacilityType ? this.selectedFacilityType : this.eventValue, value, this.selectedRoomName, this.selectedFacilityName,this.selectedStartDate,this.selectedEndDate,this.selectedEndTime,this.selectedStartTime);
          break;

      case "floorNumber":
        console.log('floor');
          this.facilityRoomNumOptions = [];
          this.selectedRoomName = value;
          this.selectedFacilityName = null;
          this.selectedRoomNum = undefined;
          await this.getFilteredFacilities(this.recordId, this.selectedFacilityType ? this.selectedFacilityType : this.eventValue, this.selectedBuildingName, value, this.selectedFacilityName,this.selectedStartDate,this.selectedEndDate,this.selectedEndTime,this.selectedStartTime);
          break;

      case "roomNum":
          this.selectedRoomNum = value;
          await this.getFilteredFacilities(this.recordId, this.selectedFacilityType ? this.selectedFacilityType : this.eventValue, this.selectedBuildingName, this.selectedRoomName, value,this.selectedStartDate,this.selectedEndDate,this.selectedEndTime,this.selectedStartTime);
          this.getAminities(this.facilityId,this.selectedBuildingName,this.selectedRoomName,this.selectedRoomNum);
          this.getAdditionalAmenities()
          
          break;

      case "facilityName":
          this.selectedFacilityName = value;
          this.isCapacity = true;
          break;

      case "startdate":
          if (new Date(value) < new Date().setHours(0, 0, 0, 0)) {
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error',
                      message: 'Start date cannot be in the past.',
                      variant: 'error',
                  })
              );
              this.selectedStartDate = '';
              console.log('selected start date 1 ---> ', this.selectedStartDate);
          } else if (this.selectedEndDate && new Date(value) > new Date(this.selectedEndDate).setHours(0, 0, 0, 0)) {
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error',
                      message: 'Start date cannot be after end date.',
                      variant: 'error',
                  })
              );
              this.selectedStartDate = '';
              console.log('selected start date 2 ---> ', this.selectedStartDate);
          } else {
              this.selectedStartDate = value;
              this.isStartDate=this.selectedStartDate;
              console.log('selected start date 3 ---> ', this.selectedStartDate);
          }
          break;

      case "enddate":
          if (new Date(value) < new Date().setHours(0, 0, 0, 0)) {
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error',
                      message: 'End date cannot be in the past.',
                      variant: 'error',
                  })
              );
              this.selectedEndDate = '';
              console.log('selected end date 1 ---> ', this.selectedEndDate);
          } else if (this.selectedStartDate && new Date(value) < new Date(this.selectedStartDate).setHours(0, 0, 0, 0)) {
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error',
                      message: 'End date cannot be before start date.',
                      variant: 'error',
                  })
              );
              this.selectedEndDate = '';
              console.log('selected end date 2 ---> ', this.selectedEndDate);
          } else {
              this.selectedEndDate = value;
              
              console.log('selected end date 3 ---> ', this.selectedEndDate);
              
          }
          break;

          case "startTime":
            console.log('valuessss---->', value, this.selectedEndTime, this.selectedStartDate, this.selectedEndDate);
            // Example usage
            
            let totalStartTimeMinutes = this.convertToMinutes(value);
            console.log(`Total minutes: ${totalStartTimeMinutes}`);
            let today = new Date(); // This retains the current date and time
            let todayMidnight = new Date(today); // Copy today and set it to midnight for date comparison
            todayMidnight.setHours(0, 0, 0, 0);
        
            // Check if the selected start date is today
            if (new Date(this.selectedStartDate).setHours(0, 0, 0, 0) === todayMidnight.getTime()) {
                // Convert current time to minutes
                let currentTime = today.getHours() * 60 + today.getMinutes();
        
                if (totalStartTimeMinutes < currentTime) {
                    // Validation: Start time cannot be in the past
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Start time cannot be in the past.',
                            variant: 'error',
                        })
                    );
                    this.selectedStartTime = '';
                    break;
                }
            }
            if (this.selectedStartDate === this.selectedEndDate) {
                if (this.selectedEndTime && value === this.selectedEndTime) {
                    // Validation: Start time cannot be the same as the end time
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Start time cannot be the same as the end time.',
                            variant: 'error',
                        })
                    );
                    this.selectedStartTime = '';
                } else if (this.selectedEndTime && value > this.selectedEndTime) {
                    // Validation: Start time should not be greater than the end time
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Start time should not be greater than the end time.',
                            variant: 'error',
                        })
                    );
                    this.selectedStartTime = '';
                } else {
                    this.selectedStartTime = value;
                }
            } else {
                this.selectedStartTime = value;
                 
            }
            break;


      case "endTime":
          console.log('valuessss123---->', value, this.selectedStartTime, this.selectedStartDate, this.selectedEndDate);
            let endTimeMinutes= this.convertToMinutes(value);
            let startTimeMunitues = this.convertToMinutes(this.selectedStartTime);
            console.log('endtime + strattime -->', endTimeMinutes , startTimeMunitues);
          if (this.selectedStartDate === this.selectedEndDate) {
              if (this.selectedStartTime && value === this.selectedStartTime) {
                  // Validation: End time cannot be the same as the start time
                  this.dispatchEvent(
                      new ShowToastEvent({
                          title: 'Error',
                          message: 'End time cannot be the same as the start time.',
                          variant: 'error',
                      })
                  );
                  this.selectedEndTime = '';
              } else if (startTimeMunitues && endTimeMinutes < startTimeMunitues) {
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
          } else {
              this.selectedEndTime = value;
          }
          break;

 

      case "Reason":
          this.bookingReason = value;
          break;

      case "additionalFacility":
      this.additionalFacility = value;
      
        if (!this.selectedValues.includes(value)) {
            this.selectedValues = [...this.selectedValues, value];
        }
          if (value === 'Others') {
              this.isAmenitiesRequired = true;
          }
          break;

       /*case "additionalFacility2":
            this.updateRow(rowId, { additionalFacility2: value });
            break;*/

       case "quantityOfAdditionalAmenities":
          console.log('value--->', value);
          this.quantityOfAdditionalAmenities = value;
          break;    

      case "Others":
          console.log('value--->', value);
          this.descriptions = value;
          break;

      case "Capacity":
          console.log('value--->', value);
          this.capacity = value;
          break;

      case "iaExamHall":
          this.selectedFacilityType = 'Event Venues';
          this.IAExamHall = true;
          break;

      /*case "quantity":
            this.updateRow(rowId, { quantity: value });
            break;*/

      case "additionalFacility2":
            case "quantity":
                this.updateRow(rowId, { [name]: value });
                break;


      default:
          break;
  }
  this.updateAdditionalFacilityString();
  if (this.selectedStartDate && this.selectedEndDate && this.selectedEndTime && this.selectedStartTime) {
    this.isDisabled = false;
   }
}

  handleRemove(event) {
        const valueToRemove = event.currentTarget.dataset.value;
        this.selectedValues = this.selectedValues.filter(value => value !== valueToRemove);
}

handleRemove2(event) {
        const valueToRemove = event.currentTarget.dataset.value;
        this.selectedValues2 = this.selectedValues2.filter(value => value !== valueToRemove);
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
    async getAminities(facilityId,selectedBuildingName,selectedRoomName,selectedRoomNum){
      const res = await getAminities({facilityId:facilityId[0],Block:selectedBuildingName,Floor:selectedRoomName,Room:selectedRoomNum});
      const aminityData= res.map((aminity,ind)=>({
        label:aminity.Item_Name__c != null || undefined || '' ? aminity.Item_Name__c:'No aminities available',
        value:aminity.Item_Name__c != null || undefined || '' ? aminity.Item_Name__c:'No aminities available'
      }));
      console.log('aminityData ---->',JSON.stringify(aminityData))
      if(aminityData.length === 0){
        this.additionalAmenitiesOptions = [{label:'No aminities are available for the selected facility',value:'Others'}];
      }else{
        this.additionalAmenitiesOptions=aminityData;
        console.log('additionalAmenitiesOptions ----->', JSON.stringify(this.additionalAmenitiesOptions));
      }
      }

    

 // Filtered facility details
 async getFilteredFacilities(accountId, facilityType, buildingName, floorNumber ,facilityName,startDate,endDate,endTime,startTime) {
  console.log('account id----->',accountId);

    console.log('facilitype L1---->',accountId,facilityType,buildingName, floorNumber ,facilityName);
    try {
      const res = await getFilteredFacilities({accountId:this.recordId,facilityType:facilityType, buildingName:buildingName, floorNumber:floorNumber , facilityName:facilityName,startDate:startDate,endDate:endDate,endTime:endTime,startTime:startTime});
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
              id:facility.Id,
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
          console.log('OUTPUT of facilityNameOptions: ',JSON.stringify(this.facilityNameOptions));
          this.facilityId = this.facilityNameOptions.map((e)=>e.id);

          console.log('this.facilityId    ---->',JSON.stringify(this.facilityId));
          // this.getAminities(this.facilityId)

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

        } catch (err) {
          console.log("error in facility -->", err);
        }
  }
  
  // course time details
  
  async getCourseScedules(){
    await getCourseScedules({recordId:this.recordId}).then((res)=>{
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
    
    this.isLoading = true; // Show spinner when the save process starts
   
    const fields = 
      {
        buildingName: this.selectedBuildingName,
        facilityName: this.selectedFacilityName ? this.selectedFacilityName:'',
        facilityType : (this.IAExamHall === true) ? 'IA Exam Hall' : (this.selectedFacilityType ? this.selectedFacilityType : (this.facilityTypes ? this.facilityTypes : this.eventValue)),
 
        //facilityType: this.selectedFacilityType ? this.selectedFacilityType : this.facilityTypes ? this.facilityTypes : this.eventValue,
        floorNumber: this.selectedRoomName,
        roomNumber: this.selectedRoomNum,
        startDate: this.selectedStartDate ? this.selectedStartDate: this.courseDate,
        endDate: this.selectedEndDate ? this.selectedEndDate:this.courseDate,
        startTime: this.selectedStartTime ? this.selectedStartTime: this.courseStartTime,
        endTime: this.selectedEndTime ? this.selectedEndTime : this.courseEndTime,
        facilityReason: this.bookingReason ? this.bookingReason : 'NA',
        additionalFacility:this.selectedValues ? this.selectedValues.join(', ') : 'NA' ,
        additionalFacility2:this.additionalFacility2 ? this.additionalFacility2 : 'NA' ,
        capacity:this.capacity[0]? this.capacity[0]:0,
        quantityOfAdditionalAmenities:this.quantityOfAdditionalAmenities ? this.quantityOfAdditionalAmenities:'NA',
        description:this.descriptions ? this.descriptions:'NA',
        IAExamhall:this.IAExamHall ? this.IAExamHall:false,
        facilityId:this.facilityId[0]? this.facilityId[0]:''
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
            this.cancelFromSave = true;
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
  }finally{
    this.isLoading = false; 
  }

         //  this.selectedValues=[];
        
  }

  async getAdditionalAmenities(){
     const result = await getAdditionalAmenities();
            if (result && result.length > 0) {
                this.additionalAmenitiesOptions2 = result.map(item => ({
                    label: item.Name__c || 'No amenities available',
                    value: item.Name__c || 'No amenities available'
                }));
            } else {
                this.additionalAmenitiesOptions2 = [{ label: 'No amenities available', value: 'Others' }];
            }
            console.log('additionalAmenitiesOptions2:', this.additionalAmenitiesOptions2);
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
      if (window.location.pathname.includes('/s/')) {
        // If the action is triggered from Experience Cloud portal
        if(this.cancelFromSave){
          this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: `${basePath}/event-hall-booking`, // Replace with your community portal URL
            },
        });
        }else{
          this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: `${basePath}`, // Replace with your community portal URL
            },
        });
        }
    } else {
        // Standard Salesforce navigation
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

@track rows = [];
addRow() {
        const newId = this.rows.length + 1;
        this.rows = [
            ...this.rows,
            {
                id: newId,
                additionalFacility2: '',
                quantity: '',
                additionalFacilityWithQuantity: ''
            }
        ];
    }

    deleteRow(event) {
        const index = event.target.dataset.index;
        this.rows = this.rows.filter((row, idx) => idx != index);
        this.updateAdditionalFacilityString();
    }
    
    handleChange2(event) {
        const { name, value, dataset } = event.target;
        const rowId = dataset.id;

        const updatedRows = this.rows.map(row => {
            if (row.id == rowId) {
                if (name === 'additionalFacility') {
                    row.amenities = value ? [value] : [];
                } else if (name === 'quantity') {
                    row.quantities = value ? [value] : [];
                }

                // Create the additionalFacility string
                const amenitiesWithQuantities = row.amenities.map((amenity, index) => {
                    const quantity = row.quantities[index] || '';
                    return `${amenity} - ${quantity}`;
                }).join(', ');

                row.additionalFacility = amenitiesWithQuantities || 'NA';

                return { ...row };
            }
            return row;
        });
        this.rows = updatedRows;
    }

   updateRow(rowId, updatedFields) {
        this.rows = this.rows.map(row => {
            if (row.id == rowId) {
                const updatedRow = { ...row, ...updatedFields };
                if (updatedRow.additionalFacility2 && updatedRow.quantity) {
                    updatedRow.additionalFacilityWithQuantity = `${updatedRow.additionalFacility2} - ${updatedRow.quantity}`;
                }
                return updatedRow;
            }
            return row;
        });
        this.updateAdditionalFacilityString();
    }
    updateAdditionalFacilityString() {
        this.additionalFacility2 = this.rows
            .filter(row => row.additionalFacilityWithQuantity)
            .map(row => row.additionalFacilityWithQuantity)
            .join(', ');
        console.log('additionalFacility2', this.additionalFacility2);
    }

}