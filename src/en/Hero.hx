package en;

import action.*;

typedef ActionType = {
    function getInstance(hero: Hero, x: Float, y: Float): Action;
}

class Hero extends Entity {
    var actionsByPriority: Array<ActionType> = [
        Reload, Wait, HeadShot, BlindShot, KickGrab, GrabMob, TakeCover, Move,
        TurnBack
    ];
    var availableActions: Array<ActionType> = [];

    public var moveTarget: FPoint;
    public var afterMoveAction: Action;

    public var icon(default, null): HSprite;

    public var ammo: Int;
    public var maxAmmo: Int;
    public var grabbedMob: Null<en.Mob>;
    public var help: Null<h2d.Text>;

    public function new(x, y) {
        super(x, y);

        this.unlockAction(
            BlindShot, GrabMob, HeadShot, KickGrab, Move, Reload, TakeCover,
            TurnBack, Wait
        );

        afterMoveAction = new None(this);

        game.scroller.add(spr, Const.HERO_LAYER);
        spr.anim.registerStateAnim(
            "heroPush", 21, function() return !onGround && isStunned());
        spr.anim.registerStateAnim(
            "heroStun", 20, function() return cd.has("reloading"));
        spr.anim.registerStateAnim(
            "heroCover", 10, function() return cover != null
        );
        spr.anim.registerStateAnim(
            "heroRoll", 9,
            function() return
                onGround &&
                moveTarget != null &&
                !movementLocked() &&
                cd.has("rolling")
        );
        spr.anim.registerStateAnim(
            "heroBrake", 6,
            function() return
                onGround &&
                moveTarget != null &&
                !movementLocked() &&
                cd.has("rollBraking")
        );
        spr.anim.registerStateAnim(
            "heroRun", 5,
            function() return
                onGround &&
                moveTarget != null &&
                !movementLocked()
        );
        spr.anim.registerStateAnim(
            "heroBrake", 2,
            function() return cd.has("braking") && grabbedMob == null);
        spr.anim.registerStateAnim(
            "heroIdleGrab", 1, function() return grabbedMob != null
        );
        spr.anim.registerStateAnim("heroIdle", 0);

        icon = Assets.gameElements.h_get("iconMove");
        game.scroller.add(icon, Const.UI_LAYER);
        icon.setCenterRatio(0.5, 0.5);
        icon.blendMode = Add;

        isAffectBySlowMo = false;
        setAmmo(6);
        initLife(3);
        // initLife(Const.INFINITE);

        // Blind shot
        var s = createSkill("blindShot");
        s.setTimers(0.1, 0, 0.22);
        s.onStart = function() {
            lookAt(s.target);
            if (grabbedMob == null)
                spr.anim.playAndLoop("heroBlind");
            else
                spr.anim.playAndLoop("heroGrabBlind");
        }
        s.onExecute = function(e) {
            if (!useAmmo()) {
                Assets.SFX.empty(1);
                if (grabbedMob == null)
                    spr.anim.play("heroBlindShoot");
                else
                    spr.anim.play("heroGrabBlindShoot");
                return;
            }

            if (e.hit(1, this)) {
                var r = e.getDiminishingReturnFactor("blindShot", 1, 1);
                e.dx *= 0.3;
                e.dx += dirTo(e) * rnd(0.03, 0.05) * r;
                e.stunS(1.1 * r);
                fx.bloodHit(shootX, shootY, e.centerX, e.centerY);
            }
            fx.shoot(shootX, shootY, e.centerX, e.centerY, 0x2780D8);
            Assets.SFX.pew2(0.5);
            // Assets.SBANK.gun1(1);
            Assets.SFX.blaster1(1);
            fx.bullet(shootX - dir * 5, shootY, -dir);
            fx.flashBangS(0x477ADA, 0.1, 0.1);

            if (cover == null && grabbedMob == null)
                dx += 0.03 * -dir;

            if (grabbedMob == null)
                spr.anim.play("heroBlindShoot");
            else
                spr.anim.play("heroGrabBlindShoot");
        }

        // Head shot
        var s = createSkill("headShot");
        s.setTimers(0.85, 0, 0.1);
        s.onStart = function() {
            lookAt(s.target);
            spr.anim.playAndLoop("heroAim");
        }
        s.onExecute = function(e) {
            if (!useAmmo()) {
                Assets.SFX.empty(1);
                spr.anim.play("heroAimShoot");
                return;
            }

            fx.flashBangS(0x477ADA, 0.1, 0.1);

            if (e.hit(2, this, true))
                fx.headShot(shootX, shootY, e.headX, e.headY, dirTo(e));
            fx.shoot(shootX, shootY, e.headX, e.headY, 0x2780D8);
            fx.bullet(shootX - dir * 5, shootY, dir);
            // Assets.SBANK.gun0(1);
            Assets.SFX.heavy(1);
            Assets.SFX.pew0(0.5);

            if (cover == null)
                if (grabbedMob == null)
                    dx += 0.03 * -dir;
                else
                    dx += 0.01 * -dir;
            spr.anim.play("heroAimShoot");
        }
    }

    function unlockAction(...actions: ActionType) {
        for (action in actions) {
            var index = 0;

            for (availableAction in this.availableActions)
                if (this.actionsByPriority.indexOf(
                    availableAction
                ) < this.actionsByPriority.indexOf(action))
                    index++;
                else
                    break;

            this.availableActions.insert(index, action);
        }
    }

    override public function isCoveredFrom(source: Entity) {
        return
            super.isCoveredFrom(source) ||
            grabbedMob != null &&
            dirTo(grabbedMob) == dirTo(source);
    }

