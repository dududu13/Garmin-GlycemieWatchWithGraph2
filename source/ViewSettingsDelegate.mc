using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;

(:onlyWithSettingOnWatchface)
class ViewSettingsDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        InputDelegate.initialize();
    }

     function seconds() { 
        afficheSecondes = ! afficheSecondes;
        App.getApp().setProperty("afficheSecondes",afficheSecondes);
        return true;
    }

    function meteo() {
        afficheMeteo = ! afficheMeteo;
        App.getApp().setProperty("afficheMeteo",afficheMeteo);
    }

    function graph() { 
            var settingsDureeGraphView = new $.ViewSettingGraphOptions();
            Ui.pushView(settingsDureeGraphView, new $.ViewSettingGraphOptionsDelegate(),0);
    }

    function back() {
        onBack();
    }

    function sourceBG() { 
        var settingsSourceBGView = new $.ViewSettingSourceBG();
        Ui.pushView(settingsSourceBGView, new $.ViewSettingSourceBGDelegate(),0);
    }


    function onBack() {
        WatchApp.onSettingsChanged();
        Ui.popView(0);
        return true;
    }
    function onSelect() {
        return true;
    }

}


