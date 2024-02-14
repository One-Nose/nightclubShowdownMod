package wave;

class Battle extends Wave {
    public var mobCount(default, null) = 0;

    var color: dn.Col;

    public function new(color: dn.Col, ...registries) {
        super(...registries);
        this.color = color;
        this.isRewarding = true;
    }

    override function registerEntity(entity, delaySeconds = 0.0) {
        super.registerEntity(entity, delaySeconds);
        if (entity is entity.Mob)
            this.mobCount++;
    }

    override function start() {
        super.start();
        Game.ME.level.hue(Color.intToHsl(this.color).h * 6.28, 2.5);
    }

    function isOver() {
        return this.mobCount <= 0;
    }

    override function onMobDie() {
        super.onMobDie();
        this.mobCount--;
    }
}
