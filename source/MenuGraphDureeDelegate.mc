
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;


(:onlyWithSettingOnWatchface)
class MenuGraphDureeDelegate extends Ui.BehaviorDelegate {

    var menuView;


    function initialize(menuV) {
    	BehaviorDelegate.initialize();
    	menuView = menuV;
    }

    function onNextPage() {
        menuView.next();
        return true;
    }
    function onPreviousPage() {
        menuView.prev();
       return true;
    }
    function onSelect() {
        nbHGraph = menuView.itemEnCours;
        Application.getApp().setProperty("nbHGraph",nbHGraph);
        System.println("duree = "+nbHGraph);
        WatchUi.popView(WatchUi.SLIDE_LEFT);
    }

}
