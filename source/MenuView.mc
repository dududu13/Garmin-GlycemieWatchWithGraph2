
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;

(:onlyWionlyWithSettingOnWatchfacethMenus)
class MenuView extends Ui.View {
	var _titre;
	var _tab;
	var _nbre;
	var _x;
	var _posAff;
	var itemEnCours;
	var item0;
	var nbreAff,nbreAffDepart;
	var centrex,centrey;
	var transparent = Gfx.COLOR_TRANSPARENT;
	var coeff;
	var hFont;
	var font = Gfx.FONT_MEDIUM;

	//var itemString;   // when outputing the menu, you can recupere the item (number of the line) or itemstring

    function initialize(titre,tab,posAff) {

		View.initialize();
    	_tab = tab;
		_titre = titre;					// tab of strings  = lines of the menu
    	itemEnCours = posAff;

    	_nbre = tab.size()-1;		// number of items in the menu
		if (itemEnCours>tab.size()) {itemEnCours = _nbre;}				// 1er affich 
		nbreAff = 5;
		item0 = 0;
		nbreAffDepart = nbreAff;
		if (nbreAff > _nbre ) {nbreAff = _nbre;}

		System.println("Initialize MenuView "+_titre);
    }

    function onLayout(dc) {
		System.println("onLayout MenuView "+_titre);
		hFont = Gfx.getFontHeight(font);
		itemEnCours = calculeItem0(0);
		_x = dc.getWidth()/2;
		coeff = dc.getWidth()/218.0;
		//if (Toybox.Graphics has :BufferedBitmap) {dc.clearClip();}
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(3*coeff);

    }



    function onUpdate(dc) {
System.println("UPDATE nbre="+_nbre+"  nbreAff="+nbreAff+"  item0="+item0+"  itemEnCours="+itemEnCours);
    	var y;
		var coulFond = Gfx.COLOR_BLACK;
		var coulPP = Gfx.COLOR_WHITE;
	    dc.setColor(coulPP, coulFond );
		dc.clear();
		//Title
		y = hFont+25*coeff;		
		dc.setColor( coulPP, Gfx.COLOR_TRANSPARENT );
		dc.fillRectangle(0, 0, dc.getWidth(), y-2);
		dc.setColor( coulFond, Gfx.COLOR_TRANSPARENT );
		dc.drawText(dc.getWidth()/2, y/2, font, _titre, Gfx.TEXT_JUSTIFY_CENTER+Gfx.TEXT_JUSTIFY_VCENTER); 

		// lignes
		dc.setColor( coulPP, Gfx.COLOR_TRANSPARENT );
		for (var i=item0;i<item0+nbreAff;i++) {
			if (i==itemEnCours) {
				dc.fillRectangle(0,y,dc.getWidth(),hFont);
				dc.setColor( coulFond,Gfx.COLOR_TRANSPARENT );
			}
			dc.drawText(_x, y, font, _tab[i], Gfx.TEXT_JUSTIFY_CENTER); 
			dc.setColor(coulPP, Gfx.COLOR_TRANSPARENT );
			y = y + hFont;
			if (i!=itemEnCours) {dc.drawLine(0,y,dc.getWidth(),y);}
		}
		if (item0+nbreAff < _tab.size()) {
			dc.drawText(_x, y, font, _tab[item0+nbreAff] , Gfx.TEXT_JUSTIFY_CENTER);
			
		}
		if (item0+1+nbreAff < _tab.size()) {
			dc.drawLine(0,y+ hFont,dc.getWidth(),y+ hFont);
			y = y + hFont;
			dc.drawText(_x, y, font, _tab[item0+1+nbreAff] , Gfx.TEXT_JUSTIFY_CENTER);
		}
	}
//item0 = celui du haut
//itemEnCours  = celui selectionné
	function calculeItem0(delta) {

		nbreAff = nbreAffDepart;
		itemEnCours = (itemEnCours+delta+_nbre+1) % (_nbre+1);
		if (item0>itemEnCours) {item0=itemEnCours;}
		if (itemEnCours>nbreAff-1+item0) {item0=itemEnCours-nbreAff+1;}
		if (itemEnCours<item0) {item0=itemEnCours;}
		if (itemEnCours>nbreAff-1+item0) {item0=itemEnCours-nbreAff+1;}
		if (_nbre<nbreAff) {
			nbreAff = _nbre+1;
			item0 = 0;
		}
System.println("APRES CALCUL nbre="+_nbre+"  nbreAff="+nbreAff+"  item0="+item0+"  itemEnCours="+itemEnCours);
return itemEnCours;
	}
	
	function prev() {
		calculeItem0(-1);
		Ui.requestUpdate();
	}

    function next() {
		calculeItem0(1);
		Ui.requestUpdate();
	}


}
