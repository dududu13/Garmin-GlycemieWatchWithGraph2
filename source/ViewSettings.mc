using Toybox.WatchUi as Ui;
using Toybox.System;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;

(:onlyWithSettingOnWatchface)
class ViewSettings extends Ui.View {
    var caseAcocher;

    public function initialize() {
        View.initialize();
        caseAcocher = Ui.loadResource(Rez.Drawables.Coche);
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.Settings(dc));
    }
    
    function onUpdate(dc) {
		View.onUpdate( dc );
        var drawable = View.findDrawableById("choixSource");
        drawable.setText("Source " + ((sourceBG == 0) ? "(NS)" : (sourceBG ==1) ? "(AAPS)" : "(Xdrip)"));
        dessineCoches(dc);
   }

   function dessineCoches(dc) {
         var X = dc.getHeight() *  .68  ;
        var tab = [afficheSecondes, afficheMeteo, ! afficheMeteo];
        for (var i=0;i<3;i++) {
            if (tab[i]) {
                var Y = dc.getHeight() *  (.14 + i *.15) ;
                dc.drawBitmap(X, Y, caseAcocher);
            }
        }
   }


 }


