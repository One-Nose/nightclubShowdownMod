using Upgrade;

import hxd.Key;

typedef HistoryEntry = {t: Int, a: Action};

class Game extends dn.Process {
    public static var ME: Game;

    public var scroller: h2d.Layers;
    public var viewport: Viewport;
    public var fx: Fx;
    public var level: Level;
    public var hero: entity.Hero;

    public var unlockableUpgrades(default, null): Array<Upgrade>;
    public var unlockableRewards(default, null): Array<Upgrade>;
    public var upgradeMessage: Null<h2d.Text>;

    var clickTrap: h2d.Interactive;
    var mask: h2d.Graphics;

    public var mouseX = 0.0;
    public var mouseY = 0.0;

    public var isReplay: Bool;
    public var heroHistory: Array<HistoryEntry>;

    public var hud: h2d.Flow;

    public var nextIcon: HSprite;

    public var cinematic: dn.Cinematic;

    public function new(
        context: h2d.Object, ?replayHistory: Array<HistoryEntry>
    ) {
        super(Main.ME);

        ME = this;
        this.createRoot(context);

        Assets.gameElements.defineAnim(
            "heroReload", "0(15),1(15), 2(8), 3(6), 4(4), 5(6)"
        );

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

        this.nextIcon = Assets.gameElements.h_get("next");
        this.nextIcon.visible = false;
        this.nextIcon.colorize(0x00C700);
        this.nextIcon.blendMode = Add;
        this.nextIcon.alpha = 0;
        this.nextIcon.setCenterRatio(1, 0.5);
        this.root.add(this.nextIcon, Const.UI_LAYER);

        this.level = new Level();
        this.hero = new entity.Hero(2, 6);
        this.hero.init();

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
                new action.Reload(this.hero).execute();
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

        this.unlockableUpgrades = Upgrade.initUpgrades([
            new Upgrade("Bigger Mags", {
                description: "+2 bullets per reload",
                onUnlock: () -> this.hero.setAmmo(this.hero.maxAmmo + 2),
                maxLevel: 2,
                children: [new Upgrade("Quicker Shots", {
                    description: "Quicker consecutive shots while not taking cover",
                    onUnlock: () -> this.hero
                        .getSkill("blindShot")
                        .lockAfterS /= 2,
                    icon: "Shot"
                })],
                icon: "BiggerMags"
            }),
            new Upgrade("Dash", {
                description: "Dash to move faster and dodge bullets",
                onUnlock: () -> this.hero.unlockAction(action.Dash),
                children: [
                    new Upgrade("Cover Dash", {
                        description: "Dash into cover to skip the vulnerability moment",
                        onUnlock: () -> this.hero.canCoverDash = true,
                        icon: "Dash"
                    }),
                    new Upgrade("Kick Dash", {
                        description: "Dash into enemies to skip the vulnerability moment",
                        onUnlock: () -> this.hero.canKickDash = true,
                        isUnlockable: () -> this.hero.hasAction(action.KickMob),
                        icon: "KickDash"
                    })
                ],
                icon: "Dash"
            }),
            new Upgrade("Fast Reload", {
                description: "Double your reload speed",
                onUnlock: () -> {
                    Assets.gameElements.defineAnim(
                        "heroReload",
                        "0(7),1(7), 2(4), 3(3), 4(2), 5(3)"
                    );
                    this.hero.reloadSpeed = 2;
                },
                icon: "Reload"
            }),
            new Upgrade("Head Shot", {
                description: "Aim for the head to deal +1 damage and ignore cover",
                onUnlock: () -> this.hero.unlockAction(action.HeadShot),
                children: [
                    new Upgrade("Quick Aim", {
                        description: "Faster head shots",
                        onUnlock: () -> this.hero
                            .getSkill("headShot")
                            .chargeS -= 0.25,
                        icon: "Aim"
                    }),
                    new Upgrade("Fatal Shot", {
                        description: "+1 head shot damage",
                        onUnlock: () -> this.hero.headShotDamage++,
                        icon: "HeadShot"
                    }),
                    new Upgrade("Piercing Shot", {
                        description: "Head shots pierce through the closest target",
                        onUnlock: () -> this.hero.piercingShot = 1,
                        icon: "Pierce",
                        children: [new Upgrade("Multiple Piercing", {
                            description: "Head shots pierce through all targets",
                            onUnlock: () -> this.hero.piercingShot = 2,
                            icon: "Pierce"
                        })]
                    }),
                ],
                icon: "HeadShot"
            }),
            new Upgrade("Kick Enemies", {
                description: "Kick enemies to stun them",
                onUnlock: () -> this.hero.unlockAction(action.KickMob),
                children: [new Upgrade("Grab Enemies", {
                    description: "Grab enemies to use them as cover",
                    onUnlock: () -> {
                        this.hero.unlockAction(action.GrabMob);
                        this.hero.hasKicked = false;
                    },
                    icon: "Grab"
                })],
                icon: "Kick"
            }),
            new Upgrade("Larger Grenades", {
                description: "Increase grenade explosion radius",
                onUnlock: () -> this.hero.grenadeRange++,
                maxLevel: 2,
                isUnlockable: () -> this.hero.hasThrownGrenade,
                icon: "Explosion"
            }),
            new Upgrade("Quick Throw", {
                description: "Throw grenades more quickly",
                onUnlock: () -> this.hero
                    .getSkill("throwGrenade")
                    .chargeS -= 0.25,
                isUnlockable: () -> this.hero.hasThrownGrenade,
                icon: "Throw"
            })
        ]);

        this.unlockableRewards = Upgrade.initUpgrades([
            new Upgrade("Bonus Heart", {
                description: "+1 max life",
                onUnlock: () -> {
                    this.hero.initLife(4);
                    this.updateHud();
                },
                isUnlockable: () ->
                    this.hero.life == this.hero.maxLife &&
                    this.hero.bestNoDamageStreak >= 6,
                icon: "BonusHeart"
            }),
            new Upgrade("Evasion", {
                description: "Protection from the next hit",
                onUnlock: () -> {
                    this.hero.hasEvasion = true;
                    this.updateHud();
                },
                isUnlockable: () -> !this.hero.hasEvasion,
                infinite: true,
                icon: "Evasion"
            }),
            new Upgrade("Heal", {
                description: "Heal one heart",
                onUnlock: () -> {
                    this.hero.life++;
                    this.updateHud();
                },
                isUnlockable: () -> this.hero.life < this.hero.maxLife,
                infinite: true,
                icon: "Heal"
            }),
            new Upgrade("Two Grenades", {
                description: "+2 grenades you can throw them around",
                onUnlock: () -> {
                    this.hero.grenades += 2;
                    this.updateHud();
                },
                isUnlockable: () -> this.hero.grenades <= 4,
                infinite: true,
                icon: "Grenade"
            })
        ]);
    }

