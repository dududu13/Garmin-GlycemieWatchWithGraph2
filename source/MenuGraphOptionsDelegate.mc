using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;


(:onlyWithSettingOnWatchface)
class MenuGraphOptionsDelegate extends Ui.BehaviorDelegate {

enum {
log,
duree
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
            var position = logarithmique ? 1 : 0;
            var menuLog = new $.MenuView("Scale type",
            ["Linear","Logarithm"],position);
            Ui.pushView(menuLog, new $.MenuGraphScaleDelegate(menuLog),Ui.SLIDE_RIGHT);
      	} else if (menuView.itemEnCours == duree) { 
            var position = Application.getApp().getProperty("nbHGraph");
            var menuDureeGraphView = new $.MenuView("Graph hours",
            ["1 h","2 h","4 h","6 h"],position);
            Ui.pushView(menuDureeGraphView, new $.MenuGraphDureeDelegate(menuDureeGraphView),Ui.SLIDE_RIGHT);
        } 
        Ui.requestUpdate();
    }

}

