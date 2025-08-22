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

using Toybox.Application as App;
using Toybox.Background;
using Toybox.Time;
using Toybox.System as Sys;
using Toybox.Time.Gregorian as Calendar;

// NOTE: every object created here uses memory in the background process (as well as the watchface process.)
//       the background app is extremely limited in memory (32KB), so only define what is absolutely needed.

// cgm sync state
const NBRE_MAXI_DATA = 72;//6h

(:background)
var myView = null;
var sourceBG,afficheSecondes,afficheMeteo,nbHGraph,logarithmique,debugage,units;

var nextEventSecs = 0;

(:background)
class WatchApp extends App.AppBase {
    
    var bgdataPreView = null;

	// cgm sync state
	const defaultOffsetSeconds = 30;
	var offsetSeconds = defaultOffsetSeconds;
	var shiftingOffset = false;
	var syncAtSecond = -1;
    var secAfterCapteur = [20,10,10]; 




    function initialize() {
	    //Sys.println("app initialize");
        //this gets called in both the foreground and background
        AppBase.initialize();
    }

    function onSettingsChanged() {
	    //Sys.println("onSettingsChanged");
        if (myView != null) {
	        myView.readSettings();
	        //WatchApp.resync(0);
        }
    }

    // Return the initial view of your application here
    function getInitialView() {
	    //Sys.println("getInitialView");
        myView = new WatchView();
        Background.deleteTemporalEvent();
        var thisApp = Application.getApp();
        var lastBGmillis = myView.bgSecondes;
        //Sys.println("Initialize sync with offsetMillis="+lastBGmillis);
        var next = WatchView.prochainBackground(); //return [delaiRestant,prochainTime];
        System.println("Delai restant="+next[0]);
            resync(lastBGmillis);
        return [ myView, new bgbgDelegate()];
    }


    function DelaiTemporalEventSecondRestant() {
        
        var delaiMin = 1;

        var lastBackgroundMoment = Background.getLastTemporalEventTime();// as Time.Moment or Time.Duration or Null
        var delaiRestantSecondes=0;
        if (lastBackgroundMoment != null) {
          //Sys.println("DelaiTemporalEventSecondRestant temporal depuis = "+(Time.now().value() - lastBackgroundMoment.value()) +" sec");
          delaiRestantSecondes = 300 -Time.now().value() + lastBackgroundMoment.value();
        } else {
          //Sys.println("DelaiTemporalEventSecondRestant temporal null, delai = 0");

        }
        var delaiCalcule = delaiRestantSecondes;
        if (delaiCalcule<delaiMin) {delaiRestantSecondes = delaiMin;}
        //s.println("DelaiTemporalEventSecondRestant = "+delaiRestantSecondes);
        return delaiRestantSecondes;
    }

    function resync(last_capteur_seconds) { // réglage prochain temporal event, 5 min au moins après le précédent, et juste après la prochaine lecture du capteur + tempo
        //Sys.println("start RESYNC : last_capteur_seconds = "+last_capteur_seconds);
        var TEMPO_WEB = [15,10,15];  //tempo pour que la nouvelle glycemie soit dispo sur Nightscout, Xdrip ou AAPS 
        var tempoWeb = TEMPO_WEB[Application.getApp().getProperty("sourceBG")];
        var timeNowValue = Time.now().value();
        var delaiCapteurRestantMini = 0;
        //var last_capteur_seconde;
        if ((last_capteur_seconds == null) || (last_capteur_seconds == 0)){
            last_capteur_seconds = timeNowValue - 600 - tempoWeb -60; //pour synchro des que possible
        }

        var capteurElapsed = timeNowValue - last_capteur_seconds;
        delaiCapteurRestantMini = 300 - capteurElapsed + tempoWeb; //
        var delaicapteurCorrige = delaiCapteurRestantMini;
        if ((delaiCapteurRestantMini >-300 ) && (delaiCapteurRestantMini <295)){
            delaicapteurCorrige = delaiCapteurRestantMini % 300 +300; // de 300 à 599
        }
        var temporalMinRestant = WatchApp.DelaiTemporalEventSecondRestant();
        var timeTempo = temporalMinRestant;

        if ((delaicapteurCorrige < 595) && (temporalMinRestant<delaicapteurCorrige)) {
            timeTempo = delaicapteurCorrige; //correction en rallongeant
        }

        //Sys.println("RESYNC 0 timeNowValue            = " +timeNowValue);
        //Sys.println("RESYNC 1 capteurElapsed          = " +capteurElapsed);
        //Sys.println("RESYNC 2 delaiCapteurRestantMini = " +delaiCapteurRestantMini);
        //Sys.println("RESYNC 3 delaicapteurCorrige     = " +delaicapteurCorrige);
        //Sys.println("RESYNC 4 temporalMinRestant      = " +temporalMinRestant);
        //Sys.println("RESYNC 5 tempofinal              = " +timeTempo);
        Background.registerForTemporalEvent(Time.now().add(new Time.Duration(timeTempo))); 
        //Sys.println("RESYNC fin OK---Tempo final posee = " + timeTempo);
    }


