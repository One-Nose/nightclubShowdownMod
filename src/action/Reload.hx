package action;

class Reload extends Action {
    public function new(hero: en.Hero) {
        super(hero, "Reload");
    }

    public static function getInstance(
        hero: en.Hero, x: Float, y: Float
    ): Null<Reload> {
        if (
            hero.ammo < hero.maxAmmo &&
            M.fabs(hero.centerX - x) <= Const.GRID * 0.3 &&
            M.fabs(hero.centerY - y + Const.GRID / 3) <= Const.GRID * 0.7
        )
            return new Reload(hero);

        return null;
    }

    public override function execute() {
        super.execute();

        this.hero.spr.anim.stopWithStateAnims();
        this.hero.spr.anim.play("heroReload");
        Assets.SFX.reload0(1);
        this.hero.game.delayer.addS(Assets.SFX.reload1.bind(1), 0.25);
        this.hero.game.delayer.addS(Assets.SFX.reload1.bind(1), 0.7);
        this.hero.fx.charger(
            this.hero.centerX - this.hero.dir * 6, this.hero.centerY - 4,
            -this.hero.dir
        );
        this.hero.cd.setS("reloading", 0.8);
        this.hero.lockControlsS(0.8);
        this.hero.setAmmo(this.hero.maxAmmo);
    }

    public override function updateDisplay() {
        this.hero.icon.setPos(this.hero.centerX, this.hero.footY);
        this.hero.icon.set("iconReload");

        super.updateDisplay();
    }
}