    // function updateWave() {
    // var n = 0;
    // for(e in entity.Cover.ALL)
    // if( e.isAlive() )
    // n++;
    // for(i in n...2) {
    // var e = new entity.Cover(10,0);
    // }
    // }

    /**
        Marks HUD to be updates next frame
    **/
    public function updateHud()
        this.cd.setS("invalidateHud", Const.INFINITE);

    public function loopNextIconAlpha() {
        if (this.level.waveId == 1) {
            this.tw.createMs(this.nextIcon.alpha, 0.7, 400).end(() -> {
                this.tw
                    .createMs(this.nextIcon.alpha, 0.4, 400)
                    .end(this.loopNextIconAlpha);
            });
        }
    }

    /**
        Only updates HUD if `updateHud()` was called since the last update
    **/
    function _updateHud() {
        if (!this.cd.has("invalidateHud"))
            return;

        this.hud.removeChildren();
        this.cd.unset("invalidateHud");

        if (this.hero.hasEvasion) {
            var evasion = Assets.gameElements.h_get("iconEvasion", this.hud);
            evasion.colorize(0x8888FF);
            this.hud.addSpacing(8);
        }

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

        if (hero.grenades > 0)
            this.hud.addSpacing(8);

        for (_ in 0...hero.grenades)
            var grenade = Assets.gameElements.h_get("grenade", this.hud);

        this.onResize();
    }

    function onMouseDown(event: hxd.Event) {
        if (
            !this.hero.isAlive() &&
            !Main.ME.isTransitioning() &&
            this.cd.hasSetS("restartGame", 1)
        ) {
            Main.ME.restartGame();
            return;
        }

        var point = new h2d.col.Point(event.relX, event.relY);
        point = this.scroller.globalToLocal(point);
        point.x = M.floor(point.x);
        point.y = M.floor(point.y);

        for (entity in Entity.ALL)
            entity.onClick(point.x, point.y, event.button);
    }

    override public function onResize() {
        super.onResize();

        this.clickTrap.width = this.w();
        this.clickTrap.height = this.h();

        this.hud.x = Std.int(
            this.w() * 0.5 / Const.SCALE - this.hud.outerWidth * 0.5
        );
        this.hud.y = 2 * Const.GRID;

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
        static var actualMouseX = 0;
        static var actualMouseY = 0;

        var newMouseX = Std.int(
            hxd.Window.getInstance().mouseX / Const.SCALE - this.scroller.x
        );
        var newMouseY = Std.int(
            hxd.Window.getInstance().mouseY / Const.SCALE - this.scroller.y
        );

        if (actualMouseX != newMouseX || actualMouseY != newMouseY) {
            this.mouseX = newMouseX;
            this.mouseY = newMouseY;
        }

        actualMouseX = newMouseX;
        actualMouseY = newMouseY;

        return {
            x: this.mouseX,
            y: this.mouseY,
            cx: Std.int(this.mouseX / Const.GRID),
            cy: Std.int(this.mouseY / Const.GRID),
        }
    }

    public function logo() {
        var logo = Assets.gameElements.h_get("logo", root);
        logo.y = 60;
        logo.colorize(0x3D65C2);
        logo.blendMode = Add;
        this.tw
            .createMs(logo.x, 500 | -logo.tile.width > 12, 250)
            .onEnd = function() {
                var d = 5000;
                this.tw.createMs(logo.alpha, d | 0, 1500).onEnd = logo.remove;
            }
    }

