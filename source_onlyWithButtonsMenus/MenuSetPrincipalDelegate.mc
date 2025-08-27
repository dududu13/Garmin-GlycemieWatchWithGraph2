
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;

(:onlyWithSettingOnWatchface)
class MenuSetPrincipalDelegate extends Ui.BehaviorDelegate {

    enum {
    seconds,
    graphOrFields,
    graphOrFieldsOptions,
    provenance,
    unites
    }


var _menu_principalview;


    function initialize(menu_principalview) {
    	BehaviorDelegate.initialize();
    	_menu_principalview = menu_principalview;
    }

    
    function onNextPage()    {
    	_menu_principalview.itemEnCours = _menu_principalview.calculeItem0(1);
        Ui.requestUpdate();
    }
    
    function onPreviousPage() 	{
    	_menu_principalview.itemEnCours = _menu_principalview.calculeItem0(-1);
        Ui.requestUpdate();
	}    

    function onBack() {
        WatchApp.onSettingsChanged();
    }


    function onSelect()    {
/*
seconds,
fields,
graphOptions,
provenance */
      	if (_menu_principalview.itemEnCours == provenance) { 
            var position = Application.getApp().getProperty("sourceBG");
            var menuProvenance = new $.MenuView("BG source",
            ["NightScout","AAPS","Xdrip"],position);
            Ui.pushView(menuProvenance, new $.MenuSetSourceBGViewDelegate(menuProvenance),Ui.SLIDE_RIGHT);
      	} else if (_menu_principalview.itemEnCours == seconds) { 
            afficheSecondes = ! afficheSecondes;
            App.getApp().setProperty("afficheSecondes",afficheSecondes);
            var menuSettings =  MenuSetPrincipalDelegate.menuPrincipal(seconds);
            Ui.switchToView(menuSettings, new $.MenuSetPrincipalDelegate(menuSettings),Ui.SLIDE_IMMEDIATE);
            System.println("Set seconds to "+afficheSecondes);
        } else if (_menu_principalview.itemEnCours == graphOrFields)   {
            afficheFields = ! afficheFields;
            App.getApp().setProperty("afficheFields",afficheFields);
            var menuSettings =  MenuSetPrincipalDelegate.menuPrincipal(graphOrFields);
            Ui.switchToView(menuSettings, new $.MenuSetPrincipalDelegate(menuSettings),Ui.SLIDE_IMMEDIATE);
            System.println("afficheFields "+afficheFields);
        } else if (_menu_principalview.itemEnCours == graphOrFieldsOptions)    {
            if (afficheFields) {
                var menuFieldsOptionView = new $.MenuView("Fields options",
                ["Field 1","Field 2","Field 3"],0);
                Ui.pushView(menuFieldsOptionView, new $.MenuSetFieldsOptionsDelegate(menuFieldsOptionView),Ui.SLIDE_RIGHT);
            } else {
                var menuGraphOptionView = new $.MenuView("Graph options",
                ["Linear or Log scale","Duration"],0);
                Ui.pushView(menuGraphOptionView, new $.MenuSetGraphOptionsDelegate(menuGraphOptionView),Ui.SLIDE_RIGHT);
            }
        } else if (_menu_principalview.itemEnCours == unites)    {
            var menuUnitsView = new $.MenuView("Units\nif necessary",
            ["Don't force","Force to mg/l","Force to mmol/l"],units);
            Ui.pushView(menuUnitsView, new $.MenuSetUnitsDelegate(menuUnitsView),Ui.SLIDE_RIGHT);
        } 
        
    }

    public function menuPrincipal(position) {
        var unitStr = ["","(mg/l)","(mmol/l)"][units];
        var tab = [afficheSecondes ? "Set seconds OFF" : "Set seconds ON",
                    afficheFields ?  "Fields-->Graph" : "Graph-->Fields",
                    afficheFields ? "Fields options" : "Graph options",
                    "BG source",
                    "Units "+unitStr];
        return  new $.MenuView("Settings "+WatchUi.loadResource(Rez.Strings.version),tab,position);
    }


}

