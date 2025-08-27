using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics;
using Toybox.Application as App;
import Toybox.Lang;

(:onlyWithSettingOnWatchface)
class GraphSetGraphOptions_view extends WatchUi.View {
    private var larg = System.getDeviceSettings().screenWidth;


    public function initialize() {
        View.initialize();
    }

    public function onLayout(dc as Graphics.Dc) as Void {
        setLayout(Rez.Layouts.SettingsGraphOptions(dc));
    }
    public function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);
        dc.clear();
        View.onUpdate(dc);
        dessineCasesActives(dc);
    }


    function pc(val) {
        return (val/100.0*larg).toNumber();
    }

    function dessineCasesActives(dc) {
        for (var i = 0;i<4;i++) {
            var text = ["1 h","2 h","4 h","6h"][i]; 
            var X ;
            var Y ;
            dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
            if (i == nbHGraph) {
                X = pc(5+i*24);
                Y = pc(28);
                dc.fillRoundedRectangle(X, Y, pc(18), pc(16), 5);
                dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_TRANSPARENT);
            }
            X = pc(8+i*24);
            Y = pc(30);
            dc.drawText(X,Y,Graphics.FONT_SMALL,text,Graphics.TEXT_JUSTIFY_LEFT);

        }
        for (var i = 0;i<2;i++) {
            var text = ["log","linear"][i]; 
            var X ;
            var Y ;
            dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
            if (((i==0) && (logarithmique)) ||((i == 1) &&(! logarithmique))) {
                X = pc(20+35*i);
                Y = pc(63);
                dc.fillRoundedRectangle(X,Y, pc(25), pc(16), 5);
                dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_TRANSPARENT);
            }
            X = pc(32+35*i);
            Y = pc(65);
            dc.drawText(X,Y,Graphics.FONT_SMALL,text,Graphics.TEXT_JUSTIFY_CENTER);

        }
    }


}


(:onlyWithSettingOnWatchface)
class GraphSetGraphOptions_Delegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        
        BehaviorDelegate.initialize();

    }

    function onBack() as Void {
        return false;
    }

    function UN() {
        setHeures(0);
    }
    function DEUX() {
        setHeures(1);
    }
    function QUATRE() {
        setHeures(2);
    }
    function SIX() {
        setHeures(3);
    }
    function setHeures(nbre) {
        nbHGraph = nbre;
        Application.getApp().setProperty("nbHGraph",nbre);
    }

    function LOG() {
        logarithmique = true;
        Application.getApp().setProperty("logarithmique",logarithmique);
    }
    function LINEAR() {
        logarithmique = false;
        Application.getApp().setProperty("logarithmique",logarithmique);
        
    }
    function back() {
        WatchUi.popView(0);
        return true;
    }
}