    public function announce(
        str: String, ?color = 0xFFFFFF, ?permanent = false, ?delayMs = 500
    ) {
        var text = new h2d.Text(Assets.font, root);
        text.text = str;
        text.textColor = color;
        text.y = Std.int(88 - text.textHeight);

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
        text.y = Std.int(160 - text.textHeight);
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
        this.clearLevel();
        this.level.prepareWave(id);

        if (this.level.waveId == 2) {
            this.fx.clear();
            this.fx.allSpots(25, this.level.wid * Const.GRID);
            this.fx.flashBangS(0xFFCC00, 0.5, 0.5);
            for (body in entity.DeadBody.ALL)
                body.destroy();

            for (cover in entity.Cover.ALL)
                cover.destroy();
        }

        if (this.level.waveId <= 0)
            this.level.startWave();
        else {
            this.announce('Wave ${this.level.waveId}...', 0xFFD11C);
            this.delayer.addS(function() {
                this.announce("          Fight!", 0xEF4810);
            }, 0.5);
            this.delayer.addS(function() {
                if (this.level.waveId >= 2)
                    this.fx.allSpots(25, this.level.wid * Const.GRID);
                this.level.startWave();
                this.cd.unset("lockNext");
            }, 1);
        }
    }

    function startUpgrades(upgradeOptions: Array<Upgrade>, message: String) {
        this.clearLevel();

        this.upgradeMessage = new h2d.Text(Assets.font, this.root);
        this.upgradeMessage.text = message;
        this.upgradeMessage.textColor = 0x44F774;
        this.upgradeMessage.y = 45;

        var messageDest =
            this.level.wid * Const.GRID / 2 -
            this.upgradeMessage.textWidth / 2;

        this.tw.createMs(
            this.upgradeMessage.x,
            -this.upgradeMessage.textWidth > messageDest, 200
        );

        this.delayer.addS(() -> {
            this.level.startUpgrades(upgradeOptions);
            this.cd.unset("lockNext");
        }, 0.8);
    }

    function clearLevel() {
        for (mob in entity.Mob.ALL)
            mob.destroy();
    }

    function exitLevel() {
        this.cd.setS("lockNext", Const.INFINITE);

        if (this.level.wave is wave.Battle) {
            this.hero.noDamageStreak++;
            this.hero.bestNoDamageStreak = M.imax(
                this.hero.bestNoDamageStreak,
                this.hero.noDamageStreak
            );
        }

        final isUpgradeReward = this.level.waveId % 2 == 0;

        var upgradeOptions = (if (isUpgradeReward) {
            this.unlockableUpgrades;
        } else {
            this.unlockableRewards;
        }).filter(upgrade -> upgrade.isUnlockable());

        if (this.level.wave.isRewarding && upgradeOptions.length > 0) {
            this.cd.unset("lastMobDiedRecently");
            this.startUpgrades(
                upgradeOptions,
                if (isUpgradeReward) "Choose an upgrade" else "Choose a reward"
            );
        } else if (this.level.waveId == 1) {
            this.cinematic.create({
                this.mask.visible = true;
                this.tw.createS(this.mask.alpha, 0 > 1, 0.6);
                600;
                this.nextIcon.visible = false;
                this.hero.setPosCase(0, this.level.hei - 3);
                this.startWave(this.level.waveId + 1);
                this.tw.createS(this.mask.alpha, 0, 0.3);
                this.mask.visible = false;
                this.hero.moveTarget = new FPoint(
                    this.hero.centerX + 30, this.hero.footY
                );
                end("move");
            });
        } else
            this.startWave(this.level.waveId + 1);
    }

    public function isSlowMo() {
        #if debug
        if (Key.isDown(Key.SHIFT))
            return false;
        #end
        if (
            this.isReplay ||
            !this.hero.isAlive() ||
            this.hero.controlsLocked() ||
            this.hero.curAnimId == "heroRun"
        )
            return false;

        for (mob in entity.Mob.ALL)
            if (mob.isAlive() && mob.canBeShot())
                return true;

        if (entity.Grenade.ALL.length > 0)
            return true;

        for (cover in entity.Cover.ALL)
            if (!cover.onGround)
                if (!cover.cd.has("coverFalling"))
                    cover.cd.setS("coverFalling", 2);
                else if (M.inRange(cover.cd.getS("coverFalling"), 0, 1.9))
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
        if (this.cd.has("lockNext") || this.hasCinematic())
            return false;

        if (this.level.waveId == 1 && !this.level.wave.isRewarding)
            return
                this.level.wave.isOver() &&
                this.hero.cx >= this.level.wid - 2;

        return this.level.wave.isOver();
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
            this.startWave(this.level.waveId + 1);
        if (Main.ME.keyPressed(Key.K))
            for (mob in entity.Mob.ALL)
                if (mob.isAlive())
                    mob.hit(99, this.hero);
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
            this.itime >= this.heroHistory[0].t
        )
            this.heroHistory.shift().a.execute();
    }
}
