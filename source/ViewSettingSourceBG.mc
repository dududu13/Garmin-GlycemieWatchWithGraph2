using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;

(:onlyWithSettingOnWatchface)
class ViewSettingSourceBG extends Ui.View {

    private var coeff;


    function initialize() {
        View.initialize();
        coeff = System.getDeviceSettings().screenWidth/416.0;

    }

    function onResume() {
        Ui.requestUpdate();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.layoutSettingsChoixSourceBG( dc ));
    }
    
    function onUpdate(dc) {
		View.onUpdate( dc );
        dc.setColor(Gfx.COLOR_WHITE,Gfx.COLOR_TRANSPARENT);
        var centre = dc.getHeight() /2 ;
        var Y = dc.getHeight() *  (.2 + sourceBG *.2) + 1;
        dc.fillRoundedRectangle(93*coeff, Y, 237*coeff, 59*coeff, 5);
        dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_TRANSPARENT);
        var text = ["NigthScout","AAPS","Xdrip"][sourceBG]; 
        dc.drawText(centre,Y,Gfx.FONT_MEDIUM,text,Gfx.TEXT_JUSTIFY_CENTER);
    }

}
