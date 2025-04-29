
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

    function onSettingsChanged() {
        myView.readSettings();
        WatchBG.registerASAP();
		return true; 
    }

    function getInitialView() {
        //System.println("start getInitialView()");
        myView = new WatchView();
        return [ myView, new WatchDelegate()];
    }

    function getServiceDelegate() { //lance le service Background, et le premier appel
        //System.println("APP call gestService Delegate");
        Background.deleteTemporalEvent();
        var BGservice = new WatchBG();
        WatchBG.registerASAP();
        WatchBG.setCapteurChanged(true);
        return [BGservice];
    }



(:onlyWithSettingOnWatchface)
    function getSettingsView() {
        if (Sys.getDeviceSettings().isTouchScreen) {
            return [new $.ViewSettings(), new $.ViewSettingsDelegate()];
        } else {
            var menuSettings =  menuPrincipal(0);
            return [menuSettings, new $.MenuPrincipalDelegate(menuSettings),Ui.SLIDE_RIGHT];
        }
    }


(:onlyWithSettingOnWatchface)
    public function menuPrincipal(position) {
        var ligne1 = afficheMeteo ?  "Graph I/O meteo" : "Meteo I/O graph";
        var ligne0 = afficheSecondes ? "Set seconds OFF" : "Set seconds ON" ;
        return  new $.MenuView("Settings "+Ui.loadResource(Rez.Strings.version),[ligne0,ligne1,"Graph options","BG source"],position);
    }
}

