package entity.mob;

class Sniper extends entity.Mob {
    public function new(x, y, ?dir) {
        super(x, y, dir);

        initLife(3);

        // spr.colorMatrix = new h3d.Matrix();
        // spr.colorMatrix.identity();
        // spr.colorMatrix.colorHue(0.5);

        var s = createSkill("shoot");
        s.setTimers(1.3, 0.7, 0.3);
        s.onStart = function() {
            lookAt(s.target);
            spr.anim.playAndLoop("sniperAim");
        }
        s.onProgress = function(t) {
            final target = s.target;
            if (this.dir != this.dirTo(target))
                s.interrupt(false);
            this.lookAt(target);
        }
        s.onInterrupt = function() spr.anim.stopWithStateAnims();
        s.onExecute = function(e) {
            lookAt(e);
            dy = -0.1;

            fx.flashBangS(0xFF0000, 0.1, 0.1);

            if (e.hitOrHitCover(2, this)) {
                e.knockback(this.dirTo(e));
                this.fx.bloodHit(
                    this.shootX, this.shootY, e.centerX, e.centerY
                );
            }
            Assets.SFX.heavy(1);
            fx.shoot(shootX, shootY, e.centerX, e.centerY, 0xFF0000);
            spr.anim
                .play("sniperAimShoot")
                .chainFor("sniperBlind", Const.FPS * 0.2);
        }
    }

    override function init() {
        super.init();

        spr.anim.registerStateAnim(
            "sniperGrab", 5, function() return isGrabbed());
        spr.anim.registerStateAnim(
            "sniperRun", 4, function() return cd.has("entering"));
        spr.anim.registerStateAnim(
            "sniperPush", 3, function() return !onGround && isStunned());
        spr.anim.registerStateAnim(
            "sniperStun", 2, function() return isStunned());
        spr.anim.registerStateAnim("sniperIdle", 0);
        lockControlsS(
            cd.getS("ctrlLock") + 0.1 + countMobs(Sniper, false) * 0.6
        );
    }

    override function onDie() {
        super.onDie();
        // Assets.SBANK.death0(1);
        new entity.DeadBody(this, "sniper").init();
    }

    override function get_shootY(): Float {
        return switch (curAnimId) {
            case "sniperBlind": footY - 16;
            case "sniperAim": footY - 16;
            default: super.get_shootY();
        }
    }

    override function get_headY(): Float {
        if (spr != null && !spr.destroyed)
            return super.get_headY() + switch (spr.groupName) {
                case "sniperStun": 7;
                default: 0;
            }
        return super.get_headY();
    }

    override function onDamage(v: Int) {
        super.onDamage(v);

        spr.anim.playOverlap("sniperHit");
        playHitSound();

        interruptSkills(true);
    }

    override public function update() {
        super.update();

        if (!controlsLocked() && onGround && tx == -1) {
            if (getSkill("shoot").isReady() && game.hero.isAlive())
                getSkill("shoot").prepareOn(game.hero);
        }
    }
}
