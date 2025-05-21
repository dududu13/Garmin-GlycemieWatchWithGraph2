/*
 * NightscoutWatch Garmin Connect IQ watchface
 * Copyright (C) 2017-2018 tynbendad@gmail.com
 * #WeAreNotWaiting
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, version 3 of the License.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   A copy of the GNU General Public License is available at
 *   https://www.gnu.org/licenses/gpl-3.0.txt
 */

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time;
using Toybox.Time.Gregorian as Calendar;


class watchView extends Ui.WatchFace {
var debug = [
[120,3,0],
[200,80,0],
[159,-41,0],
[220,61,0],
[147,-73,0],
[199,52,0],
[251,52,0],
[248,-3,0],
[249,1,0],
[139,-110,0],
[134,-5,0],
[248,114,0],
[218,-30,0],
[200,-18,0],
[147,-53,0],
[265,118,0],
[176,-89,0],
[244,68,0],
[272,28,0],
[131,-141,0],
[264,133,0],
[185,-79,0],
[259,74,0],
[203,-56,0],
[197,-6,0],
[193,-4,0],
[194,1,0],
[210,16,0],
[257,47,0],
[240,-17,0],
[164,-76,0],
[181,17,0],
[208,27,0],
[155,-53,0],
[270,115,0],
[272,2,0],
[188,-84,0],
[241,53,0],
[218,-23,0],
[231,13,0],
[199,-32,0],
[212,13,0],
[180,-32,0],
[274,94,0],
[212,-62,0],
[137,-75,0],
[179,42,0],
[220,41,0],
[137,-83,0],
[227,90,0],
[198,-29,0],
[271,73,0],
[142,-129,0],
[197,55,0],
[180,-17,0],
[264,84,0],
[146,-118,0],
[248,102,0],
[144,-104,0],
[262,118,0],
[269,7,0],
[222,-47,0],
[221,-1,0],
[220,-1,0],
[151,-69,0],
[170,19,0],
[182,12,0],
[122,-60,0],
[270,148,0],
[171,-99,0],
[168,-3,0],
[250,82,0],

];

    var partialUpdatesAllowed = false;

    var inLowPower = false;
    //var sourceBG,afficheSecondes,afficheMeteo,nbHGraph,logarithmique,debugage,CapteurChanged;


    const prov = ["NS","AAPS","Xd"];  
    var BTlogo = Ui.loadResource(Rez.Drawables.blueTooth);  
    
    var graph;
    var tabData = new[0];
    var bgBg =0;
    var bgSecondes = Time.now().value()- 99*60; 
    var bgDelta = 0;

    var decalageY_OLED = 0;



    var largeurEcran = System.getDeviceSettings().screenWidth;
    var hauteurEcran = System.getDeviceSettings().screenHeight;//dc.getHeight();;
    var OledModel  = System.getDeviceSettings().requiresBurnInProtection; 


var x = {
"date"=>(0.5 * largeurEcran),
"heure"=>(0.5 * largeurEcran),
"notif"=>(0.12 * largeurEcran),
"BG"=>(0.75 * largeurEcran),
"Delta"=>(0.24 * largeurEcran),
"Elapsed"=>(0.96 * largeurEcran),
"sourceBG"=>(0.02 * largeurEcran),
"Secondes"=>(0.96 * largeurEcran),
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
    	System.println("view.initialize()");
        readSettings();
        tabData = readAllData();
        //tabData = debug;
        //WatchApp.storeAllData(tabData);
        graph = new watchGraph(tabData);
        WatchFace.initialize();
    }


    function onSettingsChanged() {
        readSettings();
		return true; // always register the event now, since we attempt xdrip or spike regardless of empty urls
    }

    function readSettings() {
        sourceBG = getProp("sourceBG",2);
        afficheSecondes = getProp("afficheSecondes",false);
        afficheMeteo = getProp("afficheMeteo",false);
        
        debugage = getProp("debuging",false);
        //CapteurChanged = true;
    }

    function getProp(key,defaultValue) {
        var property = Application.getApp().getProperty(key);
        if (property == null) {property = defaultValue;}
        return property;
    }

    function getStorage(key,defaultValue) {
        var data = App.Storage.getValue(key);
        if (data == null) {return defaultValue;}
        return data;
    }


