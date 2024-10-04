global class schedulableFeeRemainder implements schedulable
{
    global void execute(SchedulableContext sc)
    {
    	SendEmailHostelFeeRemainder objsch = new SendEmailHostelFeeRemainder(); 
      	database.executebatch(objsch);
    }
}