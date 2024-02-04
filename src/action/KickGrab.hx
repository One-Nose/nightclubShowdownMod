package action;

class KickGrab extends Action {
    public function new() {
        super("Kick your cover");
    }

    public function execute(hero: en.Hero) {
        if (hero.grabbedMob != null) {
            Assets.SFX.hit1(1);
            hero.grabbedMob.hit(1, hero, true);
            hero.grabbedMob.xr += 0.5 * hero.dirTo(hero.grabbedMob);
            hero.grabbedMob.violentBump(hero.dir * 0.5, -0.1, 1.5);
            hero.stopGrab();
            hero.spr.anim.play("heroKick");
        }
    }

    public override function updateDisplay(hero: en.Hero) {
        hero.icon.setPos(hero.centerX - hero.dir * 8, hero.centerY);
        hero.icon.set("iconKickGrab");

        hero.icon.colorize(0xFF9300);
        super.updateDisplay(hero);
    }
}
