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
            spr.anim.playAndLoop("cAim");
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
            spr.anim.play("cAimShoot").chainFor("cBlind", Const.FPS * 0.2);
        }
    }

    override function init() {
        super.init();

        spr.anim.registerStateAnim(
            "cRun", 4, function() return cd.has("entering"));
        spr.anim.registerStateAnim(
            "cPush", 3, function() return !onGround && isStunned());
        spr.anim.registerStateAnim("cStun", 2, function() return isStunned());
        spr.anim.registerStateAnim(
            "cCover", 1, function() return cover != null
        );
        spr.anim.registerStateAnim("cIdle", 0);

        lockControlsS(rnd(0.3, 1.6));
    }

    override public function stunS(t: Float) {}

    override public function canBeGrabbed()
        return false;

    override public function canBePushed()
        return false;

    override function onDie() {
        super.onDie();
        new entity.DeadBody(this, "c").init();
    }

    override function get_shootY(): Float {
        return switch (curAnimId) {
            case "cBlind": footY - 13;
            case "cAim": footY - 18;
            default: super.get_shootY();
        }
    }

    override function get_headY(): Float {
        if (spr != null && !spr.destroyed)
            return super.get_headY() - 5 + switch (spr.groupName) {
                case "cStun": 7;
                default: 0;
            }
        return super.get_headY();
    }

    override function onDamage(v: Int) {
        super.onDamage(v);

        spr.anim.playOverlap("cHit");
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
