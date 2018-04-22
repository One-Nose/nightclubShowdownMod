import h2d.Sprite;
import mt.heaps.HParticle;
import mt.deepnight.Lib;
import mt.deepnight.Color;
import mt.deepnight.Tweenie;
import mt.MLib;


class Fx extends mt.Process {
	public var pool : ParticlePool;

	public var bgAddSb    : h2d.SpriteBatch;
	public var bgNormalSb    : h2d.SpriteBatch;
	public var topAddSb       : h2d.SpriteBatch;
	public var topNormalSb    : h2d.SpriteBatch;

	var game(get,never) : Game; inline function get_game() return Game.ME;
	var level(get,never) : Level; inline function get_level() return Game.ME.level;

	public function new() {
		super(Game.ME);

		pool = new ParticlePool(Assets.gameElements.tile, 2048, Const.FPS);

		bgAddSb = new h2d.SpriteBatch(Assets.gameElements.tile);
		game.scroller.add(bgAddSb, Const.DP_FX_BG);
		bgAddSb.blendMode = Add;
		bgAddSb.hasRotationScale = true;

		bgNormalSb = new h2d.SpriteBatch(Assets.gameElements.tile);
		game.scroller.add(bgNormalSb, Const.DP_FX_BG);
		bgNormalSb.hasRotationScale = true;

		topNormalSb = new h2d.SpriteBatch(Assets.gameElements.tile);
		game.scroller.add(topNormalSb, Const.DP_FX_TOP);
		topNormalSb.hasRotationScale = true;

		topAddSb = new h2d.SpriteBatch(Assets.gameElements.tile);
		game.scroller.add(topAddSb, Const.DP_FX_TOP);
		topAddSb.blendMode = Add;
		topAddSb.hasRotationScale = true;
	}

	override public function onDispose() {
		super.onDispose();

		pool.dispose();

		bgAddSb.remove();
		bgNormalSb.remove();
		topAddSb.remove();
		topNormalSb.remove();
	}


	public inline function allocTopAdd(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(topAddSb, t, x, y);
	}

	public inline function allocTopNormal(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(topNormalSb, t,x,y);
	}

	public inline function allocBgAdd(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(bgAddSb, t,x,y);
	}

	public inline function allocBgNormal(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(bgNormalSb, t,x,y);
	}

	public inline function getTile(id:String) : h2d.Tile {
		return Assets.gameElements.getTileRandom(id);
	}

	public function killAll() {
		pool.killAll();
	}

	public function markerEntity(e:Entity, ?c=0xFF00FF, ?short=false) {
		#if debug
		if( e==null )
			return;

		markerCase(e.cx, e.cy, c, short);
		#end
	}

