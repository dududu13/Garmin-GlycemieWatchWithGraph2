
using Toybox.Application as App;
using Toybox.Background;
using Toybox.Time;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

// NOTE: every object created here uses memory in the background process (as well as the watchface process.)
//       the background app is extremely limited in memory (32KB), so only define what is absolutely needed.

const NBRE_MAXI_DATA = 72;//6h

(:background)
var myView;


(:background)
var capteur_seconde=0;

var sourceBG,afficheSecondes,afficheMeteo,nbHGraph,logarithmique;

(:background)
class WatchApp extends App.AppBase {


    function initialize() {
        AppBase.initialize();       
    }

(:onlyWithSettingOnWatchface)
    function getSettingsView() {
        if (Sys.getDeviceSettings().isTouchScreen) {
            var view = new $.ViewSettings();
            return [view, new $.ViewSettingsDelegate()];
        } else {
            var menuSettings =  menuPrincipal(0);
            return [menuSettings, new $.MenuPrincipalDelegate(menuSettings),Ui.SLIDE_RIGHT];
        }
    }





    function onSettingsChanged() {
        if (myView != null) {myView.readSettingsAndInitGraph();}
		return true; 
    }

    function getInitialView() {
        System.println("start getInitialView()");
        myView = new WatchView();
        return [ myView, new WatchDelegate()];
        //var myView2 = new SettingsDureeGraphView();
        //return [ myView2, new WatchDelegate()];
    }

    function onBackgroundData(capteur) {
        if (myView == null) {return;}
        if (capteur==null) { return;}
        if (! (capteur instanceof Toybox.Lang.Array)) {return;}
        if (capteur.size()<1) {return;}
        if (capteur[0]>0) {
            myView.addCapteur(capteur);

        }
    }



    function getServiceDelegate() { //lance le service Background, et le premier appel
        System.println("APP call gestService Delegate");
        var BGservice = new WatchBG();
        return [BGservice];
    }

(:onlyWithSettingOnWatchface)
    public function menuPrincipal(position) {
        var ligne1 = afficheMeteo ?  "Graph I/O meteo" : "Meteo I/O graph";
        var ligne0 = afficheSecondes ? "Set seconds OFF" : "Set seconds ON" ;
        return  new $.MenuView("Settings "+Ui.loadResource(Rez.Strings.version),[ligne0,ligne1,"Graph options","BG source"],position);
    }
}

