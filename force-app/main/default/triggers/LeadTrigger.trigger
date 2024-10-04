trigger LeadTrigger on Lead (before insert, before update,after Update) {

    switch on Trigger.OperationType{
      when BEFORE_INSERT{
          system.debug('Inside Before insert');
          //Combined method for Leads created by Publishers / Counselor / Data upload
          LeadTriggerHandler.insertPrimarySource(Trigger.new);
      }
      when BEFORE_UPDATE{
          system.debug('Inside Before Update');
          LeadTriggerHandler.updateCCAndMobilePhone(Trigger.oldMap, Trigger.new);
          LeadTriggerHandler.updateLeadSource(Trigger.oldMap, Trigger.new);
      }when AFTER_UPDATE{
          system.debug('Inside After Update');
          ReassignmentSendSMSANdWhatsapp.handleOwnerChangeLead(Trigger.new, Trigger.oldMap);
      }
    }
}