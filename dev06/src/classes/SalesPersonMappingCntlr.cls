public with sharing class SalesPersonMappingCntlr 
{

    public SalesPersonMappingCntlr() {
}
    public list<User> Users {get;set;}
    public String ConfigId{get;set;}
    public String FirstName{get;set;}
    public String LastName{get;set;}
    public String ConfigObjectPrefix {get;set;}
    public String SalesObjectPrefix {get;set;} 
    public list<Salesperson_Mapping__c> lstUserMapping {get;set;}
    public list<UserMapping> Mappings {get;set;} 
    public Map<Id,Profile> profileIds {get;set;}
    public Boolean bAdministration{get;set;}
    public String NameSpace {get;set;}
    public String ProfileName {get;set;}
    public String DefaulIntegrationID{get;set;}
    public String DefaulIntegrationName{get;set;}
    public SalesPersonMappingCntlr(ApexPages.StandardController controller) 
    {
        if(UserInfo.getProfileId() != '' && UserInfo.getProfileId() != null) 
        {
            // Check if the user has read access on the Profile.name
            if (Schema.sObjectType.Profile.fields.name.isAccessible()) {
                ProfileName = [select name from profile where id =: UserInfo.getProfileId() limit 1].name;
            }
        }

        NameSpace=Utility.FetchNameSpace();
        Security_Matrix__c SM = Security_Matrix__c.getInstance();
        bAdministration = Boolean.valueOf(SM.GUMU_Administration__c);

        ConfigObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'ERP_Config__c'); //NameSpace+'ERP_Config__c'
        SalesObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Salesperson__c');
        ConfigId ='';
        Mappings = new list<UserMapping>();

        // Check if the user has read access on the Profile.Id, Profile.UserLicenseId and UserLicense.Id
        if (Schema.sObjectType.Profile.fields.Id.isAccessible() && Schema.sObjectType.Profile.fields.UserLicenseId.isAccessible()
                && Schema.sObjectType.UserLicense.fields.Id.isAccessible() ){

            profileIds = new Map<id,profile>([SELECT Id,UserLicenseId FROM Profile where UserLicenseId  in (SELECT Id FROM UserLicense where name in('Salesforce','Salesforce Platform'))]);
        }
        
        // Assign Default Integration
        List<ERP_Config__c> lstERPConfig = [select Id, Name from ERP_Config__c where Default__c =true limit 1] ;  

        DefaulIntegrationID = '';
        DefaulIntegrationName = '';
        if(lstERPConfig.size() > 0)
        {
            DefaulIntegrationID = lstERPConfig[0].Id;
            DefaulIntegrationName = lstERPConfig[0].Name;
        }

    }

    private void CreateMappingList()
    {
        Mappings=new list<UserMapping>();

        for(User u : Users)
        {
            UserMapping um = new UserMapping();

            um.SFFirstName=u.FirstName;
            um.SFLastName=u.LastName;
            um.SFUsername=u.Username;
            um.SFEmail=u.Email;
            um.SFUserID=u.Id;

            // ERP Property Members
            um.ConfigId=ConfigId;
           
            for(Salesperson_Mapping__c SM:lstUserMapping)
            {
                if(SM.User_Id__c == u.id )
                {
                    um.MappingId=SM.Id;
                    um.SPEmail=SM.Salesperson_Id__r.Email__c;
                    um.SPId=SM.Salesperson_Id__c;                    
                    um.SPCode=SM.Salesperson_Id__r.Salesperson_Code__c;
                    um.SPDesc=SM.Salesperson_Id__r.Salesperson_Description__c;                    

                    break;
                }
            }

            Mappings.add(um);
        }
    }   

    public PageReference GetUserMapping() 
    {

        if(Apexpages.hasMessages())
            Apexpages.getMessages().clear();

        lstUserMapping=new list<Salesperson_Mapping__c>();

        Users=new list<User>();

        // Check if the user has read access on the Salesperson_Mapping__c fields
        if (!Schema.sObjectType.Salesperson_Mapping__c.fields.User_Id__c.isAccessible() || !Schema.sObjectType.Salesperson_Mapping__c.fields.Salesperson_Id__c.isAccessible()
                || !Schema.sObjectType.Salesperson_Mapping__c.fields.Id.isAccessible() || !Schema.sObjectType.Salesperson_Mapping__c.fields.Integration_Key__c.isAccessible()){
            return null;
        }

        lstUserMapping=[Select User_Id__c, Salesperson_Id__c,Salesperson_Id__r.Salesperson_Code__c,Salesperson_Id__r.Salesperson_Description__c, Salesperson_Id__r.Email__c,Id, Integration_Key__c From Salesperson_Mapping__c Where Integration_Key__c=:ConfigId];

        // Check if the user has read access on the User Fields
        if (!Schema.sObjectType.user.fields.Id.isAccessible() || !Schema.sObjectType.user.fields.Name.isAccessible()
                || !Schema.sObjectType.user.fields.Username.isAccessible() || !Schema.sObjectType.user.fields.Email.isAccessible() 
                || !Schema.sObjectType.user.fields.FirstName.isAccessible() || !Schema.sObjectType.user.fields.LastName.isAccessible()){
            return null;
        }
        Users = [select Id,Name,Username,Email,FirstName,LastName from user where profileId in:profileIds.Keyset()];

        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'profileIds.Keyset() '+profileIds.Keyset()));
        //Apexpages.Message msg=new Apexpages.Message(ApexPages.Severity.INFO, 'Please select the Integration first.');

        CreateMappingList();

        return null;                            
    }

    public PageReference SearchUser()
    {
        if(Apexpages.hasMessages())
            Apexpages.getMessages().clear();

        if(ConfigId=='' || ConfigId==null)
        {

            Apexpages.Message msg=new Apexpages.Message(ApexPages.Severity.INFO, 'Please select the Integration first.');
            Apexpages.addMessage(msg);

            return null;
        }
        else
        {
            Users=new list<User>();

            // Check if the user has read access on the User Fields
            if (!Schema.sObjectType.user.fields.Id.isAccessible() || !Schema.sObjectType.user.fields.Name.isAccessible()
                    || !Schema.sObjectType.user.fields.Username.isAccessible() || !Schema.sObjectType.user.fields.Email.isAccessible() 
                    || !Schema.sObjectType.user.fields.FirstName.isAccessible() || !Schema.sObjectType.user.fields.LastName.isAccessible()){
                return null;
            }

            string sQuery = 'Select Id,Name,Email,Username,FirstName,LastName FROM User ';

            sQuery += ' where profileId In (';
            boolean bfirst = true;
            for(Id proId:profileIds.Keyset())
            {
                if(!bfirst) {
                    sQuery +=',';
                }

                sQuery += '\'' + String.escapeSingleQuotes(proId) + '\'';
                bfirst = false;
            }
            sQuery +=' )';

            string whereClause = '';
            if(FirstName.trim()!='' && FirstName.trim()!=null)
            {
                whereClause += 'FirstName like \'%'+ String.escapeSingleQuotes(FirstName) +'%\'';

                if(LastName.trim()!='' && LastName.trim()!=null)
                    whereClause += 'and LastName like \'%'+ String.escapeSingleQuotes(LastName) +'%\'';                    
            }
            else if(LastName.trim()!='' && LastName.trim()!=null)
                whereClause += ' LastName like \'%'+ String.escapeSingleQuotes(LastName) +'%\'';

            if(whereClause!='')
                sQuery+=    ' AND ' + whereClause;
                           
            Users=Database.query(sQuery);
            
            //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'Users '+Users));

            CreateMappingList();

            return null;
        }            
    }
    
    public Pagereference GetSalespersonCode()
    {
        return null;
    }
    
    public Pagereference AutoMap()
    {
        if(Apexpages.hasMessages())
            Apexpages.getMessages().clear();

        if(ConfigId=='' || ConfigId==null)
        {
            Apexpages.Message msg=new Apexpages.Message(ApexPages.Severity.INFO, 'Please select the Integration first.');
            Apexpages.addMessage(msg);

            return null;
        }
        else
        {
            // Check if the user has read access on the Salesperson__c Fields
            if (!Schema.sObjectType.Salesperson__c.fields.Id.isAccessible() || !Schema.sObjectType.Salesperson__c.fields.Salesperson_Description__c.isAccessible()
                    || !Schema.sObjectType.Salesperson__c.fields.Email__c.isAccessible() || !Schema.sObjectType.Salesperson__c.fields.AR_Division_Code__c.isAccessible()
                    || !Schema.sObjectType.Salesperson__c.fields.Integration_Key__c.isAccessible()){
                return null;
            }
            list<Salesperson__c> Salespersons=[Select Salesperson_Description__c, Salesperson_Code__c, Id, Email__c ,  AR_Division_Code__c From Salesperson__c Where Integration_Key__c=:ConfigId];
            
            list<UserMapping> AutoMappings=new list<UserMapping>();
            
            for(UserMapping OldMap : Mappings)
            {                
                UserMapping NewMap = new UserMapping();
                NewMap.MappingId=OldMap.MappingId;
                NewMap.SFFirstName=OldMap.SFFirstName;
                NewMap.SFLastName=OldMap.SFLastName;
                NewMap.SFUsername=OldMap.SFUsername;
                NewMap.SFEmail=OldMap.SFEmail;
                NewMap.SFUserID=OldMap.SFUserID;

                // ERP Property Members
                NewMap.ConfigId=ConfigId; 
                for(Salesperson__c SP:Salespersons)
                {     
                    if(OldMap.SPCode !='' && OldMap.SPCode !=null)
                    {
                        NewMap.SPCode=OldMap.SPCode;
                        NewMap.SPDesc=OldMap.SPDesc;
                        break;
                    }
                    
                    if(SP.Email__c!='' && SP.Email__c!=null && SP.Email__c== OldMap.SFEmail)
                    {
                        NewMap.SPEmail=SP.Email__c;
                        NewMap.SPId=SP.Id;
                        NewMap.SPCode=SP.Salesperson_Code__c;
                        NewMap.SPDesc=SP.Salesperson_Description__c;                       
                        break;
                    }
                }

                AutoMappings.add(NewMap);
            }
            
            Mappings=AutoMappings;
            return null;
        }
    }
    @RemoteAction
    public static Boolean SaveMapping(list<map<string,string>> lstMapping)
    {
        try
        { 
            list<Salesperson_Mapping__c> MappingsToBeUpserted=new list<Salesperson_Mapping__c>();
            list<Salesperson_Mapping__c> MappingsToBeDeleted=new list<Salesperson_Mapping__c>();

            for(map<string,string> iMap : lstMapping)
            {
                Salesperson_Mapping__c oMap=new Salesperson_Mapping__c();

                if(iMap.get('SalespersonId')!='')
                {
                    oMap.Salesperson_Id__c=iMap.get('SalespersonId');
                    oMap.User_Id__c=iMap.get('UserId');
                    oMap.Integration_Key__c= iMap.get('IntegrationKey');

                    if(iMap.get('MappingId') !='')
                        oMap.Id=iMap.get('MappingId');

                    MappingsToBeUpserted.add(oMap);
                }
                else if(iMap.get('MappingId')!='')
                {
                    oMap.Id=iMap.get('MappingId');                  
                    MappingsToBeDeleted.add(oMap);
                }
            }

            if(MappingsToBeUpserted.size() > 0)
                upsert MappingsToBeUpserted;

            if(MappingsToBeDeleted.size() > 0)
                delete MappingsToBeDeleted;

            return true;
        }
        catch(Exception ex)
        {
            return false;
        }
    }
    public class UserMapping
    {
        //Mapping Table Id
        public string MappingId{get;set;}

        // Salesforce Property Members
        public string SFFirstName{get;set;}
        public string SFLastName{get;set;}
        public string SFUsername{get;set;}
        public string SFEmail{get;set;}
        public string SFUserID{get;set;}

        // ERP Property Members
        public string ConfigId {get;set;}
        public string SPEmail{get;set;}
        public string SPId{get;set;}
        public string SPCode{get;set;}
        public string SPDesc{get;set;}
    }
}