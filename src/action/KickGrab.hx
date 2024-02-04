package action;

class KickGrab extends Action {
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
}
