using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;

(:onlyWithSettingOnWatchface)
class GraphSetFields_View extends Ui.View {
    private var larg = System.getDeviceSettings().screenWidth;

    public function initialize() {
        View.initialize();

    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.SettingsFields(dc));
    }
    
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);
        dc.clear();
        View.onUpdate(dc);
        dessineCasesActives(dc);
   }

    function pc(val) {
        return (val/100.0*larg).toNumber();
    }

    function dessineCasesActives(dc) {
        for (var i = 0;i<3;i++) {
            var text = ["Field 1","Field 2","Field 3"][i]; 
            var X ;
            var Y ;
            dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
            //if (i == units) {
            //    X = pc(26);
            //    Y = pc(20+20*i);
            //    dc.fillRoundedRectangle(X, Y, pc(48), pc(16), 5);
            //    dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_TRANSPARENT);
            //}
            X = pc(50);
            Y = pc(22+20*i);
            dc.drawText(X,Y,Graphics.FONT_SMALL,text,Graphics.TEXT_JUSTIFY_CENTER);

        }
    }


}

(:onlyWithSettingOnWatchface)
class GraphSetFields_Delegate extends Ui.BehaviorDelegate {

    function initialize() {
        InputDelegate.initialize();
    }

    function field1() { 
        pushMenuField(0);
    }
    function field2() { 
        pushMenuField(1);
    }
    function field3() {
        pushMenuField(2);
    }

    function pushMenuField(numField) {
        var valeurField = WatchView.getProp("field"+(numField+1),[1,2,3][numField]);
        var tabMenu = ["Nothing","Battery","Temperature","Wind speed","Pressure","Altitude","Steps","Distance","Heart rate","Floors climbed","Calories"];
        var fieldOptionsMenuView = new $.MenuView("Field "+(numField+1),tabMenu,valeurField);
        Ui.pushView(fieldOptionsMenuView, new $.MenuSetOneFieldOptionsDelegate(fieldOptionsMenuView,numField),Ui.SLIDE_RIGHT);

    }



    function onBack() {
        back();
    }

    function back() {
        WatchApp.onSettingsChanged();
        Ui.popView(0);
        return true;
    }
    function onSelect() {
        return true;
    }

}





