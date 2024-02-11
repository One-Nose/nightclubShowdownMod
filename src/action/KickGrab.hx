package action;

class KickGrab extends Action {
    public function new(hero: en.Hero) {
        super(hero, "Kick your cover");
    }

    public static function getInstance(
        hero: en.Hero, x: Float, y: Float
    ): Null<KickGrab> {
        if (
            hero.grabbedMob != null &&
            M.fabs(hero.centerX - hero.dir * 10 - x) <= 9 &&
            M.fabs(hero.centerY - y) <= 20
        )
            return new KickGrab(hero);

        return null;
    }

    public override function execute() {
        super.execute();

        if (this.hero.grabbedMob != null) {
            Assets.SFX.hit1(1);
            this.hero.grabbedMob.hit(1, this.hero, true);
            this.hero.grabbedMob.xr += 0.5 * this.hero.dirTo(
                this.hero.grabbedMob
            );
            this.hero.grabbedMob.violentBump(this.hero.dir * 0.5, -0.1, 1.5);
            this.hero.stopGrab();
            this.hero.spr.anim.play("heroKick");
        }
    }

    public override function updateDisplay() {
        this.hero.icon.setPos(
            this.hero.centerX - this.hero.dir * 8, this.hero.centerY
        );
        this.hero.icon.set("iconKickGrab");

        this.hero.icon.colorize(0xFF9300);
        super.updateDisplay();
    }
}
