package action;

class Reload extends Action {
    public function new() {
        super("Reload");
    }

    public function execute(hero: en.Hero) {
        hero.spr.anim.stopWithStateAnims();
        hero.spr.anim.play("heroReload");
        Assets.SFX.reload0(1);
        hero.game.delayer.addS(Assets.SFX.reload1.bind(1), 0.25);
        hero.game.delayer.addS(Assets.SFX.reload1.bind(1), 0.7);
        hero.fx.charger(
            hero.centerX - hero.dir * 6, hero.centerY - 4, -hero.dir
        );
        hero.cd.setS("reloading", 0.8);
        hero.lockControlsS(0.8);
        hero.setAmmo(hero.maxAmmo);
    }

    public override function updateDisplay(hero: en.Hero) {
        hero.icon.setPos(hero.centerX, hero.footY);
        hero.icon.set("iconReload");

        super.updateDisplay(hero);
    }
}
