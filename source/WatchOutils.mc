using Toybox.Communications;
using Toybox.Application as App;
using Toybox.Time;
using Toybox.System as Sys;


class WatchOutils {

    function storeData(tabData) {
      System.println("debut store données ="+tabData);
      var st = "";
      for (var i = 0;i<tabData.size();i++) {
        st=st+tabData[i][0].toString()+";"+tabData[i][1].toString()+";"+tabData[i][2].toString()+";";
      }
      Application.Storage.setValue("data",st);
      App.Storage.setValue("capteur_seconde",tabData[tabData.size()-1][2].toString());//pour la synchro background, la seconde de la dernière lecture
      System.println("fin store données ="+st);
    }

    function readStoredData() {
      System.println("readStoredData");
        var st = Application.Storage.getValue("data");
        var tab=new[0];
        //System.println("charge Data : " +st);
        if ((st == null) || (st.length() < 3)) {
            return tab;
        }
        var	n1 = st.find(";");
        while (n1 != null) {
            var value = st.substring(0,n1).toNumber();
            st = st.substring(n1+1,st.length());
            n1 = st.find(";");
            var delta = st.substring(0,n1).toNumber();
            st = st.substring(n1+1,st.length());
            n1 = st.find(";");
            var seconde = st.substring(0,n1).toNumber();
            st = st.substring(n1+1,st.length());
            n1 = st.find(";");
            tab.add([value,delta,seconde]);
        }
        //System.println("fin charge data ="+tab);
        return tab;
    }



}