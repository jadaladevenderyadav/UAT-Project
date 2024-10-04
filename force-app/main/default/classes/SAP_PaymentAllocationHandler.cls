public class SAP_PaymentAllocationHandler {
    public static void handlePaymentAllocation(List<Student_Payment__c> newPayments, Map<Id, Student_Payment__c> oldPaymentsMap) {
        Set<String> setSp = new Set<String>();
        Set<String> setSpDemandnotnull = new Set<String>();
        Set<String> setSpIdDemandNull = new Set<String>();
        Map<Id,string> mapStdPayment = new Map<Id,string>();
        for (Student_Payment__c sp : newPayments) {
            // Student_Payment__c oldPayment = oldPaymentsMap.get(sp.Id);
            /* if (sp.Auto_Allocate__c && !oldPayment.Auto_Allocate__c && !sp.Auto_Allocate_isDone__c) {
setSp.add(sp.Contact__c);
}*/
            if (sp.Auto_Allocate__c && (sp.SAP_Code__c != '' || sp.SAP_Code__c !=null )&& sp.Demand_Number__c == null)
                setSp.add(sp.Contact__c);
            /*if(sp.Demand_Number__c == null)
                setSpIdDemandNull.add(sp.Id);*/
            if(sp.Demand_Number__c != null && (sp.Auto_Allocate__c && (sp.SAP_Code__c != '' || sp.SAP_Code__c !=null ))){
                 setSpDemandnotnull.add(sp.Contact__c);
                mapStdPayment.put(sp.Id,sp.Demand_Number__c);
            }
               
        }
        
       /* if (setSp.isEmpty()) {
            return;
        }*/
        
        if(!setSp.isEmpty()){
            
            
            
            
            Set<String> feeTypes = new Set<String>{'University Fee', 'Tuition Fee'};
                Map<String, List<Student_Fee__c>> mapStuFees = new Map<String, List<Student_Fee__c>>();
            
            for(Student_Fee__c sf : [SELECT id,Contact__c,Fee_Type__c,Amount__c,Amount_Paid__c,Amount_Pending__c,Due_Date__c FROM Student_Fee__c 
                                     WHERE Contact__c =: setSp AND Due_Date__c != Null AND Amount_Pending__c > 0 AND 
                                     Fee_Type__c =: feeTypes ORDER By Due_Date__c ASC]){
                                         if(mapStuFees.containsKey(sf.Contact__c)){
                                             mapStuFees.get(sf.Contact__c).add(sf);
                                         }
                                         else{
                                             mapStuFees.put(sf.Contact__c,new list<Student_Fee__c>{sf});
                                         }
                                     }
            
            
            for(Student_Fee__c sf : [SELECT id,Contact__c,Fee_Type__c,Amount__c,Amount_Paid__c,Amount_Pending__c,Due_Date__c FROM Student_Fee__c 
                                     WHERE Contact__c =: setSp AND Due_Date__c = Null AND Amount_Pending__c > 0 AND 
                                     Fee_Type__c =: feeTypes  ORDER By Display_No__c ASC]){
                                         if(mapStuFees.containsKey(sf.Contact__c)){
                                             mapStuFees.get(sf.Contact__c).add(sf);
                                         }
                                         else{
                                             mapStuFees.put(sf.Contact__c,new list<Student_Fee__c>{sf});
                                         }
                                     }
            /* 
for(Student_Fee__c sf : [SELECT id,Contact__c,Fee_Type__c,Amount__c,Amount_Paid__c,Amount_Pending__c,Due_Date__c FROM Student_Fee__c 
WHERE Contact__c =: setSp AND Due_Date__c = Null AND Amount_Pending__c > 0 AND 
Fee_Type__c !=: type]){
if(mapStuFees.containsKey(sf.Contact__c)){
mapStuFees.get(sf.Contact__c).add(sf);
}
else{
mapStuFees.put(sf.Contact__c,new list<Student_Fee__c>{sf});
}
}

*/
            
            
            system.debug('mapStuFees++++++++'+mapStuFees);
            list<Student_Payment__c> updateStuPay = new  list<Student_Payment__c>();
            map<string,Student_Fee__c> updateStuFee = new  map<string,Student_Fee__c>();
            list<Student_Fee_Payment__c> updateSfp = new list<Student_Fee_Payment__c>();
            
            for(Student_Payment__c sp : newPayments){
                if(mapStuFees.containsKey(sp.Contact__c)){
                    //sp.Auto_Allocate_isDone__c = true;
                    updateStuPay.add(sp);
                    decimal paidAmount = sp.Amount__c;
                    
                    integer recSize = mapStuFees.get(sp.Contact__c).size();
                    integer count = 0;
                    for(Student_Fee__c sf : mapStuFees.get(sp.Contact__c)){
                        system.debug('paidAmount++++++++'+paidAmount);
                        count = count + 1;
                        
                        if(paidAmount > 0){
                            system.debug('Count+++++++++'+count);
                            system.debug('recSize+++++++++'+recSize);
                            if(sf.Amount_Pending__c > paidAmount && paidAmount > 0 && ((sf.Amount_Pending__c > 0 && recSize != count)|| recSize == count)){
                                
                                system.debug('sf.Amount_Paid__c+++++++++'+sf.Amount_Paid__c);
                                system.debug('sf.Amount__c+++++++++'+sf.Amount__c);
                                system.debug('sf.Amount_Pending__c+++++++++'+sf.Amount_Pending__c);
                                system.debug('paidAmount+++++++++'+paidAmount);
                                
                                Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
                                sf.Amount_Paid__c = sf.Amount_Paid__c + paidAmount;
                                sf.Amount_Pending__c = sf.Amount__c - sf.Amount_Paid__c;
                                sfp.Amount__c = paidAmount;
                                sfp.Mode_of_Payment__c = sp.Mode_of_Payment__c;
                                sfp.Student_Fee__c = sf.id;
                                sfp.Student_Payment__c = sp.id;
                                sfp.Line_Item_Payment_Status__c = sp.Payment_Status__c;
                                sfp.Transaction_Date_Time__c = sp.Payment_Date_Time__c;
                                sfp.Line_Item_Payment_Gateway__c = sp.Payment_Gateway__c;
                                sfp.Payment_Mode_Type__c = sp.Payment_Mode_Type__c;
                                sfp.Remarks__c = sp.Description__c;
                                updateSfp.add(sfp);
                                paidAmount = 0;
                            }
                            else if(sf.Amount_Pending__c < paidAmount && paidAmount > 0 && ((sf.Amount_Pending__c > 0 && recSize != count)|| recSize == count)){
                                
                                system.debug('sf.Amount_Paid__c+++++++++'+sf.Amount_Paid__c);
                                system.debug('sf.Amount__c+++++++++'+sf.Amount__c);
                                system.debug('sf.Amount_Pending__c+++++++++'+sf.Amount_Pending__c);
                                system.debug('paidAmount+++++++++'+paidAmount);
                                
                                Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
                                
                                if(recSize == count){
                                    sf.Amount_Paid__c = sf.Amount_Paid__c + paidAmount;
                                    sfp.Amount__c = paidAmount;
                                }
                                else{
                                    sf.Amount_Paid__c = sf.Amount_Paid__c + sf.Amount_Pending__c;
                                    sfp.Amount__c = sf.Amount_Pending__c;
                                }
                                paidAmount = paidAmount - sf.Amount_Pending__c;
                                sf.Amount_Pending__c = sf.Amount__c - sf.Amount_Paid__c;
                                sfp.Mode_of_Payment__c = sp.Mode_of_Payment__c;
                                sfp.Student_Fee__c = sf.id;
                                sfp.Student_Payment__c = sp.id;
                                sfp.Line_Item_Payment_Status__c = sp.Payment_Status__c;
                                sfp.Transaction_Date_Time__c = sp.Payment_Date_Time__c;
                                sfp.Line_Item_Payment_Gateway__c = sp.Payment_Gateway__c;
                                sfp.Payment_Mode_Type__c = sp.Payment_Mode_Type__c;
                                sfp.Remarks__c = sp.Description__c;
                                updateSfp.add(sfp);
                                
                            }
                            else if(sf.Amount_Pending__c == paidAmount && paidAmount > 0 && ((sf.Amount_Pending__c > 0 && recSize != count)|| recSize == count)){
                                
                                system.debug('sf.Amount_Paid__c+++++++++'+sf.Amount_Paid__c);
                                system.debug('sf.Amount__c+++++++++'+sf.Amount__c);
                                system.debug('sf.Amount_Pending__c+++++++++'+sf.Amount_Pending__c);
                                system.debug('paidAmount+++++++++'+paidAmount);
                                
                                sf.Amount_Paid__c = sf.Amount_Paid__c + paidAmount;
                                sf.Amount_Pending__c = sf.Amount__c - sf.Amount_Paid__c;
                                sf.Amount_Pending__c = 0;
                                Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
                                sfp.Amount__c = paidAmount;
                                sfp.Mode_of_Payment__c = sp.Mode_of_Payment__c;
                                sfp.Student_Fee__c = sf.id;
                                sfp.Student_Payment__c = sp.id;
                                sfp.Line_Item_Payment_Status__c = sp.Payment_Status__c;
                                sfp.Transaction_Date_Time__c = sp.Payment_Date_Time__c;
                                sfp.Line_Item_Payment_Gateway__c = sp.Payment_Gateway__c;
                                sfp.Payment_Mode_Type__c = sp.Payment_Mode_Type__c;
                                sfp.Remarks__c = sp.Description__c;
                                updateSfp.add(sfp);
                                paidAmount = 0;
                            }
                            updateStuFee.put(sf.id,sf);
                        }
                    }
                }
            }
            
            // Update student fees and payments
            if (!updateStuFee.isEmpty()) {
                update updateStuFee.values();
            }
            
            if (!updateStuPay.isEmpty()) {
                //update updateStuPay;
            }
            
            if (!updateSfp.isEmpty()) {
                insert updateSfp;
            }
        } 
         if(!setSpDemandnotnull.isEmpty()){
            
            
            Map<String, List<Student_Fee__c>> mapStuFees = new Map<String, List<Student_Fee__c>>();
            
            
            for(Student_Fee__c sf : [SELECT id,Contact__c,Fee_Type__c,Amount__c,Amount_Paid__c,Amount_Pending__c,Due_Date__c FROM Student_Fee__c 
                                     WHERE Contact__c =: setSpDemandnotnull AND Demand_Number__c IN:mapStdPayment.values()]){
                                         if(mapStuFees.containsKey(sf.Contact__c)){
                                             mapStuFees.get(sf.Contact__c).add(sf);
                                         }
                                         else{
                                             mapStuFees.put(sf.Contact__c,new list<Student_Fee__c>{sf});
                                         }
                                     }
            
            system.debug('mapStuFees++++++++'+mapStuFees);
            list<Student_Payment__c> updateStuPay = new  list<Student_Payment__c>();
            map<string,Student_Fee__c> updateStuFee = new  map<string,Student_Fee__c>();
            list<Student_Fee_Payment__c> updateSfp = new list<Student_Fee_Payment__c>();
            
            for(Student_Payment__c sp : newPayments){
                if(mapStuFees.containsKey(sp.Contact__c)){
                    //sp.Auto_Allocate_isDone__c = true;
                    updateStuPay.add(sp);
                    decimal paidAmount = sp.Amount__c;
                    
                    integer recSize = mapStuFees.get(sp.Contact__c).size();
                    integer count = 0;
                    for(Student_Fee__c sf : mapStuFees.get(sp.Contact__c)){
                        system.debug('paidAmount++++++++'+paidAmount);
                        count = count + 1;
                        
                        if(paidAmount > 0){
                            system.debug('Count+++++++++'+count);
                            system.debug('recSize+++++++++'+recSize);
                            if(sf.Amount_Pending__c > paidAmount && paidAmount > 0 && ((sf.Amount_Pending__c > 0 && recSize != count)|| recSize == count)){
                                
                                system.debug('sf.Amount_Paid__c+++++++++'+sf.Amount_Paid__c);
                                system.debug('sf.Amount__c+++++++++'+sf.Amount__c);
                                system.debug('sf.Amount_Pending__c+++++++++'+sf.Amount_Pending__c);
                                system.debug('paidAmount+++++++++'+paidAmount);
                                
                                Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
                                sf.Amount_Paid__c = sf.Amount_Paid__c + paidAmount;
                                sf.Amount_Pending__c = sf.Amount__c - sf.Amount_Paid__c;
                                sfp.Amount__c = paidAmount;
                                sfp.Mode_of_Payment__c = sp.Mode_of_Payment__c;
                                sfp.Student_Fee__c = sf.id;
                                sfp.Student_Payment__c = sp.id;
                                sfp.Line_Item_Payment_Status__c = sp.Payment_Status__c;
                                sfp.Transaction_Date_Time__c = sp.Payment_Date_Time__c;
                                sfp.Line_Item_Payment_Gateway__c = sp.Payment_Gateway__c;
                                sfp.Payment_Mode_Type__c = sp.Payment_Mode_Type__c;
                                sfp.Remarks__c = sp.Description__c;
                                updateSfp.add(sfp);
                                paidAmount = 0;
                            }
                            else if(sf.Amount_Pending__c < paidAmount && paidAmount > 0 && ((sf.Amount_Pending__c > 0 && recSize != count)|| recSize == count)){
                                
                                system.debug('sf.Amount_Paid__c+++++++++'+sf.Amount_Paid__c);
                                system.debug('sf.Amount__c+++++++++'+sf.Amount__c);
                                system.debug('sf.Amount_Pending__c+++++++++'+sf.Amount_Pending__c);
                                system.debug('paidAmount+++++++++'+paidAmount);
                                
                                Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
                                
                                if(recSize == count){
                                    sf.Amount_Paid__c = sf.Amount_Paid__c + paidAmount;
                                    sfp.Amount__c = paidAmount;
                                }
                                else{
                                    sf.Amount_Paid__c = sf.Amount_Paid__c + sf.Amount_Pending__c;
                                    sfp.Amount__c = sf.Amount_Pending__c;
                                }
                                paidAmount = paidAmount - sf.Amount_Pending__c;
                                sf.Amount_Pending__c = sf.Amount__c - sf.Amount_Paid__c;
                                sfp.Mode_of_Payment__c = sp.Mode_of_Payment__c;
                                sfp.Student_Fee__c = sf.id;
                                sfp.Student_Payment__c = sp.id;
                                sfp.Line_Item_Payment_Status__c = sp.Payment_Status__c;
                                sfp.Transaction_Date_Time__c = sp.Payment_Date_Time__c;
                                sfp.Line_Item_Payment_Gateway__c = sp.Payment_Gateway__c;
                                sfp.Payment_Mode_Type__c = sp.Payment_Mode_Type__c;
                                sfp.Remarks__c = sp.Description__c;
                                updateSfp.add(sfp);
                                
                            }
                            else if(sf.Amount_Pending__c == paidAmount && paidAmount > 0 && ((sf.Amount_Pending__c > 0 && recSize != count)|| recSize == count)){
                                
                                system.debug('sf.Amount_Paid__c+++++++++'+sf.Amount_Paid__c);
                                system.debug('sf.Amount__c+++++++++'+sf.Amount__c);
                                system.debug('sf.Amount_Pending__c+++++++++'+sf.Amount_Pending__c);
                                system.debug('paidAmount+++++++++'+paidAmount);
                                
                                sf.Amount_Paid__c = sf.Amount_Paid__c + paidAmount;
                                sf.Amount_Pending__c = sf.Amount__c - sf.Amount_Paid__c;
                                sf.Amount_Pending__c = 0;
                                Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
                                sfp.Amount__c = paidAmount;
                                sfp.Mode_of_Payment__c = sp.Mode_of_Payment__c;
                                sfp.Student_Fee__c = sf.id;
                                sfp.Student_Payment__c = sp.id;
                                sfp.Line_Item_Payment_Status__c = sp.Payment_Status__c;
                                sfp.Transaction_Date_Time__c = sp.Payment_Date_Time__c;
                                sfp.Line_Item_Payment_Gateway__c = sp.Payment_Gateway__c;
                                sfp.Payment_Mode_Type__c = sp.Payment_Mode_Type__c;
                                sfp.Remarks__c = sp.Description__c;
                                updateSfp.add(sfp);
                                paidAmount = 0;
                            }
                            updateStuFee.put(sf.id,sf);
                        }
                    }
                }
            }
            
            // Update student fees and payments
            if (!updateStuFee.isEmpty()) {
                update updateStuFee.values();
            }
            
            if (!updateStuPay.isEmpty()) {
                //update updateStuPay;
            }
            
            if (!updateSfp.isEmpty()) {
                insert updateSfp;
            }
        }
    }
}