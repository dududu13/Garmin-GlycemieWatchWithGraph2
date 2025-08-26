using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;


(:onlyWithSettingOnWatchface)
class MenuSetFieldsOptionsDelegate extends Ui.BehaviorDelegate {

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
        var numField = menuView.itemEnCours;
        var valeurField = WatchView.getProp("field"+(numField+1),[1,2,3][numField]);
        var tabMenu = ["Nothing","Battery","Temperature","Wind speed","Pressure","Altitude","Steps","Distance","Heart rate","Floors climbed","Calories"];
        var fieldOptionsMenuView = new $.MenuView("Field "+(numField+1),tabMenu,valeurField);
        Ui.pushView(fieldOptionsMenuView, new $.MenuSetOneFieldOptionsDelegate(fieldOptionsMenuView,numField),Ui.SLIDE_RIGHT);
    }

}

(:onlyWithSettingOnWatchface)
class MenuSetOneFieldOptionsDelegate extends Ui.BehaviorDelegate {

var menuView;
var numField;


    function initialize(menuV,_numField) {
    	BehaviorDelegate.initialize();
    	menuView = menuV;
        numField = _numField;
    }

    
    function onNextPage()    {
    	menuView.next();
    }
    
    function onPreviousPage() 	{
    	menuView.prev();
	}    


    function onSelect()    {
        //System.print("field"+numField+"-->"+menuView.itemEnCours);
        Application.getApp().setProperty("field"+(numField+1),menuView.itemEnCours);
        field1  = WatchView.getProp("field1",1);
        field2  = WatchView.getProp("field2",2);
        field3  = WatchView.getProp("field3",3);
        //System.println("  lecture = "+field1+"  "+field2+"  "+field3);
        Ui.popView(Ui.SLIDE_LEFT);
    }

}

