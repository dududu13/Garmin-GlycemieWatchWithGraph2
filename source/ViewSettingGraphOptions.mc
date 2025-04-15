using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics;
using Toybox.Application as App;
import Toybox.Lang;

(:onlyWithSettingOnWatchface)
class ViewSettingGraphOptions extends WatchUi.View {
    private var coeff;
    private var larg = System.getDeviceSettings().screenWidth;


    public function initialize() {
        View.initialize();
    }

    public function onLayout(dc as Graphics.Dc) as Void {
        setLayout(Rez.Layouts.layoutSettingsHeuresGraph(dc));
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
        var width = dc.getHeight() ;
        var Y = pc(28);
        var X = pc(5+nbHGraph*24);
        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(X, Y, pc(18), pc(16), 5);
        dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_TRANSPARENT);
        X = pc(8+nbHGraph*24);
        Y = pc(30);
        var text = ["1 h","2 h","4 h","6h"][nbHGraph]; 
        dc.drawText(X,Y,Graphics.FONT_SMALL,text,Graphics.TEXT_JUSTIFY_LEFT);

        X= logarithmique ? pc(20) : pc(55);
        Y = pc(58);
        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(X,Y, pc(25), pc(16), 5);
        X = logarithmique ? pc(32) : pc(68);
        text = logarithmique ? "log" : "linear";
        dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_TRANSPARENT);
        dc.drawText(X,pc(60),Graphics.FONT_SMALL,text,Graphics.TEXT_JUSTIFY_CENTER);
     }


}

