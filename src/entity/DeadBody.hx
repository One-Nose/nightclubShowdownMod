package entity;

class DeadBody extends Entity {
    public static var ALL: Array<DeadBody> = [];

    var sid: String;

    public function new(e: Entity, sid: String) {
        super(e.cx, e.cy);
        xr = e.xr;
        yr = e.yr;

        sprScaleX = e.sprScaleX;
        sprScaleY = e.sprScaleY;
        dx = e.lastHitDir * 0.18;
        dir = -e.lastHitDir;
        gravity *= 0.25;
        frict = 0.97;
        dy = -0.1;

        this.sid = sid;

        spr.colorize(e.spr.color.toColor());
    }

    override function init() {
        super.init();

        ALL.push(this);

        spr.anim.registerStateAnim(
            sid + "DeathBounce", 2,
            function() return !onGround && cd.has("hitGround"));
        spr.anim.registerStateAnim(
            sid + "DeathFly", 1, function() return !onGround
        );
        spr.anim.registerStateAnim(sid + "DeathGround", 0);

        cd.setS("bleeding", 2);
        cd.setS("decay", rnd(20, 25));
    }

    override public function dispose() {
        super.dispose();
        ALL.remove(this);
    }

    override function onLand() {
        if (M.fabs(dy) <= 0.05) {
            dy = 0;
            frict = 0.8;
        } else
            dy = -dy * 0.7;
        cd.setS("hitGround", Const.INFINITE);
    }

    override public function postUpdate() {
        super.postUpdate();
        if (cd.has("decay"))
            spr.scaleY = cd.getRatio("decay");
    }

    override public function update() {
        super.update();
        if (cd.has("bleeding") && !cd.hasSetS("bleedFx", 0.03))
            fx.woundBleed(centerX - dir * 8, centerY);

        if (!onGround) {
            // Dmg covers
            for (e in entity.Cover.ALL)
                if (
                    distPx(e) <= radius + e.radius &&
                    !e.cd.hasSetS("bodyHit", 0.3) &&
                    (dx > 0 && dirTo(e) == 1 || dx < 0 && dirTo(e) == -1)
                )
                    e.hit(2, this, true);

            // Push mobs
            for (e in entity.Mob.ALL)
                if (
                    e.isAlive() &&
                    distPx(e) <= radius + e.radius &&
                    !e.cd.hasSetS("bodyHit", 0.4) &&
                    e.canBePushed()
                ) {
                    if (!e.cd.hasSetS("bodyDmg", 1))
                        e.hit(1, this, true);
                    e.violentBump(dirTo(e) * 0.4, -0.2, 1.75);
                }
        }

        if (!cd.has("decay"))
            destroy();
    }
}
