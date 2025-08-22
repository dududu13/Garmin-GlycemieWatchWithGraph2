using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;

(:onlyWithSettingOnWatchface)
class GraphSetSourceBG_View extends Ui.View {

    private var larg = System.getDeviceSettings().screenWidth;


    function initialize() {
        View.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.SettingsSourceBG(dc));
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
        var text = ["Nightscout","AAPS","Xdrip"];
        for (var i = 0;i<text.size();i++) {
            var X ;
            var Y ;
            dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
            if (i == sourceBG) {
                X = pc(26);
                Y = pc(20+20*i);
                dc.fillRoundedRectangle(X, Y, pc(48), pc(16), 5);
                dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_TRANSPARENT);
            }
            X = pc(50);
            Y = pc(22+20*i);
            dc.drawText(X,Y,Graphics.FONT_SMALL,text[i],Graphics.TEXT_JUSTIFY_CENTER);

        }
    }


}


(:onlyWithSettingOnWatchface)
class GraphSetSourceBG_Delegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function nigthscout() {
        sourceBG = 0;
        Application.getApp().setProperty("sourceBG",sourceBG);
    }
    function aaps() {
        sourceBG = 1;
        Application.getApp().setProperty("sourceBG",sourceBG);
    }
    function xdrip() {
        sourceBG = 2;
        Application.getApp().setProperty("sourceBG",sourceBG);
    }

    function onBack() as Void {
        return false;
    }
    function back() as Void {
        Ui.popView(0);
    }

    function onSelect() {
        Ui.popView(0);
    }


}

