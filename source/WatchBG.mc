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

using Toybox.Background;
using Toybox.Communications;
using Toybox.System as Sys;
using Toybox.Time.Gregorian as Calendar;

// The Service Delegate is the main entry point for background processes
// our onTemporalEvent() method will get run each time our periodic event
// is triggered by the system.

(:background)
class WatchBG extends Toybox.System.ServiceDelegate {
    var receiveCtr = 0;
    //var bgdata = {};
    var reqNum = 0;
    //var propReq = {};




    function initialize() {
        Sys.ServiceDelegate.initialize();
    }

    function onTemporalEvent() {
        Sys.println("in onTemporalEvent");
        receiveCtr = 0;
        reqNum = 0;
        myWebRequest(true, 1, false);
        //Sys.println("onTemporalEvent receiveCtr="+receiveCtr);

    }

	function removeWhitespace(url) {
		while(!url.equals("") &&
		      url.substring(0,1).equals(" ")) {
		    url = url.substring(1,url.length());
        }
		while(!url.equals("") &&
		      url.substring(url.length()-1,url.length()).equals(" ")) {
		    url = url.substring(0,url.length()-1);
        }
        while(url.substring(url.length()-1,url.length()).equals("/")) {
		    url = url.substring(0,url.length()-1);
        }
        if (url.substring(url.length()-9,url.length()).equals("/sgv.json")) {
		    url = url.substring(0,url.length()-9);
        }
		return url;
	}


    function makeNSURL(fetchMode, loop) {
        var thisApp = Application.getApp();
        var url = thisApp.getProperty("NSurl");
        var utilisateurNS = thisApp.getProperty("NStoken");
		var token = "";
		if ((utilisateurNS != null) && (! utilisateurNS.equals(""))) {token = "?token="+utilisateurNS;}
		
		url = url+token;
		if (url == null) { url = ""; }

		url = removeWhitespace(url);

        if (!url.equals("")) {
        	var options = "";
	        if (url.find("://") == null) {
    	        url = "https://" + url;
        	}
	        if (url.find("?") != null) {
	        	// support token based nightscout authentication, set NS URL = your-site.herokuapp.com?token=your-token
	        	options = "&" + url.substring(url.find("?")+1,url.length());
			    url = url.substring(0,url.find("?"));
				url = removeWhitespace(url);
	        }
			url = url + "/api/v1/entries/sgv.json?count=3/";
			url = url + options;
	   	}
		//System.println("makeNSURL "+url);
        return url;
	}

    function myWebRequest(ns, fetchMode, loop) {
		var url;
		var sourceBG = Application.getApp().getProperty("sourceBG");
		if (sourceBG==0) {
			url = makeNSURL(fetchMode, loop);//Nightscout
		} else if (sourceBG == 1) {
			url = "http://127.0.0.1:28891/sgv.json?count=3&brief_mode=true"; //AAPS
		} else if (sourceBG == 2) {
			url = "http://127.0.0.1:17580/sgv.json?count=3" ; //xdrip
		}
		traiteDebugSent(sourceBG);
		receiveCtr++;
		reqNum++;
		Sys.println("request url: " + url);
		Communications.makeWebRequest(url, {}, { :method => Communications.HTTP_REQUEST_METHOD_GET,
														:headers => {                                           // set headers
																"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
														:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
													}, method(:onReceiveSGV));
		return true;
    } 

  	function traiteDebugSent(sourceBG) {
	 	var sourceText = ["NS","AAPS","Xd+"][sourceBG];
        var info = Calendar.info(Time.now(), Time.FORMAT_LONG);
        var timeString = Lang.format("$1$:$2$:$3$", [info.hour, info.min.format("%02d"),info.sec.format("%02d")]);

        var debugInfos = "demandé à \n" +timeString + "                         ";

        Application.Storage.setValue("debugData", "Attente réponse\nde "+sourceText);
        Application.Storage.setValue("debugInfos", debugInfos);
	}

    function onReceiveSGV(responseCode, data) {//si coderesponse 404=pas de réseau
        Sys.println("in OnReceiveSGV  responseCode="+ responseCode);
		var timeMillis=0;
		var sgv=0;
		var delta=0;
        var validData = false;
        if ((responseCode == 200) &&
            (data != null) &&
        	(data instanceof Array) &&
            (data.size() > 1) &&
            (data[0] != null) &&
            (data[1] != null) &&
            !data[0].isEmpty() &&
            !data[1].isEmpty()
            ) {
            //bgdata["sgv"] = data;
            if (data[0].hasKey("sgv") &&
                data[0].hasKey("date") &&
                data[0].hasKey("delta")
                ) {
                timeMillis = data[0]["date"].toLong();
				sgv = data[0]["sgv"].toNumber();
				delta = data[0]["delta"].toNumber();
	            Sys.println("onReceiveSGV valid data: " + sgv + "  "+delta + "  "+timeMillis);
                validData = true;
            }
            //bgdata["elapsedMills"] = elapsedMills;
        } else {
            Sys.println("onReceiveSGV SGV resp: " + responseCode.toString());
            Sys.println("onReceiveSGV data: " + data);
        }
        Sys.println("onReceiveSGV receiveCtr = "+receiveCtr);
		receiveCtr--;
        if  (validData) {
            var capteur = [sgv,delta,timeMillis/1000];
            Sys.println("onReceiveSGV call OnBackground.exit capteur="+capteur);
            Background.exit([capteur, data]);
        }
        
        Sys.println("out OnReceiveSGV pas bon");
    }


}
