import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getSummitParticularsMetadata from "@salesforce/apex/smt_Summit_Tracker_Controller.getSummitParticularsMetadata";
import createSummitParticular from "@salesforce/apex/smt_Summit_Tracker_Controller.createSummitParticular";
import getAllSummitParticulars from "@salesforce/apex/smt_Summit_Tracker_Controller.getAllSummitParticulars";
import updateAllSummitParticular from "@salesforce/apex/smt_Summit_Tracker_Controller.updateAllSummitParticular";

export default class Smt_Create_Summit_Particulars extends LightningElement {
  @api summitSectionLabel;
  @api summitSectionId;
  @api buttonLabel;
  @api keyCount = 0;
  @api semesterOneTimeline;
  @api semesterTwoTimeline;
  @api schoolName;

  isSpinner;

  @track summitParticulars = [];
  connectedCallback() {
    if (this.buttonLabel == "Create Particulars") {
      this.getSummitParticularsMetadata();
    } else if (this.buttonLabel == "Update Particulars") {
      this.getAllSummitParticulars();
    }
  }

  getSummitParticularsMetadata() {
    getSummitParticularsMetadata({
      summitSectionLabel: this.summitSectionLabel,
      keyCount: this.keyCount
    })
      .then((result) => {
        let sNo = 0;
        this.summitParticulars = result.map((summitParticular) => {
          sNo++;
          let timeline =
            summitParticular.MasterLabel.endsWith("Odd") ||
            summitParticular.MasterLabel.endsWith("OS") ||
            summitParticular.MasterLabel.endsWith("Odd Sem")
              ? this.semesterTwoTimeline
              : this.semesterOneTimeline;
          return {
            id: sNo,
            summitParticularName: summitParticular.MasterLabel,
            timeline,
            target: 0,
            targetText: "",
            isTargetApplicable: false,
            isEvidenceApplicable: false
          };
        });
      })
      .catch((error) => {
        console.error("Error when fetching summit particular metadata ", error);
        this.showToastNotification(
          "Error when fetching summit particular metadata ",
          error.body.message,
          "error"
        );
      });
  }
  getAllSummitParticulars() {
    getAllSummitParticulars({
      summitSectionId: this.summitSectionId,
      keyCount: this.keyCount
    })
      .then((result) => {
        let sNo = 0;
        this.summitParticulars = result.map((summitParticular) => {
          sNo++;
          return {
            id: sNo,
            summitParticularName: summitParticular.Name,
            timeline: summitParticular.smt_Timeline__c || new Date(),
            target: summitParticular.smt_Target__c,
            targetText: summitParticular.smt_Target_Text__c,
            isTargetApplicable: summitParticular.smt_Is_Target_Applicable__c,
            isEvidenceApplicable:
              summitParticular.smt_Is_Evidence_Applicable__c,
            summitParticularId: summitParticular.Id
          };
        });
      })
      .catch((error) => {
        console.error("Error when fetching summit particular records ", error);
        this.showToastNotification(
          "Error when fetching summit particular records ",
          error.body.message,
          "error"
        );
      });
  }
  handleParticularChange(event) {
    const id = event.target.dataset.id;
    const label = event.target.dataset.label;
    let value = event.target.value;
    if (label == "isTargetApplicable" || label == "isEvidenceApplicable") {
      value = event.target.checked;
    }
    const changedSummitParticular = this.summitParticulars.find(
      (summitParticular) => summitParticular.id == id
    );
    if (changedSummitParticular) {
      changedSummitParticular[label] = value;
    }
  }
  handleCreateOrUpdateParticulars(event) {
    if (event.target.dataset.label === "Create Particulars") {
      this.handleCreateParticulars();
    } else if (event.target.dataset.label === "Update Particulars") {
      this.handleUpdateParticulars();
    }
  }
  handleUpdateParticulars() {
    if (!this.summitSectionId) {
      this.showToastNotification(
        "No Summit Section Id Available So We Can't Proceed Creating Particulars",
        "",
        "info"
      );
      return;
    }
    this.isSpinner = true;
    updateAllSummitParticular({
      jsonData: JSON.stringify(this.summitParticulars)
    })
      .then((result) => {
        this.showToastNotification(
          "Summit Particular Saved Successfully",
          "",
          "success"
        );
        this.isSpinner = false;
      })
      .catch((error) => {
        console.error(
          "Error when saving summit particulars " + JSON.stringify(error)
        );
        this.showToastNotification(
          "Error when saving summit particulars",
          error.body.message,
          "error"
        );
        this.isSpinner = false;
      });
  }
  handleCreateParticulars() {
    if (!this.summitSectionId) {
      this.showToastNotification(
        "No Summit Section Id Available So We Can't Proceed Creating Particulars",
        "",
        "info"
      );
      return;
    }
    this.isSpinner = true;
    createSummitParticular({
      jsonData: JSON.stringify(this.summitParticulars),
      summitSectionId: this.summitSectionId
    })
      .then((result) => {
        this.showToastNotification(
          "Particulars Created Successfully ",
          "",
          "success"
        );
        this.isSpinner = false;
      })
      .catch((error) => {
        console.error("Error when creating Particulars " + error);
        this.showToastNotification(
          "Error When Creating Particulars",
          error.body.message,
          "error"
        );
        this.isSpinner = false;
      });
  }

  showToastNotification(title, message, variant) {
    const evt = new ShowToastEvent({
      title,
      message,
      variant
    });
    this.dispatchEvent(evt);
  }

  handleBackClick(event) {
    this.dispatchEvent(new CustomEvent("clickback"));
  }
}