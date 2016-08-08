//This is used for returning integration framework of Sage100 ERP
public class Sage100IntegrationFramework extends BaseIntegrationFramework
{
    BaseERPProvider provider;
    public static integer counter=0;
    private static final string className='Sage100IntegrationFramework';

    public Sage100IntegrationFramework()
    {     
        provider= new Sage100ERPProvider();
    }   

    // Method to establish connection
    public override boolean TestConnection(String URL, list<String> ConnectionParameters) 
    {   
        boolean result= provider.TestConnection(URL, ConnectionParameters);
        return result;
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
        list<Data_Page__c> DataPageList;
        try
        {
            list<object> AttribParam=AttribParams.get('IntegrationId');
            integrationID=(String)AttribParam[0];
            AttribParam=AttribParams.get('SourceEntity');
            sourceEntity=(String)AttribParam[0];
            system.debug('sourceEntity0'+sourceEntity);

            AttribParam=AttribParams.get('MappingPurpose');
            purpose=(Helper.MappingPurpose) AttribParam[0];
            //Get the connection information from custom setting 
            oIntegration = [SELECT ERP_Company_Code__c,Web_Service_URL__c,Integration_Information__c,
                            Integration_Information_2__c,Integration_Information_3__c,ERP_System__c FROM ERP_Config__c WHERE ID =: integrationID];

            //ERP_System__c,
            if(purpose == Helper.MappingPurpose.SYNC)
            {                    
                //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'AttribParamsfgg '+AttribParams));           
                 //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'sync'));           
                oMappingHeader = [SELECT ERP_Function__c,IsStandardPB__c,Source_Entity__c,Sync_Direction__c,Entity_Id__c,
                                  Target_Entity__c,Parent_Target_Entity__c,Entity_Id__r.API_Method__c FROM Entity_Mapping_Header__c 
                                  WHERE Source_Entity__c =:sourceEntity ];              

                ERPFuncName=oMappingHeader.Entity_Id__r.API_Method__c;
                AttribParam=new list<object>();
                AttribParam.Add(ERPFuncName);
                AttribParams.put('ERPFuncName',AttribParam);


                ObjEntity=[select Id,API_Method__c,Entity_Code__c,Group_Name__c,Entity_Detail_Id__c,
                           Entity_Detail_Id__r.Field_APIName__c ,Parent_Entity_Id__c,Parent_Entity_Id__r.API_Method__c from  
                           Entity__c Where Id=:oMappingHeader.Entity_Id__c];

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
                //AttribParam= oIntegration.ERP_System__c;
                AttribParam=AttribParams.get('ERPFuncName');
                
                if (AttribParam !=null)
                {
                    ERPFuncName=(String)AttribParam[0];
                }   
                else
                {
                    DataPageList = [SELECT Name, Description__c, ERP_Function__c, Name__c, Type__c FROM Data_Page__c 
                                    WHERE Name =:sourceEntity AND ERP_System__c=:oIntegration.ERP_System__c]; 
                    system.debug('DataPageList '+DataPageList);

                    //ERP_System__c,
                    if(DataPageList.size() > 0)
                    {   
                        ERPFuncName =DataPageList[0].ERP_Function__c; 
                        system.debug('ERPFuncName '+ERPFuncName);
                    }
                    //ERPFuncName='AR_Customer';
                }  
            }               

            if (string.isBlank(ERPFuncName))
            {
                NoDataFoundException NoERPFuncName=new NoDataFoundException();
                NoERPFuncName.setMessage('ERP Function not definied - '+oIntegration.ERP_System__c + ' SourceEntity:' + sourceEntity);
                throw NoERPFuncName; 
            }
            //Add Finder values
            list<string> FinderName = new list<string>();
            FinderName.add(ERPFuncName);
            AttribParams.put('ERPFuncName',FinderName);
            oGUMU_Response=new  Helper.GUMU_Response(); 

            if(Test.isRunningTest())
            {
                oGUMU_Response.responseERPData='<?xml version="1.0" encoding="UTF-8"?><xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ame="http://schemas.sage.com/accpac/sdata/ame/2009" xmlns:sme="http://schemas.sage.com/sdata/sme/2007" xmlns:tns="http://schemas.sage.com/sageERP" elementFormDefault="qualified" targetNamespace="http://schemas.sage.com/sageERP"><xs:element name="arCustomerFinder" sme:batchingMode="syncOrAsync" sme:canDelete="true" sme:canGet="true" sme:canPageIndex="true" sme:canPageNext="true" sme:canPagePrevious="true" sme:canPost="true" sme:canPut="true" sme:label="Customers" sme:pluralName="arCustomersFinder" sme:role="resourceKind" sme:supportsETag="true" type="tns:arCustomerFinder--type" /><xs:complexType name="arCustomerFinder--type"><xs:all><xs:element name="IDCUST" sme:canFilter="true" sme:canSort="true" sme:isMandatory="true" sme:isReadOnly="false" sme:label="Customer Number" sme:precedence="1" type="tns:arCustomerFinder--IDCUST--type" /><xs:element name="NAMECUST" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Customer Name" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="TEXTSNAM" nillable="true" sme:averageLength="10" sme:canFilter="true" sme:canSort="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Short Name" sme:maxLength="10" sme:precedence="1" type="xs:string" /><xs:element name="SWHOLD" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="On Hold" sme:precedence="1" type="tns:arCustomerFinder--SWHOLD--enum" /><xs:element name="IDGRP" sme:canFilter="true" sme:canSort="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Group Code" sme:precedence="1" type="tns:arCustomerFinder--IDGRP--type" /><xs:element name="IDNATACCT" sme:canFilter="true" sme:canSort="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="National Account" sme:precedence="1" type="tns:arCustomerFinder--IDNATACCT--type" /><xs:element name="CODECURN" sme:canFilter="true" sme:canSort="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Currency Code" sme:precedence="1" type="tns:arCustomerFinder--CODECURN--type" /><xs:element name="NAMECITY" nillable="true" sme:averageLength="30" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="City" sme:maxLength="30" sme:precedence="1" type="xs:string" /><xs:element name="CODESTTE" nillable="true" sme:averageLength="30" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="State/Province" sme:maxLength="30" sme:precedence="1" type="xs:string" /><xs:element name="CODECTRY" nillable="true" sme:averageLength="30" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Country" sme:maxLength="30" sme:precedence="1" type="xs:string" /><xs:element name="SWACTV" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Status" sme:precedence="1" type="tns:arCustomerFinder--SWACTV--enum" /><xs:element name="SWBALFWD" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Account Type" sme:precedence="1" type="tns:arCustomerFinder--SWBALFWD--enum" /><xs:element name="TEXTSTRE1" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Address Line 1" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="TEXTSTRE2" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Address Line 2" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="TEXTSTRE3" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Address Line 3" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="TEXTSTRE4" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Address Line 4" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="CODEPSTL" nillable="true" sme:averageLength="20" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Zip/Postal Code" sme:maxLength="20" sme:precedence="1" type="xs:string" /><xs:element name="TEXTPHON1" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Phone Number" sme:precedence="1" type="tns:arCustomerFinder--TEXTPHON1--type" /><xs:element name="TEXTPHON2" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Fax Number" sme:precedence="1" type="tns:arCustomerFinder--TEXTPHON2--type" /><xs:element name="NAMECTAC" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Contact Name" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="PRICLIST" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Customer Price List" sme:precedence="1" type="tns:arCustomerFinder--PRICLIST--type" /><xs:element name="DATEINAC" nillable="true" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Inactive Date" sme:precedence="1" type="tns:arCustomerFinder--DATEINAC--type" /><xs:element name="DATELASTMN" nillable="true" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Date Last Maintained" sme:precedence="1" type="tns:arCustomerFinder--DATELASTMN--type" /><xs:element name="CODETERR" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Territory Code" sme:precedence="1" type="tns:arCustomerFinder--CODETERR--type" /><xs:element name="IDACCTSET" sme:canFilter="true" sme:canSort="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Account Set" sme:precedence="1" type="tns:arCustomerFinder--IDACCTSET--type" /><xs:element name="CODETERM" sme:canFilter="true" sme:canSort="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Terms" sme:precedence="1" type="tns:arCustomerFinder--CODETERM--type" /><xs:element name="CTACPHONE" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Contacts Phone" sme:precedence="1" type="tns:arCustomerFinder--CTACPHONE--type" /><xs:element name="PAYMCODE" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Payment Code" sme:precedence="1" type="tns:arCustomerFinder--PAYMCODE--type" /><xs:element name="AMTCRLIMT" sme:canFilter="true" sme:fractionDigits="3" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Credit Limit (Cust. Curr.)" sme:precedence="1" sme:totalDigits="18" type="xs:decimal" /><xs:element name="LOCATION" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Inventory Location" sme:precedence="1" type="tns:arCustomerFinder--LOCATION--type" /><xs:element name="CODETAXGRP" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Tax Group" sme:precedence="1" type="tns:arCustomerFinder--CODETAXGRP--type" /><xs:element name="FOB" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Free On Board" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="SHPVIADESC" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Ship Via Description" sme:maxLength="60" sme:precedence="1" type="xs:string" /></xs:all><xs:anyAttribute /></xs:complexType><xs:complexType name="arCustomerFinder--list"><xs:sequence><xs:element maxOccurs="unbounded" minOccurs="0" name="arCustomerFinder" type="tns:arCustomerFinder--type" /></xs:sequence></xs:complexType><xs:simpleType name="arCustomerFinder--IDCUST--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--SWHOLD--enum"><xs:restriction base="xs:short"><xs:enumeration sme:label="No" value="0" /><xs:enumeration sme:label="Yes" value="1" /></xs:restriction></xs:simpleType><xs:simpleType name="arCustomerFinder--IDGRP--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--IDNATACCT--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--CODECURN--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--SWACTV--enum"><xs:restriction base="xs:short"><xs:enumeration sme:label="Inactive" value="0" /><xs:enumeration sme:label="Active" value="1" /></xs:restriction></xs:simpleType><xs:simpleType name="arCustomerFinder--SWBALFWD--enum"><xs:restriction base="xs:short"><xs:enumeration sme:label="Open Item" value="0" /><xs:enumeration sme:label="Balance Forward" value="1" /></xs:restriction></xs:simpleType><xs:simpleType name="arCustomerFinder--TEXTPHON1--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--TEXTPHON2--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--PRICLIST--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--DATEINAC--type"><xs:restriction base="xs:date" /></xs:simpleType><xs:simpleType name="arCustomerFinder--DATELASTMN--type"><xs:restriction base="xs:date" /></xs:simpleType><xs:simpleType name="arCustomerFinder--CODETERR--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--IDACCTSET--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--CODETERM--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--CTACPHONE--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--PAYMCODE--type"><xs:restriction base="xs:string"></xs:restriction></xs:simpleType><xs:simpleType name="arCustomerFinder--LOCATION--type"><xs:restriction base="xs:string"></xs:restriction></xs:simpleType><xs:simpleType name="arCustomerFinder--CODETAXGRP--type"><xs:restriction base="xs:string" /></xs:simpleType></xs:schema>';
                oGUMU_Response.statusCode = '200';
            }
            else
            {
                oGUMU_Response=provider.getRecords(WhereParams,AttribParams);
                system.debug('frm providre '+oGUMU_Response);
            }
            Helper.GUMU_Response pGUMU_Response;
            pGUMU_Response=oGUMU_Response;
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
                    customObjects=getCustomObject(oIntegration ,oMappingHeader, oGUMU_Response.ERPDataMap);
                    
                }   
                else
                {
                    customObjects=getCustomObject(oIntegration ,oMappingHeader, oGUMU_Response.ERPDataMapDetail);
                }   

                if (customObjects != null)
                {
                    customObjectsList.addAll(customObjects);
                }
                oGUMU_Response.responseSFData=customObjectsList;
                oGUMU_Response.totalRecord=pGUMU_Response.totalRecord;
            }