    function readAllData() {
        var data = WatchApp.readAlldData();
        getLastData(data);
        return data;
    }


    function getLastData(data) {
        bgBg = 0;
        bgDelta = 0;
        bgSecondes = 0;                                
        var size = data.size();
        for (var i=size-1;i>=0;i=i-1) {
            System.println("getlastdata "+data[i]);
            if (data[i][0] > 0) {
                bgBg = data[i][0];
                bgDelta = data[i][1];
                bgSecondes = data[i][2]; 
                return;
            }
        }

    }



    function prochainBackground() { //avec moment
        var prochainBackground = Background.getTemporalEventRegisteredTime();// Time.Moment or Time.Duration or Null
        var delaiRestant = 0;
        var prochainTime = "";
        if (prochainBackground == null) {
            System.println("prochainBackground null, registerasap");
            delaiRestant = "...";
            //WatchApp.resync(0);
        } else { 
            if (prochainBackground.compare(Time.now())<0) {
                System.println("prochainBackground < now, registerasap");
                delaiRestant = "ERR";
                //WatchApp.resync(0);
            } else {
                delaiRestant = prochainBackground.value()-Time.now().value();
                var info = Calendar.info(prochainBackground, Time.FORMAT_LONG);
                prochainTime = Lang.format("$1$:$2$:$3$", [info.hour.format("%02d"),info.min.format("%02d"),info.sec.format("%02d")]);

            }
        }
        return [delaiRestant,prochainTime];
    }