    override public function hitCover(dmg: Int, source: Entity) {
        if (grabbedMob != null)
            grabbedMob.hit(dmg, source);
        else
            super.hitCover(dmg, source);
    }

    public function setAmmo(v) {
        ammo = maxAmmo = v;
        game.updateHud();
    }

    function useAmmo() {
        if (ammo <= 0) {
            say("I need to reload!", 0xFF0000);
            fx.noAmmo(shootX, shootY, dir);
            lockControlsS(0.2);
            return false;
        } else {
            ammo--;
            game.updateHud();
            return true;
        }
    }

    override function onDamage(v: Int) {
        super.onDamage(v);
        game.updateHud();
        fx.flashBangS(0xFF0000, 0.2, 0.2);
        spr.anim.playOverlap("heroHit");
    }

    override function onDie() {
        super.onDie();
        stopGrab();
        new en.DeadBody(this, "hero");
        game.announce("T to restart", 0xFF0000, true);
    }

    override public function dispose() {
        super.dispose();
        icon.remove();
    }

    override function get_shootY(): Float {
        return switch (curAnimId) {
            case "heroGrabBlind": footY - 16;
            case "heroBlind": footY - 16;
            case "heroAim": footY - 21;
            default: super.get_shootY();
        }
    }

    // override function onTouchWall(wallDir:Int) {
    // dx = -wallDir*M.fabs(dx);
    // }

    override public function controlsLocked() {
        for (s in skills)
            if (s.isCharging())
                return true;

        return super.controlsLocked() || moveTarget != null || !onGround;
    }

    override public function onClick(x: Float, y: Float, bt) {
        super.onClick(x, y, bt);

        if (controlsLocked())
            return;

        getActionAt(x, y).execute();

        // switch(bt) {
        // case 0 :
        // target = new FPoint(x,footY);
        // leaveCover();
        //
        // case 1 :
        // var dh = new DecisionHelper(en.Mob.ALL);
        // dh.remove( function(e) return e.distPxFree(x,y)>=30 );
        // dh.score( function(e) return -e.distPxFree(x,y) );
        // var e = dh.getBest();
        // if( e!=null ) {
        // if( e.head.contains(x,y) && getSkill("headShot").isReady() )
        // getSkill("headShot").prepareOn(e);
        // else if( getSkill("blindShot").isReady() )
        // getSkill("blindShot").prepareOn(e);
        // }
        // }
    }

    function getActionAt(x: Float, y: Float): Action {
        if (!this.game.hasCinematic())
            for (actionType in this.availableActions) {
                final action = actionType.getInstance(this, x, y);
                if (action != null)
                    return action;
            }

        return new None(this);
    }

    override public function postUpdate() {
        super.postUpdate();
        if (spr.groupName == "heroRoll") {
            spr.setCenterRatio(0.5, 0.5);
            spr.rotation += 0.6 * tmod * dir;
            spr.y -= 7;
        } else {
            spr.rotation = 0;
            spr.setCenterRatio(0.5, 1);
        }
        // ammoBar.x = headX-2;
        // ammoBar.y = headY-4;
    }

    public function startGrab(e: en.Mob) {
        if (!e.isAlive())
            return;
        grabbedMob = e;
        grabbedMob.hasGravity = false;
        grabbedMob.interruptSkills(false);
        game.scroller.add(grabbedMob.spr, Const.HERO_LAYER);
    }

    public function stopGrab() {
        if (grabbedMob == null)
            return;
        grabbedMob.hasGravity = true;
        if (grabbedMob.isAlive())
            game.scroller.add(grabbedMob.spr, Const.MOBS_LAYER);
        grabbedMob = null;
    }

    public function setHelp(?e: Entity, ?str: String, ?c = 0xADAED6) {
        if (str == null && help != null) {
            help.remove();
            help = null;
        }
        if (str != null) {
            if (e == null)
                e = this;
            if (help == null) {
                help = new h2d.Text(Assets.font);
                game.scroller.add(help, Const.UI_LAYER);
            }
            help.text = str;
            help.textColor = c;
            help.x = Std.int(e.footX - help.textWidth * 0.5);
            help.y = Std.int(e.headY - help.textHeight - 12);
        }
    }

    override public function update() {
        super.update();

        if (cover != null && !hasSkillCharging() && !controlsLocked())
            lookAt(cover);

        // HUD icon
        var m = game.getMouse();
        var action = getActionAt(m.x, m.y);
        icon.alpha = 0.7;
        icon.visible = true;
        icon.colorize(0xffffff);
        setHelp();

        action.updateDisplay();

        if (
            !controlsLocked() &&
            Main.ME.keyPressed(hxd.Key.R) &&
            ammo < maxAmmo
        )
            new Reload(this).execute();

        // Move
        if (moveTarget != null && !movementLocked())
            if (M.fabs(centerX - moveTarget.x) <= 5) {
                // Arrived
                game.cinematic.signal("move");
                afterMoveAction.execute();
                moveTarget = null;
                afterMoveAction = new None(this);
                dx *= 0.3;
                if (M.fabs(dx) >= 0.04)
                    cd.setS("braking", 0.2);
            } else {
                var s = 0.011;
                if (moveTarget.x > centerX) {
                    dir = 1;
                    dx += s * tmod;
                }
                if (moveTarget.x < centerX) {
                    dir = -1;
                    dx -= s * tmod;
                }
            }

        if (grabbedMob != null) {
            if (!grabbedMob.isAlive()) {
                stopGrab();
            } else {
                grabbedMob.setPosPixel(footX + dir * 6, footY - 1);
                grabbedMob.dir = dir;
            }
        }
    }
}
