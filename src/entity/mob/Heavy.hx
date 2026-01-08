package entity.mob;

class Heavy extends entity.Mob {
    public function new(x, y, ?dir) {
        super(x, y, dir);

        initLife(6);
        sprScaleX = sprScaleY = 1.25;

        var s = createSkill("shoot");
        s.setTimers(1, 0.7, 0.3);
        s.onStart = function() {
            lookAt(s.target);
            spr.anim.playAndLoop("heavyAim");
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
            if (e.hitOrHitCover(1, this)) {
                e.knockback(this.dirTo(e));
                this.fx.bloodHit(
                    this.shootX, this.shootY, e.centerX, e.centerY
                );
            }
            Assets.SFX.blaster0(1);
            fx.shoot(shootX, shootY, e.centerX, e.centerY, 0xFF0000);
            spr.anim
                .play("heavyAimShoot")
                .chainFor("heavyBlind", Const.FPS * 0.2);
        }
    }

    override function init() {
        super.init();

        spr.anim.registerStateAnim(
            "heavyRun", 4, function() return cd.has("entering"));
        spr.anim.registerStateAnim(
            "heavyPush", 3, function() return !onGround && isStunned());
        spr.anim.registerStateAnim(
            "heavyStun", 2, function() return isStunned());
        spr.anim.registerStateAnim("heavyIdle", 0);

        lockControlsS(rnd(0.3, 1.6));
    }

    override public function stunS(t: Float) {}

    override public function canBeGrabbed()
        return false;

    override public function canBePushed()
        return false;

    override function onDie() {
        super.onDie();
        new entity.DeadBody(this, "heavy").init();
    }

    override function get_shootY(): Float {
        return switch (curAnimId) {
            case "heavyBlind": footY - 13;
            case "heavyAim": footY - 18;
            default: super.get_shootY();
        }
    }

    override function get_headY(): Float {
        if (spr != null && !spr.destroyed)
            return super.get_headY() - 5 + switch (spr.groupName) {
                case "heavyStun": 7;
                default: 0;
            }
        return super.get_headY();
    }

    override function onDamage(v: Int) {
        super.onDamage(v);

        spr.anim.playOverlap("heavyHit");
        playHitSound();
    }

    override public function update() {
        super.update();

        if (!controlsLocked() && onGround && tx == -1) {
            if (getSkill("shoot").isReady() && game.hero.isAlive())
                getSkill("shoot").prepareOn(game.hero);
        }
    }
}
