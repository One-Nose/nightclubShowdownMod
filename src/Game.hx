import hxd.Key;

typedef HistoryEntry = {t: Int, a: Action};

class Game extends dn.Process {
    public static var ME: Game;

    public var scroller: h2d.Layers;
    public var viewport: Viewport;
    public var fx: Fx;
    public var level: Level;
    public var hero: en.Hero;

    var clickTrap: h2d.Interactive;
    var mask: h2d.Graphics;

    public var waveId: Int;
    public var isReplay: Bool;
    public var heroHistory: Array<HistoryEntry>;

    public var hud: h2d.Flow;

    public var cinematic: dn.Cinematic;

    public function new(
        context: h2d.Object, ?replayHistory: Array<HistoryEntry>
    ) {
        super(Main.ME);

        ME = this;
        this.createRoot(context);

        if (replayHistory != null) {
            this.isReplay = true;
            this.heroHistory = replayHistory.copy();
        } else {
            this.heroHistory = [];
            this.isReplay = false;
        }

        cinematic = new dn.Cinematic(Const.FPS);
        // Console.ME.runCommand("+ bounds");

        this.scroller = new h2d.Layers(this.root);
        this.viewport = new Viewport();
        this.fx = new Fx();

        this.clickTrap = new h2d.Interactive(1, 1, Main.ME.root);
        // clickTrap.backgroundColor = 0x4400FF00;
        this.clickTrap.onPush = this.onMouseDown;
        // clickTrap.enableRightButton = true;

        this.mask = new h2d.Graphics(Main.ME.root);
        this.mask.visible = false;

        this.hud = new h2d.Flow();
        this.root.add(this.hud, Const.UI_LAYER);
        this.hud.horizontalSpacing = 1;

        this.level = new Level();
        this.hero = new en.Hero(2, 6);

        #if debug
        this.hero.setPosCase(8, 6);
        this.startWave(0);
        #else
        this.logo();
        if (!Main.ME.cd.hasSetS("intro", Const.INFINITE)) {
            this.startWave(0);
            this.delayer.addS(function() {
                this.announce("A fast turned-based action game", 0x706ACC);
            }, 1);
            this.cinematic.create({
                this.hud.visible = false;
                this.hero.moveTarget = new FPoint(8 * Const.GRID, hero.footY);
                end("move");
                500;
                this.hero.executeAction(new action.Reload(this.hero));
                1500;
                this.hero.say("Let's finish this.", 0xFBAD9F);
                end;
                this.hud.visible = true;
                1000;
            });
        } else {
            this.hero.setPosCase(8, 6);
            this.startWave(0);
        }
        #end

        this.viewport.repos();

        this.onResize();
    }

    // function updateWave() {
    // var n = 0;
    // for(e in en.Cover.ALL)
    // if( e.isAlive() )
    // n++;
    // for(i in n...2) {
    // var e = new en.Cover(10,0);
    // }
    // }

    /**
        Marks HUD to be updates next frame
    **/
    public function updateHud()
        this.cd.setS("invalidateHud", Const.INFINITE);

    /**
        Only updates HUD if `updateHud()` was called since the last update
    **/
    function _updateHud() {
        if (!this.cd.has("invalidateHud"))
            return;

        this.hud.removeChildren();
        this.cd.unset("invalidateHud");

        for (i in 0...M.imin(this.hero.maxLife, 6)) {
            var heart = Assets.gameElements.h_get("iconHeart", this.hud);
            heart.colorize(if (i + 1 <= hero.life) 0xFFFFFF else 0xFF0000);
            heart.alpha = if (i + 1 <= hero.life) 1 else 0.8;
            heart.blendMode = Add;
        }

        this.hud.addSpacing(4);

        for (i in 0...hero.maxAmmo) {
            var bullet = Assets.gameElements.h_get("iconBullet", this.hud);
            bullet.colorize(if (i + 1 <= hero.ammo) 0xFFFFFF else 0xFF0000);
            bullet.alpha = if (i + 1 <= hero.ammo) 1 else 0.8;
            bullet.blendMode = Add;
        }

        this.onResize();
    }

    function onMouseDown(event: hxd.Event) {
        var mouse = this.getMouse();
        for (entity in Entity.ALL)
            entity.onClick(mouse.x, mouse.y, event.button);
    }

