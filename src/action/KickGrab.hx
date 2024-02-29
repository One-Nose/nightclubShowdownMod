package action;

class KickGrab extends Action {
    public function new(hero: entity.Hero) {
        super(hero, "Kick your cover");
    }

    public static function getInstance(
        hero: entity.Hero, x: Float, y: Float
    ): Null<KickGrab> {
        var action = new KickGrab(hero);

        if (
            action.canBePerformed() &&
            M.fabs(hero.centerX - hero.dir * 10 - x) <= Const.GRID &&
            M.fabs(hero.centerY - y) <= 20
        )
            return action;

        return null;
    }

    override function canBePerformed(): Null<Bool> {
        return this.hero.grabbedMob != null;
    }

    function _execute() {
        Assets.SFX.hit1(1);
        this.hero.grabbedMob.hit(1, this.hero, true);
        this.hero.grabbedMob.xr += 0.5 * this.hero.dirTo(this.hero.grabbedMob);
        this.hero.grabbedMob.violentBump(this.hero.dir * 0.5, -0.1, 1.5);
        this.hero.stopGrab();
        this.hero.spr.anim.play("heroKick");
    }

    public override function updateDisplay() {
        this.hero.icon.setPos(
            this.hero.centerX - this.hero.dir * 8, this.hero.centerY
        );
        this.hero.icon.set("iconKickGrab");

        this.hero.icon.colorize(0xFF9300);
        super.updateDisplay();
    }

    public function equals(action: Action): Bool {
        try {
            cast(action, KickGrab);
        } catch (e) {
            return false;
        }
        return true;
    }
}
