global class UpdateMobileNumber implements Database.Batchable<SObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'SELECT Id, MobilePhone' + //Father__r.MobilePhone, Mother__r.MobilePhone' +
                    ' FROM Contact WHERE MobilePhone = \'8109666063\' OR MobilePhone = \'918109666063\' OR MobilePhone = \'+91-8109666063\'';
            //Father__r.MobilePhone != null' +
                    //' AND Mother__r.MobilePhone != null AND MobilePhone != null';
    	return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> contList) {
        
        for(Contact c : contList){
        	c.MobilePhone = '999999';
            //c.Father__r.MobilePhone = c.MobilePhone;
            //c.Mother__r.MobilePhone = c.MobilePhone;
        }
        update contList;
    }
    
    global void finish(Database.BatchableContext bc) {}

    
    
    
    /*
     * List<Contact> cnt = [LIMIT 2000];
for(Contact c : cnt){
    c.Father__r.MobilePhone = c.MobilePhone;
    c.Mother__r.MobilePhone = c.MobilePhone;
}
update cnt;
	*/

}