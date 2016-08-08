public class PostInstallRecords implements InstallHandler 
{

   public void onInstall(InstallContext ctx) 
   {
        //loadLicenceData();
        PasswordSetting(); 
        loadStandardSetting();
   }
   
   public void loadLicenceData()
   {
        list<GUMU_App_Setting__c> GumuAppSettingLst = [select Id from GUMU_App_Setting__c LIMIT 100];
        if(GumuAppSettingLst.size() ==0)
        {
            string strAppSettingData='[{"No_of_Users__c":"10","Expiration_Date__c":"2016-07-01","ERP_System__c":"SageERPX3","Activation_Key__c":"123456789","Name":"GUMU SageERPX3"}]';
            List<map<String,String>> RecordList=(List<map<String,String>>)JSON.deserializeStrict(strAppSettingData,List<map<String,String>>.class);
            
            list<GUMU_App_Setting__c> lstAppSetting = new list<GUMU_App_Setting__c>();
            GUMU_App_Setting__c AppSetting;
            integer cnt =1;
            for(map<String,String> Record :RecordList)
            {           
                AppSetting = new GUMU_App_Setting__c();
                for(string key :Record.keyset())
                {                    
                   if(key=='Expiration_Date__c')
                        AppSetting.put(key,Date.valueOf(Record.get(key)));
                    else if(key=='No_of_Users__c')
                      AppSetting.put(key,integer.valueOf(Record.get(key)));
                     else                  
                        AppSetting.put(key,Record.get(key));
                }   
                lstAppSetting.add(AppSetting);
                if(math.mod(cnt,10) ==0)
                {       
                    insert lstAppSetting;
                    lstAppSetting = new list<GUMU_App_Setting__c>();
                }
                cnt++;
            
            }
            if(lstAppSetting.size()>0)
            {
                insert lstAppSetting;
            }
        }
   }
   
   public void PasswordSetting()
   {
        list<PasswordSetting__c> PassSettingLst = [select Id from PasswordSetting__c LIMIT 1];
        if(PassSettingLst.size() ==0)
        {

            string strPassSettingData='[{"Password_Key__c":"123456789012345678901234","Name":"PS001"}]';
            List<map<String,String>> RecordList=(List<map<String,String>>)JSON.deserializeStrict(strPassSettingData,List<map<String,String>>.class);

            list<PasswordSetting__c> lstPassSetting = new list<PasswordSetting__c>();
            PasswordSetting__c PassSetting;
            integer cnt =1;
            for(map<String,String> Record :RecordList)
            {           
                PassSetting = new PasswordSetting__c();
                for(string key :Record.keyset())
                {                                   
                    PassSetting.put(key,Record.get(key));
                }
                   
                lstPassSetting.add(PassSetting);
                
                if(math.mod(cnt,10) ==0)
                {       
                    insert lstPassSetting;
                    lstPassSetting = new list<PasswordSetting__c>();
                }
                cnt++;

            }
            if(lstPassSetting.size()>0)
            {
                insert lstPassSetting;
            }
        }
   }
   
   public void loadStandardSetting()
       {
            
            string response='[{"Address_Code_2__c":"SHP01","Address_Code_1__c":"BIL01","Name":"STDSetting","Insert_New_Records__c":true,"Update_Existing_Records__c":true,"Default_Decimals__c":2,"Promote_Additional_Address__c":true,"RunTrigger__c":true}]';
            List<map<String,String>> RecordList=(List<map<String,String>>)JSON.deserializeStrict(response,List<map<String,String>>.class);
            
            list<Standard_Setting__c> records =[select Id from Standard_Setting__c limit 1000];
            
            if(records.size()==0)
            {
            
                list<Standard_Setting__c> lstAddrSetting = new list<Standard_Setting__c>();
                Standard_Setting__c AddrSetting;
                integer cnt =1;
                for(map<String,String> Record :RecordList)
                {           
                    AddrSetting = new Standard_Setting__c();
                    for(string key :Record.keyset())
                    {    
                        if(key == 'Insert_New_Records__c' || key =='Update_Existing_Records__c' || key =='Promote_Additional_Address__c' || key =='RunTrigger__c')
                            AddrSetting.put(key,boolean.valueOf(Record.get(key)));
                        else if(key == 'Default_Decimals__c')
                            AddrSetting.put(key,decimal.valueof(Record.get(key)));
                        else           
                            AddrSetting.put(key,Record.get(key));
                    }   
                    lstAddrSetting.add(AddrSetting);
                    if(math.mod(cnt,10) ==0)
                    {       
                        insert lstAddrSetting;
                        lstAddrSetting = new list<Standard_Setting__c>();
                    }
                    cnt++;
                
                }
                if(lstAddrSetting.size()>0)
                {
                    insert lstAddrSetting;
                }
            }
        }
}