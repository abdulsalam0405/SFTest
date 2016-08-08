public with sharing class HomeSettingController {

 
        public String ConfigarationPage {get; set;}
        public String ImportDataPage {get;set;}
        public String SecurityMatrixPage {get;set;}  
        public String LinkAccountPage {get;set;}
        public String UnlinkAccountPage {get;set;} 
        public String MapSalepersonPage{get;set;}   
        public List<AppMenuItem> appMenuItemLst{get;set;}
        
        
        public HomeSettingController ()
        {
        
            ConfigarationPage = 'Configurationlist';
            LinkAccountPage = 'LinkAccount';
            UnlinkAccountPage = 'UnlinkAccount';
            ImportDataPage = 'DemoImportData';
            SecurityMatrixPage= 'SecurityMatrix';
            MapSalepersonPage='SalesPersonMapping';
            appMenuItemLst = new List<AppMenuItem>();
            AppItemMenu();
        
        }
        public void AppItemMenu()
            {
                appMenuItemLst =[Select a.Type,a.StartUrl, a.NamespacePrefix, a.Name,a.Label From AppMenuItem a where Type = 'Tabset'];
            }
}