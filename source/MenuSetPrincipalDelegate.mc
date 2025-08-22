
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;

(:onlyWithSettingOnWatchface)
class MenuSetPrincipalDelegate extends Ui.BehaviorDelegate {

    enum {
    seconds,
    meteo,
    graphOptions,
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
meteo,
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
            var menuSettings =  WatchApp.menuPrincipal(seconds);
            Ui.switchToView(menuSettings, new $.MenuSetPrincipalDelegate(menuSettings),Ui.SLIDE_IMMEDIATE);
            System.println("Set seconds to "+afficheSecondes);
        } else if (_menu_principalview.itemEnCours == meteo)   {
            afficheMeteo = ! afficheMeteo;
            App.getApp().setProperty("afficheMeteo",afficheMeteo);
            var menuSettings =  WatchApp.menuPrincipal(meteo);
            Ui.switchToView(menuSettings, new $.MenuSetPrincipalDelegate(menuSettings),Ui.SLIDE_IMMEDIATE);
            System.println("afficheMeteo "+afficheMeteo);
        } else if (_menu_principalview.itemEnCours == graphOptions)    {
            var menuGraphOptionView = new $.MenuView("Graph options",
            ["Linear or Log scale","Duration"],0);
            Ui.pushView(menuGraphOptionView, new $.MenuSetGraphOptionsDelegate(menuGraphOptionView),Ui.SLIDE_RIGHT);
        } else if (_menu_principalview.itemEnCours == unites)    {
            var menuUnitsView = new $.MenuView("Units\nif necessary",
            ["Don't force","Force to mg/l","Force to mmol/l"],units);
            Ui.pushView(menuUnitsView, new $.MenuSetUnitsDelegate(menuUnitsView),Ui.SLIDE_RIGHT);
        } 
        
    }

}

