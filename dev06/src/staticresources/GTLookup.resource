function openLookup(ControlId,Form,objectPrefix,fldsrch1,fldsrch2,fldshow1,fldshow2,fldshow3,wherefield1,wherefieldvalue1,wherecompareop1,wherefield2,wherefieldvalue2,wherecompareop2)
{                   
        var baseURL;
        
        baseURL = "/apex/GTLookup?obj="+objectPrefix;
        baseURL += "&fldsrch1="+fldsrch1+"&fldsrch2="+fldsrch2;
        baseURL += "&fldshow1="+fldshow1+"&fldshow2="+fldshow2+"&fldshow3="+fldshow3;
        baseURL += "&txt="+ControlId;
        baseURL += "&groupbyfield1=&groupbyfield2=";
        baseURL += "&wherefield1="+wherefield1+"&wherefieldvalue1="+wherefieldvalue1+"&wherecompareop1="+wherecompareop1;
        baseURL += "&wherefield2="+wherefield2+"&wherefieldvalue2="+wherefieldvalue2+"&wherecompareop2="+wherecompareop2;
        baseURL += "&frm="+Form;
        
        var lookup=window.open(baseURL,"mywin","width=675,height=480,screenX=50,left=50,screenY=50,top=50,status=no,menubar=yes,modal=yes");
        lookup.focus(); 
}


function openLookup(ControlId,Form,objectPrefix,fldsrch1,fldsrch2,fldshow1,fldshow2,fldshow3,wherefield1,wherefieldvalue1,wherecompareop1,wherefield2,wherefieldvalue2,wherecompareop2,wherefield3,wherefieldvalue3,wherecompareop3)
{                   
        var baseURL;
        
        baseURL = "/apex/GTLookup?obj="+objectPrefix;
        baseURL += "&fldsrch1="+fldsrch1+"&fldsrch2="+fldsrch2;
        baseURL += "&fldshow1="+fldshow1+"&fldshow2="+fldshow2+"&fldshow3="+fldshow3;
        baseURL += "&txt="+ControlId;
        baseURL += "&groupbyfield1=&groupbyfield2=";
        baseURL += "&wherefield1="+wherefield1+"&wherefieldvalue1="+wherefieldvalue1+"&wherecompareop1="+wherecompareop1;
        baseURL += "&wherefield2="+wherefield2+"&wherefieldvalue2="+wherefieldvalue2+"&wherecompareop2="+wherecompareop2;
        baseURL += "&wherefield3="+wherefield3+"&wherefieldvalue3="+wherefieldvalue3+"&wherecompareop3="+wherecompareop3;
        baseURL += "&frm="+Form;
        
        var lookup=window.open(baseURL,"mywin","width=675,height=480,screenX=50,left=50,screenY=50,top=50,status=no,menubar=yes,modal=yes");
        lookup.focus(); 
}
