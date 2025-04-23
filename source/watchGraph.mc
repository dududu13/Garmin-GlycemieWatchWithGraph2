import Toybox.Lang;


using Toybox.Application.Properties;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.WatchUi as Ui;
using Toybox.Math;


class watchGraph  {
  private const HAUTEUR_GRAPH_EPIX as Number = 80.0;
  private const MIN_GLUCOSE = 50; // valeur mini sur affichage (pour ne pas afficher depuis zéro)
  private const BG_BAS = 70;
  private const BG_HAUT = 170;
  private const posY_EPIX = 300;
  private const XoffsetDroite_EPIX = 80;
  private const XoffsetGauche_EPIX = 30;

  private var coeff = System.getDeviceSettings().screenHeight/416.0;

  private var HAUTEUR_GRAPH = HAUTEUR_GRAPH_EPIX * coeff;
  private var posY = posY_EPIX * coeff;
  private var XoffsetDroite = XoffsetDroite_EPIX * coeff;
  private var XoffsetGauche = XoffsetGauche_EPIX * coeff;


  private var glucoseBarWidthSec as Number = 5 * 60; // 5 minutes
  private var glucoseBarPaddingPixel as Number = 1;
  private var glucoseBarWidthPixel; //as Number = XoffsetDroite / (nbHGraph*12) - glucoseBarPaddingPixel;
  private var data = new[0];
  private var maxGlucose = MIN_GLUCOSE;
  private var MIN_GLUCOSE1;
  private var BG_BAS1;
  private var BG_HAUT1;


  private var lowGlucoseColor = Gfx.COLOR_RED;
  private var lowGlucoseHighlightColor = Gfx.COLOR_DK_RED;
  private var normalGlucoseColor = 0x55FF55;
  private var normalGlucoseHighlightColor = Gfx.COLOR_DK_GREEN;
  private var highGlucoseColor = 0xFFFF55;
  private var highGlucoseHighlightColor = 0xFFFF00;

  function initialize() {
    System.println("Graph INIT");

  }
  function calcule_tout(data) {
    me.data = data;
  }

  function log(val) {
    if (! logarithmique) { return val;}
    var log = Math.ln(val);
    if (log < MIN_GLUCOSE1) {
      log = MIN_GLUCOSE1+.1;
    }
    //System.println(val+"   "+MIN_GLUCOSE+"   "+log);
    return log;
  }

  function dessine_tout(dc) {
    var totalPixel = dc.getWidth()-XoffsetGauche-XoffsetDroite;
    glucoseBarWidthPixel = (totalPixel/([1,2,4,6][nbHGraph]*12)- glucoseBarPaddingPixel).toNumber();
    //System.println("param = "+nbHGraph+"  nbh = "+[1,2,4,6][nbHGraph] +"  log ? "+logarithmique);

    if (logarithmique) { MIN_GLUCOSE1 = Math.ln(MIN_GLUCOSE);}
    else {MIN_GLUCOSE1 = MIN_GLUCOSE;}
    BG_BAS1 = log(BG_BAS);
    BG_HAUT1 = log(BG_HAUT);
    maxGlucose = MIN_GLUCOSE1;
    var tabData = new[0];
    for (var i=0 ; i<data.size() ; i++) {
      var gl = log(data[i][0]);
      tabData.add(gl);
      if ( gl>maxGlucose) {
        maxGlucose = gl;
      }
    }
    var x = (dc.getWidth()-XoffsetDroite);
    var yLow = getYForGlucose(BG_BAS1);
    var yHigh = getYForGlucose(BG_HAUT1);
    for (var i = tabData.size()-1 ; i>=0 ; i = i-1) {
      var BG = (tabData[i]);
      x = x-glucoseBarWidthPixel-1;
      if (x<XoffsetGauche) {
        break;
      }
      var gl = BG;
      var y = getYForGlucose(gl);
      var yHaut = y+posY;
      //System.println("yhight="+yHigh+"  yLow="+yLow+"  x="+x);
      

      //var hlColor = highGlucoseHighlightColor;
      if (gl < BG_BAS1) {
        drawRectangle(dc, lowGlucoseColor, x, yHaut, glucoseBarWidthPixel, HAUTEUR_GRAPH - y);
        //hlColor = lowGlucoseHighlightColor;
      } else if (gl < BG_HAUT1) {
        drawRectangle(dc, lowGlucoseColor, x, yLow+posY, glucoseBarWidthPixel, HAUTEUR_GRAPH - yLow);
        drawRectangle(dc, normalGlucoseColor, x, yHaut, glucoseBarWidthPixel, yLow - y);
        //hlColor = normalGlucoseHighlightColor;
      } else {
        drawRectangle(dc, lowGlucoseColor, x, yLow+posY, glucoseBarWidthPixel, HAUTEUR_GRAPH - yLow);
        drawRectangle(dc, normalGlucoseColor, x, yHigh+posY, glucoseBarWidthPixel, yLow - yHigh);
        drawRectangle(dc, highGlucoseColor, x, yHaut, glucoseBarWidthPixel, yHigh - y);
      }
      //drawRectangle(dc, hlColor, x, yHaut, glucoseBarWidthPixel, 3);
    }

  }

  private function getYForGlucose(glucose as Number) as Number {
    return (HAUTEUR_GRAPH * (maxGlucose - glucose) / (maxGlucose - MIN_GLUCOSE1)).toNumber();
  }


  function drawRectangle(dc, color,x , y , w, h) as Void {
    //System.println("x="+x+" y="+y+" w="+w+" h="+h);
    dc.setColor(color, Gfx.COLOR_TRANSPARENT);
    dc.fillRectangle(x,y, w, h);
  }

}