	public function markerCase(cx:Int, cy:Int, ?c=0xFF00FF, ?short=false) {
		var p = allocTopAdd(getTile("circle"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.frict = 0.92;
		p.lifeS = short ? 0.06 : 3;

		var p = allocTopAdd(getTile("dot"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(2);
		p.frict = 0.92;
		p.lifeS = short ? 0.06 : 3;
	}

	public function markerFree(x:Float, y:Float, ?c=0xFF00FF, ?short=false) {
		var p = allocTopAdd(getTile("dot"), x,y);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(3);
		p.dr = 0.3;
		p.frict = 0.92;
		p.lifeS = short ? 0.06 : 3;
	}

	public function markerText(cx:Int, cy:Int, txt:String, ?t=1.0) {
		var tf = new h2d.Text(Assets.font, topNormalSb);
		tf.text = txt;

		var p = allocTopAdd(getTile("circle"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.colorize(0x0080FF);
		p.frict = 0.92;
		p.alpha = 0.6;
		p.lifeS = 0.3;
		p.fadeOutSpeed = 0.4;
		p.onKill = tf.remove;

		tf.setPos(p.x-tf.textWidth*0.5, p.y-tf.textHeight*0.5);
	}

	public function flashBangS(c:UInt, a:Float, ?t=0.1) {
		var e = new h2d.Bitmap(h2d.Tile.fromColor(c,1,1,a));
		game.root.add(e, Const.DP_FX_TOP);
		e.scaleX = game.w();
		e.scaleY = game.h();
		e.blendMode = Add;
		game.tw.createS(e.alpha, 0, t).end( function() {
			e.remove();
		});
	}

	function collGround(p:HParticle) {
		return level.hasColl( Std.int(p.x/Const.GRID), Std.int((p.y+1)/Const.GRID) );
	}
	function _bloodPhysics(p:HParticle) {
		if( collGround(p) && Math.isNaN(p.data0) ) {
			p.data0 = 1;
			p.gy = 0;
			p.dx*=0.5;
			p.dy = 0;
			p.dr = 0;
			p.rotation = 0;
		}
	}

	public function shoot(fx:Float, fy:Float, tx:Float, ty:Float, c:UInt) {
		var dir = fx<tx ? 1 : -1;
		var a = Math.atan2(ty-fy, tx-fx);
		a = Lib.angularClampRad(a, dir==1 ? 0 : 3.14, 0.1);

		// Core
		for(i in 0...4) {
			var d = i<=2 ? 0 : rnd(0,5);
			var p = allocTopAdd(getTile("dot"), fx+Math.cos(a)*d, fy+Math.sin(a)*d);
			p.setFadeS(rnd(0.6,1), 0, rnd(0.1,0.12));
			p.colorize(c);
			p.setCenterRatio(0,0.5);

			p.scaleX = rnd(8,15);
			p.scaleXMul = rnd(0.9,0.97);

			//p.moveAng(a, rnd(1,3));
			p.rotation = a;
			p.lifeS = 0;
		}

		// Core sides
		for(i in 0...20) {
			var a = a + rnd(0.2,0.5, true);
			var d = i<=2 ? 0 : rnd(0,5);
			var p = allocTopAdd(getTile("dot"), fx+Math.cos(a)*d, fy+Math.sin(a)*d);
			p.setFadeS(rnd(0.4,0.6), 0, rnd(0.1,0.12));
			p.colorize(0xF5450A);
			p.setCenterRatio(0,0.5);

			p.scaleX = rnd(3,5);
			p.scaleXMul = rnd(0.9,0.97);

			p.rotation = a;
			p.lifeS = 0;
		}

		// Shoot line
		var n = 40;
		var d = Lib.distance(fx,fy,tx,ty);
		for(i in 0...n) {
			var d = 0.8 * d*i/(n-1) + rnd(0,6);
			var p = allocTopAdd(getTile("dot"), fx+Math.cos(a)*d, fy+Math.sin(a)*d);
			p.setFadeS(rnd(0.4,0.6), 0, rnd(0.1,0.12));
			p.colorize(c);

			p.scaleX = rnd(2,4);
			p.moveAng(a, rnd(2,10));
			p.frict = 0.8;
			p.gy = rnd(0,0.1);
			p.scaleXMul = rnd(0.9,0.97);

			p.rotation = a;
			p.lifeS = 0;
		}
	}


	public function bloodHit(fx:Float, fy:Float, x:Float, y:Float) {
		var dir = fx<x ? -1 : 1;
		// Dots
		var n = 40;
		for( i in 0...n) {
			var p = allocTopNormal(getTile("dot"), x+rnd(0,3,true), y+rnd(0,4,true));
			p.colorize( Color.interpolateInt(0xFF0000,0x6F0000, rnd(0,1)) );
			p.dx = dir * (i<=10 ? rnd(3,12) : rnd(1,5) );
			p.dy = rnd(-2,1);
			p.gy = rnd(0.1,0.2);
			p.frict = rnd(0.85,0.96);
			p.lifeS = rnd(1,3);
			p.setFadeS(rnd(0.7,1), 0, rnd(3,7));
			p.onUpdate = _bloodPhysics;
			p.delayS = i>20 ? rnd(0,0.1) : 0;
		}

		// Line
		var n = 40;
		var a = 3.14 + Math.atan2(y+rnd(0,3,true)-fy, x+rnd(0,3,true)-fx);
		a = Lib.angularClampRad(a, dir==1 ? 3.14 : 0, 0.2);
		for( i in 0...n) {
			var a = a+rnd(0,0.03,true);
			var d = rnd(0,15);
			var p = allocTopNormal(getTile("dot"), x+Math.cos(a)*d, y+Math.sin(a)*d+rnd(0,1,true));
			p.colorize( Color.interpolateInt(0xFF0000,0x6F0000, rnd(0,1)) );
			p.scaleX = rnd(1,3);
			p.scaleXMul = rnd(0.92,0.97);
			p.moveAng(a, (i<=10 ? rnd(1,4) : rnd(0.2,1.5) ));
			p.rotation = a;
			p.gy = rnd(0.005,0.010);
			p.frict = rnd(0.97,0.98);
			p.lifeS = rnd(1,3);
			p.setFadeS(rnd(0.7,1), 0, rnd(3,7));
			p.onUpdate = _bloodPhysics;
			p.delayS = i>20 ? rnd(0,0.1) : 0;
		}
	}

	public function headShot(fx:Float, fy:Float, x:Float, y:Float, dir:Int) {
		// Blood dots
		var n = 40;
		for( i in 0...n) {
			var p = allocTopNormal(getTile("dot"), x+rnd(0,3,true), y+rnd(0,4,true));
			p.colorize( Color.interpolateInt(0xFF0000,0x6F0000, rnd(0,1)) );
			p.scaleX = rnd(1,3);
			p.scaleX = rnd(1,1.5);
			p.rotation = rnd(0,6.28);
			p.dr = dir*rnd(0.2,0.4);
			p.dx = dir * (i<=10 ? rnd(3,12) : rnd(1,5) );
			p.dy = rnd(-2,1);
			p.gy = rnd(0.1,0.2);
			p.frict = rnd(0.85,0.96);
			p.lifeS = rnd(1,3);
			p.setFadeS(rnd(0.7,1), 0, rnd(3,7));
			p.onUpdate = _bloodPhysics;
			p.delayS = i>20 ? rnd(0,0.1) : 0;
		}

		// Line
		var n = 40;
		var a = 3.14 + Math.atan2(y+rnd(0,3,true)-fy, x+rnd(0,3,true)-fx);
		a = Lib.angularClampRad(a, dir==1 ? 3.14 : 0, 0.2);
		for( i in 0...n) {
			var a = a+rnd(0,0.03,true);
			var d = rnd(0,15);
			var p = allocTopNormal(getTile("dot"), x+Math.cos(a)*d, y+Math.sin(a)*d+rnd(0,1,true));
			p.colorize( Color.interpolateInt(0xFF0000,0x6F0000, rnd(0,1)) );
			p.scaleX = rnd(1,3);
			p.scaleXMul = rnd(0.92,0.97);
			p.moveAng(a, (i<=10 ? rnd(1,4) : rnd(0.2,1.5) ));
			p.rotation = a;
			p.gy = rnd(0.01,0.02);
			p.frict = rnd(0.97,0.98);
			p.lifeS = rnd(1,3);
			p.setFadeS(rnd(0.7,1), 0, rnd(3,7));
			p.onUpdate = _bloodPhysics;
			p.delayS = i>20 ? rnd(0,0.1) : 0;
		}

		// Brain
		var n = 20;
		var a = Math.atan2(y+rnd(0,3,true)-fy, x+rnd(0,3,true)-fx);
		a = Lib.angularClampRad(a, dir==1 ? 0 : 3.14, 0.2);
		for( i in 0...n) {
			var a = a+rnd(0,0.03,true);
			var d = rnd(0,15);
			var p = allocTopNormal(getTile("dot"), x+Math.cos(a)*d, y+Math.sin(a)*d+rnd(0,1,true));
			p.colorize(0xE1C684);
			p.setFadeS(rnd(0.7,1), 0, rnd(3,7));

			p.scaleX = rnd(1,3);
			p.scaleY = rnd(1.5,2);
			p.scaleMul = rnd(0.96,0.99);

			p.rotation = a;
			p.dr = rnd(0.1,0.4)*dir;

			p.moveAng(a, (i<=10 ? rnd(1,4) : rnd(0.2,1.5) ));
			p.gy = rnd(0.02,0.05);
			p.frict = rnd(0.97,0.98);

			p.lifeS = rnd(1,3);
			p.onUpdate = _bloodPhysics;
			p.delayS = i>20 ? rnd(0,0.1) : 0;
		}
	}

	function _hardPhysics(p:HParticle) {
		if( collGround(p) && Math.isNaN(p.data0) ) {
			p.data0 = 1;
			p.gy = 0;
			p.dx*=0.5;
			p.dy = 0;
			p.dr = 0;
			p.rotation *= 0.1;
		}
	}
	public function woodCover(x:Float, y:Float, dir:Int) {
		var c = 0x7e593e;

		// Dots
		var n = 100;
		for( i in 0...n) {
			var p = allocTopNormal(getTile("dot"), x+rnd(0,3,true), y+rnd(0,4,true));
			p.colorize( Color.interpolateInt(c,0x0,rnd(0,0.1)) );
			p.scaleX = rnd(1,3);
			p.dx = dir * (i<=n*0.2 ? rnd(3,12) : rnd(-2,5) );
			p.dy = rnd(-3,1);
			p.gy = rnd(0.1,0.2);
			p.frict = rnd(0.85,0.96);
			p.rotation = rnd(0,6.28);
			p.dr = rnd(0,0.3,true);
			p.lifeS = rnd(5,10);
			p.setFadeS(rnd(0.7,1), 0, rnd(3,7));
			p.onUpdate = _hardPhysics;
			p.delayS = i>20 ? rnd(0,0.1) : 0;
		}

		// Planks
		var n = 20;
		for( i in 0...n) {
			var p = allocTopNormal(getTile("dot"), x+rnd(0,3,true), y+rnd(0,4,true));
			p.colorize( Color.interpolateInt(c,0x0,rnd(0,0.1)) );
			p.setFadeS(rnd(0.7,1), 0, rnd(3,7));

			p.scaleX = rnd(3,5);
			p.scaleY = 2;
			p.scaleMul = rnd(0.992,0.995);

			p.dx = dir * (i<=n*0.2 ? rnd(2,8) : rnd(-2,5) );
			p.dy = rnd(-5,0);
			p.gy = rnd(0.1,0.2);
			p.frict = rnd(0.85,0.96);

			p.rotation = rnd(0,6.28);
			p.dr = rnd(0,0.3,true);

			p.lifeS = rnd(5,10);
			p.onUpdate = _hardPhysics;
			p.delayS = i>20 ? rnd(0,0.1) : 0;
		}

		// Planks
		//var n = 40;
		//a = Lib.angularClampRad(a, dir==1 ? 3.14 : 0, 0.2);
		//for( i in 0...n) {
			//var a = a+rnd(0,0.03,true);
			//var d = rnd(0,15);
			//var p = allocTopNormal(getTile("dot"), x+Math.cos(a)*d, y+Math.sin(a)*d+rnd(0,1,true));
			//p.colorize( Color.interpolateInt(0xFF0000,0x6F0000, rnd(0,1)) );
			//p.scaleX = rnd(1,3);
			//p.scaleXMul = rnd(0.92,0.97);
			//p.moveAng(a, (i<=10 ? rnd(1,4) : rnd(0.2,1.5) ));
			//p.rotation = a;
			//p.gy = rnd(0.005,0.010);
			//p.frict = rnd(0.97,0.98);
			//p.lifeS = rnd(1,3);
			//p.setFadeS(rnd(0.7,1), 0, rnd(3,7));
			//p.onUpdate = _bloodPhysics;
			//p.delayS = i>20 ? rnd(0,0.1) : 0;
		//}
	}


	function _dust(p:HParticle) {
		p.rotation = p.getMoveAng();
	}

	public function noAmmo(x:Float, y:Float, dir:Int) {
		var n = 9;
		var base = dir==1 ? 0 : 3.14;
		for( i in 0...n ) {
			var a = base + -1.7+ 3.4*i/(n-1);
			var p = allocTopAdd(getTile("dot"), x+Math.cos(a)*5, y+Math.sin(a)*5);
			p.setFadeS(0.4, 0, 0.06);
			p.rotation = a;
			p.scaleX = i%2==0 ? 2 : 5;
			p.scaleXMul = 0.96;
			p.moveAng(a, 1);
			p.frict = 0.8;
			p.lifeS = 0.1;
		}
	}

	function envDust() {
		var n = 6;
		for(i in 0...n) {
			var p = allocTopAdd(getTile("dot"), rnd(0,game.vp.wid), rnd(0,game.vp.hei));
			//var p = allocTopAdd(getTile("dot"), rnd(0,game.vp.wid), rnd(-30,0));
			p.setFadeS(rnd(0.03,0.05), rnd(0.6,1), rnd(2,3));
			p.scaleX = rnd(5,10);
			p.scaleXMul = rnd(0.97,0.99);
			p.dx = rnd(0,2);
			p.dy = rnd(-1,2);
			p.frict = rnd(0.94,0.97);
			p.gx = rnd(0.01,0.03);
			p.gy = rnd(0.01,0.02);
			p.lifeS = rnd(2,3);
			p.onUpdate = _dust;
		}
	}

	override function update() {
		speedMod = game.getSlowMoFactor();

		super.update();

		if( !cd.hasSetS("envInit",Const.INFINITE) )
			for(i in 0...30 )
				envDust();

		if( !cd.hasSetS("env",0.06) )
			envDust();

		pool.update( game.getSlowMoDt() );
	}
}