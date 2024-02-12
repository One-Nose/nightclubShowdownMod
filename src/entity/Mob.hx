package entity;

class Mob extends Entity {
    public static var ALL: Array<Mob> = [];

    var tx = -1;
    var onArrive: Null<() -> Void>;

    var hitSounds: Array<(Float) -> dn.heaps.Sfx>;

    public function new(x, y) {
        super(x, y);

        hitSounds = [
            Assets.SFX.grunt0, Assets.SFX.grunt1, Assets.SFX.grunt2,
            Assets.SFX.grunt3, Assets.SFX.grunt4,
        ];
        dn.Lib.shuffleArray(hitSounds, Std.random);
        // var g = new h2d.Graphics(spr);
        // g.beginFill(0xFF0000,1);
        // g.drawCircle(0,-radius,radius);

        initLife(4);
    }

    override function init() {
        super.init();
        ALL.push(this);

        game.scroller.add(spr, Const.MOBS_LAYER);

        lifeBar.visible = true;
    }

    function playHitSound() {
        var s = hitSounds.shift();
        s(0.7);
        hitSounds.insert(hitSounds.length - irnd(0, 2), s);
    }

    override public function violentBump(bdx: Float, bdy: Float, sec: Float) {
        super.violentBump(bdx, bdy, sec);
        leaveCover();
    }

    override function onDamage(v: Int) {
        super.onDamage(v);
        leaveCover();
    }

    public function enterArena() {
        spr.alpha = 0;
        cd.setS("entering", 0.5);
        cd.onComplete("entering", function() {
            lookAt(hero);
        });
        lockControlsS(rnd(0.2, 0.8) + cd.getS("entering"));
    }

    public function canBePushed()
        return true;

    public function canBeGrabbed() {
        return true;
    }

    override function onDie() {
        super.onDie();
        level.waveMobCount--;

        for (mob in Mob.ALL)
            if (mob.isAlive())
                return;
        this.game.cd.setS("lastMobDiedRecently", 1.5);
    }

    override public function stunS(t: Float) {
        super.stunS(t);
        if (t > 0)
            tx = -1;
    }

    public function isGrabbed()
        return hero.isAlive() && hero.grabbedMob == this;

    public function canBeShot()
        return this.isAlive() && !cd.has("entering");

    override public function isBlockingHeroMoves()
        return !isGrabbed();

    override public function dispose() {
        super.dispose();
        ALL.remove(this);
    }

    override public function postUpdate() {
        super.postUpdate();
        if (cd.has("entering"))
            spr.alpha = 1 - cd.getRatio("entering");
    }

    function goto(x: Int, ?onDone: () -> Void) {
        tx = x;
        onArrive = onDone;
    }

    public function countMobs(c: Class<Mob>, includeSelf: Bool) {
        var n = 0;
        for (e in ALL)
            if (e.is(c) && (includeSelf || e != this))
                n++;
        return n;
    }

    override public function movementLocked() {
        return super.movementLocked() || isGrabbed();
    }

    override public function controlsLocked() {
        return super.controlsLocked() || isGrabbed();
    }

    override public function update() {
        super.update();

        if (
            tx != -1 &&
            !cd.has("entering") &&
            !movementLocked() &&
            !controlsLocked() &&
            !hasSkillCharging()
        ) {
            if (cover != null)
                leaveCover();

            var s = 0.015;
            if (tx > cx) {
                dir = 1;
                dx += s * tmod;
            }
            if (tx < cx) {
                dir = -1;
                dx -= s * tmod;
            }

            if (tx == cx) {
                tx = -1;
                if (onArrive != null) {
                    var cb = onArrive;
                    onArrive = null;
                    cb();
                }
            }
        }

        if (cd.has("entering"))
            dx = dir * 0.05;

        // Find cover
        if (
            cover == null &&
            tx == -1 &&
            !controlsLocked() &&
            !hasSkillCharging()
        )
            for (e in entity.Cover.ALL)
                if (
                    distCase(e) <= 3 &&
                    e.canHostSomeone(-dirTo(hero)) &&
                    !e.coversAnyone()
                ) {
                    // fx.markerEntity(e, true);
                    goto(e.cx - dirTo(hero), function() {
                        startCover(e, -dirTo(hero));
                    });
                }

        // Dodge hero
        if (
            onGround &&
            !movementLocked() &&
            !controlsLocked() &&
            (!hasSkillCharging() || canInterruptSkill()) &&
            distCase(hero) <= 1.75 &&
            hero.moveTarget == null &&
            !cd.has("dodgeHero")
        ) {
            if (cover == null || dirTo(cover) != dirTo(hero)) {
                leaveCover();
                for (s in skills)
                    s.interrupt(false);
                dx = -dirTo(hero) * 0.12;
                dy = -0.15;
                cd.setS("dodgeHero", 0.6);
            }
        }
    }
}
