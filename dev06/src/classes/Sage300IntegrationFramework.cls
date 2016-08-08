//This is used for returning integration framework of Sage300 ERP
public with sharing Class Sage300IntegrationFramework extends BaseIntegrationFramework
{ 
    BaseERPProvider provider;

    private static final string className='Sage300IntegrationFramework';
    private list<Entity_Detail__c> EntityDetailList = new list<Entity_Detail__c> ();

    public Sage300IntegrationFramework()
    {     
        //provider= IntegrationFactory.getERPProvider(); remove comment after changes done . 17/12/2015
        provider= new Sage300ERPProvider();
    }   

    // Method to establish connection
    public override boolean TestConnection(String URL, list<String> ConnectionParameters) 
    {     
        boolean result= provider.TestConnection(URL, ConnectionParameters);
        return result;
    }

    //This function is used to get the customer from Sage300ERP
    public override Helper.GUMU_Response getData(map<string,map<string,list<string>>> Params,map<string,list<object>> Attributes)
    { 
        return getRecords(Params,Attributes);
    }

    private Helper.GUMU_Response getRecords(map<string,map<string,list<string>>> WhereParams,map<string,list<object>> AttribParams)
    {  
       
        Helper.MappingPurpose purpose;
        string sourceEntity; 
        string integrationID;
        Entity__c ObjEntity;
        ERP_Config__c oIntegration ;
        Entity_Mapping_Header__c oMappingHeader; 
        Data_Page__c oDataPage;
        Helper.GUMU_Response oGUMU_Response; 
        String ERPFuncName='';
        String ERPFuncName_1='';
        list<Data_Page__c> DataPageList;
        string RequestType;
        try
        {
            //Create Utility function to validate WhereParams and AttribParams
            //TODO: need to create constant or enum 
            list<object> AttribParam=AttribParams.get('IntegrationId');
            integrationID=(String)AttribParam[0];

            AttribParam=AttribParams.get('SourceEntity');
            sourceEntity=(String)AttribParam[0];

            AttribParam=AttribParams.get('MappingPurpose');
            purpose=(Helper.MappingPurpose) AttribParam[0];
            
            
            //Get the connection information from custom setting 
            oIntegration = [SELECT ERP_System__c,ERP_Company_Code__c,Web_Service_URL__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c FROM ERP_Config__c WHERE ID =: integrationID];
            
            if(purpose == Helper.MappingPurpose.SYNC)
            {
                

                oMappingHeader = [SELECT ERP_Function__c,IsStandardPB__c,Source_Entity__c,Sync_Direction__c,Entity_Id__c,Entity_Id__r.API_Method__c,
                                  Target_Entity__c,Parent_Target_Entity__c,Sync_Type__c FROM Entity_Mapping_Header__c WHERE Source_Entity__c =:sourceEntity ];//AND ERP_System__c=:oIntegration.ERP_System__c              

                ERPFuncName=oMappingHeader.Entity_Id__r.API_Method__c;
                
                ERPFuncName_1=oMappingHeader.ERP_Function__c;
                ObjEntity=[select Id,API_Method__c,Entity_Code__c,Group_Name__c,Entity_Detail_Id__c,Entity_Detail_Id__r.Field_APIName__c ,Parent_Entity_Id__c,Parent_Entity_Id__r.API_Method__c from  
                           Entity__c Where Id=:oMappingHeader.Entity_Id__c];
                           
                
                if(string.isNotBlank(oMappingHeader.Entity_Id__c))
                 {
                    EntityDetailList = [select Field_APIName__c,Values__c from Entity_Detail__c 
                                             where Entity_Id__c=:oMappingHeader.Entity_Id__c];
                 }
                
                if (string.IsBlank(ObjEntity.Group_Name__c))
                {
                }    
                else
                {
                    list<string> Include = new list<string>();
                    //Group_Name__c
                    Include.add(ObjEntity.Group_Name__c);
                    AttribParams.put('include',Include);
                    
                }   
            }
            else
            { 
                DataPageList = [SELECT Name, Description__c, ERP_Function__c, Name__c, Type__c,Entity_Id__c FROM Data_Page__c WHERE Name =:sourceEntity AND ERP_System__c=:oIntegration.ERP_System__c];                
                if(DataPageList.size() > 0)
                {
                	if(string.isNotBlank(DataPageList[0].Entity_Id__c))
                     {
                        EntityDetailList = [select Field_APIName__c,Values__c from Entity_Detail__c 
                                                 where Entity_Id__c=:DataPageList[0].Entity_Id__c ];
                     }
                     
                    ERPFuncName =DataPageList[0].ERP_Function__c; 
                } 
                else//If not exist in data page or direclty calling from known position 
                {
                    AttribParam=AttribParams.get('ERPFuncName');
                    if (AttribParam !=null)
                    { 
                        if (AttribParam.size()>0)
                            ERPFuncName=(String)AttribParam[0];
                    }       
                        
                }
            }               
            system.debug('ERPFuncName'+ERPFuncName);   
            if (string.isBlank(ERPFuncName))
            {
                NoDataFoundException NoERPFuncName=new NoDataFoundException();
                NoERPFuncName.setMessage('ERP Function not defined- '+ oIntegration.ERP_System__c + ' SourceEntity:' + sourceEntity);
                throw NoERPFuncName; 
            }

            //Add Finder values
            list<string> FinderName = new list<string>();
            FinderName.add(ERPFuncName);
            FinderName.add(ERPFuncName_1);
            AttribParams.put('DataFinder',FinderName);
            oGUMU_Response=new  Helper.GUMU_Response(); 
            oGUMU_Response=provider.getRecords(WhereParams,AttribParams);
            Helper.GUMU_Response pGUMU_Response;
            pGUMU_Response=oGUMU_Response;
            system.debug('pGUMU_Response'+pGUMU_Response);
            //TODO:Do not use  200 for response code user cusotm label or constant
            
            if(oGUMU_Response.statusCode != '200')
            {   
                return oGUMU_Response;
            }   

            oGUMU_Response=getMapForXML(oGUMU_Response,AttribParams);
            
            if(purpose == Helper.MappingPurpose.SYNC)
            {
                list<sObject> customObjectsList = new list<sObject> ();
                list<sObject> customObjects = new list<sObject> ();
                
                if (string.IsBlank(ObjEntity.Group_Name__c))
                {
                    customObjects=getCustomObject(oIntegration ,oMappingHeader,oGUMU_Response.ERPDataMap);
                    
                }
                else
                {
                    customObjects=getCustomObject(oIntegration ,oMappingHeader,oGUMU_Response.ERPDataMapDetail);
                }   

                if (customObjects != null)
                    customObjectsList.addAll(customObjects);

                oGUMU_Response.responseSFData=customObjectsList;
                oGUMU_Response.totalRecord=pGUMU_Response.totalRecord;
            }
            else
            {
                return oGUMU_Response ;
            }        
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'getRecords',ex,false);
            throw ex;   
        }
        
        return oGUMU_Response ;
    }

    public override Helper.GUMU_Response PostData(string IntegrationId,string SourceEntity,map<string,
            list<object>> SFObject,map<string,string> PromotionFields,map<string,list<object>> AttribParams)
    { 
        
        Helper.MappingPurpose purpose;
        ERP_Config__c oIntegration ;
        Entity_Mapping_Header__c oMappingHeader; 
        list<Data_Page__c> DataPageList = new List<Data_Page__c>();
        Helper.GUMU_Response oGUMU_Response; 
        string ERPFuncName='';
        string objectXML  ;
        string objectXML_1;
        string PostDataforXml;


        list<string> objectXMLList=new list<string>();
        list<string> objectXMLList_1 =new list<string>();
        try
        {
        	system.debug('AttribParams'+AttribParams);
            //Create Utility function to validate WhereParams and AttribParams
            list<object> AttribParam=AttribParams.get('IntegrationId');
            integrationID=(String)AttribParam[0];
			
			
            AttribParam=AttribParams.get('SourceEntity');
            sourceEntity=(String)AttribParam[0];
			
			
            AttribParam=AttribParams.get('MappingPurpose');         
            purpose=(Helper.MappingPurpose) AttribParam[0];
            system.debug('AttribParam'+AttribParam);
            AttribParam=AttribParams.get('PostDataXml');
            PostDataforXml=(String)AttribParam[0];
            
            list<string> RequestType = new list<string>();
            system.debug('AttribParam'+AttribParam);
            if(purpose == Helper.MappingPurpose.POST)
            {
                
                if(sourceEntity =='Customer')
                {
                    
                    RequestType.add('save');
                    //set the attributes
                    

                    list<Account>   CurrentAccount  =(list<Account>)SFObject.get('Accounts');  
                    list<Contact>   Contacts        =(list<Contact>)SFObject.get('Contacts');
                    list<Ship_To__c> Addresses      =(list<Ship_To__c>)SFObject.get('Addresses');
                    
                    
                    objectXML = setAccountXML(CurrentAccount[0],PromotionFields,Contacts,Addresses);
                    objectXMLList.Add(objectXML);  
                    
                    objectXML_1 = setAccountAddressXML(CurrentAccount[0],PromotionFields,Contacts,Addresses);
                    objectXMLList_1.Add(objectXML_1);
                    
                    AttribParams.put('RequestXML',objectXMLList); 
                }
               
                if(sourceEntity =='Address')
                {
                    RequestType.add('save');
                    //set the attributes
                    list<Account>   CurrentAccount  =(list<Account>)SFObject.get('Accounts');   
                    list<Contact>   Contacts        =(list<Contact>)SFObject.get('Contacts');
                    list<Ship_To__c> Addresses      =(list<Ship_To__c>)SFObject.get('Addresses');
                    objectXML = setAccountAddressXML(CurrentAccount[0],PromotionFields,Contacts,Addresses);
                    
                    objectXMLList.Add(objectXML);
                    AttribParams.put('RequestXML',objectXMLList ); 

                }

            }
            
            else if(purpose == Helper.MappingPurpose.MODIFY)
            {
               system.debug('sourceEntity'+sourceEntity);
                list<string> KeyValue= new list<string>();
                if(sourceEntity =='Customer')
                {
                    RequestType.add('update');
                    //set the attributes
                    list<Account>   CurrentAccount  =(list<Account>)SFObject.get('Accounts');   
                    list<Contact>   Contacts        =(list<Contact>)SFObject.get('Contacts');
                    list<Ship_To__c> Addresses      =(list<Ship_To__c>)SFObject.get('Addresses');
                    KeyValue.add(CurrentAccount[0].ERP_Customer_Number__c);
                    system.debug('KeyValue'+KeyValue);
                    objectXML = setAccountXML(CurrentAccount[0],PromotionFields,Contacts,Addresses);
                    objectXMLList.Add(objectXML);  
                    objectXML_1 = setAccountAddressXML(CurrentAccount[0],PromotionFields,Contacts,Addresses);
                    objectXMLList_1.Add(objectXML_1);
                    AttribParams.put('RequestXML',objectXMLList); 
                    AttribParams.put('KeyValue',KeyValue);
                }
                    
                if(sourceEntity =='Address')
                {
                     RequestType.add('update');
                    //set the attributes
                    list<Account>   CurrentAccount  =(list<Account>)SFObject.get('Accounts');   
                    list<Contact>   Contacts        =(list<Contact>)SFObject.get('Contacts');
                    list<Ship_To__c> Addresses      =(list<Ship_To__c>)SFObject.get('Addresses');
                    KeyValue.add(CurrentAccount[0].ERP_Customer_Number__c);
                    KeyValue.add(Addresses[0].Ship_To_Code__c);
                    
                    objectXML = setAccountAddressXML(CurrentAccount[0],PromotionFields,Contacts,Addresses);
                   
                    objectXMLList.Add(objectXML);
                    AttribParams.put('RequestXML',objectXMLList); 
                    AttribParams.put('KeyValue',KeyValue);
                }
            }
            
            AttribParam=AttribParams.get('ERPFuncName');
            ERPFuncName=(String)AttribParam[0];
           
            //Add Finder values
            list<string> FinderName = new list<string>();
            for (object ERPFunc : AttribParam)
            {
                FinderName.add((String) ERPFunc);
            }
            
            AttribParams.put('DataFinder',FinderName);
            AttribParams.put('RequestType',RequestType);
            oGUMU_Response=new  Helper.GUMU_Response();  
             
            oGUMU_Response=provider.PostRecords(AttribParams);
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'oGUMU_Response :'+oGUMU_Response));
             
            if (Test.isRunningTest())
            {
                oGUMU_Response.statusCode='100';
            }

            if(oGUMU_Response.statusCode =='100')
            {               
                return oGUMU_Response;
            }
            else if(oGUMU_Response.statusCode =='0')
            {   
                return oGUMU_Response;      
            }
            else if(oGUMU_Response.responseERPData!=null)
            {
                if(oGUMU_Response.responseERPData.contains('Service Temporarily Unavailable'))
                {   
                    return oGUMU_Response;
                }
            }
            
            if( oGUMU_Response.statusCode =='200' ||  oGUMU_Response.statusCode =='201'  ) 
            {
                    if(PostDataforXml =='PostOrder')
                        oGUMU_Response=getMapForPostXML(oGUMU_Response,AttribParams);
                        else
                            oGUMU_Response=getMapForXML(oGUMU_Response,AttribParams);   
              
            }
            
            return oGUMU_Response; 
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'PostData',ex,false);
            throw ex;   
        }
    }
    
    public Helper.GUMU_Response getMapForPostXML(Helper.GUMU_Response pGUMU_Response,map<string,list<object>> AttribParams)
    { 
    
        Dom.Document doc;
        ReadAndWriteXML.XmlNode objXmlNode;
        string totalRecords='';  
        string itemPerPage='';  
        string startIndex=''; 
        string hasNext='';    
        string nodeText='';

        list<map<string,string>> ERPDataMapAll          =   new list<map<string,string>>();
        map<string,string> ERPDataMap                   =   new map<string,string>();
        list<map<string,string>> ERPDataMapDetailAll    =   new list<map<string,string>>();  
        map<string,string> ERPDataMapDetail             =   new map<string,string>();
        map<string,string> Sections                     =   new map<string,string>();
        map<string,list<map<string,string>>> ERPDataMapRelSections  = new map<string,list<map<string,string>>> ();

        try
        { 
        	
            doc = new Dom.Document(); 
            doc.load(pGUMU_Response.responseERPData);
            Dom.XMLNode Envelope = doc.getRootElement();       
            ERPDataMapDetailAll =   new list<map<string,string>>();    
            //Set the section values            
            //Sections
            for(string fieldKey : AttribParams.keySet()) {
                //TODO include some cons
                if (fieldKey=='include')
                {
                    list<object> IncludeParams=  AttribParams.get('include');
                    for (object param :IncludeParams)
                    {
                        Sections.put((string)param,(string)param);
                    }   
                }
            }

            for(Dom.XMLNode child : Envelope.getChildElements())
            {
                
                        if(child.getName() == 'payload') 
                        {

                            ERPDataMap=new map<string,string>();  

                            for(Dom.XMLNode subsubchild : child.getChildElements()) 
                            {
                                for(Dom.XMLNode subsubsubchild : subsubchild.getChildElements()) 
                                {
                                    nodeText = string.valueof(subsubsubchild.getText());
                        		    ERPDataMap.put(subsubsubchild.getName() ,nodeText);


                                    // Here write the code to loop all the detail 
                                    if (Sections.get(subsubsubchild.getName())!=null )
                                    {
                                         
                                        for(Dom.XMLNode Detailchild : subsubsubchild.getChildElements()) 
                                        {
                                            ERPDataMapDetail=new map<string,string>();  
                                            //Add code for adding detail:s
                                            for(Dom.XMLNode subsubsubchildR : subsubchild.getChildElements()) 
                                            {
                                                nodeText = string.valueof(subsubsubchildR.getText());
                                               ERPDataMapDetail.put(subsubsubchildR.getName() ,nodeText);

                                            }   
                                            //Add code for adding detail:e
                                                
                                            for(Dom.XMLNode subDetailchild : Detailchild.getChildElements()) 
                                            {
                                                nodeText = string.valueof(subDetailchild.getText());
                                                ERPDataMapDetail.put(subDetailchild.getName() ,nodeText);

                                                	
                                            }

                                            ERPDataMapDetailAll.Add(ERPDataMapDetail);
                                            ERPDataMapRelSections.put(subsubsubchild.getName(),ERPDataMapDetailAll);
                                        }
                                    }
                                }   
                            }
                            ERPDataMapAll.Add(ERPDataMap);
                        }
                
            }
            
            //ERPDataMapAll.add(ERPDataMap);
            
            pGUMU_Response.ERPDataMap           = ERPDataMapAll;
            pGUMU_Response.ERPDataMapDetail     = ERPDataMapDetailAll;
            pGUMU_Response.ERPDataMapRelSection = ERPDataMapRelSections;
            //set the veriable for paging
            pGUMU_Response.TotalRecord = TotalRecords;
            pGUMU_Response.startIndex  = startIndex;
            pGUMU_Response.itemPerPage = itemPerPage;
            return pGUMU_Response;          
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'getMapForXML',ex,false);
            throw ex;
        }           
    }   


    //Create object XML for Promoting Customer/Prospects to the Sage 300 ERP
    private string setAccountXML(Account Act, map<String,String> PromotionFields,list<Contact> Contacts,list<Ship_To__c> shipToLst) 
    {
        
        string CustomerNoX3 = PromotionFields.get('CustomerNo300');
        if (CustomerNoX3 ==null ||CustomerNoX3 =='null' ) 
            CustomerNoX3 =Act.ERP_Customer_Number__c;
        string Category = PromotionFields.get('Category');
        string Tax_rule = PromotionFields.get('Tax_group');

        string strObjXML='';        
        strObjXML +='<entry>';
        strObjXML +='<sdata:payload>';
        strObjXML +='<arCustomerFinder>';

        strObjXML +='<IDCUST>'+ CustomerNoX3 +'</IDCUST>';
        strObjXML +='<NAMECUST>'+Act.Name+'</NAMECUST>';

        string Address1 = '';
        string Address2 = '';
        string Address3 = '';
        string BillingCountry='';
        string City='';
        string PostalCode='';
        string state='';
        string Phone='';
        string Fax='';

        if(Act.BillingStreet != null)
        {
            string[] Address = Act.BillingStreet.split('\n');
            if (Address.size() > 2)
            { 
                Address1 = Address[0]==null? '' : Address[0];
                Address2 = Address[1]==null? '' : Address[1];
                Address3 = Address[2]==null? '' : Address[2];           
            }
            else if (Address.size() > 1)
            { 
                Address1 = Address[0]==null? '' : Address[0];
                Address2 = Address[1]==null? '' : Address[1];
            }
            else if (Address.size() > 0)
                Address1 = Address[0]==null? '' : Address[0];
        }
		
		if(Act.BillingCity!= null)
        {
           City = Act.BillingCity;
        }

        if(Act.BillingCountry!= null)
        {
            if(Act.BillingCountry.length() >2)
                BillingCountry = Act.BillingCountry.substring(0,2);
            else
                BillingCountry = string.valueof(Act.BillingCountry);
        }
        if(Act.BillingState!= null)
        {
            if(Act.BillingState.length() >2)
                state = Act.BillingState.substring(0,2);
            else
                state = string.valueof(Act.BillingState);
        }
        if(Act.BillingPostalCode!= null)
        {
            PostalCode = string.valueof(Act.BillingPostalCode);
        }
        if(Act.Phone!= null)
        {
            Phone = string.valueof(Act.Phone);
        }
        if(Act.Fax!= null)
        {
            Fax = string.valueof(Act.Fax);
        }

        strObjXML +='<TEXTSTRE1>'+Address1+'</TEXTSTRE1>';
        strObjXML +='<TEXTSTRE2>'+Address2+'</TEXTSTRE2>';
        strObjXML +='<NAMECITY>'+City+'</NAMECITY>';
        strObjXML +='<CODESTTE>'+state+'</CODESTTE>';
        strObjXML +='<CODEPSTL>'+PostalCode+'</CODEPSTL>';
        strObjXML +='<CODECTRY>'+BillingCountry+'</CODECTRY>';
        strObjXML +='<TEXTPHON1>'+Phone+'</TEXTPHON1>';
        strObjXML +='<TEXTPHON2>'+Fax+'</TEXTPHON2>';
        //Add code for other fields

        if (string.isNotBlank(Category))
            strObjXML +='<IDGRP>'+Category+'</IDGRP>';

        if (string.isNotBlank(Tax_rule))
            strObjXML +='<CODETAXGRP>'+Tax_rule+'</CODETAXGRP>';

        strObjXML +='</arCustomerFinder>';
        strObjXML +='</sdata:payload>';
        strObjXML +='</entry>';


        return strObjXML; 
    }   

    //Create object XML for Promoting Customer/Prospects to the Sage 300 ERP
    public static string setAccountAddressXML(Account Act, map<String,String> PromotionFields,list<Contact> Contacts,list<Ship_To__c> shipToLst) 
    {
        
        string CustomerNoX3 = PromotionFields.get('CustomerNo300');
        if (CustomerNoX3 ==null ||CustomerNoX3 =='null' ) 
            CustomerNoX3 =Act.ERP_Customer_Number__c;

        string strObjXML_1='';

        if (shipToLst!=null)
        {
            strObjXML_1 +='<entry>';
            strObjXML_1 +='<sdata:payload>';
            for(Ship_To__c shipTo:shipToLst)
            {

                strObjXML_1 +='<arshiptolocationsfinder>';

                strObjXML_1 +='<IDCUST>'+ CustomerNoX3 +'</IDCUST>';
                strObjXML_1 +='<CODESTTE>'+shipTo.Ship_To_State__c+'</CODESTTE>';
                strObjXML_1 +='<CODEPSTL>'+shipTo.Ship_To_Zip_Code__c+'</CODEPSTL>';
                strObjXML_1 +='<CODECTRY>'+shipTo.Ship_To_Country_Code__c+'</CODECTRY>';
                strObjXML_1   +='<IDCUSTSHPT>'+shipTo.Ship_To_Code__c+'</IDCUSTSHPT>';
                strObjXML_1 +='<NAMELOCN>'+shipTo.Ship_To_Name__c+'</NAMELOCN>';
                strObjXML_1 +='<CODECTRY>US</CODECTRY>';
                strObjXML_1 +='<NAMECITY>'+shipTo.Ship_To_City__c+'</NAMECITY>';
                //strObjXML_1 += '<SHPVIACODE>'+shipTo.Ship_To_Code__c+ '</SHPVIACODE>';
                //strObjXML_1 += '<NAMECTAC></NAMECTAC>';
                strObjXML_1 += '<CODETERR>US</CODETERR>';
                strObjXML_1 += '<TEXTSTRE1>'+shipTo.Ship_To_Address1__c+'</TEXTSTRE1>';
                strObjXML_1 +='<TEXTSTRE2>'+shipTo.Ship_To_Address2__c+'</TEXTSTRE2>';
                strObjXML_1 +='<TEXTSTRE3>' +shipTo.Ship_To_Address3__c+'</TEXTSTRE3> ';
                //strObjXML_1 += '<TEXTSTRE4>'+Ship_To_Address4__c+'</TEXTSTRE2> ';
                strObjXML_1  +='<SWACTV>1</SWACTV>';
                //strObjXML_1 +='<FOB xsi:nil="false" />;
                //strObjXML_1+= <SHPVIADESC xsi:nil="false" />;
                strObjXML_1 +='</arshiptolocationsfinder>';

            }

            strObjXML_1 +='</sdata:payload>';
            strObjXML_1 +='</entry>';
        }       
        system.debug('strObjXML_1:'+strObjXML_1);
        
        return strObjXML_1; 
    }  


    //This function is used to get the list of map of sage300 ERP data  
    public Helper.GUMU_Response getMapForXML(Helper.GUMU_Response pGUMU_Response,map<string,list<object>> AttribParams)
    { 		
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'getMapForXML:'));
        Dom.Document doc;
        ReadAndWriteXML.XmlNode objXmlNode;
        string totalRecords='';  
        string itemPerPage='';  
        string startIndex=''; 
        string hasNext='';    
        string nodeText='';

        list<map<string,string>> ERPDataMapAll          =   new list<map<string,string>>();
        map<string,string> ERPDataMap                   =   new map<string,string>();
        list<map<string,string>> ERPDataMapDetailAll    =   new list<map<string,string>>();  
        map<string,string> ERPDataMapDetail             =   new map<string,string>();
        map<string,string> Sections                     =   new map<string,string>();
        map<string,list<map<string,string>>> ERPDataMapRelSections  = new map<string,list<map<string,string>>> ();

        try
        { 
            doc = new Dom.Document(); 
           
            doc.load(pGUMU_Response.responseERPData);
            Dom.XMLNode Envelope = doc.getRootElement();       
            ERPDataMapDetailAll =   new list<map<string,string>>();    
            //Set the section values            
            //Sections
            for(string fieldKey : AttribParams.keySet())
            {
                //TODO include some cons
                if (fieldKey=='include')
                {
                    list<object> IncludeParams=  AttribParams.get('include');
                    for (object param :IncludeParams)
                    {
                        Sections.put((string)param,(string)param);
                    }   
                }
            }

            for(Dom.XMLNode child : Envelope.getChildElements())
            {
                //get the total no of records
                if(child.getName() == 'totalResults')
                {
                    totalRecords=child.getText();
                }
                else if(child.getName() == 'startIndex')
                {
                    startIndex=child.getText();
                }
                else if(child.getName() == 'itemsPerPage')
                {
                    itemPerPage=child.getText();
                }
                else if(child.getName() == 'entry')
                {
                    for(Dom.XMLNode subchild : child.getChildElements()) 
                    {
                        if(subchild.getName() == 'payload') 
                        {
                            ERPDataMap=new map<string,string>();  
                            for(Dom.XMLNode subsubchild : subchild.getChildElements()) 
                            {
                                for(Dom.XMLNode subsubsubchild : subsubchild.getChildElements()) 
                                {
                                    nodeText = string.valueof(subsubsubchild.getText());
                                    string valDescription=valuesdescription(subsubsubchild.getName(), nodeText);
                                    if(valDescription =='')
                                    	ERPDataMap.put(subsubsubchild.getName() ,nodeText);
                                    else
                                    	ERPDataMap.put(subsubsubchild.getName() ,valDescription);                                   
                                    
                                    // Here write the code to loop all the detail 
                                    if (Sections.get(subsubsubchild.getName())!=null )
                                    {
                                        for(Dom.XMLNode Detailchild : subsubsubchild.getChildElements()) 
                                        {
                                            ERPDataMapDetail=new map<string,string>();  
                                            //Add code for adding detail:s
                                            for(Dom.XMLNode subsubsubchildR : subsubchild.getChildElements()) 
                                            {
                                                nodeText = string.valueof(subsubsubchildR.getText());
                                                valDescription=valuesdescription(subsubsubchildR.getName(), nodeText);
                                    			if(valDescription =='')
                                    				ERPDataMapDetail.put(subsubsubchildR.getName() ,nodeText);
                                    			else
                                    				ERPDataMapDetail.put(subsubsubchildR.getName() ,valDescription);
                                            }   
                                            //Add code for adding detail:e

                                            for(Dom.XMLNode subDetailchild : Detailchild.getChildElements()) 
                                            {
                                                nodeText = string.valueof(subDetailchild.getText());
                                                valDescription=valuesdescription(subDetailchild.getName(), nodeText);
                                    			if(valDescription =='')
                                    				ERPDataMapDetail.put(subDetailchild.getName() ,nodeText);
                                    			else
                                                	 ERPDataMapDetail.put(subDetailchild.getName() ,valDescription);
                                            }

                                            ERPDataMapDetailAll.Add(ERPDataMapDetail);
                                            ERPDataMapRelSections.put(subsubsubchild.getName(),ERPDataMapDetailAll);
                                        }
                                    }
                                }   
                            }
                            ERPDataMapAll.Add(ERPDataMap);
                        }
                    }
                }
            }

            //ERPDataMapAll.add(ERPDataMap);
            pGUMU_Response.ERPDataMap           = ERPDataMapAll;
            pGUMU_Response.ERPDataMapDetail     = ERPDataMapDetailAll;
            pGUMU_Response.ERPDataMapRelSection = ERPDataMapRelSections;
            //set the veriable for paging
            pGUMU_Response.TotalRecord = TotalRecords;
            pGUMU_Response.startIndex  = startIndex;
            pGUMU_Response.itemPerPage = itemPerPage;
            return pGUMU_Response;          
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'getMapForXML',ex,false);
            throw ex;
        }           
    }   

     
    //Returns the list of Accounts to updated or inserted while importing customers from ERP system.
    /*public list<Account> GetCustomers(ERP_Config__c oIntegration,Entity_Mapping_Header__c MappingHeader, List<map<String,String>> RecordList)
    {
        list<Account> Accounts = new list<Account>();
        list<Entity_Fields_Mapping_Detail__c> fieldMappingDetails;               

        fieldMappingDetails=[select Salesforce_Field__c,ERP_Field__c From Entity_Fields_Mapping_Detail__c where  Entity_Mapping_Id__c=:MappingHeader.Id]; 

        for (map<String,String> record : RecordList)
        {
            Account account=new Account();
            try
            {
                //set mandatory field integration
                account.ERP_Company_Code__c = oIntegration.ERP_Company_Code__c; 

                account.Integration_Key__c=oIntegration.Id;
                account.put('External_UId__c',record.get('IDCUST'));
                for(Entity_Fields_Mapping_Detail__c fieldMap:fieldMappingDetails) 
                {
                    account.put(fieldMap.Salesforce_Field__c,record.get(fieldMap.ERP_Field__c));
                }
            }
            catch(Exception ex){}               
            Accounts.add(account); 
        }  
        return Accounts;
    }*/
     
    
    //This function is used to creare parameters based on no of parameters 
    public override map<string,map<string,list<string>>> PrepareFieldParam( String Param1, String Param2)
    {
        map<string,map<string,list<string>>> fieldParameters = new map<string,map<string,list<string>>> ();
        if (Param1 != '' && Param2=='') 
        {
            map<string,list<string>> parameter = new map<string,list<string>>();
            list<string> listParams=new list<string> ();

            //TODO for date field do this discuss where we need to implement this 
            String[] aDatePart= Param1.split('/');
            listParams.add(aDatePart[2]+aDatePart[0]+aDatePart[1]);
            parameter.put(string.valueOf(Helper.Operator.GREATER_OR_EQUAL),listParams);
            fieldParameters.put('DATELASTMN',parameter);
        }
        else
        {
            map<string,list<string>> parameter = new map<string,list<string>>();
            list<string> listParams=new list<string> ();
            listParams.add(Param1);
            listParams.add(Param2);
            parameter.put(string.valueOf(Helper.Operator.RANGE),listParams);
            fieldParameters.put('IDCUST',parameter);
        }
        return fieldParameters ;  
    }

    //This function is used to get the field name that used for auto match
    public override string GetFieldForAutoMatch()
    {
        //TODO create some contant at this class level
        return 'NAMECUST';
    }

    //This function is used to get the common ERP data map format for specific ERP data
    public override List<Helper.Customer> GetGenericCustomers(Helper.GUMU_Response pGUMU_Response)
    { 
        List<Helper.Customer> lstCustomer = New List<Helper.Customer>();
        Helper.Customer oCustomer;

        try
        {
            if(pGUMU_Response.ERPDataMap != null)
            {
                for (Map<String,String> RecMap : pGUMU_Response.ERPDataMap)
                {
                    oCustomer = new Helper.Customer();
                    oCustomer.UniqueKey =  RecMap.get('IDCUST'); 
                    oCustomer.CategoryCode =  RecMap.get('IDGRP'); 
                    oCustomer.CustomerName =  RecMap.get('NAMECUST'); 
                    lstCustomer.add(oCustomer);
                }
            }                
        }
        catch(exception ex)
        {
            GUMUException exc= new GUMUException(className,'GetGenericCustomers',ex);
            throw ex;          
        }
        return lstCustomer;
    } 


    //Get the field of Web method
    public override Helper.GUMU_Response ReadSchema(string MethodName,string Integration_Id)
    {
        try
        {
            map<string,list<object>> AttribParams = new map<string,list<object>>();
            list<string> FinderName = new list<string>();
            list<string> RequestType = new list<string>();
            list<string> IntegrationId= new list<string>();
            list<string> startIndex= new list<string>();
            list<string> RecCount= new list<string>();
            Entity_Detail__c Entity_Detail ;
            list<Entity_Detail__c> Entity_Details = new list<Entity_Detail__c>() ;
            FinderName.add(MethodName);


            RequestType.add('getDescription');
            IntegrationId.add(Integration_Id);
            startIndex.add('1');
            RecCount.add('1');
            AttribParams.put('DataFinder',FinderName);
            AttribParams.put('RequestType',RequestType);
            AttribParams.put('IntegrationId',IntegrationId);
            AttribParams.put('startIndex',startIndex);
            AttribParams.put('count',RecCount);

            Helper.GUMU_Response oGUMU_Response=new  Helper.GUMU_Response();             
            oGUMU_Response=provider.getRecords(null,AttribParams);

            if(oGUMU_Response.statusCode =='0')
            {
                return oGUMU_Response;
            }

            getMapForXML_Schema(oGUMU_Response,AttribParams);    
            map<string,string> AddedMap = new map<string,string> ();

            for(map<string,string> mapSFData : oGUMU_Response.ERPDataMap)
            {
                Entity_Detail = new Entity_Detail__c ();
                Entity_Detail.Name= mapSFData.get('APILabel');
                //Entity_Detail.Data_Type__c=string.valueOf(mapSFData.get('DataType')).;
                Entity_Detail.Field_APIName__c=mapSFData.get('APIName');
                Entity_Detail.Values__c=mapSFData.get('ListOfValues');
                Entity_Detail.Group_Name__c=mapSFData.get('GroupName');
                if (mapSFData.get('APILabel') !=null && AddedMap.get(mapSFData.get('APIName'))==null)   
                {
                    Entity_Details.Add(Entity_Detail);
                    AddedMap.put(mapSFData.get('APIName'),mapSFData.get('APIName'));
                }
            }

            oGUMU_Response.responseSFData=Entity_Details;
            return oGUMU_Response;
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'ReadSchema',ex,false);
            throw ex;
        } 
    } 

    //This function is used to get the list of map of Sage X3 ERP data  
    public Helper.GUMU_Response getMapForXML_Schema(Helper.GUMU_Response pGUMU_Response,map<string,list<object>> AttribParams)
    {   
        string Response=pGUMU_Response.responseERPData;   

        if (Test.isRunningTest())
        {
            Response='<?xml version="1.0" encoding="UTF-8"?><xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ame="http://schemas.sage.com/accpac/sdata/ame/2009" xmlns:sme="http://schemas.sage.com/sdata/sme/2007" xmlns:tns="http://schemas.sage.com/sageERP" elementFormDefault="qualified" targetNamespace="http://schemas.sage.com/sageERP"><xs:element name="arCustomerFinder" sme:batchingMode="syncOrAsync" sme:canDelete="true" sme:canGet="true" sme:canPageIndex="true" sme:canPageNext="true" sme:canPagePrevious="true" sme:canPost="true" sme:canPut="true" sme:label="Customers" sme:pluralName="arCustomersFinder" sme:role="resourceKind" sme:supportsETag="true" type="tns:arCustomerFinder--type" /><xs:complexType name="arCustomerFinder--type"><xs:all><xs:element name="IDCUST" sme:canFilter="true" sme:canSort="true" sme:isMandatory="true" sme:isReadOnly="false" sme:label="Customer Number" sme:precedence="1" type="tns:arCustomerFinder--IDCUST--type" /><xs:element name="NAMECUST" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Customer Name" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="TEXTSNAM" nillable="true" sme:averageLength="10" sme:canFilter="true" sme:canSort="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Short Name" sme:maxLength="10" sme:precedence="1" type="xs:string" /><xs:element name="SWHOLD" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="On Hold" sme:precedence="1" type="tns:arCustomerFinder--SWHOLD--enum" /><xs:element name="IDGRP" sme:canFilter="true" sme:canSort="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Group Code" sme:precedence="1" type="tns:arCustomerFinder--IDGRP--type" /><xs:element name="IDNATACCT" sme:canFilter="true" sme:canSort="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="National Account" sme:precedence="1" type="tns:arCustomerFinder--IDNATACCT--type" /><xs:element name="CODECURN" sme:canFilter="true" sme:canSort="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Currency Code" sme:precedence="1" type="tns:arCustomerFinder--CODECURN--type" /><xs:element name="NAMECITY" nillable="true" sme:averageLength="30" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="City" sme:maxLength="30" sme:precedence="1" type="xs:string" /><xs:element name="CODESTTE" nillable="true" sme:averageLength="30" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="State/Province" sme:maxLength="30" sme:precedence="1" type="xs:string" /><xs:element name="CODECTRY" nillable="true" sme:averageLength="30" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Country" sme:maxLength="30" sme:precedence="1" type="xs:string" /><xs:element name="SWACTV" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Status" sme:precedence="1" type="tns:arCustomerFinder--SWACTV--enum" /><xs:element name="SWBALFWD" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Account Type" sme:precedence="1" type="tns:arCustomerFinder--SWBALFWD--enum" /><xs:element name="TEXTSTRE1" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Address Line 1" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="TEXTSTRE2" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Address Line 2" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="TEXTSTRE3" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Address Line 3" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="TEXTSTRE4" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Address Line 4" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="CODEPSTL" nillable="true" sme:averageLength="20" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Zip/Postal Code" sme:maxLength="20" sme:precedence="1" type="xs:string" /><xs:element name="TEXTPHON1" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Phone Number" sme:precedence="1" type="tns:arCustomerFinder--TEXTPHON1--type" /><xs:element name="TEXTPHON2" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Fax Number" sme:precedence="1" type="tns:arCustomerFinder--TEXTPHON2--type" /><xs:element name="NAMECTAC" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Contact Name" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="PRICLIST" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Customer Price List" sme:precedence="1" type="tns:arCustomerFinder--PRICLIST--type" /><xs:element name="DATEINAC" nillable="true" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Inactive Date" sme:precedence="1" type="tns:arCustomerFinder--DATEINAC--type" /><xs:element name="DATELASTMN" nillable="true" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Date Last Maintained" sme:precedence="1" type="tns:arCustomerFinder--DATELASTMN--type" /><xs:element name="CODETERR" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Territory Code" sme:precedence="1" type="tns:arCustomerFinder--CODETERR--type" /><xs:element name="IDACCTSET" sme:canFilter="true" sme:canSort="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Account Set" sme:precedence="1" type="tns:arCustomerFinder--IDACCTSET--type" /><xs:element name="CODETERM" sme:canFilter="true" sme:canSort="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Terms" sme:precedence="1" type="tns:arCustomerFinder--CODETERM--type" /><xs:element name="CTACPHONE" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Contacts Phone" sme:precedence="1" type="tns:arCustomerFinder--CTACPHONE--type" /><xs:element name="PAYMCODE" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Payment Code" sme:precedence="1" type="tns:arCustomerFinder--PAYMCODE--type" /><xs:element name="AMTCRLIMT" sme:canFilter="true" sme:fractionDigits="3" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Credit Limit (Cust. Curr.)" sme:precedence="1" sme:totalDigits="18" type="xs:decimal" /><xs:element name="LOCATION" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Inventory Location" sme:precedence="1" type="tns:arCustomerFinder--LOCATION--type" /><xs:element name="CODETAXGRP" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Tax Group" sme:precedence="1" type="tns:arCustomerFinder--CODETAXGRP--type" /><xs:element name="FOB" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Free On Board" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="SHPVIADESC" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Ship Via Description" sme:maxLength="60" sme:precedence="1" type="xs:string" /></xs:all><xs:anyAttribute /></xs:complexType><xs:complexType name="arCustomerFinder--list"><xs:sequence><xs:element maxOccurs="unbounded" minOccurs="0" name="arCustomerFinder" type="tns:arCustomerFinder--type" /></xs:sequence></xs:complexType><xs:simpleType name="arCustomerFinder--IDCUST--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--SWHOLD--enum"><xs:restriction base="xs:short"><xs:enumeration sme:label="No" value="0" /><xs:enumeration sme:label="Yes" value="1" /></xs:restriction></xs:simpleType><xs:simpleType name="arCustomerFinder--IDGRP--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--IDNATACCT--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--CODECURN--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--SWACTV--enum"><xs:restriction base="xs:short"><xs:enumeration sme:label="Inactive" value="0" /><xs:enumeration sme:label="Active" value="1" /></xs:restriction></xs:simpleType><xs:simpleType name="arCustomerFinder--SWBALFWD--enum"><xs:restriction base="xs:short"><xs:enumeration sme:label="Open Item" value="0" /><xs:enumeration sme:label="Balance Forward" value="1" /></xs:restriction></xs:simpleType><xs:simpleType name="arCustomerFinder--TEXTPHON1--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--TEXTPHON2--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--PRICLIST--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--DATEINAC--type"><xs:restriction base="xs:date" /></xs:simpleType><xs:simpleType name="arCustomerFinder--DATELASTMN--type"><xs:restriction base="xs:date" /></xs:simpleType><xs:simpleType name="arCustomerFinder--CODETERR--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--IDACCTSET--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--CODETERM--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--CTACPHONE--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--PAYMCODE--type"><xs:restriction base="xs:string"></xs:restriction></xs:simpleType><xs:simpleType name="arCustomerFinder--LOCATION--type"><xs:restriction base="xs:string"></xs:restriction></xs:simpleType><xs:simpleType name="arCustomerFinder--CODETAXGRP--type"><xs:restriction base="xs:string" /></xs:simpleType></xs:schema>';
        }  
        Dom.Document doc;
        ReadAndWriteXML.XmlNode objXmlNode;
        string totalRecords='';  
        string itemPerPage='';  
        string startIndex=''; 
        string hasNext='';    
        string nodeText='';
        map<string,string> Sections = new map<string,string>();

        map<string,string> ERPDataMap            =      new map<string,string>();
        list<map<string,string>> ERPDataMapAll   =      new list<map<string,string>>();

        map<string,string> ERPDataMapDetail             =      new map<string,string>();
        list<map<string,string>> ERPDataMapDetailAll    =      new list<map<string,string>>(); 
        map<string,list<map<string,string>>> ERPDataMapRelSections    = new map<string,list<map<string,string>>> ();
        string GroupName= '';

        try
        { 
            objXmlNode = new ReadAndWriteXML.XmlNode();
            objXmlNode = ReadAndWriteXML.ParseXmlString(Response);
            list<ReadAndWriteXML.XmlNode> lstRsltNode = objXmlNode.ChildXmlNodes;

            map<string,list<string>> MapValuesList = new map<string,list<string>>();
            for(ReadAndWriteXML.XmlNode readRsltNode:lstRsltNode)
            {
                string staticValueName = readRsltNode.Attributes.get('name');
                String[] spiltString = staticValueName.split('--');
                if(spiltString.size()==3)
                {
                    if (!(spiltString[spiltString.size()-1] =='enum'))
                        continue;

                }
                else
                {
                    continue;   
                }

                if(readRsltNode.NodeName == 'simpleType' )//&& findertype=='arCustomerFinder--type'
                {
                    list<ReadAndWriteXML.XmlNode> lstMNUNodes = readRsltNode.ChildXmlNodes;                 
                    for(ReadAndWriteXML.XmlNode readLineNode:lstMNUNodes)
                    {                       
                        if(readLineNode.NodeName == 'restriction')
                        {
                            list<ReadAndWriteXML.XmlNode> lstVALNodes = readLineNode.ChildXmlNodes;
                            list<string> ValueList = new list<string>(); 

                            for(ReadAndWriteXML.XmlNode lstVALNode:lstVALNodes)
                            {
                                ValueList.add(lstVALNode.Attributes.get('value') + '-' + lstVALNode.Attributes.get('label')+ '\n');
                                MapValuesList.put('tns:'+staticValueName,ValueList);
                            }
                        }
                    }   

                }
            }

            for(ReadAndWriteXML.XmlNode readRsltNode:lstRsltNode)
            {
                string findertype = readRsltNode.Attributes.get('name');
                if(readRsltNode.NodeName == 'complexType' )//&& findertype=='arCustomerFinder--type'
                {
                    list<ReadAndWriteXML.XmlNode> lstMNUNodes = readRsltNode.ChildXmlNodes;                 
                    for(ReadAndWriteXML.XmlNode readLineNode:lstMNUNodes)
                    {                       
                        if(readLineNode.NodeName == 'all')
                        {
                            list<ReadAndWriteXML.XmlNode> lstVALNodes = readLineNode.ChildXmlNodes;
                            list<string> ValueList = new list<string>(); 

                            for(ReadAndWriteXML.XmlNode lstVALNode:lstVALNodes)
                            {
                                GroupName='';
                                if (lstVALNode.Attributes.get('relationship') == 'child')
                                {
                                    continue;
                                }
                                String[] spiltString = readRsltNode.Attributes.get('name').split('--');
                                if( spiltString.size()>2)
                                {
                                    if (spiltString[spiltString.size()-1] =='type')
                                    {
                                        GroupName = spiltString[spiltString.size()-2]+'s';
                                    }
                                }
                                if( spiltString.size()>3)
                                {
                                    continue;   
                                }

                                ERPDataMap= new map<string,string>();
                                ERPDataMap.put('GroupName',GroupName);
                                ERPDataMap.put('APILabel',lstVALNode.Attributes.get('label'));
                                ERPDataMap.put('DataType',lstVALNode.Attributes.get('type'));
                                ERPDataMap.put('APIName',lstVALNode.Attributes.get('name'));
                                if (MapValuesList.get(lstVALNode.Attributes.get('type'))!=null ) 
                                {
                                    //list<string> ValueList;
                                    string values='';
                                    ValueList = MapValuesList.get(lstVALNode.Attributes.get('type'));
                                    for (string val:ValueList )
                                        values=values  + val; 
                                    ERPDataMap.put('ListOfValues',values );
                                }    

                                ERPDataMapAll.add(ERPDataMap);
                            }
                        }
                    }
                }
            }

            ERPDataMapAll.add(ERPDataMap);
            pGUMU_Response.ERPDataMap  = ERPDataMapAll;
            pGUMU_Response.ERPDataMapDetail     = ERPDataMapDetailAll; 
            pGUMU_Response.ERPDataMapRelSection = ERPDataMapRelSections; 

            //set the veriable for paging
            //TODO:Remove below 
            pGUMU_Response.TotalRecord = '1';
            pGUMU_Response.startIndex  = '1';
            pGUMU_Response.itemPerPage = '1';
            return pGUMU_Response;                
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'getMapForXML_Schema',ex,false);
            throw ex;
        }                    
    }
    
    //function to create for fetching menu values
    public string valuesdescription(string ERPField,string ERPValue)
    {
        string menulab='';
        //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'ERPField '+ ERPField ));
       // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'ERPValue '+ ERPValue));
        
         for( Entity_Detail__c EntityDetail:EntityDetailList)
         {
            if(EntityDetail.Field_APIName__c == ERPField && string.isNotBlank(EntityDetail.Values__c))
            {
            	//ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'EntityDetail.Field_APIName__c '+ EntityDetail.Field_APIName__c ));
        		//ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'EntityDetail.Values__c '+ EntityDetail.Values__c));
        		
                string erpdecval = EntityDetail.Values__c;
                list<string> valuelist =  erpdecval.split('\n');
                for(string values : valuelist)
                {
                    if(ERPValue == values.subString(0,1))
                        menulab = values.subString(2,values.length());                                           
                }
            }                     
         } 
         return menulab;    
    }    

}