global class Utility 
{
    // Global variable to check whether run trigger or not 
    public static Boolean bRunTrigger=true;
    public static integer ContactSequence;

    // Global variable for NameSpace
    public static String gNameSpace = '';
    public static String GlContactCode='';
    
    private static final string ClassName='Utility';
    
    
     public static void ShowErrorMessage(object ErrorMessage)
     {
        try
        {
            //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error,''+ ErrorMessage ));
        }
        catch (Exception e){}
     }
     public static String parse(String toParse,String NodeTag)
     {
        Dom.Document doc = new Dom.Document(); 
        string ret;
        try 
        {           
            doc.load(toParse);                 
            DOM.XMLNode root = doc.getRootElement();
            ret=walkThrough(root,NodeTag);
        } 
        catch (System.XMLException e) 
        { 
            throw e;
        }        
         return ret;
    }
    
    public static String walkThrough(DOM.XMLNode node,string NodeTag) 
    {
      String result = '';
      
      try
      { 
		  if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) 
		  {
				result =  node.getName();
				if (result==NodeTag)
				{ 
			    	result=node.getText().trim();
				    apexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error Message:'+ result));
				    return result;
				} 
    	  }
	       
	        for (Dom.XMLNode child: node.getChildElements()) 
	        {
	            result = walkThrough(child,NodeTag);
	        }
	     	return result;
      }
      catch(Exception ex)
      {
      	throw ex;
      }
    }

    //Method to get the text content of the static resource by the name. 
   public static String getResourceContent(String staticResourceName)
    {
        String src='';
        try
        {
            // Check if the user has read access on the StaticResource.Bodyfield
            if (!Schema.sObjectType.StaticResource.fields.Body.isAccessible())
                return '';
            StaticResource sr = [select Body from StaticResource where Name = :staticResourceName];
            src= sr.Body.toString();
            return src;
        }
        catch(Exception ex)
        {
            src= '';
            CustomException exc= new CustomException (ClassName,'getResourceContent',ex,false);
            return src;
        }
    } 

    //Method to get the paramerts for calling webservice to retrieve records from ERP to Salesforce. 
     public static  map<string,list<object>> getAttribParameters(String strtIndex, String maxCount, String IntegrationId, String srcEntity, String includeFunction, Helper.MappingPurpose mappingType )
    {
        map<string,list<object>> AttribParams=new  map<string,list<object>>();
        list<object>  AttribParam= new list<object>();
        
        //check the StartIndex if not then set as 1
        if (strtIndex=='' ||  strtIndex==null)
                strtIndex='1';
        if (maxCount=='0' || maxCount==''|| maxCount==null)
                maxCount='10'; 
        
        AttribParam.add(strtIndex);
        AttribParams.put('startIndex',AttribParam);

        AttribParam= new list<object>();
        AttribParam.add(maxCount);
        AttribParams.put('count',AttribParam);

        AttribParam= new list<object>();
        AttribParam.add(IntegrationId);
        AttribParams.put('IntegrationId',AttribParam);

        AttribParam= new list<object>();
        AttribParam.add(srcEntity);
        AttribParams.put('SourceEntity',AttribParam);

        AttribParam= new list<object>();
        if(includeFunction != '')
        {
            AttribParam.add(includeFunction);
            AttribParams.put('include',AttribParam);
        }

        AttribParam= new list<object>();
        AttribParam.add(mappingType);
        AttribParams.put('MappingPurpose',AttribParam);

        return AttribParams;
    } 

    //Method to fetch the namespace of the managed package 
    global static String FetchNameSpace()    
    {
        String Namespace='';
        try
        {
            //Check if the user has read access on the ApexClass.NamespacePrefix
            if (!Schema.sObjectType.StaticResource.fields.NamespacePrefix.isAccessible())
                return '';
            
            list<StaticResource> SR =[SELECT NamespacePrefix FROM StaticResource where name = 'ParamConfig' limit 1];

            if(SR.size() > 0)
            {
                if(String.isNotBlank(SR[0].NamespacePrefix))
                    Namespace = SR[0].NamespacePrefix + '__';
                else  
                    Namespace= '';
            }
            return Namespace;
        }
        catch(Exception ex)
        {
            Namespace= '';
            CustomException exc= new CustomException(className,'FetchNameSpace',ex,false);
            return Namespace;
        }
    }

    //Returns the Key Prefix for the object by object name
    global static String getSobjectKeyPrefix(String ObjectName)
    {
        String objPrefix = '';
        try
        {
            if(gNameSpace == '') 
                gNameSpace = FetchNameSpace();
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            for(string sDescribe:globalDescribe.keySet()) {
                Schema.SObjectType objType = globalDescribe.get(sDescribe);

                if(objType != null) 
                {
                    if(objType.getDescribe().isCustom() && objType.getDescribe().getName().endsWith(ObjectName))
                    {
                        //uncomment this line while creating managed package
                        //ObjectName = gNameSpace +'__'+ ObjectName;
                    }

                    if(objType.getDescribe().getName()==ObjectName)
                    {
                        objPrefix = objType.getDescribe().getkeyprefix();
                        break;
                    }
                }
            }
            return objPrefix;
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'getSobjectKeyPrefix',ex,false);
            throw ex;
        }           

    }

    //Method to get the object name by providing the Key Prefix
    public static String getSobjectName(String KeyPrefix)
    {
        if(KeyPrefix== null)
            KeyPrefix='';
        
        Id oId = KeyPrefix+'000000000000000';
        String sObjName = oId.getSObjectType().getDescribe().getName();
        return sObjName;
    }

    //Returns the map with parameters required for the connection and their values
    public static Map<String,String> FormatConnectionPairs(String ConnectionInfo)
    {
        Map<String,String> ConMaps;
        try
        {
            ReadAndWriteXML.XmlNode objXmlNode = ReadAndWriteXML.ParseXmlString(ConnectionInfo);
            list<ReadAndWriteXML.XmlNode> lstNodes = objXmlNode.ChildXmlNodes;
            list<String> ConPairs = new list<String>();
            ConMaps = new Map<String,String>();
            for(ReadAndWriteXML.XmlNode Node : lstNodes)
            {
                string sConPair = Node.Attributes.get('NAME') + '=' + Node.Attributes.get('VALUE');
                ConMaps.put(Node.Attributes.get('NAME'),Node.Attributes.get('VALUE'));
                ConPairs.add(sConPair);                
            }
            
            return ConMaps;
        }
        catch(Exception ex)
        {
            ConMaps = new Map<String,String>();
            CustomException exc= new CustomException (className,'FetchNameSpace',ex,false);
            return ConMaps;
        }       
    }

    //Prepares the list of ERPs can be integrated with their properties   
    public static list<ERP> LoadParams()
    {
        string XMLContent = getResourceContent('ParamConfig');
        list<ERP> ERPs = new list<ERP>(); 
        try
        {
            ReadAndWriteXML.XmlNode objXmlNode = ReadAndWriteXML.ParseXmlString(XMLContent);
            list<ReadAndWriteXML.XmlNode> lstNodes = objXmlNode.ChildXmlNodes;

            for(ReadAndWriteXML.XmlNode Node : lstNodes)
            {
                ERP currentERP = new ERP();
                currentERP.ERPName = Node.Attributes.get('NAME');
                list<Control>currentERPParamControls = new list<Control>();             

                for (ReadAndWriteXML.XmlNode Child:Node.ChildXmlNodes)
                {
                    list<Control> ParamControls = new list<Control>();
                    list<ImportOption> ImportOptions = new list<ImportOption>();

                    if(Child.NodeName == 'PARAMS')
                    {   
                        list<ReadAndWriteXML.XmlNode> ParamNodes = Child.ChildXmlNodes;

                        for(ReadAndWriteXML.XmlNode ParamNode: ParamNodes )
                        {
                            Control ERPParamControl=new Control();
                            ERPParamControl.Name = ParamNode.NodeValue;
                            ERPParamControl.Code = ParamNode.Attributes.get('CODE');
                            ERPParamControl.Length = string.isBlank(ParamNode.Attributes.get('LENGTH')) ? 0 : Integer.valueOf(ParamNode.Attributes.get('LENGTH'));
                            ERPParamControl.Width = string.isBlank(ParamNode.Attributes.get('WIDTH')) ? 0 : Integer.valueOf(ParamNode.Attributes.get('WIDTH'));
                            ERPParamControl.ParamType = ParamNode.Attributes.get('TYPE');
                            if (! string.isBlank(ParamNode.Attributes.get('OPTIONS')))
                                ERPParamControl.Options = ParamNode.Attributes.get('OPTIONS').split(',');

                            ParamControls.add(ERPParamControl);                
                        }

                        currentERP.Params = ParamControls;                                      
                    }
                    else if(Child.NodeName == 'IMPORTOPTIONS')
                    {
                        for(ReadAndWriteXML.XmlNode ImportNode: Child.ChildXmlNodes )
                        {
                            list<CriteriaGroup> CriteriaGroups = new list<CriteriaGroup>();

                            for(ReadAndWriteXML.XmlNode CGNode: ImportNode.ChildXmlNodes[0].ChildXmlNodes)
                            {
                                list<Control> Criterias = new list<Control>();

                                for(ReadAndWriteXML.XmlNode CNode: CGNode.ChildXmlNodes)
                                {
                                    Control Criteria = new Control();

                                    Criteria.Name = CNode.NodeValue;
                                    Criteria.Code = CNode.Attributes.get('CODE');
                                    Criteria.Length = string.isBlank(CNode.Attributes.get('LENGTH')) ? 0 : Integer.valueOf(CNode.Attributes.get('LENGTH'));
                                    Criteria.Width = string.isBlank(CNode.Attributes.get('WIDTH')) ? 0 : Integer.valueOf(CNode.Attributes.get('WIDTH'));
                                    Criteria.ParamType = CNode.Attributes.get('TYPE');
                                    if (! string.isBlank(CNode.Attributes.get('OPTIONS')))
                                        Criteria.Options = CNode.Attributes.get('OPTIONS').split(',');

                                    Criterias.add(Criteria);
                                }

                                CriteriaGroup CrGroup = new CriteriaGroup();

                                CrGroup.Name = CGNode.Attributes.get('NAME');
                                CrGroup.Label = CGNode.Attributes.get('LABEL');
                                CrGroup.Criterias = Criterias;

                                CriteriaGroups.add(CrGroup);
                            }

                            ImportOption option = new ImportOption();

                            option.Name = ImportNode.Attributes.get('NAME');
                            option.Value = ImportNode.Attributes.get('VALUE');
                            option.Type = ImportNode.Attributes.get('TYPE');
                            option.CriteriaGroups = CriteriaGroups;

                            ImportOptions.add(option);
                        }
                        currentERP.ImportOptions = ImportOptions;   
                    }
                }
                ERPs.add(currentERP); 
            }           
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'UpsertDropdowns',ex,false);
        }
        return ERPs;
    }

    //function for httpRequest for X3
   public static string httpRequest(string EndPoint,string request)
    {
        string getResponse='';
        try
        {               
            HttpRequest req = new HttpRequest();
            req.setEndpoint(EndPoint);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'text/xml');
            req.setHeader('SOAPAction','');
            req.setBody(request);
            req.setTimeOut(120000);
            Http http = new Http();
            HTTPResponse res;
            if (Test.isRunningTest())
            {
                
            }
            else
                res = http.send(req);
                
            getResponse=res.getBody();

        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'httpRequest',ex,false);
            throw ex;
        }
        return getResponse;
    }

    public static map<string ,string> FormatERPInfo(string ERPInfo1,string ERPInfo2,string ERPInfo3)
    {
        String ConnectionInfo= '';
        Map<String,String> ParamMap;
        try
        {
            ConnectionInfo  += string.isNotBlank(ERPInfo1) ? ERPInfo1 : '';

            if(string.isNotBlank(ERPInfo2))
            { 
                if(ERPInfo2.startsWith('NAME') || ERPInfo2.startsWith('VALUE'))
                    ConnectionInfo  += ' ';
            }   
            ConnectionInfo  += string.isNotBlank(ERPInfo2) ? ERPInfo2 : '';

            if(string.isNotBlank(ERPInfo3))
            { 
                if(ERPInfo3.startsWith('NAME') || ERPInfo3.startsWith('VALUE'))
                    ConnectionInfo  += ' ';
            } 
            ConnectionInfo  += string.isNotBlank(ERPInfo3) ? ERPInfo3 : '';

            ParamMap = Utility.FormatConnectionPairs(ConnectionInfo);
            return ParamMap;
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'FormatERPInfo',ex,false);
            throw ex;
        }
    }

    //Convert date into MM/DD/YYYY
    public static string dateFormat(string strDate)
    {  
    	system.debug('strDate'+strDate);      
        string formatedDate='';
        try
        {
            if(strDate !='')
            {
                string strMonth=strDate.substring(4,6);
                string strDay=strDate.substring(6,8);      //substring(7,8)
                string strYear=strDate.substring(0,4);
                formatedDate = strMonth +'/'+strDay+'/'+strYear;
            }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'dateFormat',ex,false);
            throw ex;
        }
        system.debug('formatedDate'+formatedDate);
        return formatedDate;
    }

    public static string Encrypt(string encryptVal)
    {
        String encodedEncryptedText='';
        string BlobKey = [select Password_Key__c from PasswordSetting__c LIMIT 1].Password_Key__c;
        try
        {
            if(!string.isEmpty(encryptVal))
            {
                String getencryptVal = encryptVal;
                //24 byte string. since characters used are ascii, each char is 1 byte.
                Blob key = Blob.valueOf(BlobKey);
                Blob EncryptedText = Crypto.encryptWithManagedIV('AES192', key, Blob.valueOf(getencryptVal));
                encodedEncryptedText = EncodingUtil.base64Encode(EncryptedText); 
            }       
        }
        catch(Exception ex)
        {
             CustomException exc= new CustomException('Utility','Encrypt',ex,false);
        }   
        return encodedEncryptedText;
    }

    public static string Decrypt(string decryptVal)
    {
        String decryptedClearText='';
        try
        {
            string BlobKey = [select Password_Key__c from PasswordSetting__c LIMIT 1].Password_Key__c;
            if(!string.isEmpty(decryptVal))
            {
                Blob encodedEncryptedText = EncodingUtil.base64Decode(decryptVal);
                Blob key = Blob.valueOf(BlobKey);
                Blob decryptedText = Crypto.decryptWithManagedIV('AES192', key, encodedEncryptedText);
                decryptedClearText = decryptedText.toString();          
            }
        }
        catch(Exception ex)
        {
            //GUMUException exc= new GUMUException('Utility','Decrypt',ex);
            CustomException exc= new CustomException('Utility','Decrypt',ex,false);
           // ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));
        }       
        return decryptedClearText;
    }

    public static ImportResult setERPResponse(Helper.GUMU_Response pGUMU_Response,String STARTAT,String TOTALCOUNT)
    {
        Utility.ImportResult res;
        try
        {
            //TODO:Below codes need to be in common method as it will be a part of all import
            //set the next start index
            if (STARTAT=='')
                STARTAT='1';
            if (TOTALCOUNT=='0' || TOTALCOUNT=='')
                TOTALCOUNT='1';
            
            Integer nextStart=Integer.valueof(STARTAT) + Integer.valueof(TOTALCOUNT);
            //string RETCOUNT=string.valueOf(nextStart-1);
            string RETCOUNT=string.valueOf(TOTALCOUNT);
            STARTAT= string.valueOf(nextStart);
            res= new Utility.ImportResult ();
            if(pGUMU_Response.statusCode=='200')
            {  
                res.ErrorMessage='';
                Utility.PARAM oPARAM = new Utility.PARAM();
                oPARAM.MAXCOUNT     =TOTALCOUNT;
                oPARAM.STARTAT      =STARTAT;
                oPARAM.TOTALCOUNT   =pGUMU_Response.TotalRecord;
                oPARAM.RETCOUNT     =string.valueOf(RETCOUNT);

                if (pGUMU_Response.TotalRecord == '' )
                    oPARAM.HASNEXT          ='0';
                else
                {
                    if(nextStart > Integer.valueof(pGUMU_Response.TotalRecord))
                        oPARAM.HASNEXT      ='0';
                    else
                        oPARAM.HASNEXT      ='1';
                }
                oPARAM.HASPREV      ='';
                res.PARAM=oPARAM;
            }
            else
                res.ErrorMessage=pGUMU_Response.statusMessage;
                
            return res;
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'setERPResponse',ex,false);
            throw ex;
        }       
    }
    

    //Program List for Sage ERP X3 
    public class ProgramList
    {
        //X3 customers
        public string YGTCUSTLIST='YGTCUSTLST';
        public string YGTCUSTDTL='YGTCUSTDTL';
        public string YGTPROSDTL='YGTPROSDTL';

        //X3 product and category
        public string YGTPRODLIST='YGTITMLST';      
        public string YGTPRODCAT='YGTPRODCAT';
        public string YGTITMMST='YGTITMMST';
        public string YGTUOM='YGTUOM';


        //X3 Sync Dropdowns
        public string YGTPAYTRM='YGTPAYTRM';
        public string YGTLANG='YGTLANG';
        public string YGTCURRENCY='YGTCURR';
        public string YGTSALESREP='YGTSALEREP';
        public string YGTERPSITE='YGTERPSITE';
        public string YGTTAXRULE='YGTTAXRULE';
        public string YGTCUSTCAT='YGTCUSTCAT';

        //customer related tabls for list
        public string YGTARINLST='YGTARINLST';
        public string YGTSOLST='YGTSOLST';
        public string YGTSQUOT='YGTSQUOT';
        public string YGTSHPLST='YGTSHPLST';

        //inquiry details 
        public string YGTINVOICE = 'YGTINVOICE';
        public string YGTCRDTDT ='YGTCRDTDT';
        public string YGTBPINDET = 'YGTBPINDET';
        public string YGTORDER='YGTORDER';
        public string YGTQUOTES='YGTQUOTES';
        public string YGTDELIVRY='YGTDELIVRY';

        public string YGTFACILTY='YGTFACILTY';
        public string YGTITMSITE='YGTITMSITE'; 
        //Sales Summary 
        public string YGTSALESLST ='YGTSALERPT'; 
        
        //Contracts
        public string YGTCONTLST ='YGTCONTLST'; 
        public string YGTCONTDET ='YGTCONTDET';
    }   
    
    ////////////Wrapper Classes///////////////////////
    public class ImportResult
    {
        public string ErrorMessage{get;set;}
        public Utility.PARAM Param {get;set;} 
    }

    public class Result
    {
        public PARAM Param {get;set;}
        public string InqList{get;set;}
    }

    public class PARAM 
    {
        public String MAXCOUNT {get;set;}
        public String STARTAT {get;set;}
        public String TOTALCOUNT {get;set;}
        public String RETCOUNT {get;set;}
        public String HASNEXT {get;set;}
        public String HASPREV {get;set;}
    }



    public class ERP
    {
        public string ERPName{get;set;}
        public list<Control> Params{get;set;}
        public list<ImportOption> ImportOptions {get;set;}       
    }

    public class ImportOption
    {
        public string Name{get;set;}
        public string Value{get;set;}
        public string Type{get;set;}
        public list<CriteriaGroup> CriteriaGroups {get;set;}
    }

    public class CriteriaGroup
    {
        public string Name{get;set;}
        public string Label{get;set;}
        public list<Control> Criterias {get;set;} 
    }

    public class Dropdown
    {
        public string Code{get;set;}
        public string Description{get;set;}        
    }

    public class Control
    {
        public string Name{get;set;}
        public string Code{get;set;}
        public integer Length{get;set;}
        public integer Width{get;set;}
        public string ParamType{get;set;}
        public list<string> Options{get;set;}
    }

    public class PageComponent
    {
        public string ComponentType;
        public string Parent;
        public list<object> Value = new List<Object>(); 
        public string ComponentName; 
        public string DataType; 
        public string APIName;
        public string LinkTo; 
        public string ComponentSFId;
        public string KeyField;
        public string KeyValue;
    }
        
    //Function for X3 web service Request and return the response
    public static string requestXML(string requestType, string integrationID,String publicName,String whereClause,String UniqueKey,String UniqueValue, String MAXCOUNT,String STARTAT)
    {
        String strResponse ;
        Dom.Document doc;
        ReadAndWriteXML.XmlNode objXmlNode ;        
        try
        {
            ERP_Config__c oIntegration = [SELECT ERP_System__c,ERP_Company_Code__c,Web_Service_URL__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c FROM ERP_Config__c WHERE ID =: integrationID];

            String EndPoint= oIntegration.Web_Service_URL__c;
            
            String ERPSystemName= oIntegration.ERP_System__c;
            String CompanyCode=oIntegration.ERP_Company_Code__c;
            //Map<String,String> ParamMap = Utility.FormatConnectionPairs(ConnectionInfo);
            Map<String,String> ParamMap = Utility.FormatERPInfo(oIntegration.Integration_Information__c,oIntegration.Integration_Information_2__c,oIntegration.Integration_Information_3__c);
            
            String Password=Decrypt(ParamMap.get('password'));//ParamMap.get('password');
            String UserID=ParamMap.get('codeUser');

            string requestXML = '';
            if(requestType =='Read')
            {
                requestXML +='<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wss="http://www.adonix.com/WSS" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">';
                requestXML +='<soapenv:Header/><soapenv:Body><wss:read soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><callContext xsi:type="wss:CAdxCallContext">';
                requestXML +='<codeLang xsi:type="xsd:string">ENG</codeLang><codeUser xsi:type="xsd:string">'+UserID+'</codeUser><password xsi:type="xsd:string">'+Password+'</password><poolAlias xsi:type="xsd:string">'+CompanyCode+'</poolAlias></callContext>';
                requestXML +='<publicName xsi:type="xsd:string">'+publicName+'</publicName>';
                requestXML +='<objectKeys xsi:type="wss:ArrayOfCAdxParamKeyValue" soapenc:arrayType="wss:CAdxParamKeyValue[1]">';
                requestXML +='<PARAM><key>'+UniqueKey+'</key><value>'+UniqueValue+'</value></PARAM></objectKeys>';
                requestXML +='</wss:read></soapenv:Body></soapenv:Envelope>';
            }
            else if(requestType =='Action')
            {
                requestXML +='<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wss="http://www.adonix.com/WSS">';
                requestXML +='<soapenv:Header/><soapenv:Body><wss:actionObject soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><callContext xsi:type="wss:CAdxCallContext">';
                requestXML +='<codeLang xsi:type="xsd:string">ENG</codeLang><codeUser xsi:type="xsd:string">'+UserID+'</codeUser><password xsi:type="xsd:string">'+Password+'</password><poolAlias xsi:type="xsd:string">'+CompanyCode+'</poolAlias></callContext>';
                requestXML +='<publicName xsi:type="xsd:string">'+publicName+'</publicName>';
                requestXML +='<actionCode xsi:type="xsd:string">V</actionCode>';
                requestXML +='<objectXml xsi:type="xsd:string">'+whereClause+'</objectXml>';
                requestXML +=' </wss:actionObject></soapenv:Body></soapenv:Envelope>';
            }
            else
            {
                requestXML +='<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wss="http://www.adonix.com/WSS">';
                requestXML +='<soapenv:Header/><soapenv:Body><wss:run soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><callContext xsi:type="wss:CAdxCallContext">';
                requestXML +='<codeLang xsi:type="xsd:string">ENG</codeLang><codeUser xsi:type="xsd:string">'+UserID+'</codeUser><password xsi:type="xsd:string">'+Password+'</password><poolAlias xsi:type="xsd:string">'+CompanyCode+'</poolAlias></callContext>';
                requestXML +='<publicName xsi:type="xsd:string">'+publicName+'</publicName>';

                if(requestType =='Run')
                    requestXML +='<inputXml xsi:type="xsd:string"><![CDATA[<?xml version="1.0" encoding="UTF-8"?> <PARAM> <TAB ID="AX_PAR"> <LIN NUM="1"> <FLD NAME="AXPARCOD">$REC_MAX</FLD> <FLD NAME="AXPARVAL">'+MAXCOUNT+'</FLD> </LIN> <LIN NUM="2"> <FLD NAME="AXPARCOD">$REC_STARTAT</FLD> <FLD NAME="AXPARVAL">'+STARTAT+'</FLD> </LIN> <LIN NUM="3"> <FLD NAME="AXPARCOD">$TOTAL_COUNT</FLD> <FLD NAME="AXPARVAL">0</FLD> </LIN> <LIN NUM="4"> <FLD NAME="AXPARCOD">$RET_COUNT</FLD> <FLD NAME="AXPARVAL">0</FLD> </LIN> <LIN NUM="5"> <FLD NAME="AXPARCOD">$HAS_NEXT</FLD> <FLD NAME="AXPARVAL">0</FLD> </LIN> </TAB>'+whereClause+' </PARAM> ]]></inputXml>';
                else
                    requestXML +='<inputXml xsi:type="xsd:string"><![CDATA[<?xml version="1.0" encoding="UTF-8"?>'+whereClause+' ]]></inputXml>';
                requestXML +='</wss:run></soapenv:Body></soapenv:Envelope>';
            }

            system.debug('Request '+requestXML);
            string getResponse='';
            if (Test.isRunningTest())
            {
                 getResponse='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><ns1:runResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://www.adonix.com/WSS"><runReturn href="#id0"/></ns1:runResponse><multiRef id="id0" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns2:CAdxResultXml" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns2="http://www.adonix.com/WSS"><messages soapenc:arrayType="ns2:CAdxMessage[0]" xsi:type="soapenc:Array"/><resultXml xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;RESULT&gt;&lt;TAB DIM=&quot;20&quot; ID=&quot;AX_PAR&quot; SIZE=&quot;5&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$REC_MAX&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;10&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$REC_STARTAT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$TOTAL_COUNT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;221&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$RET_COUNT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;10&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$HAS_NEXT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;TAB DIM=&quot;100&quot; ID=&quot;RES&quot; SIZE=&quot;10&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;New Originals Factory, Best Seller 3 Corner Lines&lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Ciales&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;AD01&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;AB Corp.&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;ABCORP&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;AD02&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;00638&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;4222355656&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;&gt;www.abcorp.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;00638&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Ab Corp Ro&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Ciales&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;4222355656&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151223&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;New Jumeirah Street 052 85th West Avenue&lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Holtsville&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Billing Address&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;ALMEH Companay1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;ALMEH&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;00501&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;&gt;NY&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;1254589658&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;&gt;almeh@gmail.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;&gt;www.almeh.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;&gt;CA&lt;/FLD&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;90013&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;new Street&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Los Angeles&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;7854581236&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151222&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;77, Rua Soba Mandume Vila Alice &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Luanda BTT&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Luanda BTT&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;229090988&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;77, Rua So&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;229879878&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;61, Av.Pedro de C. Van-Dunem Loy &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Ciclo Belas&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Ciclo Belas&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO002&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;219898989&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;61, Av.Ped&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;219999999&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;R. Presidente Marien Ngouabi &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Farm&#xE1;cia Saude e Higiene&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Farm&#xE1;cia Saude e Higiene1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO003&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;229696969&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;R. Preside&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;229879887&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;6&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;52, Rua Alda Lara Vila Alice &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Distribui&#xE7;&#xE3;o Angola Farma&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Distribui&#xE7;&#xE3;o Angola Farma&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO004&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;52, Rua Al&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;219988776&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;7&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;43, Rua da Ambaca &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Super Mar&#xE7;al 1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Supermercados do Mar&#xE7;al&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO005&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;265788009&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;43, Rua da&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;265788000&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;8&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;Estrada do Caxito &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Caxito - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Distribuidora do Caxito&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO006&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;252372979&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Estrada do&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Caxito - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;252372970&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;9&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;Largo Irene Cohen &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;LUANDA - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Brinquedos da Tita&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO007&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Largo Iren&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;LUANDA - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151016&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;10&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;61, Rua Henrique de Carvalho &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;MALANJE - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Angola Industrial&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO008&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;58639&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;58639&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;61, Rua He&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;MALANJE - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151019&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;/RESULT&gt;</resultXml><status xsi:type="xsd:int">1</status><technicalInfos href="#id1"/></multiRef><multiRef id="id1" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns3:CAdxTechnicalInfos" xmlns:ns3="http://www.adonix.com/WSS" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><busy xsi:type="xsd:boolean">false</busy><changeLanguage xsi:type="xsd:boolean">false</changeLanguage><changeUserId xsi:type="xsd:boolean">false</changeUserId><flushAdx xsi:type="xsd:boolean">false</flushAdx><loadWebsDuration xsi:type="xsd:double">0.1238</loadWebsDuration><nbDistributionCycle xsi:type="xsd:int">1</nbDistributionCycle><poolDistribDuration xsi:type="xsd:double">2.2376</poolDistribDuration><poolEntryIdx xsi:type="xsd:int">0</poolEntryIdx><poolExecDuration xsi:type="xsd:double">4104.859</poolExecDuration><poolRequestDuration xsi:type="xsd:double">4107.3992</poolRequestDuration><poolWaitDuration xsi:type="xsd:double">0.2995</poolWaitDuration><processReport xsi:type="xsd:string" xsi:nil="true"/><processReportSize xsi:type="xsd:int">0</processReportSize><reloadWebs xsi:type="xsd:boolean">false</reloadWebs><resumitAfterDBOpen xsi:type="xsd:boolean">false</resumitAfterDBOpen><rowInDistribStack xsi:type="xsd:int">1</rowInDistribStack><totalDuration xsi:type="xsd:double">4160.6443</totalDuration><traceRequest xsi:type="xsd:string" xsi:nil="true"/><traceRequestSize xsi:type="xsd:int">0</traceRequestSize></multiRef></soapenv:Body></soapenv:Envelope>';
            }
            else
                getResponse=Utility.httpRequest(EndPoint,requestXML);
            doc = new Dom.Document();// reading response
            doc.load(getResponse);
            Dom.XMLNode Envelope = doc.getRootElement();       
            Dom.XMLNode Body= Envelope.getChildElements()[0];       


            for(Dom.XMLNode child : Body.getChildElements()) 
            {
                for(Dom.XMLNode subchild : child.getChildElements()) 
                {
                    if(subchild.getName() == 'resultXml')
                    {
                        strResponse = string.valueof(subchild.getText());

                        if(strResponse !=null ||strResponse!='')
                            break;                        
                    }
                    else if(subchild.getName() == 'message' && child.getAttribute('id','')=='id1' && (strResponse ==null ||strResponse==''))
                    {
                        strResponse = string.valueof(subchild.getText());
                        strResponse ='Error '+strResponse;
                        return strResponse;
                    }
                }
            }
        }
        catch(Exception ex)
        {
            system.debug(ex);
        }
        return strResponse;
    }
    
 public static string phoneformat(string phoneFax)
    {   
        string formattedPhone='';
        if(String.isEmpty(phoneFax))
            return formattedPhone;
            
        string rowPhone = phoneFax.replaceall(' ','');
        system.debug('rowPhone '+rowPhone);
        formattedPhone = rowPhone.replaceAll('\\p{P}','');
        system.debug('formattedPhone '+formattedPhone);
        return formattedPhone;
    } 
    
}