    function onBackgroundData(data) {
	    //Sys.println("onBackground "+data);
        
        enregistreDernierCapteur(data[0]);
        var capteurSecondes = data[0][2];
	    //Sys.println("onBackground "+capteurSecondes);
        if ((capteurSecondes != null) &&
            (capteurSecondes > 0)) {
            //Sys.println("onBackgroundData call resync(capteurSecondes) "+capteurSecondes);
            resync(capteurSecondes);            
        } else {
            //Sys.println("onBackgroundData invalid data: "+capteurSecondes + "pose 300 sec");
            Background.registerForTemporalEvent(new Time.Duration(300));
            resync(0);
        }
    

        //App.getApp().setProperty("offsetSeconds", offsetSeconds);

    }



    function enregistreDernierCapteur(capteur) {
        //if (capteur[0] ==0) { return;}
        System.println("enregistreDernierCapteur "+capteur);
        var allData = readAlldData();
        allData.add(capteur);// ajoute a la fin
        if (allData.size()>NBRE_MAXI_DATA) {
            allData.remove(allData[0]); // enleve le 1er
        }
        storeAllData(allData);
        Application.Storage.setValue("CapteurChanged",true);
        System.println("enregistreDernierCapteur FIN, secondes = "+capteur[2]);

    }
    
    function readAlldData() {
        System.println("start readAlldData ");
        var st = Application.Storage.getValue("data");
       
        var tab=new[0];
        if ((st == null) || (st.length() < 3)) {
            return tab;
        }
        var	n1 = st.find(";");
        while (n1 != null) {
            var st2 = st.substring(0,n1);
            st = st.substring(n1+1,st.length());
            n1 = st.find(";");

            var tab2 = new[0];
            var	n2 = st2.find(",");
            tab2.add(st2.substring(0,n2).toNumber()); //BG
            st2 = st2.substring(n2+1,st2.length());

            n2 = st2.find(",");
            tab2.add(st2.substring(0,n2).toNumber()); //BG,delta
            st2 = st2.substring(n2+1,st2.length());

            tab2.add(st2.toNumber()); //BG,delta,secondes

            tab.add(tab2); //[BG,delta,secondes]
        }
        System.println("fin readAlldData  ="+tab);
        return tab;
    }

    function storeAllData(myTab) {
      System.println("debut storeAllData "+myTab);
      var st = "";
      for (var i = 0;i<myTab.size();i++) {
        if ((myTab[i] !=null) && (myTab[i][0] !=null) && (myTab[i][1] !=null) && (myTab[i][2] !=null)) {
        st=st+myTab[i][0].toString()+","+myTab[i][1].toString()+","+myTab[i][2].toString()+";";
        }
      }
      Application.Storage.setValue("data",st);
      System.println("fin storeAllData st = "+st);
     }



    function getServiceDelegate(){
		//Sys.println("getServiceDelegate");
        return [new WatchBG()];
    }


(:onlyWithSettingOnWatchface)
    function getSettingsView() {
        Application.Storage.setValue("CapteurChanged",true);
         if (Sys.getDeviceSettings().isTouchScreen) {
            return [new $.GraphSet_View(), new $.GraphSet_Delegate()];
        } else {
            var menuSettings =  menuPrincipal(0);
            return [menuSettings, new $.MenuSetPrincipalDelegate(menuSettings),WatchUi.SLIDE_RIGHT];
        }
    }


(:onlyWithSettingOnWatchface)
    public function menuPrincipal(position) {
        var unitStr = ["","(mg/l)","(mmol/l)"][units];
        var tab = [afficheSecondes ? "Set seconds OFF" : "Set seconds ON",
                    afficheMeteo ?  "Graph I/O meteo" : "Meteo I/O graph",
                    "Graph options",
                    "BG source",
                    "Units "+unitStr];
        return  new $.MenuView("Settings "+WatchUi.loadResource(Rez.Strings.version),tab,position);
    }

}
