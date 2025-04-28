
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Application;



class WatchView extends Ui.WatchFace {

    public var valeursCapteur = new[3];
    const prov = ["NS","AAPS","Xd"];  
    var BTlogo = WatchUi.loadResource(Rez.Drawables.blueTooth);  
    
    var graph;
    var tabData = new[0];
    var AffichageBgValue =0;
    var AffichageSecondesCapteur = Time.now().value()- 99*60; 
    var AffichageBgDelta = 0;

    var decalageY_OLED = 0;


	var inLowPower=false;
    var largeurEcran = System.getDeviceSettings().screenWidth;
    var hauteurEcran = System.getDeviceSettings().screenHeight;//dc.getHeight();;
    var OledModel  = Sys.getDeviceSettings().requiresBurnInProtection; 

    var lastBG;
    var nowSec = 0;

var x = {
"date"=>(0.5 * largeurEcran),
"heure"=>(0.5 * largeurEcran),
"notif"=>(0.12 * largeurEcran),
"BG"=>(0.75 * largeurEcran),
"Delta"=>(0.24 * largeurEcran),
"Elapsed"=>(0.96 * largeurEcran),
"sourceBG"=>(0.02 * largeurEcran),
"Secondes"=>(0.96 * largeurEcran),
"NextCall"=>(0.25 * largeurEcran),
"Temperature"=>(0.17 * largeurEcran),
"Wind"=>(0.83 * largeurEcran),
"Batterie"=>(0.5 * largeurEcran),
"labelMin"=>(0.93 * largeurEcran),
};

var y = {
"date"=>(0.127 * hauteurEcran),
"heure"=>0.315 * hauteurEcran,
"notif"=>0.392 * hauteurEcran,
"BG"=>0.582 * hauteurEcran,
"Delta"=>0.6 * hauteurEcran,
"Elapsed"=>0.545 * hauteurEcran,
"sourceBG"=>0.49 * hauteurEcran,
"Secondes"=>0.356 * hauteurEcran,
"NextCall"=>0.49 * hauteurEcran,
"Temperature"=>0.78 * hauteurEcran,
"Wind"=>0.78 * hauteurEcran,
"Batterie"=>0.92 * hauteurEcran,
"labelMin"=>0.66 * hauteurEcran,
};

var font = {
"date"=>Gfx.FONT_LARGE,
"heure"=>Gfx.FONT_NUMBER_HOT,
"notif"=>Gfx.FONT_MEDIUM,
"BG"=>Gfx.FONT_NUMBER_HOT,
"Delta"=>Gfx.FONT_NUMBER_MILD,
"Elapsed"=>Gfx.FONT_NUMBER_MILD,
"sourceBG"=>Gfx.FONT_XTINY,
"Secondes"=>Gfx.FONT_NUMBER_MILD,
"NextCall"=>Gfx.FONT_XTINY,
"Temperature"=>Gfx.FONT_LARGE,
"Wind"=>Gfx.FONT_LARGE,
"Batterie"=>Gfx.FONT_LARGE,
"labelMin"=>Gfx.FONT_XTINY,
};

var justification = {
"date"=>Gfx.TEXT_JUSTIFY_CENTER,
"heure"=>Gfx.TEXT_JUSTIFY_CENTER,
"notif"=>Gfx.TEXT_JUSTIFY_CENTER,
"BG"=>Gfx.TEXT_JUSTIFY_RIGHT,
"Delta"=>Gfx.TEXT_JUSTIFY_RIGHT,
"Elapsed"=>Gfx.TEXT_JUSTIFY_RIGHT,
"sourceBG"=>Gfx.TEXT_JUSTIFY_LEFT,
"Secondes"=>Gfx.TEXT_JUSTIFY_RIGHT,
"NextCall"=>Gfx.TEXT_JUSTIFY_RIGHT,
"Temperature"=>Gfx.TEXT_JUSTIFY_LEFT,
"Wind"=>Gfx.TEXT_JUSTIFY_RIGHT,
"Batterie"=>Gfx.TEXT_JUSTIFY_CENTER,
"labelMin"=>Gfx.TEXT_JUSTIFY_RIGHT,
};

