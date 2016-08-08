//This is used for returning integration framework of Base ERP
public virtual Class BaseIntegrationFramework
{  
   
   //Method to establish connection
   //public abstract boolean TestConnection(String URL, list<String> ConnectionParameters);
   string Namespace='';
   private static final string className='BaseIntegrationFramework';
   
   public virtual boolean TestConnection(String URL, list<String> ConnectionParameters)
   {
        return null;
   }

    //This function is used to get records from ERP
    public virtual Helper.GUMU_Response getData(map<string,map<string,list<string>>> Params,map<string,list<object>> Attributes)
    {
        return null;
    }
    
    //This function is used to post records to ERP
    public virtual Helper.GUMU_Response PostData(string IntegrationId,string SourceEntity,map<string,list<object>> SFObject,map<string,string> PromotionalFields,map<string,list<object>> AttribParams)
    {
        return null;
    }
    
    //This function is used to creare parameters based on no of parameters 
    public virtual map<string,map<string,list<string>>> PrepareFieldParam(String Param1, String Param2){
        return null;
    }
    
    //This function is used to get the field name that used for auto match
    public virtual string GetFieldForAutoMatch(){
        return null;
    }
    
    public virtual list<Helper.Customer> GetGenericCustomers(Helper.GUMU_Response pGUMU_Response){
        return null;
    }
    
    //Returns the list of Contacts to updated or inserted while importing accounts from ERP system.
    public virtual list<Contact> GetContacts(String IntegrationId,String SourceEntity,Helper.GUMU_Response pGUMU_Response){
         return new list<Contact>();
    }
    
    //Returns the list of Addresses to updated or inserted while importing accounts from ERP system.
    public virtual list<Ship_To__c>  GetAddresses(String IntegrationId,String SourceEntity,Helper.GUMU_Response pGUMU_Response){
         return new list<Ship_To__c>();
    }
     
     //Returns the list of pricebook Entry to updated or inserted while importing products from ERP system.
    public virtual list<PricebookEntry> InsertOrUpdatePBEntries(list<Product2> UpdatedProducts,Boolean isStandard)
    {
        return new list<PricebookEntry>();
    } 
     
    //Get the field of Web method with integration key
    public virtual Helper.GUMU_Response ReadSchema(string MethodName,string Integration_Key)
    {
        return new Helper.GUMU_Response();
    } 
    
    
    public list<sObject> getCustomObject(ERP_Config__c oIntegration,Entity_Mapping_Header__c MappingHeader, 
    list<map<String,String>> RecordList)
    {
        // Namespace = Utility.FetchNameSpace();
         /*if(!MappingHeader.Target_Entity__c.endswith('__c'))
         {
            Namespace = '';
         }*/
        //sObject records = Schema.getGlobalDescribe().get(Namespace + MappingHeader.TARGET_ENTITY__C).newSObject() ;
        sObject records = Schema.getGlobalDescribe().get( MappingHeader.TARGET_ENTITY__C).newSObject() ;
        Schema.SObjectType sObj = records.getSObjectType();
        List<SObject> sObjectList = new List<SObject>();
        
        try
        {
            IsMappingSet=false ;
            //setMappingList(oIntegration,MappingHeader,RecordList);
            if (IsMappingSet==false )
            {               
                setMappingList(oIntegration,MappingHeader,RecordList);
                LstStdPriceBook=[select Id from Pricebook2 where IsStandard=true ];
            }   
           
            if (sObj != null)
                sObjectList = (List<SObject>)Type.forName('List<'+sObj+'>').newInstance();
    
            string Salesforce_Field;
            string Salesforce_Value;
            string Salesforce_Type;
            Date Salesforce_DateFieldValue;
            boolean ParentFound=true;
            integer ik=1;
            for (map<String,String> record : RecordList)
            {
                 system.debug('record '+record);
                   //apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'fieldMappingDetails '+json.serialize(fieldMappingDetails)));
                        
                sObject sObjData =sObj.newSObject();
                string ExternalUKey=oIntegration.Id;
                integer i=0;
                for(Entity_Fields_Mapping_Detail__c fieldMap:fieldMappingDetails) 
                {
                    Salesforce_Field='';
                    Salesforce_Value='';
                    Salesforce_Type='';
                    
                    if(fieldMap.ERP_Field__c == null)
                    {
                        if(string.isNotBlank(fieldMap.Default_Value__c))
                        {
                            Salesforce_Field=fieldMap.Salesforce_Field__c;
                            Salesforce_Value=fieldMap.Default_Value__c; 
                            Salesforce_Type=fieldMap.Data_Type__c;
                        }
                    }
                    
                    if(record.get(fieldMap.ERP_Field__c) != null)
                    {
                        Salesforce_Field=fieldMap.Salesforce_Field__c;
                        Salesforce_Value=record.get(fieldMap.ERP_Field__c); 
                        Salesforce_Type=fieldMap.Data_Type__c;  
                        system.debug('Salesforce_Type1 '+Salesforce_Type);
                    }
                    else
                    {
                        if(string.isNotBlank(fieldMap.Default_Value__c))
                        {
                            Salesforce_Field=fieldMap.Salesforce_Field__c;
                            Salesforce_Value=fieldMap.Default_Value__c; 
                            Salesforce_Type=fieldMap.Data_Type__c;  
                            system.debug('Salesforce_Type2 '+Salesforce_Type);    
                        }
                    }
                    
                    if (Salesforce_Type=='Date')
                    {
                        Salesforce_Value=Salesforce_Value.replace('-','');
                        Salesforce_Value=Salesforce_Value.replace('/',''); 
                        Salesforce_DateFieldValue = Date.newInstance(integer.valueOf(Salesforce_Value.subString(0,4)),
                                                                     integer.valueOf(Salesforce_Value.subString(4,6)),
                                                                     integer.valueOf(Salesforce_Value.subString(6,8)));
                        sObjData.put(Salesforce_Field,Salesforce_DateFieldValue );                                       
                    }   
                    else if(Salesforce_Type=='Number')
                        {
                        	//apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Salesforce_Value5676 '+Salesforce_Value));
                        	//apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'fieldMap.SalesforceFi1 '+fieldMap.Salesforce_Field__c));
                        	sObjData.put(fieldMap.Salesforce_Field__c,decimal.valueOf(Salesforce_Value)); //decimal.valueOf(Salesforce_Value)  
                        }
                        else
                        {
                        	//apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Salesforce_Valuegf '+Salesforce_Value));
                        	//apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'fieldMap.SalesforceField2'+Salesforce_Value));
                        	sObjData.put(fieldMap.Salesforce_Field__c,Salesforce_Value);
                        }
                }   
                
                //here we are updating parent Id into child object.
                
                if(parentKeyList.size() > 0)
                {                    
                    string ParentKeyVal=oIntegration.Id;
                    string objectName='';
                    string ParentField='';
                    
                    for(map<string,string> getParentKeys:parentKeyList)
                    {
                        objectName = getParentKeys.get('ParentObject');
                        ParentField = getParentKeys.get('TargetField');
                         
                        if(string.isNotBlank(record.get(getParentKeys.get('SourceField'))))
                        {                            
                            //check of this prent object refrence based on mutiple fields
                            ParentKeyVal =  oIntegration.Id + '-';
                            for(map<string,string> getParentKeysInner:parentKeyList)
                            {
                                if(getParentKeys.get('ParentObject')== getParentKeysInner.get('ParentObject') && 
                                    string.isNotBlank(record.get(getParentKeysInner.get('SourceField'))))
                                {
                                    ParentKeyVal += record.get(getParentKeysInner.get('SourceField')) + '-';  
                                }
                            }                           
                            ParentKeyVal=ParentKeyVal.substring(0,ParentKeyVal.length()-1);
                        }    
                        else         
                            ParentKeyVal =  oIntegration.Id  ;
                            
                        if(string.isNotBlank(ParentField) && string.isNotBlank(MapParentId.get(ParentKeyVal))) 
                            sObjData.put(ParentField,MapParentId.get(ParentKeyVal)); 
    
                        ParentFound=false;
                        if (string.isBlank(MapParentId.get(ParentKeyVal)))
                            ParentFound=true;
                    }
                }
                
                if(EntityKeyList.size()>0)
                {
                    for(Entity_Key__c EntityKey:EntityKeyList)
                    {
                        ExternalUKey += '-'+record.get(EntityKey.Key_Field__c);
                    }
                }
                
                sObjData.put('External_UId__c',ExternalUKey);
                if (MappingHeader.TARGET_ENTITY__C=='PricebookEntry' && MappingHeader.IsStandardPB__c== true)
                {
                    if (LstStdPriceBook.size()>0)
                    {
                        //sObjData.put('External_UId__c',sObjData.get('Pricebook2Id') + '-' + ExternalUKey);                                 
                        sObjData.put('External_UId__c',LstStdPriceBook[0].Id + '-' + ExternalUKey);              
                        sObjData.put('Pricebook2Id',LstStdPriceBook[0].Id);                       
                    }                        
                }                           
                sObjectList.add(sObjData);

            } 
             
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'getCustomObject',ex,false);
            throw ex;
        }
             
        if (sObjectList.size()>0)
            return sObjectList;
        else
            return null;  
    }
    
    private list<Entity_Fields_Mapping_Detail__c> fieldMappingDetails;   
    private list<Entity_Key__c> EntityKeyList; 
    list<Entity_Fields_Map_Parent__c> EntityFieldsMapParentList;
    list<map<string,string>> parentKeyList;
    private boolean IsMappingSet=false;
    private map<string,string> MapParentId;
    List<Pricebook2> LstStdPriceBook=new List<Pricebook2>();
    
    private void setMappingList(ERP_Config__c oIntegration,Entity_Mapping_Header__c MappingHeader, list<map<String,String>> RecordList)
    {
        
        try
        {
            
            fieldMappingDetails=[select Salesforce_Field__c,ERP_Field__c,Default_Value__c , Data_Type__c From Entity_Fields_Mapping_Detail__c 
                                 where  Entity_Mapping_Id__c=:MappingHeader.Id]; 
            
            // query to get Entity keys from Entity_Key__c
            EntityKeyList = [select Key_Field__c,Key_Order__c from Entity_Key__c 
                                                 where Entity_Id__c=:MappingHeader.Entity_Id__c order by Key_Order__c] ;
            
            //get ERP Fields to create parent key
            EntityFieldsMapParentList = [select Target_Field__c,Source_Field__c,Parent_Object_Name__c,Order__c from Entity_Fields_Map_Parent__c 
                                         where Entity_Fields_Map_Header_Id__c =:MappingHeader.Id];
                                         
            //List of firld to get value from parent table
            parentKeyList = new list<map<string,string>>();
            map<string,string> parentKey = new map<string,string>(); 
            
            for(Entity_Fields_Map_Parent__c EntityFieldsMapParent:EntityFieldsMapParentList)
            {
           
                parentKey = new map<string,string>(); 
                if(String.isNotBlank(string.valueOf(EntityFieldsMapParent.Order__c)))
                {
                    parentKey.put('SourceField',EntityFieldsMapParent.Source_Field__c);
                    parentKey.put('TargetField',EntityFieldsMapParent.Target_Field__c);
                    parentKey.put('ParentObject',EntityFieldsMapParent.Parent_Object_Name__c);
                }
                parentKeyList.add(parentKey);
            }
            
            list<string> listExternalKey= new list<string> ();  
            //here we are updating parent Id into child object.
           
            
            //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'RecordList '+jSon.serialize(RecordList)));
            // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'parentKeyList '+parentKeyList));
            
            for (map<String,String> record : RecordList)
            {
                if(parentKeyList.size() > 0)
                {
                        string ParentKeyVal=oIntegration.Id;
                        string objectName='';
                        string ParentField='';
     
                        for(map<string,string> getParentKeys:parentKeyList)
                        {
                            objectName = getParentKeys.get('ParentObject');
                            ParentField = getParentKeys.get('TargetField');
                             
                            if(string.isNotBlank( record.get(getParentKeys.get('SourceField'))))
                            {
                                
                                //check of this prent object refrence based on mutiple fields
                                 ParentKeyVal =  oIntegration.Id + '-';
                                 for(map<string,string> getParentKeysInner:parentKeyList)
                                 {
                                        if(getParentKeys.get('ParentObject')==getParentKeysInner.get('ParentObject') && 
                                            string.isNotBlank( record.get(getParentKeysInner.get('SourceField'))) )
                                        {
                                            ParentKeyVal += record.get(getParentKeysInner.get('SourceField')) + '-';
                                       }
                                 }
                                
                                ParentKeyVal=ParentKeyVal.substring(0,ParentKeyVal.length()-1);
                            }    
                            else         
                                ParentKeyVal =  oIntegration.Id  ;
                                
                            listExternalKey.add(ParentKeyVal);
                            
                        }
                       
                    }
            }  
            //collect distinct object name from Entity Map parent and get all data from parent object
            MapParentId =new map<string,string> ();
            string oldObjectName='';
            string newObjectName=''; 
            
           // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'EntityFieldsMapParentList '+jSon.Serialize(RecordList)));
            //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'EntityFieldsMapParentList '+EntityFieldsMapParentList));
           // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'listExternalKey '+listExternalKey));
                         
            for(Entity_Fields_Map_Parent__c EntityFieldsMapParent:EntityFieldsMapParentList)
            {
                if(String.isNotBlank(string.valueOf(EntityFieldsMapParent.Parent_Object_Name__c)))
                {
                    oldObjectName = string.valueOf(EntityFieldsMapParent.Parent_Object_Name__c);
                    if(oldObjectName != newObjectName)
                    {
                        newObjectName= oldObjectName;
                        string sParentObjectQuery = 'select Id,External_UId__c from '+ EntityFieldsMapParent.Parent_Object_Name__c + ' where External_UId__c != null and External_UId__c !=' + '\'\''  +' and  External_UId__c in : listExternalKey';
                        //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'sParentObjectQuery  '+sParentObjectQuery ));
                        list<sObject> ParentobjList=Database.query(sParentObjectQuery );
                        
                        //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'ParentobjList '+ParentobjList));
                        for(sObject Parentobj :ParentobjList)
                        {
                            MapParentId.put(string.valueOf(Parentobj.get('External_UId__c')),string.valueOf(Parentobj.get('Id')));
                            
                        }       
                    }
                }
            }
            IsMappingSet=true;
        }  
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'setMappingList',ex,false);
            throw ex;
        }
               
    }               
    //This function is used to create all pageComponents to be displayed like Sections, SectionItems etc.IntegrationKey 
    public virtual list<Utility.PageComponent> getPageComponent(String IntegrationKey,String pageName, Helper.GUMU_Response resGUMU_Response)
    {  
        try
        {    
            List<Utility.PageComponent> components= new List<Utility.PageComponent>();
            
            if (!Schema.sObjectType.Data_Page_Section__c.fields.Name.isAccessible() || !Schema.sObjectType.Data_Page_Section__c.fields.Section_Detail_Type__c.isAccessible() 
            || !Schema.sObjectType.Data_Page_Section__c.fields.Data_Page_Id__c.isAccessible()|| !Schema.sObjectType.Data_Page_Section__c.fields.Default_Section__c.isAccessible()
            || !Schema.sObjectType.Data_Page_Section__c.fields.ERP_System__c.isAccessible()|| !Schema.sObjectType.Data_Page_Section__c.fields.Section_Name__c.isAccessible()
            || !Schema.sObjectType.Data_Page_Section__c.fields.Sort_Order__c.isAccessible())
            {
              return components;
            }
        
            
            String ERPName = IntegrationFactory.getERPSystem(IntegrationKey);
            
            List<Data_Page_Section__c> sectionList= [SELECT Id, Name, Section_Detail_Type__c, Related_List_Name__c, Data_Page_Id__c, Default_Section__c, ERP_System__c, 
            Section_Name__c, Sort_Order__c, (SELECT Id, Name,  Data_Type__c, ERP_System__c, Field_API__c, Link_To__c, Field_Label__c, Key_Field__c, Key_Value__c, 
            Data_Page_Section_Id__c, Select_Field__c from Data_Page_Details__r order by Sort_Order__c ASC) from Data_Page_Section__c 
            where Data_Page_Id__r.Name =:pageName and Data_Page_Id__r.Integration_Key__c =:IntegrationKey and ERP_System__c =:ERPName order by Sort_Order__c ASC];
                       
            if (Test.isRunningTest())
            {
                sectionList= [SELECT Id, Name, Section_Detail_Type__c, Related_List_Name__c, Data_Page_Id__c, Default_Section__c, ERP_System__c, Section_Name__c, Sort_Order__c, (SELECT Id, Name,  Data_Type__c, ERP_System__c, Field_API__c, Link_To__c, Field_Label__c, Key_Field__c, Key_Value__c, Data_Page_Section_Id__c, Select_Field__c from Data_Page_Details__r order by Sort_Order__c ASC) from Data_Page_Section__c where Data_Page_Id__r.Name =:pageName order by Sort_Order__c ASC];         
            }
            
            list<map<string,string>> dataRecords = resGUMU_Response.ERPDataMap;
           // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'DEBUG:pagecomponents: '+ jSon.serialize(dataRecords))); 
            Map<String, List<Map< String, String>>>  dataRecordsDetail = resGUMU_Response.ERPDataMapRelSection;
            
            if(sectionList != null && sectionList.size() > 0)
            {
                for(Data_Page_Section__c section: sectionList)
                {
                    Utility.PageComponent pgcomp= new Utility.PageComponent();
                    pgcomp.ComponentType='Section';
                    pgcomp.ComponentName=section.Section_Name__c;
                    string sectiondetailName = section.Related_List_Name__c;
                    pgcomp.Parent='';   
                    pgcomp.Value=null;
                    pgcomp.APIName='';
                    pgcomp.LinkTo='';
                    pgcomp.ComponentSFId=section.Id;
                    pgcomp.DataType=section.Section_Detail_Type__c;
                    pgcomp.KeyField='';
                    pgcomp.KeyValue='';
                    components.add(pgcomp); 
                    for(Data_Page_Detail__c detail: section.Data_Page_Details__r)
                    {
                        
                        string componentId='';
                        Utility.PageComponent pgcompdetail= new Utility.PageComponent();
                        pgcompdetail.ComponentType='Detail';
                        pgcompdetail.ComponentName=detail.Field_Label__c;
                        pgcompdetail.LinkTo=detail.Link_To__c;
                        pgcompdetail.Parent=section.Section_Name__c;
                        pgcompdetail.DataType=detail.Data_Type__c;
                        pgcompdetail.ComponentSFId=detail.Id;
                        pgcompdetail.KeyField=detail.Key_Field__c;
                        pgcompdetail.KeyValue=detail.Key_Value__c;
                        string strFieldId=detail.Field_API__c;
                        // start handling GUMUResponse
                        if(dataRecordsDetail != null)
                        {
                                List<Map< String, String>> detailsectionData= dataRecordsDetail.get(sectiondetailName);
                                if(detailsectionData != null)
                                {
                                    Integer count=0;
                                    for(Integer i=0; i< detailsectionData.size(); i++)
                                    {
                                        Map<String,String> recorddetail= detailsectionData[i];
                                        for (String key: recorddetail.keySet()) 
                                        {
                                            string strField = key;
                                            string strValue =recorddetail.get(key);
                                            if (strFieldId == strField) 
                                            {                       
                                                count++;
                                                pgcompdetail.APIName = string.valueof('_' + i+'_'+strField);
                                                if(String.isBlank(strValue))
                                                {
                                                    pgcompdetail.Value.add('');       
                                                }
                                                else
                                                {
                                                    pgcompdetail.Value.add(string.valueof(strValue));
                                                }
                                            }
                                        }
                                    } 
                                    components.add(pgcompdetail);
                                }
                                else
                                {
                                    if(dataRecords != null)
                                    {
                                        integer count=0;
                                        for(Integer i=0; i< dataRecords.size(); i++)
                                        {
                                            Map<String,String> record= dataRecords[i];
                                            
                                            for (String key: record.keySet()) 
                                            {
                                                count++;
                                                string strField = key;
                                                string strValue =record.get(key);
                                                if (strFieldId == strField) 
                                                {                       
                                                    
                                                    pgcompdetail.APIName = string.valueof('_' + i+'_'+strField);
                                                    if(String.isBlank(strValue))
                                                    {
                                                        pgcompdetail.Value.add('');       
                                                    }
                                                    else
                                                    {
                                                        pgcompdetail.Value.add(string.valueof(strValue));
                                                    }
                                                }   
                                            }                                   
                                        }
                                    }
                                    components.add(pgcompdetail);
                                }
                            }
                        }
                    }
                }  
               return components;
         }
        catch(Exception ex) 
        {
            CustomException exc= new CustomException('BaseIntegrationFramework','getPageComponent',ex,false);
            throw ex;
        }
    }
}