
using Toybox.Background;
using Toybox.Communications;
using Toybox.Application as App;
using Toybox.Time;
using Toybox.System as Sys;

// The Service Delegate is the main entry point for background processes
// our onTemporalEvent() method will get run each time our periodic event
// is triggered by the system.

(:background)
class WatchBG extends Toybox.System.ServiceDelegate {



    function initialize() {
      Sys.println("BG initialize start");
      Sys.ServiceDelegate.initialize();
    }

    function onTemporalEvent() {
      Sys.println("BG onTemporalEvent");
      var sourceBG = Application.getApp().getProperty("sourceBG");
      if ((sourceBG == 0) || (sourceBG == null)) {
        requestNS();
      } else if (sourceBG == 1) { //AAPS
        requestAAPS();
      }
      else  { //xdrip
        requestXdrip();
      }
    }




    function requestNS() {
      Sys.println("request NS start ");
// https://glycemie.fin-tech.com/api/v2/properties/buckets[0],buckets[1]
// https://glycemie.fin-tech.com/api/v2/properties/buckets[0],buckets[1]/?token=watchface-0da8d01b0c8b3595
		  var url = Application.getApp().getProperty("url");
      var utilisateurNS = Application.getApp().getProperty("tokenNS");
		  if ((url != null) && (! url.equals(""))) {
        var token = "";
        if ((utilisateurNS != null) || (utilisateurNS.equals(""))) {token = "/?token="+utilisateurNS;}
		  	url = url + "api/v2/properties/buckets[0],buckets[1]"+token;  
			  Communications.makeWebRequest(url, {}, { :method => Communications.HTTP_REQUEST_METHOD_GET,
                                                         :headers => { "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
                                                         :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
                                                       }, method(:onReceiveNS));
		  }
    }

    function requestAAPS() {
//    message = " AA "+  message;
		  var url = "http://127.0.0.1:28891/sgv.json?count=3&brief_mode=true"; //AAPS
      Sys.println("requestAAPS");
		  Communications.makeWebRequest(url, {}, {}, method(:onReceiveXdripOrAAPS));
    }
        
    function requestXdrip() {
//    message = " Xd "+  message;
		  var url = "http://127.0.0.1:17580/sgv.json?count=3"; //Xdrip
        Sys.println("requestXdrip");
		    Communications.makeWebRequest(url, {}, {}, method(:onReceiveXdripOrAAPS));
    }

    function onReceiveNS(responseCode, data) {
      System.println("onreceiveNS code="+responseCode+"   data="+data);
      var capteur = traiteNS(responseCode, data); //return [backGd_capteur_BG,backGd_capteur_delta,backGd_capteur_seconde];
      calculeSynchro(capteur[2], DelaiTemporalEventMinRestant());
      Background.exit(capteur);
    }

    function onReceiveXdripOrAAPS(responseCode, data) {
      var capteur = traiteXdripOrAAPS(responseCode, data); //return [backGd_capteur_BG,backGd_capteur_delta,backGd_capteur_seconde];
      calculeSynchro(capteur[2], DelaiTemporalEventMinRestant());
      Background.exit(capteur);
    }
  

    function DelaiTemporalEventMinRestant() {
        
        //var message;
        //var temporalMinRestant;

        var lastBackgroundMoment = Background.getLastTemporalEventTime();// as Time.Moment or Time.Duration or Null
        var delaiRestant=0;
        if (lastBackgroundMoment != null) {
          Sys.println("DelaiTemporalEventMinRestant temporal depuis = "+(Time.now().value() - lastBackgroundMoment.value()) +" sec");
            delaiRestant = 300 -Time.now().value() + lastBackgroundMoment.value();
        } else {
          Sys.println("DelaiTemporalEventMinRestant temporal null, delai = 0");

        }
        if (delaiRestant<2) {delaiRestant = 2;}
        Sys.println("DelaiTemporalEventMinRestant = "+delaiRestant);
        return delaiRestant;
    }



function verifie(tab) {
  System.println("Verifie tab "+tab);
  for (var i =0;i<tab.size();i++) {
    if ((tab[i] instanceof Number) || (tab[i] instanceof Long)) {
//      tab[i] = tab[i].toLong();
    } else {
      return null;
    }
  }
  return tab;
}



  
  function traiteNS(responseCode, data) {
    Sys.println("traiteNS");
    var backGd_capteur_BG = 0;
    var backGd_capteur_delta = 0;
    var backGd_capteur_seconde = Time.now().value() - 99*60;
		if ((responseCode == 200) &&
      (data != null) &&
      (data instanceof Dictionary)) {
      if (data.hasKey("buckets")) {
        var buckets = data["buckets"];
        if ((buckets != null) &&
          (buckets instanceof Array)) {
          if ((buckets[0] != null) &&
            (buckets[0] instanceof Dictionary) &&
            (buckets.size()>1) &&
            (buckets[1] != null) &&
            (buckets[1] instanceof Dictionary)) {
              var dataV = [0,0,0];
              if (buckets[0].hasKey("mills")) {
                dataV = verifie([buckets[0]["last"], buckets[1]["last"], buckets[0]["mills"]]);
              } else if (buckets[0].hasKey("sgvs")) {
                dataV = verifie([buckets[0]["sgvs"]["mgdl"], buckets[1]["sgvs"]["mgdl"], buckets[0]["sgvs"]["mills"]]);
              }
              if (dataV != null) {
                backGd_capteur_BG = dataV[0];
                backGd_capteur_delta = (backGd_capteur_BG-dataV[1]);
                backGd_capteur_seconde = dataV[2] / 1000;
                
              }
//              Sys.println("TROUVE 1--> BG="+backGd_capteur_BG+"  backGd_capteur_delta="+backGd_capteur_delta+"  il a "+(Time.now().value() - backGd_capteur_seconde)+" backGd_capteur_seconde");
          }
        }
      }
    }
    return [backGd_capteur_BG,backGd_capteur_delta,backGd_capteur_seconde];
  }


/* XDRIP
    http://127.0.0.1:17580/sgv.json?count=3

[ {  "date": 1721305582000, "sgv": 77, "delta": 3, "aaps-ts": 1721305307739 },
 {  "date": 1721305282000, "sgv": 74, "delta": 0 },
 {  "date": 1721304982000, "sgv": 74, "delta": -5}
 ]
*/


/* AAPS
    http://127.0.0.1:28891/sgv.json?count=3&brief_mode=true

[ { "date": 1721304381000, "sgv": 85, "delta": -7,"iob": 1.4554161003308, "tbr": 0, "cob": 11.2548235294118 }, 
{ "date": 1721304081000, "sgv": 92, "delta": -5.02 }, 
{ "date": 1721303782000, "sgv": 97 } ]
*/

 

// ---------------------------------
//data = [{"date"=>1721513780,"sgv"=>110,"delta"=>5,"direction"=>"Flat","units_hint"=>"mgdl","iob"=>0.4636757330454287,"tbr"=>0,"cob"=>11.931999999999974},{"date"=>1721513480,"sgv"=>105,"delta"=>5,"direction"=>"Flat"},{"date"=>1721513180,"sgv"=>100,"delta"=>5.02,"direction"=>"Flat"}];
//data = [ {  "date"=> 1721305582, "sgv"=> 77, "delta"=> 3, "aaps-ts"=> 1721305307 }, {  "date"=> 1721305282, "sgv"=> 74, "delta"=> 0 }, {  "date"=> 1721304982, "sgv"=> 74, "delta"=> -5} ];
    function traiteXdripOrAAPS(responseCode, data) {
  
        Sys.println("traiteXdripOrAAPS");
        var backGd_capteur_BG = 0;
        var backGd_capteur_delta = 0;
        var backGd_capteur_seconde = Time.now().value() - 99*60;
        //var message = responseCode;

        if ((responseCode == 200) &&
            (data != null) &&
        	(data instanceof Array) &&
            (data.size() >= 1) &&
            (data[0] != null) &&
            (data[1] != null) &&
            ! data[0].isEmpty() &&
            ! data[1].isEmpty()
            ) {
            if (data[0].hasKey("sgv") &&
                data[0].hasKey("date") &&
                data[1].hasKey("date") &&
                data[0].hasKey("delta")
                ) {
                var dataV = verifie([data[0]["sgv"],data[0]["delta"],data[0]["date"]]);
                if (dataV != null) {
                  backGd_capteur_BG = dataV[0];
                  backGd_capteur_delta = dataV[1];
                  backGd_capteur_seconde = dataV[2] / 1000;
                }

              }

      }
        return [backGd_capteur_BG,backGd_capteur_delta,backGd_capteur_seconde];
    }

    function calculeSynchro(backGd_capteur_seconde,temporalMinRestant) { // réglage prochain temporal event, 5 min au moins après le précédent, et juste après la prochaine lecture du capteur + tempo
        var TEMPO_WEB = [25,15,20];  //tempo pour que la nouvelle glycemie soit dispo sur Nightscout, Xdrip ou AAPS 
        System.println("start calculesynchro");
        var sourceBG = Application.getApp().getProperty("sourceBG");
        var tempoWeb = TEMPO_WEB[sourceBG];
        var timeNowValue = Time.now().value();
        Sys.println("calculeSynchro 0 temporalMinRestant = "+temporalMinRestant);

        var capteurRestant = 0;
        var capteurElapsed = 300 + tempoWeb;
        if (backGd_capteur_seconde != null) {
            capteurElapsed = timeNowValue - backGd_capteur_seconde;
            capteurRestant =  300 - capteurElapsed + tempoWeb; //
        }
        var capteurCorrige = capteurRestant % 300 + 300; // de 300 à 599
        Sys.println("calculeSynchro 1 capteurElapsed = " +capteurElapsed);
        Sys.println("calculeSynchro 2 capteurRestant = " +capteurRestant);
        Sys.println("calculeSynchro 3 capteurCorrige = " +capteurCorrige);


        var timeTempo;
        if ((capteurRestant - 10 <= temporalMinRestant) && (capteurRestant + 10 >= temporalMinRestant)) { // on de donne une marge
          timeTempo = temporalMinRestant;
          Sys.println("calculeSynchro 4.1 Pose de temporalMinRestant = "+timeTempo);
        } else {
              timeTempo = capteurCorrige;
              Sys.println("calculeSynchro 4.2 Pose de capteurCorrige  = "+timeTempo);
        }

        if (timeTempo < 2) {
          timeTempo = 2;
          Sys.println("calculeSynchro 5.1 Correction < 2  = "+timeTempo);
        }
         if (timeTempo < temporalMinRestant) {
          timeTempo = temporalMinRestant;
          Sys.println("calculeSynchro 5.2 Correction finale avec temporalMinRestant  = "+timeTempo);
        }
        Background.registerForTemporalEvent(Time.now().add(new Time.Duration(timeTempo))); 
        Sys.println("calculeSynchro 6 reelTempo final posee = " + timeTempo);

        Sys.println("calculeSynchro fin OK--------------------------------------------------------------------");
    }


}
