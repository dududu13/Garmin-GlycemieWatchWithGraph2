using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;


(:onlyWithSettingOnWatchface)
class MenuSetGraphScaleDelegate extends Ui.BehaviorDelegate {

    enum {
    linear,log
    }


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
      	if (menuView.itemEnCours == log) { 
            logarithmique = true;
      	} else if (menuView.itemEnCours == linear) { 
            logarithmique = false;
        } 
        Application.getApp().setProperty("logarithmique",logarithmique);
        System.println("LOGartihm="+logarithmique);
        WatchUi.popView(WatchUi.SLIDE_LEFT);
    }

}