    function afficheDebug(dc) {
        var largeurEcran = System.getDeviceSettings().screenWidth;

        dc.clearClip();
        dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();
        dc.setColor(Gfx.COLOR_GREEN,Gfx.COLOR_TRANSPARENT);
        dc.drawText(0.5 * largeurEcran,0.6 * largeurEcran,Gfx.FONT_NUMBER_THAI_HOT,bgBg,Gfx.TEXT_JUSTIFY_CENTER);
        if (bgSecondes == null) {bgSecondes = 0;}
        //var elapsedSec = Time.now().value()-bgSecondes;
        var elapsedMin = ((Time.now().value() - bgSecondes)/60).toNumber();
        dc.drawText(0.7 * largeurEcran,0.34 * largeurEcran,Gfx.FONT_NUMBER_HOT,elapsedMin,Gfx.TEXT_JUSTIFY_RIGHT);
        dc.drawText(0.7 * largeurEcran,0.44 * largeurEcran,Gfx.FONT_SYSTEM_LARGE,"min",Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(0.15 * largeurEcran,0.34 * largeurEcran,Gfx.FONT_NUMBER_HOT,bgDelta,Gfx.TEXT_JUSTIFY_LEFT);


        var prochainBackground = prochainBackground(); //[delaiRestant,prochainTime]
        dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

        var InfosActuelles = ["NS","AAPS","Xdrip"][sourceBG]+"  next "+prochainBackground[0]+"\n\n\n                          next "+prochainBackground[1];
        dc.drawText(0.5 * largeurEcran,0.02 * largeurEcran,Gfx.FONT_XTINY,InfosActuelles,Gfx.TEXT_JUSTIFY_CENTER);

        var debugInfos = Application.Storage.getValue("debugInfos");
        dc.drawText(0.5 * largeurEcran,0.1 * largeurEcran,Gfx.FONT_XTINY,debugInfos,Gfx.TEXT_JUSTIFY_CENTER);

        var info = Calendar.info(Time.now(), Time.FORMAT_LONG);
        var timeString = Lang.format("$1$:$2$:$3$", [info.hour.format("%02d"),info.min.format("%02d"),info.sec.format("%02d")]);
        dc.drawText(0.15 * largeurEcran,0.24 * largeurEcran,Gfx.FONT_SYSTEM_TINY,timeString,Gfx.TEXT_JUSTIFY_LEFT);

        var debugData =Application.Storage.getValue("debugData"); 
        if (debugData == null) {debugData = "null";}
        var font = debugData.substring(0,5).equals("Atten") ? Gfx.FONT_LARGE : Gfx.FONT_XTINY;
        var long1car = (dc.getTextWidthInPixels("abcd ?Phij", Gfx.FONT_XTINY)/10).toNumber();
        var nbcar = (dc.getWidth()*.85)/long1car;
        var stData = "";
        for (var i = 0;i<debugData.length();i=i+nbcar) {
            if (i+nbcar > debugData.length()) {
                stData=stData+debugData.substring(i,debugData.length()) ;
            } else {
                stData=stData+debugData.substring(i,i+nbcar) + "\n";
            }
        }
        debugData = stData;
        dc.setPenWidth(1);
        dc.drawLine(0,0.33 * largeurEcran,largeurEcran,0.33 * largeurEcran);
        dc.setColor(Gfx.COLOR_LT_GRAY,Gfx.COLOR_TRANSPARENT);
        dc.drawText(0.5 * largeurEcran,0.33 * largeurEcran,font,debugData,Gfx.TEXT_JUSTIFY_CENTER);
    }

    function isCapteurChanged() {
        var temp = Application.Storage.getValue("CapteurChanged");
        if (temp == null) {return true;}
        else {return temp;}
    }
    function onUpdate(dc) {
		dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();
        if (isCapteurChanged()) {
            tabData = readAllData();
            graph.calcule_tout(tabData);
            Application.Storage.setValue("CapteurChanged",false);
        }
        if (debugage) {
            afficheDebug(dc);
            return;
        }
        var timeNow = Time.now();
        if (isCapteurChanged()) {
            tabData = readAllData();
            graph.calcule_tout(tabData);
            Application.Storage.setValue("CapteurChanged",false);
        }
        
        var infoTime = Calendar.info(timeNow, Time.FORMAT_LONG);

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
        var nextBG = drawNextCall(dc);
		ereaseOLEDifLowPower(dc);

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

    function drawNextCall(dc) {
        var _nextBG = prochainBackground()[0];
        drawLabel(dc,"sourceBG", prov[sourceBG] + " "+_nextBG,white);
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
        var batterie = System.getSystemStats().battery;
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
            //graph.calcule_tout(tabData);
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
                var batterie = System.getSystemStats().battery;
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
        if (bgBg !=null) {
            var colorBG = Gfx.COLOR_YELLOW;//jaune
            if (bgBg <170 ) {colorBG = Gfx.COLOR_GREEN;} //vert
            if (bgBg < 70 ) {colorBG = Gfx.COLOR_RED;} //rouge
           drawLabel(dc,"BG", bgBg,colorBG);
        } 
	}

    function barreBGsiBesoin(dc) {
        var elapsedMinutes = ((Time.now().value() - bgSecondes)/60).toNumber();
        if (elapsedMinutes>11) {
            dc.setPenWidth(5*coeff);
            dc.setColor(Gfx.COLOR_RED,trans);
            dc.drawLine(0.31*largeurEcran,0.56*hauteurEcran,0.76*largeurEcran,0.56*hauteurEcran);
            dc.drawLine(0.31*largeurEcran,0.59*hauteurEcran,0.76*largeurEcran,0.59*hauteurEcran);
        }

    }

    function drawElapsedTime(dc) {
        if (bgSecondes != null) {
            var elapsedMinutes = ((Time.now().value() - bgSecondes)/60).toNumber();
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
        if (bgDelta != null) {
            var delta = bgDelta.toNumber();
            var signe = "";
            if (delta>0) {signe="+";}
            drawLabel(dc,"Delta", signe+delta,white);
        }
    }

    function drawDeltaCadre(dc) {
        if (bgDelta != null) {
            var delta = bgDelta.toNumber();
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
        var notificationCount = System.getDeviceSettings().notificationCount;
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

    function onExitSleep() {
    	//myPrintLn("view.onExitSleep(), ctr=" + ctr); ctr++;
    	inLowPower = false;
    	Ui.requestUpdate(); 
    }

    function onEnterSleep() {
    	//myPrintLn("view.onEnterSleep(), ctr=" + ctr); ctr++;
    	inLowPower = true;
    	Ui.requestUpdate(); 
    }

}

class bgbgDelegate extends Ui.WatchFaceDelegate {

    function onPowerBudgetExceeded(powerInfo) {
         partialUpdatesAllowed = false;
    }

    function initialize() {
        WatchFaceDelegate.initialize();
    }
}
