using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;


(:onlyWithSettingOnWatchface)
class ViewSettingSourceBGDelegate extends Ui.BehaviorDelegate {

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
