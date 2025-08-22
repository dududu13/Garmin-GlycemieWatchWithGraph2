using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;



(:onlyWithSettingOnWatchface)
class MenuSetSourceBGViewDelegate extends Ui.BehaviorDelegate {

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
        sourceBG = menuView.itemEnCours;
        Application.getApp().setProperty("sourceBG",sourceBG);
        WatchUi.popView(WatchUi.SLIDE_LEFT);
    }

}