    override public function onResize() {
        super.onResize();

        this.clickTrap.width = this.w();
        this.clickTrap.height = this.h();

        this.hud.x = Std.int(
            this.w() * 0.5 / Const.SCALE - this.hud.outerWidth * 0.5
        );
        this.hud.y = Std.int((this.level.hei + 1) * Const.GRID + 6);

        this.mask.clear();
        this.mask.beginFill(0x0, 1);
        this.mask.drawRect(0, 0, this.w(), this.h());
    }

    override public function onDispose() {
        super.onDispose();

        this.mask.remove();
        this.clickTrap.remove();
        this.cinematic.destroy();

        for (entity in Entity.ALL)
            entity.destroy();
        this.gc();

        if (ME == this)
            ME = null;
    }

    /**
        Disposes of destroyed entities
    **/
    function gc() {
        var i = 0;
        while (i < Entity.ALL.length)
            if (Entity.ALL[i].destroyed)
                Entity.ALL[i].dispose();
            else
                i++;
    }

    override function postUpdate() {
        super.postUpdate();
        this._updateHud();
    }

    public function getMouse() {
        var mouseX = hxd.Window.getInstance().mouseX;
        var mouseY = hxd.Window.getInstance().mouseY;
        var x = Std.int(mouseX / Const.SCALE - scroller.x);
        var y = Std.int(mouseY / Const.SCALE - scroller.y);
        return {
            x: x,
            y: y,
            cx: Std.int(x / Const.GRID),
            cy: Std.int(y / Const.GRID),
        }
    }

    public function logo() {
        var logo = Assets.gameElements.h_get("logo", root);
        logo.y = 30;
        logo.colorize(0x3D65C2);
        logo.blendMode = Add;
        this.tw.createMs(logo.x, 500 | -logo.tile.width > 12, 250)
            .onEnd = function() {
                var d = 5000;
                this.tw.createMs(logo.alpha, d | 0, 1500).onEnd = logo.remove;
            }}

    public function announce(
        str: String, ?color = 0xFFFFFF, ?permanent = false, ?delayMs = 500
    ) {
        var text = new h2d.Text(Assets.font, root);
        text.text = str;
        text.textColor = color;
        text.y = Std.int(58 - text.textHeight);

        this.tw.createMs(text.x, -text.textWidth > 12, 200).end(() -> {
            if (!permanent) {
                var d = 1000 + str.length * 75;
                tw.createMs(text.alpha, d | 0, 1500).onEnd = text.remove;
            }
        }).delayMs(delayMs);
    }

    var lastNotif: Null<h2d.Text>;

    public function notify(string: String, ?color = 0xFFFFFF) {
        if (this.lastNotif != null)
            this.lastNotif.remove();

        var text = new h2d.Text(Assets.font, root);
        lastNotif = text;
        text.text = string;
        text.textColor = color;
        text.y = Std.int(100 - text.textHeight);
        this.tw.createMs(text.x, -text.textWidth > 12, 200).onEnd = function() {
            var d = 650 + string.length * 75;
            tw.createMs(text.alpha, d | 0, 1500).onEnd = function() {
                text.remove();
                if (this.lastNotif == text)
                    this.lastNotif = null;
            }
        }
    }

    public function hasCinematic() {
        return !this.cinematic.isEmpty();
    }

    public function startWave(id: Int) {
        this.waveId = id;

        for (mob in en.Mob.ALL)
            mob.destroy();

        this.level.startWave(waveId);

        if (this.waveId == 2) {
            this.fx.clear();
            this.fx.allSpots(25, this.level.wid * Const.GRID);
            this.fx.flashBangS(0xFFCC00, 0.5, 0.5);
            for (body in en.DeadBody.ALL)
                body.destroy();

            for (cover in en.Cover.ALL)
                cover.destroy();
        }

        this.level.waveMobCount = 1;
        if (this.waveId > 7)
            announce(
                "Thank you for playing ^_^\nA 20h game by Sebastien Benard\ndeepnight.net",
                true
            );
        else {
            if (this.waveId <= 0)
                this.level.attacheWaveEntities();
            else {
                this.announce('Wave ${this.waveId}...', 0xFFD11C);
                this.delayer.addS(function() {
                    this.announce("          Fight!", 0xEF4810);
                }, 0.5);
                this.delayer.addS(function() {
                    this.level.attacheWaveEntities();
                    this.cd.unset("lockNext");
                }, 1);
            }
        }
    }

