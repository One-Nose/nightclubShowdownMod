package entity;

class Grenade extends Entity {
    public static var ALL: Array<Grenade> = [];

    var range: Float;

    public function new(entity: Entity, range = 1.) {
        super(entity.cx, entity.cy);
        xr = entity.xr;
        yr = entity.yr;

        this.dir = entity.dir;
        this.gravity *= 0.25;
        this.frict = 0.98;
        this.radius = 5;
        this.range = Const.GRID * range;

        this.spr.setCenterRatio(0.5, 0.5);
        this.spr.set("grenade");
    }

    override function init() {
        super.init();

        ALL.push(this);

        cd.setS("timer", 1.25);
    }

    override public function dispose() {
        super.dispose();
        ALL.remove(this);
    }

    override function onLand() {
        frict = 0.93;
        dy = -dy * 0.8;
    }

    override public function postUpdate() {
        super.postUpdate();
        spr.y -= 3;
        spr.rotation += dx * 2;
    }

    override public function update() {
        super.update();

        if (cd.getS("timer") <= 0.5 && !cd.hasSetS("warn", 0.1))
            fx.warnZone(centerX, centerY, range);

        if (!cd.has("timer")) {
            fx.grenade(centerX, centerY, range);
            Assets.SFX.explode3(1);

            if (distPx(game.hero) <= range) {
                game.hero.violentBump(dirTo(game.hero) * 0.28, -0.2, 0.5);
                game.hero.hit(2, this);
            }

            for (e in entity.Cover.ALL)
                if (distPx(e) <= range)
                    e.hit(3, this);

            for (e in entity.Mob.ALL)
                if (distPx(e) <= range)
                    e.hit(3, this);

            destroy();
        }
    }
}
