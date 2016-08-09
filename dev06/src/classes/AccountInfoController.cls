//This is a Customer class which will connect to the integration controller.
global with sharing class AccountInfoController{

    public Account ERPAccount {get;set;}
    list<Data_Page__c> DataPagesList;

    //Navigation properties
    public integer startIndex {get;set;}       
    public integer selectedPagesize {get;set;}      
    public string  status {get; set;}
    public integer endIndex {get; set;}
    public integer totalcount {get; set;}

    //Data Page related variables
    public transient Component.Apex.PageBlock CustomerEnquiryPage  {get;set;}
    public transient Component.Apex.PageBlock FilterSection     {get;set;}
    //Writing test Code for GIT Testing Verison 1
    public string ChildInquiry  {get; set;}
    public string ChildField    {get;set;}
    public string ChildValue    {get;set;}

    public String ParentText {get;set;}
    public Boolean bShowParentURL{get;set;}
    public String ProfileName {get;set;} 

    public list<map<string,string>> ParentLinkList ;

    private static final string ClassName='AccountInfoController';
    public boolean InactiveIntegration {get;set;}
    public boolean ShowERPDetails {get;set;}
    public string IntegrationName{get;set;}
    
    public string IntegrationId{get;set;}
    
    //Constructor Defination
    public AccountInfoController(ApexPages.StandardController controller) {
        try
        {
            //Intialize variables
            ParentLinkList = new list<map<string,string>> ();
            startIndex = 1;
            selectedPagesize = 5;
            
            if (!Schema.sObjectType.Data_Page__c.fields.Name.isAccessible()||!Schema.sObjectType.Data_Page__c.fields.Create_Tab__c.isAccessible()
                ||!Schema.sObjectType.Data_Page__c.fields.Default__c.isAccessible()||!Schema.sObjectType.Data_Page__c.fields.Description__c.isAccessible()
                ||!Schema.sObjectType.Data_Page__c.fields.ERP_Function__c.isAccessible() ||!Schema.sObjectType.Data_Page__c.fields.ERP_System__c.isAccessible()
                ||!Schema.sObjectType.Data_Page__c.fields.Filter_Field__c.isAccessible() ||!Schema.sObjectType.Data_Page__c.fields.Sort_Order__c.isAccessible()
                ||!Schema.sObjectType.Data_Page__c.fields.Type__c.isAccessible() ||!Schema.sObjectType.Data_Page__c.fields.Entity_Id__c.isAccessible()
                )
            {
              return ;
            }
            
            if (!Schema.sObjectType.Account.fields.ERP_Customer_Number__c.isAccessible()
            ||!Schema.sObjectType.Account.fields.Integration_Key__c.isAccessible())
            {
              return ;
            }
            
            if (!Schema.sObjectType.ERP_Config__c.fields.Inactive__c.isAccessible()
            ||!Schema.sObjectType.ERP_Config__c.fields.ERP_System__c.isAccessible())
            {
              return ;
            }
            
            if(UserInfo.getProfileId() != '' && UserInfo.getProfileId() != null) 
            {
                // Check if the user has read access on the Profile.name
                if (Schema.sObjectType.Profile.fields.name.isAccessible()) {
                    ProfileName = [select name from profile where id =: UserInfo.getProfileId() limit 1].name;
                }
            }

            //Check have access
            Security_Matrix__c SM = Security_Matrix__c.getInstance();
            ShowERPDetails = Boolean.valueOf(SM.ERP_Details__c);

            string AccountId= ApexPages.currentPage().getParameters().get('Id');  
            if( AccountId != null)
                this.ERPAccount =[select Id,ERP_Customer_Number__c,Integration_Key__c from Account where Id=:AccountId LIMIT 1];
              
            
            list<ERP_Config__c> oIntegration = new list<ERP_Config__c>();
            DataPagesList = new list<Data_Page__c>();
            if(this.ERPAccount.Integration_Key__c != null && this.ERPAccount .Integration_Key__c != '') 
            {    
                oIntegration = [SELECT Id,ERP_System__c, Inactive__c FROM ERP_Config__c WHERE ID =: this.ERPAccount.Integration_Key__c LIMIT 1];
                if(oIntegration.size()>0)
                {
                    InactiveIntegration = Boolean.valueOf(oIntegration[0].Inactive__c);
                    IntegrationId = oIntegration[0].Id;
                    IntegrationName = oIntegration[0].ERP_System__c;
                    DataPagesList =[select Id,Name,Name__c,Description__c,Filter_Field__c from Data_Page__c where Create_Tab__c = true and Integration_Key__c=:IntegrationId Order By Sort_Order__c LIMIT 20];
                }
            }         
            ShowDefaultPage();
        }
        catch(Exception ex) 
        {
            CustomException exc= new CustomException(ClassName,'AccountInfoController',ex,true);
        }
             
    }

    /*This is for showing Inquiry list*/
    public Component.Apex.OutputPanel GetInquiryLinks()
    {
        Component.Apex.OutputPanel LinkPanel;
        try
        {
            if( ERPAccount != null)
            {
                LinkPanel=new Component.Apex.OutputPanel();
                Component.Apex.outputLink link;
                Component.Apex.outputText outText;
                Component.Apex.outputText outTextSeperator;

                integer iCounter = 0;
              //  ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info,'DataPagesList '+ DataPagesList));
                if(DataPagesList.size()>0)
                {
                    for(Data_Page__c DataPage : DataPagesList )
                    {
                        if(iCounter > 0) 
                        {
                            outTextSeperator = new Component.Apex.outputText(value='  |  ');
                            LinkPanel.childComponents.add(outTextSeperator);
                        }
    
                        link = new Component.Apex.outputLink(value='javascript:void(0);',onclick='fncRefreshEnquiryTab(\''+ DataPage.Name +'\',\''+ DataPage.Filter_Field__c +'\',\''+ this.ERPAccount.ERP_Customer_Number__c   +'\')', title= DataPage.Name__c,style='text-align: center;padding-left: 4px;padding-right: 4px;font-size: 90%;');                                
                        outText = new Component.Apex.outputText(value=DataPage.Name__c);
                        link.childComponents.add(outText);
                        LinkPanel.childComponents.add(link);
                        iCounter++;   
                    }
                }
            }
            return LinkPanel;
        }
        catch(Exception ex) 
        {
            CustomException exc= new CustomException(ClassName,'GetInquiryLinks',ex,true);
        }
        return LinkPanel;
    }

    /*This funciton is used to show default page*/
    public void ShowDefaultPage() 
    { 
        String ERPSystemName='';
        //String IntegrationId='';
        String IntegrationKey='';
        String UniqueKey='';
        string AccountType='';
        string KeyName='';
        string DataPageName='';
        CustomerEnquiryPage= new Component.Apex.PageBlock();
        try
        {
            if (this.ERPAccount.id != null) 
            {
                list<Data_Page__c> DefaultDataPage =[select Id,Name,Name__c,Description__c,Filter_Field__c from Data_Page__c where Create_Tab__c = true and Default__c = true and Integration_Key__c=:IntegrationId LIMIT 20];

                if (DefaultDataPage.size()>0)
                {       
                    DataPageName=DefaultDataPage[0].Name; 
                    KeyName=DefaultDataPage[0].Filter_Field__c;
                    
                    if (string.IsBlank(KeyName))
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info,'Please check Filter Field in default Data Page '+ DefaultDataPage[0].Name + ' .'));
                    else
                    {
                        ChildInquiry=DataPageName;
                        ChildField=KeyName;
                        ChildValue=this.ERPAccount.ERP_Customer_Number__c;
                        system.debug('ShowDataPage');
                        ShowDataPage();
                    } 
                } 
                else
                    ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Default Data Page not defined.'));
            }   
        }
        catch(Exception ex) 
        {
            CustomException exc= new CustomException(ClassName,'ShowDefaultPage',ex,true);
        }
    }

    /*Method to display Customer's Enquiries*/
    public void getCustomerEnquiries(string DataPageName) 
    {
         
        string ERPSystemName='';
        //string IntegrationId='';
        string IntegrationKey='';
        string UniqueKey='';
        string AccountType='';
        CustomerEnquiryPage= new Component.Apex.PageBlock();
        try
        {
            if (this.ERPAccount.id != null ) 
            {
                String index= String.valueOf(startIndex);
                String maxcount= String.valueOf(selectedPagesize);

                if (bShowParentURL==true)
                {
                    index='1';
                    maxcount='1';
                }
                        
                        if (Apexpages.currentPage().getParameters().get('KeyValue')  !=  null  && Apexpages.currentPage().getParameters().get('KeyField') !=  null && 
                            Apexpages.currentPage().getParameters().get('KeyValue')  != 'null' && Apexpages.currentPage().getParameters().get('KeyField') != 'null'  )
                         {
                            if (bShowParentURL==false)
                                endIndex = startIndex + selectedPagesize - 1;
                            
                            Helper.GUMU_UIResponse GUMU_UIResponse = new Helper.GUMU_UIResponse();
                            if(Test.isRunningTest()) 
                            {
                                GUMU_UIResponse.TotalRecordsCount = 1;
                            }
                            else
                            {
                                system.debug('DataPageName1 '+DataPageName);
                                system.debug('ERPAccount.Id1 '+this.ERPAccount.Id);
                                system.debug('KeyField '+Apexpages.currentPage().getParameters().get('KeyField'));
                                system.debug('KeyValue '+Apexpages.currentPage().getParameters().get('KeyValue'));
                                GUMU_UIResponse=Helper.getCustomerEnquiryPage(DataPageName,this.ERPAccount.Id ,Apexpages.currentPage().getParameters().get('KeyField') ,Apexpages.currentPage().getParameters().get('KeyValue'),startIndex,endindex,maxcount);
                            }
                            system.debug('GUMU_UIResponse '+GUMU_UIResponse);
                            /*if(GUMU_UIResponse.statusCode =='100')
                            {   
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Unable to connect ERP System. please check the connection'));          
                            }
                            else if(GUMU_UIResponse.responseERPData.contains('Service Temporarily Unavailable'))
                            {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Service Temporarily Unavailable.please check the Services.'));
                            }*/
                            
                            CustomerEnquiryPage =GUMU_UIResponse.UIContent;
                            totalcount =GUMU_UIResponse.TotalRecordsCount;
                            if (totalcount >0 )
                                displayStatus();
                            else
                            {
                                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info,'No records found!'));
                                status= 'No records found!';
                            } 
                        }
                        else
                            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info,'Please check Filter Field in Data Page '+ DataPageName + ' .'));                  
            }
        } 
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'getCustomerEnquiries',ex,true);
        }
    }
    
    /*Method to update the page size*/
    public void updatePagesize()
    {
        try
        { 
            startIndex=1;
            map<string,string> QueryParams= ParentLinkList[ParentLinkList.size()-1];
            SetPageParams(QueryParams.get('Inquiry'),QueryParams.get('KeyField'),QueryParams.get('KeyValue')); 
            RefreshList();
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'updatePagesize',ex,true);
        }    
    }

    /*Method to show the status of list record*/ 
    public void displayStatus()
    {   
        try
        {
            if(endIndex > totalcount)
                status= 'Showing ' + startIndex + ' - '+ totalcount+ ' of '+ totalcount +' records';    
            else
                status= 'Showing ' + startIndex + ' - '+ endIndex + ' of '+ totalcount +' records';
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'displayStatus',ex,true);
        }   
    }

    /*Method to update startindex & navigate to Next records*/
    public void navigateNext()
    {
        try
        {
            map<string,string> QueryParams= ParentLinkList[ParentLinkList.size()-1];
            SetPageParams(QueryParams.get('Inquiry'),QueryParams.get('KeyField'),QueryParams.get('KeyValue'));   
            startIndex = startIndex + selectedPagesize;
            RefreshList();
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'navigateNext',ex,true);
        }
    }


    /*Method to update startindex & navigate to previous records*/
    public void navigatePrevious()
    {
        try
        {   
            map<string,string> QueryParams= ParentLinkList[ParentLinkList.size()-1];
            SetPageParams(QueryParams.get('Inquiry'),QueryParams.get('KeyField'),QueryParams.get('KeyValue'));        
            startIndex = startIndex - selectedPagesize;
            RefreshList();
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'navigatePrevious',ex,true);
        }
    }

    /*Method to refresh selected tab/datapage*/
    public void RefreshList()
    {
        try
        {       
            map<string,string> QueryParams= ParentLinkList[ParentLinkList.size()-1];
            getCustomerEnquiries(QueryParams.get('Inquiry'));
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'CustomException',ex,true);
        }
    }

    /*Method to refresh all page header contents*/
    public void ShowDataPage() 
    {
        try
        {    
            system.debug('1');           
            startIndex = 1;
            ParentLinkList = new list<map<string,string>> ();
            AddParentLinkInfo(ChildInquiry,ChildField,ChildValue);
            bShowParentURL=false;
            SetPageParams(ChildInquiry,ChildField,ChildValue);
            getCustomerEnquiries(ChildInquiry); 
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'ShowDataPage',ex,true);
        }
    }  

    /*Method to show the detail link*/
    public void displayDetail() 
    {
        try 
        {               
            map<string,string> LastPartent=ParentLinkList[ParentLinkList.size()-1];
            ParentText= ChildField + '('+ ChildValue  +')';  //LastPartent.get('KeyField')  LastPartent.get('KeyValue')
           // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info,'LastPartent'+ LastPartent.get('KeyField') +'ParentLinkList:'+ParentLinkList));
            SetPageParams(ChildInquiry,ChildField,ChildValue);
            bShowParentURL=true;
            system.debug('ChildInquiry '+ChildInquiry);
            system.debug('ChildField '+ChildField);
             system.debug('ChildValue '+ChildValue);
            
            AddParentLinkInfo(ChildInquiry,ChildField,ChildValue);
            getCustomerEnquiries(ChildInquiry); 
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'displayDetail',ex,true);
        }
    }  

    /*Method to return to the Parent level*/
    public void BackToParent() 
    {
        try
        {
            ParentLinkList.remove(ParentLinkList.size()-1); 
            if (ParentLinkList.size()==1)
                bShowParentURL=false;
            else
            {
                map<string,string> SecLastPartent=ParentLinkList[ParentLinkList.size()-2];
                ParentText=SecLastPartent.get('KeyField') + '('+  SecLastPartent.get('KeyValue') +')'; 
            }  

            map<string,string> LastPartent=ParentLinkList[ParentLinkList.size()-1];
            SetPageParams(LastPartent.get('Inquiry'),LastPartent.get('KeyField'),LastPartent.get('KeyValue'));
            getCustomerEnquiries(LastPartent.get('Inquiry')); 
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'BackToParent',ex,true);
        }
    }  


    /*Method to refresh all page header contents*/
    private void AddParentLinkInfo(string pDataPage,string pKeyField,string pKeyValue) 
    {
        try
        {
            map<string,string> ParentLink= new  map<string,string>();
            ParentLink.put('Inquiry',pDataPage);
            ParentLink.put('KeyField',pKeyField);
            ParentLink.put('KeyValue',pKeyValue);
            ParentLink.put('Id',this.ERPAccount.Id);
            ParentLinkList.Add(ParentLink);  
            system.debug('ParentLinkList '+ParentLinkList); 
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'AddParentLinkInfo',ex,true);
        }
    } 

    /*Method to set parameter of page*/
    private void SetPageParams(string pDataPage,string pKeyField,string pKeyValue) 
    {
        try
        {
            Apexpages.currentPage().getParameters().put('Inquiry',pDataPage) ; 
            Apexpages.currentPage().getParameters().put('KeyField',pKeyField) ;
            Apexpages.currentPage().getParameters().put('KeyValue',pKeyValue) ;
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'SetPageParams',ex,true);
        }
    } 

}