            else if(purpose == Helper.MappingPurpose.POST)
            {
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

    public override Helper.GUMU_Response PostData(string IntegrationId,string SourceEntity,map<string,list<object>> SFObject,map<string,string> PromotionFields,map<string,list<object>> AttribParams)
    {     
    	boolean isfuture = System.isFuture();
        Helper.MappingPurpose purpose;
        // ERP_Config__c oIntegration ;
        // Entity_Mapping_Header__c oMappingHeader; 
        list<Data_Page__c> DataPageList = new List<Data_Page__c>();
        Helper.GUMU_Response oGUMU_Response; 
        string ERPFuncName='';
        string objectXML  ;
        string objectXML_CONT;

        list<string> objectXMLList=new list<string>();
        list<string> objectXMLList_CONT =new list<string>();
        try
        {
            //Create Utility function to validate WhereParams and AttribParams
            list<object> AttribParam=AttribParams.get('IntegrationId');
            integrationID=(String)AttribParam[0];

            AttribParam=AttribParams.get('SourceEntity');
            sourceEntity=SourceEntity;//(String)AttribParam[0];

            AttribParam=AttribParams.get('MappingPurpose');         
            purpose=(Helper.MappingPurpose) AttribParam[0];

            AttribParam=AttribParams.get('ERPFuncName');
            ERPFuncName=(String)AttribParam[0];
            list<string> RequestType;
            //RequestType.add('save');
            counter++;
            
            if(purpose == Helper.MappingPurpose.MODIFY)
            {
                RequestType = new list<string>();
                RequestType.add('update');
                AttribParams.put('RequestType',RequestType);
                if(sourceEntity =='Sage100Customer')
                {                   
                    //set the attributes
                    list<Account>   CurrentAccount  =(list<Account>)SFObject.get('Accounts');   
                    list<string> KeyValue= new list<string>();
                    KeyValue.Add(CurrentAccount[0].AR_DivisonNo__c);
                    KeyValue.add(String.valueOf(CurrentAccount[0].ERP_Customer_Number__c).toUpperCase());
                    AttribParams.put('KeyValue',KeyValue);
                }
                if(sourceEntity =='Contacts')
                {
                    //RequestType = new list<string>();
                    //RequestType.add('update');

                }

                if (sourceEntity =='Address100')
                {
                    //RequestType = new list<string>();
                    //RequestType.add('update');
                    //AttribParams.put('RequestType',RequestType);

                }

            }
            else
            //Add Finder values
            {
             
                RequestType= new list<string>();
                RequestType.add('save');
                AttribParams.put('RequestType',RequestType);
            }
            
            list<string> FinderName = new list<string>();
            FinderName.add(ERPFuncName);
            AttribParams.put('DataFinder',FinderName);
            oGUMU_Response=new  Helper.GUMU_Response(); 
            oGUMU_Response=provider.PostRecords(AttribParams);
			
			system.debug('oGUMU_Response '+oGUMU_Response);
				
            if(oGUMU_Response.statusCode =='200' || oGUMU_Response.statusCode =='201')
            { 
                oGUMU_Response=getMapForXML_forPostedRecords(oGUMU_Response,AttribParams);
            }
            else
            {
            	if(System.isFuture() == false)
                	Utility.parse(oGUMU_Response.responseERPData,'message');
            }

            if (Test.isRunningTest())
            {
                return oGUMU_Response;
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
            system.debug('Response89'+oGUMU_Response);
            return oGUMU_Response; 
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'PostData',ex,false);
            throw ex;   
        }
    }

    //getMapForXML2 of 300
    public Helper.GUMU_Response getMapForXML_forPostedRecords(Helper.GUMU_Response pGUMU_Response,map<string,list<object>> AttribParams)
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
            /*for(Dom.XMLNode child : Envelope.getChildElements())
            {        
                system.debug('child.getName() '+child.getName());
                if(child.getName() == 'entry') 
                {
                    for(Dom.XMLNode subchild : child.getChildElements()) 
                    {

                        if(subchild.getName() == 'payload') 
                        {
                            ERPDataMap=new map<string,string>(); 
                            for(Dom.XMLNode subsubchild : subchild.getChildElements()) 
                            {
                                if(subsubchild.getName() == 'SO_SalesOrderHeaderSPECIAL') 

                                    for(Dom.XMLNode subsubsubchild : subsubchild.getChildElements()) 
                                    {
                                        if(subsubsubchild.getName() == 'SalesOrderNo') 
                                        { 
                                            nodeText = string.valueof(subsubsubchild.getText());
                                            ERPDataMap.put(subsubsubchild.getName() ,nodeText);

                                        }
                                    }

                            }


                        }

                    }


                }

            }*/

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
                        }
                    }
                }
            }

            ERPDataMapAll.add(ERPDataMap);
            pGUMU_Response.ERPDataMap = ERPDataMapAll;

            pGUMU_Response.ERPDataMapDetail     = ERPDataMapDetailAll;
            pGUMU_Response.ERPDataMapRelSection = ERPDataMapRelSections;

            //set the veriable for paging
            pGUMU_Response.TotalRecord = TotalRecords;
            pGUMU_Response.startIndex  = startIndex;
            pGUMU_Response.itemPerPage = itemPerPage;
            //system.debug('pGUMU_Response '+pGUMU_Response);
            return pGUMU_Response;          
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'getMapForXML',ex,false);
            throw ex;
        }           
    }   

    /* private string setAccountXML(Account Act, map<String,String> PromotionFields,list<Contact> Contacts,list<Ship_To__c> shipToLst) 
    {
       string CustomerNo = PromotionFields.get('CustomerNo100');
        if (CustomerNo ==null ||CustomerNo=='null' ) 
            CustomerNo =Act.ERP_Customer_Number__c;

        //system.debug('PromotionFields '+PromotionFields);
        string ARDivision= PromotionFields.get('ArDivision100');
        string TermsCode= PromotionFields.get('TermsCode100');
        string ShipMethod = PromotionFields.get('ShipMethod100');
        string TaxSchedule = PromotionFields.get('TaxSchedule100');
        //string SalesPerson = PromotionFields.get('SalesPerson100');


        string strObjXML='';        
        strObjXML +='<entry xmlns:atom="http://www.w3.org/2005/Atom" ';
        strObjXML +='xmlns:xs="http://www.w3.org/2001/XMLSchema" ';
        strObjXML +='xmlns:cf="http://www.microsoft.com/schemas/rss/core/2005" ';
        strObjXML +='xmlns="http://www.w3.org/2005/Atom" ';
        strObjXML +='xmlns:sdata="http://schemas.sage.com/sdata/2008/1" ';
        strObjXML +='xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ';
        strObjXML +='xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1" ';
        strObjXML +='xmlns:sync="http://schemas.sage.com/sdata/sync/2008/1" ';
        strObjXML +='xmlns:sme="http://schemas.sage.com/sdata/sme/2007" ';
        strObjXML +='xmlns:http="http://schemas.sage.com/sdata/http/2008/1"> ';
        strObjXML +='<sdata:payload>';
        strObjXML +='<Ar_Customer xmlns="">';

        strObjXML +='<ARDivisionNo>'+ARDivision+'</ARDivisionNo>';
        //strObjXML +='<SalespersonNo>'+SalesPerson+'</SalespersonNo>';
        strObjXML +='<TermsCode>'+TermsCode+'</TermsCode>';
        strObjXML +='<TaxSchedule>'+TaxSchedule+'</TaxSchedule>';
        strObjXML +='<ShipMethod>'+ShipMethod+'</ShipMethod>';
        strObjXML +='<CustomerNo>'+ CustomerNo+'</CustomerNo>';

        strObjXML +='<CustomerName>'+ act.Name +'</CustomerName>';
        strObjXML +='<AddressLine1>'+ act.BillingStreet+'</AddressLine1>';
        strObjXML +='<AddressLine2>'+ act.BillingStreet+'</AddressLine2>';
        strObjXML +='<AddressLine3>'+ act.BillingStreet+'</AddressLine3>';
        strObjXML +='<City>'+ act.BillingCity+'</City>';

        strObjXML +='<TelephoneNo> </TelephoneNo>';        
        strObjXML +='<FaxNo>     </FaxNo>';         
        strObjXML +='<URLAddress>    </URLAddress>';
        strObjXML +='</Ar_Customer>';
        strObjXML +='</sdata:payload>';
        strObjXML +='</entry>';

        //system.debug('strObjXML '+strObjXML);
        return strObjXML; 
    }   */



    //Create object XML for Promoting Customer/Prospects to the Sage 300 ERP
    /*private string setAccountContactXML(Account Act, map<String,String> PromotionFields,list<Contact> Contacts,list<Ship_To__c> shipToLst) 
    {
        system.debug('PromotionFields from setAccountContactXML '+PromotionFields);
        string CustomerNo100 = PromotionFields.get('CustomerNo100');

        if (CustomerNo100 ==null ||CustomerNo100 =='null' ) 
            CustomerNo100 =Act.ERP_Customer_Number__c;

        string strObjXML_CONT='';

        strObjXML_CONT +='<entry xmlns:atom="http://www.w3.org/2005/Atom" ';
        strObjXML_CONT +='xmlns:xs="http://www.w3.org/2001/XMLSchema" ';
        strObjXML_CONT +='xmlns:cf="http://www.microsoft.com/schemas/rss/core/2005" ';
        strObjXML_CONT +='xmlns="http://www.w3.org/2005/Atom" ';
        strObjXML_CONT +='xmlns:sdata="http://schemas.sage.com/sdata/2008/1" ';
        strObjXML_CONT +='xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ';
        strObjXML_CONT +='xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1" ';
        strObjXML_CONT +='xmlns:sync="http://schemas.sage.com/sdata/sync/2008/1" ';
        strObjXML_CONT +='xmlns:sme="http://schemas.sage.com/sdata/sme/2007" ';
        strObjXML_CONT +='xmlns:http="http://schemas.sage.com/sdata/http/2008/1"> ';

        strObjXML_CONT +='<sdata:payload>';
        strObjXML_CONT +='<AR_CustomerContact xmlns="" >';
        for(Contact Cont:Contacts)
        {   
            string contactCode = string.isblank(Cont.ERP_Contact_Code__c) ? '':Cont.ERP_Contact_Code__c;
            string Salutation = string.isblank(Cont.Salutation) ? '':Cont.Salutation;

            strObjXML_CONT += '<ARDivisionNo>'+01+'</ARDivisionNo>';
            strObjXML_CONT += '<CustomerNo>'+ CustomerNo100 +'</CustomerNo>';
            strObjXML_CONT += '<ContactCode>'+ 1 +'</ContactCode>';
            //strObjXML_CONT += '<ContactName>'+Cont.Name+'</ContactName>';
            //strObjXML_CONT += '<AddressLine1>'+Cont.MailingAddress+'</AddressLine1>';
            //strObjXML_CONT += '<AddressLine2>'+Cont.MailingAddress+'</AddressLine2>';
            //strObjXML_CONT += '<City>'+Cont.MailingCity+'</City>';


            //strObjXML_CONT += '<State>'+Cont.MailingState+ '</State>';
            //strObjXML_CONT += '<ZipCode>'+Cont.OtherPostalCode+'</ZipCode>';
            //strObjXML_CONT += '<Salutation>' +Salutation+'</Salutation> ';

            //strObjXML_CONT += '<TelephoneNo1>'+Cont.Phone+'</TelephoneNo1> ';

            //strObjXML_CONT += '<TelephoneNo2>'+Cont.HomePhone+'</TelephoneNo2> ';


            //strObjXML_CONT += '<FaxNo>'+Cont.Fax+'</FaxNo> ';

            //strObjXML_CONT += '<EmailAddress>'+Cont.Email+'</EmailAddress> ';

            //strObjXML_CONT += '<ContactNotes>'+Ship_To_Address4__c+'</ContactNotes> ';

            //strObjXML_1 += '<TelephoneExt1>'+Cont.MobilePhone+'</TelephoneExt1> ';
            //strObjXML_1 += '<ContactTitle>'+Ship_To_Address4__c+'</ContactTitle> ';
            //strObjXML_1 +='<CountryCode>'+shipTo.Ship_To_Address2__c+'</CountryCode>';

            //strObjXML_1 += '<TimeCreated>'+Ship_To_Address4__c+'</TimeCreated> ';
            //strObjXML_1 += '<DateCreated>'+Ship_To_Address4__c+'</DateCreated> ';
            //strObjXML_1 += '<UserCreatedKey>'+Ship_To_Address4__c+'</UserCreatedKey> ';
            //strObjXML_1 += '<DateUpdated>'+Ship_To_Address4__c+'</DateUpdated> ';
            //strObjXML_1 += '<TimeUpdated>'+Ship_To_Address4__c+'</TimeUpdated> ';
            //strObjXML_1 += '<UserUpdatedKey>'+Ship_To_Address4__c+'</UserUpdatedKey> ';


            //strObjXML_CONT += '<TelephoneExt2>'+Ship_To_Address4__c+'</TelephoneExt2> ';

            //strObjXML_1  +='<SWACTV>1</SWACTV>';
            //strObjXML_1 +='<FOB xsi:nil="false" />;
            //strObjXML_1+= <SHPVIADESC xsi:nil="false" />;
        }

        strObjXML_CONT +='</AR_CustomerContact>';
        strObjXML_CONT +='</sdata:payload>';
        strObjXML_CONT+='</entry>';
        return strObjXML_CONT;

    }  */
    //This function is used to get the customer from Sage300ERP
    public override Helper.GUMU_Response getData(map<string,map<string,list<string>>> Params,map<string,list<object>> Attributes)
    { 
        return getRecords(Params,Attributes);
    }

    //This function is used to get the list of map of sage300 ERP data  
    public Helper.GUMU_Response getMapForXML(Helper.GUMU_Response pGUMU_Response,map<string,list<object>> AttribParams)
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
                                //system.debug('subsubchild = ' +subsubchild.getChildElements());
                                for(Dom.XMLNode subsubsubchild : subsubchild.getChildElements()) 
                                {
                                    nodeText = string.valueof(subsubsubchild.getText());
									
									string menulab=valuesdescription(subsubsubchild.getName(),nodeText);
									if(menulab !='')
                                    	ERPDataMap.put(subsubsubchild.getName() ,menulab);
                                    else
                                    	ERPDataMap.put(subsubsubchild.getName() ,nodeText);

                                    // Here write the code to loop all the detail 
                                    if (Sections.get(subsubsubchild.getName())!=null )
                                    {
                                        //for(Dom.XMLNode Detailchild : subsubsubchild.getChildElements()) 
                                        //{
                                            
                                            ERPDataMapDetail=new map<string,string>();  
                                            //Add code for adding detail:s
                                            for(Dom.XMLNode subsubsubchildR : subsubchild.getChildElements()) 
                                            {
                                                nodeText = string.valueof(subsubsubchildR.getText());
                                                menulab=valuesdescription(subsubsubchildR.getName(),nodeText);
                                                if(menulab !='')
			                                    	ERPDataMapDetail.put(subsubsubchildR.getName() ,menulab);
			                                    else
			                                    	ERPDataMapDetail.put(subsubsubchildR.getName() ,nodeText);
                                    	
                                                //ERPDataMapDetail.put(subsubsubchildR.getName() ,nodeText);
                                            }   
                                            //Add code for adding detail:e
                                            //  for(Dom.XMLNode subDetailchild : Detailchild.getChildElements())    
                                            for(Dom.XMLNode subDetailchild : subsubsubchild.getChildElements()) 
                                            {
                                                nodeText = string.valueof(subDetailchild.getText());
                                                ERPDataMapDetail.put(subDetailchild.getName() ,nodeText);
                                            }

                                            ERPDataMapDetailAll.Add(ERPDataMapDetail);
                                            ERPDataMapRelSections.put(subsubsubchild.getName(),ERPDataMapDetailAll);
                                        //}
                                    }
                                }   
                            }
                            ERPDataMapAll.Add(ERPDataMap);
                        }
                    }
                }
            }
            
            //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'DEBUG:ERPDataMapAll:'+JSON.serialize(ERPDataMapAll )));
            //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'DEBUG:ERPDataMapDetailAll:'+ JSON.serialize( ERPDataMapDetailAll)));
            //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'DEBUG:ERPDataMapRelSections:'+ JSON.serialize(ERPDataMapRelSections)));
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
    public list<Account> GetCustomers(ERP_Config__c oIntegration,Entity_Mapping_Header__c MappingHeader, List<map<String,String>> RecordList)
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
    }
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
            if(aDatePart.size()>1)
                listParams.add(aDatePart[2]+aDatePart[0]+aDatePart[1]);
            else
                listParams.add(Param1);
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
        return 'CustomerName';
    }

    //This function is used to get the common ERP data map format for specific ERP data
    public override List<Helper.Customer> GetGenericCustomers(Helper.GUMU_Response pGUMU_Response)
    { 
        List<Helper.Customer> lstCustomer = New List<Helper.Customer>();
        Helper.Customer oCustomer;

        try
        {
        	//ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'pGUMU_Response.ERPDataMap '+pGUMU_Response));
        
            if(pGUMU_Response.ERPDataMap !=null) 
            {
                for (Map<String,String> RecMap : pGUMU_Response.ERPDataMap)
                {
                    oCustomer = new Helper.Customer();
                    oCustomer.UniqueKey =  RecMap.get('CustomerNo'); 
                    oCustomer.CategoryCode =  RecMap.get('ARDivisionNo'); 
                    oCustomer.CustomerName =  RecMap.get('CustomerName'); 
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
    //commented on 22/01/2016 for test coverage
    public override  Helper.GUMU_Response ReadSchema(string MethodName,string Integration_Id)
    {
        try
        {
            map<string,list<object>> AttribParams = new map<string,list<object>>();
            list<string> FinderName = new list<string>();
            list<string> RequestType = new list<string>();
            list<string> IntegrationId= new list<string>();
            list<string> startIndex= new list<string>();
            list<string> TotalRecords= new list<string>();
            Entity_Detail__c Entity_Detail ;
            list<Entity_Detail__c> Entity_Details = new list<Entity_Detail__c>() ;
            FinderName.add(MethodName);
            RequestType.add('getDescription');
            IntegrationId.add(Integration_Id);
            startIndex.add('1');
            TotalRecords.add('1');
            AttribParams.put('ERPFuncName',FinderName);//DataFinder
            AttribParams.put('RequestType',RequestType);
            AttribParams.put('IntegrationId',IntegrationId);
            AttribParams.put('startIndex',startIndex);
            AttribParams.put('count',TotalRecords);
			//ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'AttribParams: '+ AttribParams));
            Helper.GUMU_Response oGUMU_Response=new  Helper.GUMU_Response();
            if (Test.isRunningTest())
            {
                oGUMU_Response.statusCode ='200';
                oGUMU_Response.responseERPData='<?xml version="1.0" encoding="UTF-8"?><xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ame="http://schemas.sage.com/accpac/sdata/ame/2009" xmlns:sme="http://schemas.sage.com/sdata/sme/2007" xmlns:tns="http://schemas.sage.com/sageERP" elementFormDefault="qualified" targetNamespace="http://schemas.sage.com/sageERP"><xs:element name="arCustomerFinder" sme:batchingMode="syncOrAsync" sme:canDelete="true" sme:canGet="true" sme:canPageIndex="true" sme:canPageNext="true" sme:canPagePrevious="true" sme:canPost="true" sme:canPut="true" sme:label="Customers" sme:pluralName="arCustomersFinder" sme:role="resourceKind" sme:supportsETag="true" type="tns:arCustomerFinder--type" /><xs:complexType name="arCustomerFinder--type"><xs:all><xs:element name="IDCUST" sme:canFilter="true" sme:canSort="true" sme:isMandatory="true" sme:isReadOnly="false" sme:label="Customer Number" sme:precedence="1" type="tns:arCustomerFinder--IDCUST--type" /><xs:element name="NAMECUST" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Customer Name" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="TEXTSNAM" nillable="true" sme:averageLength="10" sme:canFilter="true" sme:canSort="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Short Name" sme:maxLength="10" sme:precedence="1" type="xs:string" /><xs:element name="SWHOLD" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="On Hold" sme:precedence="1" type="tns:arCustomerFinder--SWHOLD--enum" /><xs:element name="IDGRP" sme:canFilter="true" sme:canSort="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Group Code" sme:precedence="1" type="tns:arCustomerFinder--IDGRP--type" /><xs:element name="IDNATACCT" sme:canFilter="true" sme:canSort="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="National Account" sme:precedence="1" type="tns:arCustomerFinder--IDNATACCT--type" /><xs:element name="CODECURN" sme:canFilter="true" sme:canSort="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Currency Code" sme:precedence="1" type="tns:arCustomerFinder--CODECURN--type" /><xs:element name="NAMECITY" nillable="true" sme:averageLength="30" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="City" sme:maxLength="30" sme:precedence="1" type="xs:string" /><xs:element name="CODESTTE" nillable="true" sme:averageLength="30" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="State/Province" sme:maxLength="30" sme:precedence="1" type="xs:string" /><xs:element name="CODECTRY" nillable="true" sme:averageLength="30" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Country" sme:maxLength="30" sme:precedence="1" type="xs:string" /><xs:element name="SWACTV" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Status" sme:precedence="1" type="tns:arCustomerFinder--SWACTV--enum" /><xs:element name="SWBALFWD" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Account Type" sme:precedence="1" type="tns:arCustomerFinder--SWBALFWD--enum" /><xs:element name="TEXTSTRE1" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Address Line 1" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="TEXTSTRE2" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Address Line 2" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="TEXTSTRE3" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Address Line 3" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="TEXTSTRE4" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Address Line 4" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="CODEPSTL" nillable="true" sme:averageLength="20" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Zip/Postal Code" sme:maxLength="20" sme:precedence="1" type="xs:string" /><xs:element name="TEXTPHON1" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Phone Number" sme:precedence="1" type="tns:arCustomerFinder--TEXTPHON1--type" /><xs:element name="TEXTPHON2" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Fax Number" sme:precedence="1" type="tns:arCustomerFinder--TEXTPHON2--type" /><xs:element name="NAMECTAC" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Contact Name" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="PRICLIST" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Customer Price List" sme:precedence="1" type="tns:arCustomerFinder--PRICLIST--type" /><xs:element name="DATEINAC" nillable="true" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Inactive Date" sme:precedence="1" type="tns:arCustomerFinder--DATEINAC--type" /><xs:element name="DATELASTMN" nillable="true" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Date Last Maintained" sme:precedence="1" type="tns:arCustomerFinder--DATELASTMN--type" /><xs:element name="CODETERR" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Territory Code" sme:precedence="1" type="tns:arCustomerFinder--CODETERR--type" /><xs:element name="IDACCTSET" sme:canFilter="true" sme:canSort="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Account Set" sme:precedence="1" type="tns:arCustomerFinder--IDACCTSET--type" /><xs:element name="CODETERM" sme:canFilter="true" sme:canSort="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Terms" sme:precedence="1" type="tns:arCustomerFinder--CODETERM--type" /><xs:element name="CTACPHONE" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Contacts Phone" sme:precedence="1" type="tns:arCustomerFinder--CTACPHONE--type" /><xs:element name="PAYMCODE" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Payment Code" sme:precedence="1" type="tns:arCustomerFinder--PAYMCODE--type" /><xs:element name="AMTCRLIMT" sme:canFilter="true" sme:fractionDigits="3" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Credit Limit (Cust. Curr.)" sme:precedence="1" sme:totalDigits="18" type="xs:decimal" /><xs:element name="LOCATION" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Inventory Location" sme:precedence="1" type="tns:arCustomerFinder--LOCATION--type" /><xs:element name="CODETAXGRP" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Tax Group" sme:precedence="1" type="tns:arCustomerFinder--CODETAXGRP--type" /><xs:element name="FOB" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Free On Board" sme:maxLength="60" sme:precedence="1" type="xs:string" /><xs:element name="SHPVIADESC" nillable="true" sme:averageLength="60" sme:canFilter="true" sme:isMandatory="false" sme:isReadOnly="false" sme:label="Ship Via Description" sme:maxLength="60" sme:precedence="1" type="xs:string" /></xs:all><xs:anyAttribute /></xs:complexType><xs:complexType name="arCustomerFinder--list"><xs:sequence><xs:element maxOccurs="unbounded" minOccurs="0" name="arCustomerFinder" type="tns:arCustomerFinder--type" /></xs:sequence></xs:complexType><xs:simpleType name="arCustomerFinder--IDCUST--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--SWHOLD--enum"><xs:restriction base="xs:short"><xs:enumeration sme:label="No" value="0" /><xs:enumeration sme:label="Yes" value="1" /></xs:restriction></xs:simpleType><xs:simpleType name="arCustomerFinder--IDGRP--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--IDNATACCT--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--CODECURN--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--SWACTV--enum"><xs:restriction base="xs:short"><xs:enumeration sme:label="Inactive" value="0" /><xs:enumeration sme:label="Active" value="1" /></xs:restriction></xs:simpleType><xs:simpleType name="arCustomerFinder--SWBALFWD--enum"><xs:restriction base="xs:short"><xs:enumeration sme:label="Open Item" value="0" /><xs:enumeration sme:label="Balance Forward" value="1" /></xs:restriction></xs:simpleType><xs:simpleType name="arCustomerFinder--TEXTPHON1--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--TEXTPHON2--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--PRICLIST--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--DATEINAC--type"><xs:restriction base="xs:date" /></xs:simpleType><xs:simpleType name="arCustomerFinder--DATELASTMN--type"><xs:restriction base="xs:date" /></xs:simpleType><xs:simpleType name="arCustomerFinder--CODETERR--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--IDACCTSET--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--CODETERM--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--CTACPHONE--type"><xs:restriction base="xs:string" /></xs:simpleType><xs:simpleType name="arCustomerFinder--PAYMCODE--type"><xs:restriction base="xs:string"></xs:restriction></xs:simpleType><xs:simpleType name="arCustomerFinder--LOCATION--type"><xs:restriction base="xs:string"></xs:restriction></xs:simpleType><xs:simpleType name="arCustomerFinder--CODETAXGRP--type"><xs:restriction base="xs:string" /></xs:simpleType></xs:schema>';
            } 
            else             
                oGUMU_Response=provider.getRecords(null,AttribParams);

            if(oGUMU_Response.statusCode =='0')
            {
                //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Error: '+ oGUMU_Response.statusMessage));
            }

            else if(oGUMU_Response.statusCode !='201' && oGUMU_Response.statusCode !='200')
            {
            	//ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Error:responseERPData **  '+ oGUMU_Response.responseERPData));
                if (string.isNotBlank(oGUMU_Response.responseERPData))
                {
                    Utility.parse(oGUMU_Response.responseERPData,'message'); 
                }       
            }  
            else 
            {   
                getMapForXML_Schema(oGUMU_Response,AttribParams);    
                map<string,string> AddedMap = new map<string,string> ();
                for(map<string,string> mapSFData : oGUMU_Response.ERPDataMap)
                {
                    Entity_Detail = new Entity_Detail__c ();
                    Entity_Detail.Name= mapSFData.get('APILabel');
                    Entity_Detail.Data_Type__c=string.valueOf(mapSFData.get('DataType')).replace('xs:','');
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
            }
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

        Dom.Document doc;
        ReadAndWriteXML.XmlNode objXmlNode;
        string totalRecords='';  
        string itemPerPage='';  
        string startIndex=''; 
        string hasNext='';    
        string nodeText='';
        map<string,string> Sections = new map<string,string>();

        map<string,string> ERPDataMap =  new map<string,string>();
        list<map<string,string>> ERPDataMapAll =  new list<map<string,string>>();

        map<string,string> ERPDataMapDetail =   new map<string,string>();
        list<map<string,string>> ERPDataMapDetailAll =  new list<map<string,string>>(); 
        map<string,list<map<string,string>>> ERPDataMapRelSections    = new map<string,list<map<string,string>>> ();
        map<string,string> ParentMap =   new map<string,string>();
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
                                    ParentMap.put(lstVALNode.Attributes.get('name')+'--type','YES');
                                    continue;
                                }

                                if (ParentMap.get(readRsltNode.Attributes.get('name')) =='YES')
                                {
                                    GroupName = readRsltNode.Attributes.get('name');
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
    
    public string valuesdescription(string ERPField,string ERPValue)
    {
        string menulab='';
        //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'DEBUG:ErpDataList:'+ jSon.serialize(EntityDetailList)));        
	      if(ERPField == 'OrderType')
    	  {
	            if(ERPValue == 'S')
	                menulab='Standard';
	            else if(ERPValue == 'B')
	                menulab='Back Order';
	            else if(ERPValue == 'M')
	                menulab='Master Order';
	            else if(ERPValue == 'R')
	                menulab='Repeating Order';
	            else if(ERPValue == 'Q')
	                menulab='Quote';
	      }
	      else if(ERPField =='InvoiceType')
	      {
	      	if(ERPValue == 'IN')
                menulab='Invoice';
	      }  
         return menulab;    
    }    

}