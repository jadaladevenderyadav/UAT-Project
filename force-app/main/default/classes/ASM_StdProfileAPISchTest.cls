@isTest
public class ASM_StdProfileAPISchTest {
    public static testmethod Void exe(){
        Test.startTest();
        String Sch = '0 0 * * * ?';
        system.schedule('ASM_StdProfileAPISch',Sch, new ASM_StdProfileAPISch());
        Test.stopTest(); 
    }  
}