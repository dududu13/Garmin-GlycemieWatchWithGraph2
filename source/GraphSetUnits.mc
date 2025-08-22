using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;

(:onlyWithSettingOnWatchface)
class GraphSetUnits_View extends Ui.View {
    private var larg = System.getDeviceSettings().screenWidth;

    public function initialize() {
        View.initialize();

    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.SettingsUnits(dc));
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
            var text = ["Don't force","mg/l","mmol/l"][i]; 
            var X ;
            var Y ;
            dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
            if (i == units) {
                X = pc(26);
                Y = pc(20+20*i);
                dc.fillRoundedRectangle(X, Y, pc(48), pc(16), 5);
                dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_TRANSPARENT);
            }
            X = pc(50);
            Y = pc(22+20*i);
            dc.drawText(X,Y,Graphics.FONT_SMALL,text,Graphics.TEXT_JUSTIFY_CENTER);

        }
    }


}

(:onlyWithSettingOnWatchface)
class GraphSetUnits_Delegate extends Ui.BehaviorDelegate {

    function initialize() {
        InputDelegate.initialize();
    }

     function dontforce() { 
        units = 0;
        App.getApp().setProperty("units",units);
    }
     function forcemgl() { 
        units = (units == 1) ? 0 : 1;
        App.getApp().setProperty("units",units);
    }

    function forcemmol() {
        units = (units == 2) ? 0 : 2;
        App.getApp().setProperty("units",units);
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





