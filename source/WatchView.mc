
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time;
using Toybox.Time.Gregorian as Calendar;


class WatchView extends Ui.WatchFace {

    var partialUpdatesAllowed = false;

    var inLowPower = false;
    //var sourceBG,afficheSecondes,afficheFields,nbHGraph,logarithmique,debugage,CapteurChanged;


    const prov = ["NS","AAPS","Xd"];  
    
    var graph;
    var tabData = new[0];
    var bgBg =0;
    var bgSecondes = Time.now().value()- 99*60; 
    var bgDelta = 0;

    var decalageY_OLED = 0;



    var largeurEcran = System.getDeviceSettings().screenWidth;
    var hauteurEcran = System.getDeviceSettings().screenHeight;//dc.getHeight();;
    var OledModel  = System.getDeviceSettings().requiresBurnInProtection; 

var FONT_LARGE = Gfx.FONT_LARGE;
var FONT_MEDIUM = Gfx.FONT_MEDIUM;
var FONT_NUMBER_HOT = Gfx.FONT_NUMBER_HOT;
var FONT_NUMBER_MILD = Gfx.FONT_NUMBER_MILD;
var FONT_XTINY = Gfx.FONT_XTINY;

var x,y,font,justification;


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
        ajusteFonts();
        ajustexy();
        //tabData = debug;
        //WatchApp.storeAllData(tabData);
        graph = new WatchGraphique(tabData);
        WatchFace.initialize();
    }


    function onSettingsChanged() {
        readSettings();
		return true; 
    }
    function ajusteFonts() {
        var pourCent = 1.0*Gfx.getFontHeight(FONT_NUMBER_HOT)/hauteurEcran;
        //System.println("pourCent = "+pourCent);
        if (pourCent > .36) { //pour les montres genre fenix 8
            System.println("réducton font size");
            FONT_LARGE = FONT_LARGE-1;
            FONT_MEDIUM = FONT_MEDIUM-1;
            FONT_NUMBER_HOT = FONT_NUMBER_HOT-1;
            FONT_NUMBER_MILD = FONT_NUMBER_MILD-1;
            FONT_XTINY = FONT_XTINY;
        }

    }
    function ajustexy() {
        x = {
        "date"=>(0.5 * largeurEcran),
        "heure"=>(0.5 * largeurEcran),
        "notif"=>(0.12 * largeurEcran),
        "BG"=>(0.78 * largeurEcran),
        "Delta"=>(0.29 * largeurEcran),
        "Elapsed"=>(0.96 * largeurEcran),
        "sourceBG"=>(0.02 * largeurEcran),
        "Secondes"=>(0.96 * largeurEcran),
        "field1"=>(0.46 * largeurEcran),
        "field2"=>(0.54 * largeurEcran),
        "field3"=>(0.5 * largeurEcran),
        "labelMin"=>(0.93 * largeurEcran),
        };

        y = {
        "date"=>(0.127 * hauteurEcran),
        "heure"=>0.315 * hauteurEcran,
        "notif"=>0.392 * hauteurEcran,
        "BG"=>0.582 * hauteurEcran,
        "Delta"=>0.6 * hauteurEcran,
        "Elapsed"=>0.545 * hauteurEcran,
        "sourceBG"=>0.49 * hauteurEcran,
        "Secondes"=>0.356 * hauteurEcran,
        "field1"=>0.78 * hauteurEcran,
        "field2"=>0.78 * hauteurEcran,
        "field3"=>0.92 * hauteurEcran,
        "labelMin"=>0.66 * hauteurEcran,
        };

        font = {
        "date"=>FONT_LARGE,
        "heure"=>FONT_NUMBER_HOT,
        "notif"=>FONT_MEDIUM,
        "BG"=>FONT_NUMBER_HOT,
        "Delta"=>FONT_NUMBER_MILD,
        "Elapsed"=>FONT_NUMBER_MILD,
        "sourceBG"=>FONT_XTINY,
        "Secondes"=>FONT_NUMBER_MILD,
        "field1"=>FONT_LARGE,
        "field2"=>FONT_LARGE,
        "field3"=>FONT_LARGE,
        "labelMin"=>FONT_XTINY,
        };

        justification = {
        "date"=>Gfx.TEXT_JUSTIFY_CENTER,
        "heure"=>Gfx.TEXT_JUSTIFY_CENTER,
        "notif"=>Gfx.TEXT_JUSTIFY_CENTER,
        "BG"=>Gfx.TEXT_JUSTIFY_RIGHT,
        "Delta"=>Gfx.TEXT_JUSTIFY_RIGHT,
        "Elapsed"=>Gfx.TEXT_JUSTIFY_RIGHT,
        "sourceBG"=>Gfx.TEXT_JUSTIFY_LEFT,
        "Secondes"=>Gfx.TEXT_JUSTIFY_RIGHT,
        "field1"=>Gfx.TEXT_JUSTIFY_RIGHT,
        "field2"=>Gfx.TEXT_JUSTIFY_LEFT,
        "field3"=>Gfx.TEXT_JUSTIFY_CENTER,
        "labelMin"=>Gfx.TEXT_JUSTIFY_RIGHT,
        };
    }

    //var sourceBG,afficheSecondes,afficheFields,nbHGraph,logarithmique,debugage;

    function readSettings() {
        sourceBG = getProp("sourceBG",2);
        afficheSecondes = getProp("afficheSecondes",false);
        afficheFields = getProp("afficheFields",false);
        nbHGraph = getProp("nbHGraph",2);
        logarithmique = getProp("logarithmique",false);
        units  = getProp("units",0);
        field1  = getProp("field1",1);
        field2  = getProp("field2",2);
        field3  = getProp("field3",3);
    }

    function getProp(key,defaultValue) {
        var property = Application.getApp().getProperty(key);
        if (property == null) {
            property = defaultValue;
            Application.getApp().setProperty(key,defaultValue);
        }
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
/*
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
*/
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
        var timeNow = Time.now();
        if (isCapteurChanged()) {
            tabData = readAllData();
            graph.calcule_tout(tabData);
            Application.Storage.setValue("CapteurChanged",false);
        }
        
        var coeff = 1.0;
        var format = "%01d";
        if (units == 1) {
            coeff = 18;
        }
        else if (units == 2) {
            coeff = 1/18.0;
            format = "%2.1f";
        }
        var infoTime = Calendar.info(timeNow, Time.FORMAT_MEDIUM);

        drawGraphOrFieldsIfNotLowPower(dc);
        drawDeltaValue(dc,coeff,format);
        drawClock(dc,infoTime);
        drawElapsedTime(dc);
        drawBG(dc,coeff,format);
        drawNotifs(dc);
        drawDate(dc,infoTime);    
        barreBGsiBesoin(dc);
        drawBatterieAnalog(dc);
        drawDeltaCadre(dc,coeff,format);
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
        
    function drawGraphOrFieldsIfNotLowPower(dc) {
        if ((! OledModel) || (! inLowPower)) {
            if (afficheFields) {
                drawFields(dc);
            } else {
                if (tabData.size()==0) {
                    dc.drawText(.5*largeurEcran,.65*hauteurEcran,Gfx.FONT_LARGE,"No BG data,check\nsettings",Gfx.TEXT_JUSTIFY_CENTER);
                    return;
                }
                graph.dessine_tout(dc);
            }
        }
    }

    function drawFields(dc) {
    
        if (((afficheFields) and ((! OledModel) || (! inLowPower)))) {
            var data = dataField(field1);
            drawLabel(dc,"field1", data[0],data[1]);
            data = dataField(field2);
            drawLabel(dc,"field2", data[0],data[1]);
            data = dataField(field3);
            drawLabel(dc,"field3", data[0],data[1]);
            dc.setPenWidth(2);
            dc.setColor(white,Gfx.COLOR_TRANSPARENT);
            var y1 = y.get("field2") + (y.get("field3") - y.get("field2"))/2;
            dc.drawLine(0,y1,largeurEcran,y1);
            dc.drawLine(0.5 * largeurEcran,separationLine2*coeff,0.5 * largeurEcran,y1);
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

	function drawBG(dc,coeff,format) {
        if (bgBg !=null) {
            var colorBG = Gfx.COLOR_YELLOW;//jaune
            if (bgBg * coeff <170 * coeff ) {colorBG = Gfx.COLOR_GREEN;} //vert
            if (bgBg * coeff< 70 * coeff ) {colorBG = Gfx.COLOR_RED;} //rouge
           drawLabel(dc,"BG", (bgBg*coeff).format(format),colorBG);
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

    function drawDeltaValue(dc,coeff,format) {
        //System.println("sourceBG="+sourceBG);
        if (bgDelta != null) {
            var delta = (bgDelta*coeff);//.toNumber();
            var signe = "";
            if (delta>=0) {signe="+";}
            drawLabel(dc,"Delta", signe+delta.format(format),white);
        }
    }

    function drawDeltaCadre(dc,coeff,format) {
        if (bgDelta != null) {
            var delta = bgDelta*coeff;//.toNumber();
            var colorDelta = Gfx.COLOR_GREEN;
            if (delta == 99*coeff) {delta = 0;}
            if (delta > 4*coeff ) {colorDelta = Gfx.COLOR_YELLOW;} 
            if (delta > 10*coeff ) {colorDelta = Gfx.COLOR_ORANGE;} 
            if (delta < -4*coeff ) {colorDelta = Gfx.COLOR_YELLOW;} 
            if (delta < -10*coeff ) {colorDelta = Gfx.COLOR_ORANGE;} 
            if (delta < -15*coeff ) {colorDelta = Gfx.COLOR_RED;} 
            dc.setColor( colorDelta,trans);
            drawCadre(dc,colorDelta);
        }
    }

    function drawCadre(dc,color) {// dessin cadre
        var epaisseur = 6;
        dc.setPenWidth(epaisseur*coeff);
        dc.setColor(Gfx.COLOR_WHITE,trans);
        dc.drawLine(0,separationLine*coeff,largeurEcran,separationLine*coeff);
        dc.setColor( color,trans);
        if (afficheFields) {
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
        var m = infoTime.month;
        if (m.length()>3) {m = m.substring(0,3);}
        var dateStr = Lang.format("$1$ $2$ $3$", [infoTime.day_of_week, infoTime.day,m]);
        drawLabel(dc,"date",dateStr,white);
    }

    function drawBlueTooth(dc,infoTime) {
        if (! System.getDeviceSettings().phoneConnected) {
            dc.setColor(Gfx.COLOR_RED,trans);
            var L = largeurEcran;
            var H = hauteurEcran;
            var centrex = L/2;
            var centrey = H/2;
            dc.setPenWidth(12*L/416);
            if (infoTime.sec %2 == 1) {
                dc.fillCircle(L/2,H*.375,L*.16);
                dc.fillCircle(L/2,H*.625,L*.16);
                dc.fillRectangle(L*.34,H*.375,L*.32,H*.25);
                dc.setColor(Gfx.COLOR_WHITE,trans);
                var tailleLogo = H*.40;
                dc.drawLine(centrex+0*tailleLogo,centrey+-0.5*tailleLogo,centrex+0*tailleLogo,centrey+0.5*tailleLogo);
                dc.drawLine(centrex+-0.25*tailleLogo,centrey+-0.25*tailleLogo,centrex+0.25*tailleLogo,centrey+0.25*tailleLogo);
                dc.drawLine(centrex+-0.25*tailleLogo,centrey+0.25*tailleLogo,centrex+0.25*tailleLogo,centrey+-0.25*tailleLogo);
                dc.drawLine(centrex+0*tailleLogo,centrey+-0.5*tailleLogo,centrex+0.25*tailleLogo,centrey+-0.25*tailleLogo);
                dc.drawLine(centrex+0*tailleLogo,centrey+0.5*tailleLogo,centrex+0.25*tailleLogo,centrey+0.25*tailleLogo);
                
            } else {
            dc.setColor(Gfx.COLOR_RED,trans);
                dc.drawCircle(centrex, centrey, centrex-3);       	
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

    function dataField(num) {
        //System.println("num = "+num);
        if (num == 0) {//rien
        return ["",white];
        }
        else if (num == 1) {//batterie
            var batterie = System.getSystemStats().battery;
            var colorBatt = Gfx.COLOR_RED; //rouge
            if (batterie >10 ) {colorBatt = Gfx.COLOR_ORANGE;} //orange
            if (batterie >20 ) {colorBatt = Gfx.COLOR_YELLOW;} //jaune
            if (batterie >30 ) {colorBatt = Gfx.COLOR_GREEN;} //vert
            return [batterie.toNumber()+" %",colorBatt];
        } else if (num == 2) {//temperature
            if (Toybox has :Weather) {
                var CC = Toybox.Weather.getCurrentConditions();
                if (CC != null) {
                    if (CC.temperature != null) {
                        var colorTemp;
                        var temp = CC.temperature;
                        colorTemp = Gfx.COLOR_RED; //rouge
                        if (temp <35 ) {colorTemp = Gfx.COLOR_ORANGE;} //orange
                        if (temp <28 ) {colorTemp = Gfx.COLOR_YELLOW;} //jaune
                        if (temp <24 ) {colorTemp = Gfx.COLOR_GREEN;} //vert
                        if (temp <18 ) {colorTemp = Gfx.COLOR_BLUE;} //bleu clair
                        if (temp <6 ) {colorTemp = Gfx.COLOR_PURPLE;} // violet clair
				var unitstr = "°C";
				if (System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE ) {
					temp = temp*1.8+32; 
					unitstr = "°F";
				}
                        return [temp.format("%2.1f") + unitstr,colorTemp];
                    }
                }
            }
        } else if (num == 3) { //wind
            if (Toybox has :Weather) {
                var CC = Toybox.Weather.getCurrentConditions();
                if (CC != null) {
                    if (CC.windSpeed != null) {
                        var windSpeed = (CC.windSpeed == null) ? 0 : (CC.windSpeed * 1.943844).toNumber();
                        var colorWind;
                        colorWind = Gfx.COLOR_RED; //rouge
                        if (windSpeed <25 ) {colorWind = Gfx.COLOR_PURPLE;} // violet 
                        if (windSpeed <20 ) {colorWind = Gfx.COLOR_ORANGE;} //orange
                        if (windSpeed <15 ) {colorWind = Gfx.COLOR_GREEN;} //vert
                        if (windSpeed <10 ) {colorWind = Gfx.COLOR_BLUE;} //bleu clair
                        if (windSpeed <6 ) {colorWind = Gfx.COLOR_LT_GRAY;}  //blanc vert pale
                        if (windSpeed <3 ) {colorWind = white;}  //blanc 
                        return [windSpeed.format("%01d") +" kts",colorWind];
                    }
                }
            }
        } else if (num == 4) { //pressure
			var r;
			if (Activity.Info has :rawAmbientPressure) {
				r = Activity.getActivityInfo().rawAmbientPressure;
			}
			if ((r == null) && (Toybox has :SensorHistory) && (Toybox.SensorHistory has :getPressureHistory)) {
				r = Toybox.SensorHistory.getPressureHistory({});
				if (r != null) { r = r.next().data;}
				}
			if (r != null) {
				return [(r/100).format("%01d")+" Pa",white] ;
			}
        } else if (num == 5) { //altitude
			var alt = Activity.getActivityInfo().altitude;
			if ((alt == null) && (Toybox has :SensorHistory) && (Toybox.SensorHistory has :getElevationHistory)) {
				alt = Toybox.SensorHistory.getElevationHistory({});
				if (alt != null) { alt = alt.next().data;}
			}
			if (alt != null) {
				var unitstr = "m";
				if (System.getDeviceSettings().heightUnits != 0) {
					alt = alt* 3.28084;
					unitstr = "ft";
				}
				return [(alt).format("%01d") +unitstr,white];
			}
        } else if (num == 6) { //steps
            return [ActivityMonitor.getInfo().steps.format("%01d")+" st",white];
        } else if (num == 7) { // distance
            return [(ActivityMonitor.getInfo().distance/100).format("%01d")+" m",white];
        } else if (num == 8) { // heart rate
			var r = Activity.getActivityInfo().currentHeartRate;
			if ((r == null) && (Toybox has :SensorHistory) && (Toybox.SensorHistory has :getHeartRateHistory)) {
				r = Toybox.SensorHistory.getHeartRateHistory({});
				if (r != null) { r = r.next().data;}
			}
			if (r != null) {
				return ["HR "+r.toString(),white];
			}
        } else if (num == 9) { //floor
			if  (Toybox.ActivityMonitor.Info has :floorsClimbed) {
				return [ActivityMonitor.getInfo().floorsClimbed +" Fl",white];
                }
        } else if (num == 10) { // calories
			if  (Toybox.ActivityMonitor.Info has :calories) {
				return [ActivityMonitor.getInfo().calories+" Kc",white];
                }
        } else if (num == 11) { 
        } else if (num == 12) { 
        } else if (num == 13) { 
        } else if (num == 14) { 
        }
        return ["N/A",Gfx.COLOR_WHITE];
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