    function exitLevel() {
        this.cd.setS("lockNext", Const.INFINITE);
        switch (this.waveId) {
            case 1:
                this.cinematic.create({
                    this.mask.visible = true;
                    this.tw.createS(this.mask.alpha, 0 > 1, 0.6);
                    600;
                    this.hero.setPosCase(0, this.level.hei - 3);
                    this.startWave(this.waveId + 1);
                    this.tw.createS(this.mask.alpha, 0, 0.3);
                    this.mask.visible = false;
                    this.hero.moveTarget = new FPoint(
                        this.hero.centerX + 30, this.hero.footY
                    );
                    end("move");
                });

            default:
                this.startWave(this.waveId + 1);
        }
    }

    public function isSlowMo() {
        #if debug
        if (Key.isDown(Key.SHIFT))
            return false;
        #end
        if (this.isReplay || !this.hero.isAlive() || this.hero.controlsLocked())
            return false;

        for (mob in en.Mob.ALL)
            if (mob.isAlive() && mob.canBeShot())
                return true;

        if (this.cd.has("lastMobDiedRecently"))
            return true;

        return false;
    }

    public function getSlowMoDt() {
        return if (this.isSlowMo()) this.tmod * Const.PAUSE_SLOWMO else tmod;
    }

    public function getSlowMoFactor() {
        return if (isSlowMo()) Const.PAUSE_SLOWMO else 1;
    }

    function canStartNextWave() {
        if (this.level.waveMobCount > 0)
            return false;

        if (this.cd.has("lockNext") || this.hasCinematic())
            return false;

        return switch (this.waveId) {
            case 0: this.level.waveMobCount <= 0;
            case 1: this.hero.cx >= this.level.wid - 2;

            default: this.level.waveMobCount <= 0;
        }
    }

    override public function update() {
        this.cinematic.update(tmod);

        super.update();

        // Updates
        for (entity in Entity.ALL) {
            entity.setTmod(this.tmod);
            if (!entity.destroyed)
                entity.preUpdate();
            if (!entity.destroyed)
                entity.update();
            if (!entity.destroyed)
                entity.postUpdate();
        }
        gc();

        if (this.canStartNextWave())
            this.exitLevel();

        #if hl
        if (Main.ME.keyPressed(Key.ESCAPE))
            if (!this.cd.hasSetS("exitTwice", 3))
                this.announce("Escape again to quit...", 0x9900ff, 0);
            else
                hxd.System.exit();
        #end

        if (Main.ME.keyPressed(Key.T)) {
            if (Key.isDown(Key.SHIFT)) {
                Main.ME.cd.unset("intro");
                Assets.musicIn.stop();
                Assets.musicOut.stop();
                Main.ME.restartGame();
            } else
                Main.ME.restartGame();
        }

        #if debug
        if (Main.ME.keyPressed(Key.N))
            this.startWave(this.waveId + 1);
        if (Main.ME.keyPressed(Key.K))
            for (mob in en.Mob.ALL)
                if (mob.isAlive())
                    mob.hit(99, this.hero, true);
        #end

        if (Key.isDown(Key.ALT) && Main.ME.keyPressed(Key.ENTER))
            Main.ME.toggleFullscreen();

        if (Main.ME.keyPressed(Key.S)) {
            this.notify(
                "Sounds: " + if (dn.heaps.Sfx.isMuted(0)) "ON" else "off"
            );
            dn.heaps.Sfx.toggleMuteGroup(0);
            Assets.SFX.grunt0().playOnGroup(0);
        }

        if (Main.ME.keyPressed(Key.M)) {
            this.notify(
                "Music: " + if (dn.heaps.Sfx.isMuted(1)) "ON" else "off"
            );
            dn.heaps.Sfx.toggleMuteGroup(1);
        }

        if (
            this.isReplay &&
            this.heroHistory.length > 0 &&
            this.itime >= this.heroHistory[
                0
            ].t
        )
            this.hero.executeAction(this.heroHistory.shift().a);
    }
}
