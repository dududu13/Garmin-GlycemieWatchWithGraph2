import Toybox.Lang;


using Toybox.Application.Properties;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.WatchUi as Ui;
using Toybox.Math;


class WatchGraphique  {
  private const HAUTEUR_GRAPH_EPIX as Number = 80.0;
  private const MIN_GLUCOSE = 50; // valeur mini sur affichage (pour ne pas afficher depuis zéro)
  private const BG_BAS = 70;
  private const BG_HAUT = 170;
  private const posY_EPIX = 300;
  private const XoffsetDroite_EPIX = 80;
  private const XoffsetGauche_EPIX = 70;

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

 var tabData;
    var x ;
    var yLow ;
    var yHigh;

  private var lowGlucoseColor = Gfx.COLOR_RED;
  private var lowGlucoseHighlightColor = Gfx.COLOR_DK_RED;
  private var normalGlucoseColor = 0x55FF55;
  private var normalGlucoseHighlightColor = Gfx.COLOR_DK_GREEN;
  private var highGlucoseColor = 0xFFFF55;
  private var highGlucoseHighlightColor = 0xFFFF00;
  //private var 

  function initialize(data) {
    System.println("Graph INIT");
    calcule_tout(data);
  }

  function calcule_tout(data) {
    System.println("GraphData calcule tout avec data="+data);
    //logarithmique = Application.getApp().getProperty("logarithmique");
    if (logarithmique == null) {logarithmique = false;}
    //nbHGraph  = Application.getApp().getProperty("nbHGraph");
    if ((nbHGraph == null) || (nbHGraph>3)) {nbHGraph = 3;}
    System.println("graph calcul tout");
    //me.data = data;
    var witdth = System.getDeviceSettings().screenWidth;
    var totalPixel = witdth-XoffsetGauche-XoffsetDroite;
    glucoseBarWidthPixel = (totalPixel/([1,2,4,6][nbHGraph]*12)- glucoseBarPaddingPixel+.5).toNumber();
//System.println("(totalPixel/([1,2,4,6][nbHGraph]*12)- glucoseBarPaddingPixel) = "+(totalPixel/([1,2,4,6][nbHGraph]*12)- glucoseBarPaddingPixel)+"  glucoseBarWidthPixel = "+glucoseBarWidthPixel);

    if (logarithmique) { MIN_GLUCOSE1 = Math.ln(MIN_GLUCOSE);}
    else {MIN_GLUCOSE1 = MIN_GLUCOSE;}
    BG_BAS1 = log(BG_BAS);
    BG_HAUT1 = log(BG_HAUT);
    maxGlucose = MIN_GLUCOSE1;
     tabData = new[0];
    for (var i=0 ; i<data.size() ; i++) {
      var gl;
      if (data[i][0] == 0) {gl = 0;}
      else {gl = log(data[i][0]);}
      tabData.add(gl);
      if ( gl>maxGlucose) {
        maxGlucose = gl;
      }
    }
     yLow = getYForGlucose(BG_BAS1);
     yHigh = getYForGlucose(BG_HAUT1);
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
    x = (System.getDeviceSettings().screenWidth-XoffsetDroite);
    //var x0 = x;
    //System.println("dessine tout graph tabdata="+tabData);
    for (var i = tabData.size()-1 ; i>=0 ; i = i-1) {
      var BG = (tabData[i]);
      x = x-glucoseBarWidthPixel-1;
      if (x<0) {
        break;
      }
      var gl = BG;
      var y = getYForGlucose(gl);
      var yHaut = y+posY;
      if (gl == 0) {} // un vide si plycemie = 0
      else if (gl < BG_BAS1) {
        drawRectangle(dc, lowGlucoseColor, x, yHaut, glucoseBarWidthPixel, HAUTEUR_GRAPH - y);
      } else if (gl < BG_HAUT1) {
        drawRectangle(dc, lowGlucoseColor, x, yLow+posY, glucoseBarWidthPixel, HAUTEUR_GRAPH - yLow);
        drawRectangle(dc, normalGlucoseColor, x, yHaut, glucoseBarWidthPixel, yLow - y);
      } else {
        drawRectangle(dc, lowGlucoseColor, x, yLow+posY, glucoseBarWidthPixel, HAUTEUR_GRAPH - yLow);
        drawRectangle(dc, normalGlucoseColor, x, yHigh+posY, glucoseBarWidthPixel, yLow - yHigh);
        drawRectangle(dc, highGlucoseColor, x, yHaut, glucoseBarWidthPixel, yHigh - y);
      }
      //drawRectangle(dc, hlColor, x, yHaut, glucoseBarWidthPixel, 3);
    }
    drawScale(dc);
  }

  private function drawScale(dc) {
    var nbH = [1,2,4,6][nbHGraph];
    var y = posY + HAUTEUR_GRAPH;
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawText(dc.getWidth()/2, y ,Gfx.FONT_SYSTEM_XTINY,nbH+" h",Gfx.TEXT_JUSTIFY_CENTER);

    var witdth = System.getDeviceSettings().screenWidth;
    var hourPixel = (glucoseBarWidthPixel+1)*12;
    var x = witdth - XoffsetDroite;
    dc.setPenWidth(2);
    for (var i = 0;i<=nbH;i++) {
      dc.drawLine(x,y-1,x- hourPixel,y-1);
      dc.drawLine(x,y+5,x,y);
      x = x - hourPixel;
    }

  }

  private function getYForGlucose(glucose as Number) as Number {
    if (maxGlucose == MIN_GLUCOSE1) {return HAUTEUR_GRAPH;}
    return (HAUTEUR_GRAPH * (maxGlucose - glucose) / (maxGlucose - MIN_GLUCOSE1)).toNumber();
  }


  function drawRectangle(dc, color,x , y , w, h) as Void {
    //System.println("x="+x+" y="+y+" w="+w+" h="+h);
    dc.setColor(color, Gfx.COLOR_TRANSPARENT);
    dc.fillRectangle(x,y, w, h);
  }

}