    var coeff=largeurEcran/416.0;
    var centreEcran = hauteurEcran/2;
    var separationLine = 190;
    var separationLine2 = 294;

    var white = Gfx.COLOR_WHITE;
    var trans = Gfx.COLOR_TRANSPARENT;

    

    function initialize() {
        
        WatchFace.initialize();
        System.println("View debut init");
        readSettingsAndInitGraph();
        System.println("View fin init");    

    }

    function onLayout(dc) {
   }


    function onExitSleep() {
        inLowPower = false;
    }


    function onEnterSleep() {
    	inLowPower = true;
       	WatchUi.requestUpdate(); 
    }


    function onUpdate(dc) {
        var timeNow = Time.now();
        if (WatchBG.isCapteurChanged()) {
            tabData = WatchBG.readAlldData();
            var size = tabData.size();
            if (size >0) {
                AffichageBgValue = tabData[size-1][0];
                AffichageBgDelta = tabData[size-1][1];
                AffichageSecondesCapteur = tabData[size-1][2];
                                
            }
            WatchBG.setCapteurChanged(false);
        }
        
        var infoTime = Calendar.info(timeNow, Time.FORMAT_LONG);
		dc.setColor( Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();

        drawMeteoIfNotLowPower(dc);
        drawDeltaValue(dc);
        drawClock(dc,infoTime);
        drawElapsedTime(dc);
        drawBG(dc);
        drawNotifs(dc);
        drawDate(dc,infoTime);    
        barreBGsiBesoin(dc);
        drawGraphIfNotLowPower(dc);
        drawBatterieAnalog(dc);
        drawDeltaCadre(dc);
        drawBlueTooth(dc,infoTime);        
		ereaseOLEDifLowPower(dc);
        var nextBG = drawNextCall(dc);
        if (lastBG == null) {
            lastBG = nextBG -1;
        }
        //System.println("onUpdate nextBG = "+nextBG + "  lastBG = "+lastBG);
        if ((nextBG == lastBG) and (timeNow.value != nowSec)) { //lors de l'init on a 2 update au meme moment
            //System.println("onUpdate call registerASAP()");
            //Background.registerASAP(); 
        }
        lastBG = nextBG;
        nowSec = timeNow.value;


    }

    public function drawLabel(dc,labelId, labelText,color)  {
        dc.setColor(color,trans);
        if ((labelText !=null) and (x.get(labelId) != null)) {
            dc.drawText(x.get(labelId),y.get(labelId),font.get(labelId),labelText,justification.get(labelId)+Gfx.TEXT_JUSTIFY_VCENTER);
        }
    }

    function drawClock(dc,info) {
        dc.setColor(white,trans);
        var timeString = Lang.format("$1$:$2$", [info.hour, info.min.format("%02d")]);
        drawLabel(dc,"heure", timeString,white);
        var texte="";
        if (afficheSecondes ){
            texte = info.sec.format("%02d");
            drawLabel(dc,"Secondes",texte,white);
       }    
    }

    function prochainBackground() {
        var prochainBackground = Background.getTemporalEventRegisteredTime();// Time.Moment or Time.Duration or Null
        var delaiRestant = 0;
        if (prochainBackground == null) {
            System.println("prochainBackground null, registerasap");
            delaiRestant = 3;
            WatchBG.registerASAP();
        } else { 
            if (prochainBackground.compare(Time.now())<0) {
                System.println("prochainBackground < now, registerasap");
                WatchBG.registerASAP();
                delaiRestant = 3;
            } else {
                delaiRestant = prochainBackground.value()-Time.now().value();
            }
        }
        return delaiRestant;
    }

    function drawNextCall(dc) {
        var _nextBG = prochainBackground();
        drawLabel(dc,"NextCall",_nextBG,white);
        return _nextBG;
    }

    function coordMarkBattery(angle){
        var Coord = [[0,195*coeff],[0,205*coeff]];
        angle = Math.toRadians(angle);
        var cos = Math.cos((angle) * Math.PI /180.0);
        var sin = Math.sin((angle) * Math.PI /180.0);
        cos = Math.cos(angle);
        sin = Math.sin(angle);
        var x,y;
        var tabLines = new[0];

        for (var i = 0; i < Coord.size(); i ++) { 
            x = centreEcran+((Coord[i][0] * cos) + (Coord[i][1] * sin));
            y = centreEcran+((Coord[i][0] * sin) - (Coord[i][1] * cos));
            tabLines.add([x.toNumber(),y.toNumber()]);
        }
        return tabLines;
    }

    function drawBatterieAnalog(dc) {
        var batterie = Sys.getSystemStats().battery;
        var colorBatt = Gfx.COLOR_RED; //rouge
        if (batterie >10 ) {colorBatt = Gfx.COLOR_ORANGE;} //orange
        if (batterie >20 ) {colorBatt = Gfx.COLOR_YELLOW;} //jaune
        if (batterie >30 ) {colorBatt = Gfx.COLOR_GREEN;} //vert
        dc.setColor(colorBatt,trans);


        //dessin des marques batterie tous les 10%
        var angle_zero = 174;
        var angle_cent = 6;
        var nbre_marques = 10.0;
        var sens = Gfx.ARC_CLOCKWISE;
        var epaisseur = 6*coeff;
        var angle_entre_marques = (angle_cent-angle_zero)/nbre_marques;
        dc.setPenWidth(epaisseur/2);
        for (var i=1 ; i<=nbre_marques-1; i++) {
            var angle = angle_zero + i*angle_entre_marques; 
            var coord = coordMarkBattery(angle+270);
            dc.drawLine(coord[0][0],coord[0][1],coord[1][0],coord[1][1]);
        }    


        // dessin de l'arc
        dc.setPenWidth(epaisseur);    
        var arcDeg = (angle_cent-angle_zero) * (batterie/100)+angle_zero;
        dc.drawArc(centreEcran,centreEcran,centreEcran-epaisseur/4, sens,angle_zero,arcDeg);

    }
        
    function drawGraphIfNotLowPower(dc) {
        if (((! afficheMeteo) and ((! OledModel) || (! inLowPower)))) {
            var size = tabData.size();
            if (size==0) {
                dc.drawText(.5*largeurEcran,.65*hauteurEcran,Gfx.FONT_LARGE,"No BG data,check\nsettings",Gfx.TEXT_JUSTIFY_CENTER);
            return;
            }
            graph.calcule_tout(tabData);
            graph.dessine_tout(dc);
        }
    }
	function drawMeteoIfNotLowPower(dc) {
        if (((afficheMeteo) and ((! OledModel) || (! inLowPower)))) {
            if (Toybox has :Weather) {
                var CC = Toybox.Weather.getCurrentConditions();
                if (CC != null) {
                    var colorTemp = white;
                    var texte = "no temp";
                    if (CC.temperature != null) {
                        var temp = CC.temperature;
                        colorTemp = Gfx.COLOR_RED; //rouge
                        if (temp <35 ) {colorTemp = Gfx.COLOR_ORANGE;} //orange
                        if (temp <28 ) {colorTemp = Gfx.COLOR_YELLOW;} //jaune
                        if (temp <24 ) {colorTemp = Gfx.COLOR_GREEN;} //vert
                        if (temp <18 ) {colorTemp = Gfx.COLOR_BLUE;} //bleu clair
                        if (temp <6 ) {colorTemp = Gfx.COLOR_PURPLE;} // violet clair
                        texte = temp.format("%2.1f") + "°C";
                    }
                    drawLabel(dc,"Temperature", texte,colorTemp);
                    var colorWind = white;
                    texte = "no wind";
                    if (CC.windSpeed != null) {
                        var windSpeed = (CC.windSpeed == null) ? 0 : (CC.windSpeed * 1.943844).toNumber();
                        colorWind = Gfx.COLOR_RED; //rouge
                        if (windSpeed <25 ) {colorWind = Gfx.COLOR_PURPLE;} // violet 
                        if (windSpeed <20 ) {colorWind = Gfx.COLOR_ORANGE;} //orange
                        if (windSpeed <15 ) {colorWind = Gfx.COLOR_GREEN;} //vert
                        if (windSpeed <10 ) {colorWind = Gfx.COLOR_BLUE;} //bleu clair
                        if (windSpeed <6 ) {colorWind = Gfx.COLOR_LT_GRAY;}  //blanc vert pale
                        if (windSpeed <3 ) {colorWind = white;}  //blanc 
                        texte = windSpeed.format("%01d") +" nd";
                    }
                    drawLabel(dc,"Wind", texte,colorWind);
                } else {
                    drawLabel(dc,"Temperature", "No weather",white);
                } 
                var batterie = Sys.getSystemStats().battery;
                var colorBatt = Gfx.COLOR_RED; //rouge
                if (batterie >10 ) {colorBatt = Gfx.COLOR_ORANGE;} //orange
                if (batterie >20 ) {colorBatt = Gfx.COLOR_YELLOW;} //jaune
                if (batterie >30 ) {colorBatt = Gfx.COLOR_GREEN;} //vert
                drawLabel(dc,"Batterie",batterie.toNumber()+" %",colorBatt);
            } else {
                drawLabel(dc,"Temperature", "No weather",white);
            }
        } 
    }



    function ereaseOLEDifLowPower(dc) {
        if ((inLowPower) and (OledModel)) {
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
            decalageY_OLED = 1 + decalageY_OLED;
            if (decalageY_OLED > 1) {decalageY_OLED = -1;}
            dc.setPenWidth(3);
            for (var i = 0;i<dc.getHeight();i=i+4)	{
                dc.drawLine(0,i+decalageY_OLED,dc.getWidth(),i+decalageY_OLED);
            }
        }
    }

	function drawBG(dc) {
        if (AffichageBgValue !=null) {
            var colorBG = Gfx.COLOR_YELLOW;//jaune
            if (AffichageBgValue <170 ) {colorBG = Gfx.COLOR_GREEN;} //vert
            if (AffichageBgValue < 70 ) {colorBG = Gfx.COLOR_RED;} //rouge
           drawLabel(dc,"BG", AffichageBgValue,colorBG);
        } 
	}

    function barreBGsiBesoin(dc) {
        var elapsedMinutes = ((Time.now().value() - AffichageSecondesCapteur)/60).toNumber();
        if (elapsedMinutes>11) {
            dc.setPenWidth(5*coeff);
            dc.setColor(Gfx.COLOR_RED,trans);
            dc.drawLine(0.31*largeurEcran,0.56*hauteurEcran,0.76*largeurEcran,0.56*hauteurEcran);
            dc.drawLine(0.31*largeurEcran,0.59*hauteurEcran,0.76*largeurEcran,0.59*hauteurEcran);
        }

    }

    function drawElapsedTime(dc) {
        if (AffichageSecondesCapteur != null) {
            var elapsedMinutes = ((Time.now().value() - AffichageSecondesCapteur)/60).toNumber();
            var colorMinutes = white;
            if (elapsedMinutes >10 ) {colorMinutes = Gfx.COLOR_YELLOW;} 
            if (elapsedMinutes >30 ) {colorMinutes = Gfx.COLOR_ORANGE;} 
            if (elapsedMinutes >=99 ) {
                colorMinutes = Gfx.COLOR_RED;
                elapsedMinutes = 99;
                } 
            drawLabel(dc,"Elapsed",elapsedMinutes,colorMinutes);
            drawLabel(dc,"labelMin","min",white);

        } 
    }

    function drawDeltaValue(dc) {
        //System.println("sourceBG="+sourceBG);
        drawLabel(dc,"sourceBG", prov[sourceBG],white);
        if (AffichageBgDelta != null) {
            var delta = AffichageBgDelta.toNumber();
            var signe = "";
            if (delta>0) {signe="+";}
            drawLabel(dc,"Delta", signe+delta,white);
        }
    }

    function drawDeltaCadre(dc) {
        if (AffichageBgDelta != null) {
            var delta = AffichageBgDelta.toNumber();
            var colorDelta = Gfx.COLOR_GREEN;
            if (delta == 99) {delta = 0;}
            if (delta > 4 ) {colorDelta = Gfx.COLOR_YELLOW;} 
            if (delta > 10 ) {colorDelta = Gfx.COLOR_ORANGE;} 
            if (delta < -4 ) {colorDelta = Gfx.COLOR_YELLOW;} 
            if (delta < -10 ) {colorDelta = Gfx.COLOR_ORANGE;} 
            if (delta < -15 ) {colorDelta = Gfx.COLOR_RED;} 
            dc.setColor( colorDelta,trans);
            drawCadre(dc,colorDelta);
        }
    }

    function drawCadre(dc,color) {// dessin cadre
        var epaisseur = 6;
        dc.setColor( color,trans);
        dc.setPenWidth(epaisseur*coeff);
        dc.drawLine(0,separationLine*coeff,largeurEcran,separationLine*coeff);
         dc.setPenWidth(epaisseur*coeff);  
        //afficheMeteo = true;
        if (afficheMeteo) {
            dc.drawArc(centreEcran,centreEcran,centreEcran-1, Gfx.ARC_CLOCKWISE,205,175);
            dc.drawArc(centreEcran,centreEcran,centreEcran-1, Gfx.ARC_CLOCKWISE,5,335);
            dc.drawLine(0,separationLine2*coeff,largeurEcran,separationLine2*coeff);
        } else {
            dc.drawArc(centreEcran,centreEcran,centreEcran-epaisseur*coeff/2, Gfx.ARC_CLOCKWISE,5,175);
                   
        }
    } 

    function drawNotifs(dc) {
        var notificationCount = Sys.getDeviceSettings().notificationCount;
        if  (notificationCount > 0) { // notifications
            dc.setColor(Gfx.COLOR_RED,trans);
            dc.fillCircle(x.get("notif"),y.get("notif"),.06*largeurEcran);
           drawLabel(dc,"notif",notificationCount,white);
       }
    }

    function drawDate(dc,infoTime) {
        var dateStr = Lang.format("$1$ $2$ $3$", [infoTime.day_of_week, infoTime.day,infoTime.month]);
        drawLabel(dc,"date",dateStr,white);
    }

    function drawBlueTooth(dc,infoTime) {
        if (! System.getDeviceSettings().phoneConnected) {
            if (infoTime.sec %2 == 1) {
                var l = BTlogo.getWidth();
                var h = BTlogo.getHeight();
                dc.drawBitmap(largeurEcran/2- l/2, hauteurEcran/2-h/2,BTlogo);
            } else {
                dc.setColor(Gfx.COLOR_RED,trans);
                dc.setPenWidth(15);
                dc.drawCircle(largeurEcran/2, largeurEcran/2, largeurEcran/2-3);       	
            }
        } 
        
    }

// --------------------------LECTURES SETTINGS ET DATA-----------------------------------------------------------------------------------------------------

    function getProp(key,defaultVal) {
        var property = Application.getApp().getProperty(key);
        if (property == null) {property = defaultVal;}
        return property;
    }
    function readSettingsAndInitGraph() {
        sourceBG = getProp("sourceBG",0);
        afficheSecondes = getProp("afficheSecondes",false);
        afficheMeteo = getProp("afficheMeteo",false);
        nbHGraph  = getProp("nbHGraph",2);
        if (nbHGraph>3) {nbHGraph = 3;}
        logarithmique = getProp("logarithmique",true);
        graph = new watchGraph();
        graph.calcule_tout(tabData);
    }




}

class WatchDelegate extends Ui.WatchFaceDelegate {

    function onPowerBudgetExceeded(powerInfo) {
    }

    function initialize() {
        WatchFaceDelegate.initialize();
    }
}
