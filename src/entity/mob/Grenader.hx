package entity.mob;

class Grenader extends entity.Mob {
    public function new(x, y, ?dir) {
        super(x, y, dir);

        initLife(3);

        var s = createSkill("shoot");
        s.setTimers(0.6, 0, 3);
        s.onStart = function() {
            lookAt(s.target);
            spr.anim.playAndLoop("bGrenade");
        }
        s.onProgress = function(t) lookAt(s.target);
        s.onInterrupt = function() spr.anim.stopWithStateAnims();
        s.onExecute = function(e) {
            dy = -0.1;
            var g = new entity.Grenade(this);
            g.init();
            g.setPosPixel(shootX, shootY);
            g.dx = dirTo(e) * 0.2 * M.fabs(e.cx - cx) / 7; // 0.2 for 7 cells
            g.dy = -0.05;
            // if( e.hitOrHitCover(1,this) ) {
            // e.dx*=0.3;
            // e.dx+=dirTo(e)*rnd(0.03,0.06);
            // e.lockMovementsS(0.3);
            // e.lockControlsS(0.3);
            // fx.bloodHit(shootX, shootY, e.centerX, e.centerY);
            // }
            // fx.shoot(shootX, shootY, e.centerX, e.centerY, 0xFF0000);
            spr.anim.play("bThrowGrenade");
        }
    }

    override function init() {
        super.init();

        spr.anim.registerStateAnim("bGrab", 4, function() return isGrabbed());
        spr.anim.registerStateAnim(
            "bPush", 2, function() return !onGround && cd.has("bodyHit"));
        spr.anim.registerStateAnim("bStun", 1, function() return isStunned());
        spr.anim.registerStateAnim("bIdle", 0);
    }

    override function onDie() {
        super.onDie();
        new entity.DeadBody(this, "b").init();
    }

    override function get_shootY(): Float {
        return footY - 12;
    }

    override function get_headY(): Float {
        if (spr != null && !spr.destroyed)
            return super.get_headY() + switch (spr.groupName) {
                case "bStun": 11;
                default: 0;
            }
        return super.get_headY();
    }

    override function onDamage(v: Int) {
        super.onDamage(v);

        spr.anim.playOverlap("bHit");

        if (getDiminishingReturnFactor("hitInterrupt", 3, 3) > 0)
            interruptSkills(true);
    }

    override public function update() {
        super.update();

        if (
            tx == -1 &&
            !controlsLocked() &&
            onGround &&
            getSkill("shoot").isReady() &&
            game.hero.isAlive()
        )
            getSkill("shoot").prepareOn(game.hero);
    }
}
