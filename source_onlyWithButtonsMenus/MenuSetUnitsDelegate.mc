using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;


(:onlyWithSettingOnWatchface)
class MenuSetUnitsDelegate extends Ui.BehaviorDelegate {


var menuView;


    function initialize(menuV) {
    	BehaviorDelegate.initialize();
    	menuView = menuV;
    }

    
    function onNextPage()    {
    	menuView.next();
    }
    
    function onPreviousPage() 	{
    	menuView.prev();
	}    


    function onSelect()    {
        units = menuView.itemEnCours;
        App.getApp().setProperty("units",units);
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        var menuSettings =  MenuSetPrincipalDelegate.menuPrincipal(4);
        switchToView(menuSettings, new $.MenuSetPrincipalDelegate(menuSettings),WatchUi.SLIDE_RIGHT);
    }

}

