
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics;
using Toybox.Application as App;
import Toybox.Lang;

(:onlyWithSettingOnWatchface)
class ViewSettingGraphOptionsDelegate extends WatchUi.BehaviorDelegate {

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