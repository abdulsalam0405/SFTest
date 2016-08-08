global with sharing class SecurityMatrixController
{
    public String secLevel {get;set;}
    public list<SecurityMatrix> Mappings {get;set;}
    public list<Field> SettingFields {get;set;} 
    public Boolean bAdministration{get;set;} 
    public String NameSpace {get;set;}
    public String ProfileName {get;set;} 
    /// Constructor calling with default values set.

    //Constructor calling with default values set.
    public SecurityMatrixController()
    {
        try
        {
            NameSpace=Utility.FetchNameSpace();

            if(UserInfo.getProfileId() != '' && UserInfo.getProfileId() != null) 
            {
                // Check if the user has read access on the Profile.name
                if (Schema.sObjectType.Profile.fields.name.isAccessible()) {
                    ProfileName = [select name from profile where id =: UserInfo.getProfileId() limit 1].name;
                }
            }

            // Get Security Value and set it to the varible.
            Security_Matrix__c SM = Security_Matrix__c.getInstance();
            bAdministration = Boolean.valueOf(SM.GUMU_Administration__c);

            secLevel='Profile'; 
            FindSecurityFields();
            CreateRecords();
        }
        catch(Exception ex)
        {
            GUMUException exc= new GUMUException('SecurityMatrixController','SecurityMatrixController',ex);
            ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));
        }
    }

    //Create records for Users Or Profiles based on Security Level Selected.
    public Pagereference CreateRecords()
    {
        try
        {
            mappings=new list<SecurityMatrix>();
            list<Sobject> UsersORProfiles;
            String KeyPrefix='';

            if(secLevel=='Profile')
            {
                KeyPrefix='00e';
                UsersORProfiles=[Select Id,Name FROM Profile limit 500];
            }
            else if (secLevel=='User')
            {
                KeyPrefix='005';
                UsersORProfiles=[Select Id,Name,Profile.Name FROM User ORDER BY Profile.Name limit 500];
            }

            // Check if the user has read access on the Security_Matrix__c fields
            if (!Schema.sObjectType.Security_Matrix__c.fields.Name.isAccessible() 
                    || !Schema.sObjectType.Security_Matrix__c.fields.SetupOwnerId.isAccessible()
                    || !Schema.sObjectType.Security_Matrix__c.fields.GUMU_Administration__c.isAccessible()
                    || !Schema.sObjectType.Security_Matrix__c.fields.ERP_Details__c.isAccessible()
                    || !Schema.sObjectType.Security_Matrix__c.fields.Promote_Customer__c.isAccessible()
                    || !Schema.sObjectType.Security_Matrix__c.fields.Promote_Order__c.isAccessible()
                    || !Schema.sObjectType.Security_Matrix__c.fields.Update_Customer__c.isAccessible()
                    || !Schema.sObjectType.Security_Matrix__c.fields.Id.isAccessible()){

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                        'Insufficient access to Security Matrix Fields'));

                return null;
            }

            list<Security_Matrix__c> Matrices=[Select Name,SetupOwnerId , Id, GUMU_Administration__c, ERP_Details__c,Promote_Customer__c
                                               , Promote_Order__c,Update_Customer__c From Security_Matrix__c limit 1000];


            for (Sobject UP : UsersORProfiles)
            {
                Security_Matrix__c MatchMat=new Security_Matrix__c();

                for(Security_Matrix__c Mat : Matrices)
                {
                    if(Mat.SetupOwnerId == UP.Id)
                    {
                        MatchMat=Mat;
                        break;
                    }
                }

                SecurityMatrix SM =new SecurityMatrix();
                SM.Id=MatchMat.Id;
                SM.OwnerId =UP.Id;

                if (secLevel=='User')
                {
                    User U = (User)UP;
                    SM.OwnerName = string.valueOf(UP.get('Name')) + ' (' + string.valueOf(U.Profile.Name) + ')';
                }
                else
                    SM.OwnerName = string.valueOf(UP.get('Name'));

                SM.GUMU_Administration =MatchMat.GUMU_Administration__c;
                SM.ERP_Details = MatchMat.ERP_Details__c;
                SM.Promote_Customer= MatchMat.Promote_Customer__c;
                SM.Promote_Order= MatchMat.Promote_Order__c;
                SM.Update_Customer= MatchMat.Update_Customer__c;

                mappings.add(SM);
            } 
        }
        catch(Exception ex)
        {
            GUMUException exc= new GUMUException('SecurityMatrixController','CreateRecords',ex);
            ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));
        }               
        return null;
    }

    //Finding the Security Fields from the Database object.
    public void FindSecurityFields()
    {
        try
        {
            SettingFields=new list<Field>();
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            for(Schema.SObjectType objectInstance : gd.values())
            {
                if(objectInstance.getDescribe().getName()=='Security_Matrix__c')
                {
                    Map<String, Schema.SObjectField> FieldsMap=objectInstance.getDescribe().fields.getMap();

                    for(Schema.SObjectField field: FieldsMap.values())
                    {
                        if(field.getDescribe().isCustom() && field.getDescribe().getType()==Schema.Displaytype.Boolean)
                        {    
                            Field fld=new Field();
                            fld.Name=field.getDescribe().getName();
                            fld.Label=field.getDescribe().getLabel();
                            SettingFields.add(fld);                     
                        }
                    }                    
                }
            }

        }
        catch(Exception ex)
        {
            GUMUException exc= new GUMUException('SecurityMatrixController','FindSecurityFields',ex);
            ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));
        }
    }

    //Saving Security Matrix Based on the list passed and Security Level 
    //and Boolean variable for updating the Users if updating Profile
    @RemoteAction
    public static Boolean SaveSecurityMatrix(list<map<string,string>> lstMatrix, String SLType,Boolean IsUpdateUsers)
    {
        system.debug('lstMatrix '+lstMatrix);
        try
        { 
            if (!Schema.sObjectType.User.fields.Name.isAccessible() 
                    || !Schema.sObjectType.User.fields.ProfileId.isAccessible())
            {
                return false;
            }

            list<Security_Matrix__c> MatrixToBeUpserted =new list<Security_Matrix__c>();
            Security_Matrix__c oMat;

            if(SLType == 'Profile' && IsUpdateUsers) 
            {
                // Loop Through the Selected Profies and found associated users
                // And apply same Matrix to Users 
                for(map<string,string> iMap : lstMatrix)
                {

                    oMat = new Security_Matrix__c();

                    if(iMap.get('Id')!= '')
                        oMat.Id =iMap.get('Id');

                    oMat.SetupOwnerId =iMap.get('OwnerId');
                    oMat.GUMU_Administration__c=Boolean.valueOf(iMap.get('GUMU_Administration'));
                    oMat.ERP_Details__c=Boolean.valueOf(iMap.get('ERP_Details'));
                    oMat.Promote_Customer__c=Boolean.valueOf(iMap.get('Promote_Customer'));
                    oMat.Promote_Order__c=Boolean.valueOf(iMap.get('Promote_Order'));
                    oMat.Update_Customer__c = Boolean.valueOf(iMap.get('Update_Customer'));

                    MatrixToBeUpserted.add(oMat);

                    list<User>Users = [Select Id,Name,Profile.Name,ProfileId  FROM User WHERE ProfileId =: iMap.get('OwnerId')];

                    list<Security_Matrix__c> Matrices  =[Select SetupOwnerId, Name, Id, GUMU_Administration__c, ERP_Details__c,Promote_Customer__c,Promote_Order__c From Security_Matrix__c limit 1000];

                    string sMatrixId = '';
                    for (User U : Users)
                    {
                        Security_Matrix__c MatchMat=new Security_Matrix__c();

                        sMatrixId = '';
                        for(Security_Matrix__c Mat : Matrices)
                        {
                            if(Mat.SetupOwnerId == U.Id)
                            {
                                sMatrixId = Mat.Id;
                                break;
                            }
                        }

                        oMat = new Security_Matrix__c();

                        if(sMatrixId != '')
                            oMat.Id = sMatrixId;

                        oMat.SetupOwnerId = U.Id;
                        oMat.GUMU_Administration__c = Boolean.valueOf(iMap.get('GUMU_Administration'));
                        oMat.ERP_Details__c = Boolean.valueOf(iMap.get('ERP_Details'));
                        oMat.Promote_Customer__c = Boolean.valueOf(iMap.get('Promote_Customer'));
                        oMat.Promote_Order__c = Boolean.valueOf(iMap.get('Promote_Order'));
                        oMat.Update_Customer__c = Boolean.valueOf(iMap.get('Update_Customer'));

                        MatrixToBeUpserted.add(oMat);
                    }
                }
            }
            else
            {
                for(map<string,string> iMap : lstMatrix)
                {
                    oMat = new Security_Matrix__c();

                    if(iMap.get('Id')!= '')
                        oMat.Id =iMap.get('Id');

                    oMat.SetupOwnerId =iMap.get('OwnerId');
                    oMat.GUMU_Administration__c=Boolean.valueOf(iMap.get('GUMU_Administration'));
                    oMat.ERP_Details__c=Boolean.valueOf(iMap.get('ERP_Details'));
                    oMat.Promote_Customer__c = Boolean.valueOf(iMap.get('Promote_Customer'));
                    oMat.Promote_Order__c = Boolean.valueOf(iMap.get('Promote_Order'));
                    oMat.Update_Customer__c = Boolean.valueOf(iMap.get('Update_Customer'));

                    MatrixToBeUpserted.add(oMat);
                }
            }

            if(MatrixToBeUpserted.size() > 0)
                upsert MatrixToBeUpserted;

            return true;
        }
        catch(Exception ex)
        {
            return false;
        }
    }

    /// Wrapper Classes ///
    public class Field
    {
        public string Name {get;set;}
        public string Label {get;set;}
    }

    public class SecurityMatrix
    {
        public String Id {get;set;}
        public String OwnerId {get;set;}
        public String OwnerName {get;set;}
        public Boolean GUMU_Administration {get;set;}
        public Boolean ERP_Details {get;set;} 
        public Boolean Promote_Customer {get;set;}  
        public Boolean Promote_Order {get;set;} 
        public Boolean Update_Customer {get;set;}        
    }
    public PageReference cancelChanges()
    {
        PageReference pg = new PageReference('/apex/HomeSetting');
        pg.setRedirect(true);
        return pg;


    }
}