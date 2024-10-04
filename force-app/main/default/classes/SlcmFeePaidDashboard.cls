public without sharing class SlcmFeePaidDashboard {    
    
    @AuraEnabled(cacheable=true)
    public static String getResponseString(){
        return 'Hello REVA';
    }
    
    @AuraEnabled(cacheable=true)
    public static String getFeePaymentStats() {
        // Initialize variables to hold the results
        Decimal todayAmount = 0.0; 
        Decimal yesterdayAmount = 0.0;
        Decimal lastWeekAmount = 0.0;
        Decimal currentWeekAmount = 0.0;   
		Decimal lastSevenDaysAmount = 0.0;
        Decimal lastMonthAmount = 0.0;
        Decimal currentMonthAmount = 0.0;
		
        
        // Query to get today's field value
        AggregateResult todayResult = [
            SELECT SUM(Amount__c) totalAmount
            FROM Student_Fee_Payment__c
            WHERE Line_Item_Payment_Status__c = 'Success'
              AND Student_Payment__r.Mode_of_Payment__c = 'Online'
              AND Transaction_Date_Time__c = TODAY
              AND Integrated_with_SAP__c = TRUE
        ];

        if (todayResult != null && todayResult.get('totalAmount') != null) {
            todayAmount =  (Decimal)todayResult.get('totalAmount');
        }      
        
         // Query to get yesterday's field value
        AggregateResult yesterdayResult = [
            SELECT SUM(Amount__c) totalAmount
            FROM Student_Fee_Payment__c 
            where Line_Item_Payment_Status__c = 'Success' 
            and Student_Payment__r.Mode_of_Payment__c ='Online' 
            AND Transaction_Date_Time__c = YESTERDAY 
            AND Integrated_with_SAP__c = TRUE
        ];

        if (yesterdayResult != null && yesterdayResult.get('totalAmount') != null) {
            yesterdayAmount =  (Decimal)yesterdayResult.get('totalAmount');
        }
        
         // Query to get lastWeek's field value
        AggregateResult lastWeekResult = [
            SELECT SUM(Amount__c) totalAmount
            FROM Student_Fee_Payment__c 
            where Line_Item_Payment_Status__c = 'Success' 
            and Student_Payment__r.Mode_of_Payment__c ='Online' 
            AND Transaction_Date_Time__c = LAST_WEEK  
            AND Integrated_with_SAP__c = TRUE
        ];

        if (lastWeekResult != null && lastWeekResult.get('totalAmount') != null) {
            lastWeekAmount =  (Decimal)lastWeekResult.get('totalAmount');
        }
        
         // Query to get currentWeek's field value
        AggregateResult currentWeekResult = [
            SELECT SUM(Amount__c) totalAmount
            FROM Student_Fee_Payment__c 
            where Line_Item_Payment_Status__c = 'Success' 
            and Student_Payment__r.Mode_of_Payment__c ='Online' 
            AND Transaction_Date_Time__c = THIS_WEEK   
            AND Integrated_with_SAP__c = TRUE
        ];

        if (currentWeekResult != null && currentWeekResult.get('totalAmount') != null) {
            currentWeekAmount =  (Decimal)currentWeekResult.get('totalAmount');
        }
        
         // Query to get lastMonth's field value
        AggregateResult lastMonthResult = [
            SELECT SUM(Amount__c) totalAmount
            FROM Student_Fee_Payment__c 
            where Line_Item_Payment_Status__c = 'Success' 
            and Student_Payment__r.Mode_of_Payment__c ='Online' 
            AND Transaction_Date_Time__c = LAST_MONTH  
            AND Integrated_with_SAP__c = TRUE
        ];

        if (lastMonthResult != null && lastMonthResult.get('totalAmount') != null) {
            lastMonthAmount =  (Decimal)lastMonthResult.get('totalAmount');
        }       
        
        // Query to get last seven days field value
        AggregateResult lastSevenDaysResult = [
            SELECT SUM(Amount__c) totalAmount
            FROM Student_Fee_Payment__c
            WHERE Line_Item_Payment_Status__c = 'Success'
              AND Student_Payment__r.Mode_of_Payment__c = 'Online'
              AND Transaction_Date_Time__c = LAST_N_DAYS:7
              AND Integrated_with_SAP__c = TRUE
        ];

        if (lastSevenDaysResult != null && lastSevenDaysResult.get('totalAmount') != null) {
            lastSevenDaysAmount = (Decimal)lastSevenDaysResult.get('totalAmount');
        }

        // Query to get current month field value
        AggregateResult currentMonthResult = [
            SELECT SUM(Amount__c) totalAmount
            FROM Student_Fee_Payment__c
            WHERE Line_Item_Payment_Status__c = 'Success'
              AND Student_Payment__r.Mode_of_Payment__c = 'Online'
              AND Transaction_Date_Time__c = THIS_MONTH
              AND Integrated_with_SAP__c = TRUE
        ];

        if (currentMonthResult != null && currentMonthResult.get('totalAmount') != null) {
            currentMonthAmount = (Decimal)currentMonthResult.get('totalAmount');
        }

        // Construct the response as a JSON string
        Map<String, Decimal> resultMap = new Map<String, Decimal>{
            'today' => todayAmount,
            'yesterday' => yesterdayAmount,
			'lastWeek' => lastWeekAmount,   
            'currentWeek' => currentWeekAmount,                
            'last_seven_days' => lastSevenDaysAmount,
            'current_month' => currentMonthAmount,
            'lastMonth' => lastMonthAmount                
        };

        return JSON.serialize(resultMap);
    }
    
    // Month wise data     
    @AuraEnabled(cacheable=true)
    public static String getFeePaymentsMonthStats(){
        // Initialize a map to hold the results
        Map<String, Decimal> resultMap = new Map<String, Decimal>();

        // Calculate the current financial year start and end dates
        Date today = Date.today();
        Integer currentYear = today.year();
        Integer financialYearStartYear = today.month() >= 4 ? currentYear : currentYear - 1;
        Date financialYearStartDate = Date.newInstance(financialYearStartYear, 4, 1); // Start of the financial year (April 1st)
        Date financialYearEndDate = Date.newInstance(financialYearStartYear + 1, 3, 31); // End of the financial year (March 31st)

        // Query to get all data for the current financial year
        List<Student_Fee_Payment__c> payments = [
            SELECT Amount__c, Transaction_Date_Time__c
            FROM Student_Fee_Payment__c
            WHERE Line_Item_Payment_Status__c = 'Success'
              AND Student_Payment__r.Mode_of_Payment__c = 'Online'
              AND Transaction_Date_Time__c >= :financialYearStartDate
              AND Transaction_Date_Time__c <= :financialYearEndDate
              AND Integrated_with_SAP__c = TRUE
        ];

        // Process the results to aggregate monthly data
        for (Student_Fee_Payment__c payment : payments) {
            DateTime transactionDateTime = payment.Transaction_Date_Time__c;
            // Convert DateTime to String in 'YYYY-MM' format
            String monthKey = transactionDateTime.format('yyyy-MM'); // Use 'yyyy-MM' for month key
            
            if (!resultMap.containsKey(monthKey)) {
                resultMap.put(monthKey, 0.0);
            }
            
            resultMap.put(monthKey, resultMap.get(monthKey) + payment.Amount__c);
        }
			System.debug('Months ->'+resultMap);
        // Construct the response as a JSON string
        return JSON.serialize(resultMap);		
    }
    
    // get today yesterday last week current week last month current month
    @AuraEnabled(cacheable=true)
    public static String getPeriodData() {
        // Initialize a map to hold the results
        Map<String, Decimal> resultMap = new Map<String, Decimal>();

        // Calculate the date ranges for each period
        Date today = Date.today();
        Date yesterday = today.addDays(-1);
        Date lastSevenDaysStart = today.addDays(-7);
        Date currentWeekStart = today.toStartOfWeek();
        Date currentWeekEnd = currentWeekStart.addDays(6);
        Date lastWeekStart = currentWeekStart.addDays(-7);
        Date lastWeekEnd = currentWeekStart.addDays(-1);
        Date currentMonthStart = today.toStartOfMonth();
        Date currentMonthEnd = Date.newInstance(today.year(), today.month() + 1, 1).addDays(-1); // End of the current month
        Date lastMonthStart = currentMonthStart.addMonths(-1);
        Date lastMonthEnd = currentMonthStart.addDays(-1); // End of the last month

        // Query for today's data
        resultMap.put('today', getSumAmount(today, today));

        // Query for yesterday's data
        resultMap.put('yesterday', getSumAmount(yesterday, yesterday));

        // Query for last seven days' data
        resultMap.put('last_seven_days', getSumAmount(lastSevenDaysStart, today));

        // Query for current week's data
        resultMap.put('current_week', getSumAmount(currentWeekStart, currentWeekEnd));

        // Query for last week's data
        resultMap.put('last_week', getSumAmount(lastWeekStart, lastWeekEnd));

        // Query for current month's data
        resultMap.put('current_month', getSumAmount(currentMonthStart, currentMonthEnd));

        // Query for last month's data
        resultMap.put('last_month', getSumAmount(lastMonthStart, lastMonthEnd));

        // Convert the map to a JSON string and return
        return JSON.serialize(resultMap);
    }

    private static Decimal getSumAmount(Date startDate, Date endDate) {
        AggregateResult result = [
            SELECT SUM(Amount__c) totalAmount
            FROM Student_Fee_Payment__c
            WHERE Line_Item_Payment_Status__c = 'Success'
              AND Student_Payment__r.Mode_of_Payment__c = 'Online'
              AND Transaction_Date_Time__c >= :startDate
              AND Transaction_Date_Time__c <= :endDate
              AND Integrated_with_SAP__c = TRUE
        ];
        
        Decimal totalAmount = (Decimal) result.get('totalAmount');
        return totalAmount != null ? totalAmount : 0.0;
    }
    
    @AuraEnabled(cacheable=true)
   	public static String formatDatetimeToCustomString(Datetime dateTime1) {
        // Get the date and time parts
        String formattedDateTime = dateTime1.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        return formattedDateTime;
    	}
    
        // Sample executable code
        public static void testFormat() {
            // Get the current Datetime (now)
            Datetime currentDateTime = Datetime.now();
            System.debug('Current DateTime: ' + currentDateTime);
            
            // Format the current Datetime in the required format
            String formattedDateTime = formatDatetimeToCustomString(currentDateTime);
            System.debug('Formatted DateTime: ' + formattedDateTime);
        }
    
}