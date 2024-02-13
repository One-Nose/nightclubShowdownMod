class Entity {
    public static var ALL: Array<Entity> = [];

    public var game(get, never): Game;

    inline function get_game()
        return Game.ME;

    public var hero(get, never): entity.Hero;

    inline function get_hero()
        return Game.ME.hero;

    public var level(get, never): Level;

    inline function get_level()
        return Game.ME.level;

    public var fx(get, never): Fx;

    inline function get_fx()
        return Game.ME.fx;

    public var destroyed(default, null) = false;
    public var cd: dn.Cooldown;
    public var tmod: Float;

    public var spr: HSprite;
    public var debug: Null<h2d.Graphics>;
    public var label: Null<h2d.Text>;

    var cAdd: h3d.Vector;
    var lifeBar: h2d.Flow;

    public var uid: Int;
    public var cx = 0;
    public var cy = 0;
    public var xr = 0.;
    public var yr = 0.;
    public var dx = 0.;
    public var dy = 0.;
    public var frict = 0.9;
    public var gravity = 0.02;
    public var hasGravity = true;
    public var weight = 1.;
    public var radius: Float;
    public var dir(default, set) = 1;
    public var hasColl = true;
    public var isAffectBySlowMo = true;
    public var lastHitDir = 0;
    public var sprScaleX = 1.0;
    public var sprScaleY = 1.0;
    public var isInvulnerable = false;

    public var life: Int;
    public var maxLife: Int;

    var skills: Array<Skill>;
    var diminishingUses: Map<String, Int> = new Map();

    public var head(default, null): Area;
    public var torso(default, null): Area;
    public var legs(default, null): Area;

    public var cover: Null<entity.Cover>;

    public var footX(get, never): Float;

    inline function get_footX()
        return (this.cx + this.xr) * Const.GRID;

    public var footY(get, never): Float;

    inline function get_footY()
        return (this.cy + this.yr) * Const.GRID;

    public var centerX(get, never): Float;

    inline function get_centerX()
        return this.footX;

    public var centerY(get, never): Float;

    inline function get_centerY()
        return this.footY - this.radius;

    public var headX(get, never): Float;

    function get_headX()
        return this.footX;

    public var headY(get, never): Float;

    function get_headY()
        return this.footY - 22;

    public var shootX(get, never): Float;

    function get_shootX()
        return this.footX + this.dir * 11;

    public var shootY(get, never): Float;

    function get_shootY()
        return this.footY - this.radius * 0.8;

    public var onGround(get, never): Bool;

    inline function get_onGround()
        return this.level.hasColl(cx, cy + 1) && this.yr >= 1 && this.dy == 0;

    public var curAnimId(get, never): String;

    inline function get_curAnimId()
        return if (
            !this.isAlive() ||
            this.spr == null ||
            this.spr.destroyed
        ) "" else this.spr.groupName;

    private function new(x, y) {
        this.uid = Const.UNIQ++;

        this.lifeBar = new h2d.Flow();
        this.lifeBar.horizontalSpacing = 1;
        this.lifeBar.visible = false;

        this.radius = Const.GRID * 0.6;
        this.setPosCase(x, y);
        this.initLife(3);
        this.skills = [];

        this.spr = new HSprite(Assets.gameElements);
        this.spr.setCenterRatio(0.5, 1);
        this.spr.colorAdd = this.cAdd = new h3d.Vector();

        this.head = new Area(this, 6, () -> this.headX, () -> this.headY);
        this.head.color = 0xFF0000;

        this.torso = new Area(
            this,
            8,
            () -> (this.headX + this.footX) * 0.5,
            () -> (this.headY + this.footY - 4) * 0.5
        );
        this.torso.color = 0x0080FF;

        this.legs = new Area(this, 5, () -> this.footX, () -> this.footY - 4);
        this.legs.color = 0x9D55DF;
    }

    public function init() {
        ALL.push(this);

        this.cd = new dn.Cooldown(Const.FPS);

        this.game.scroller.add(this.lifeBar, Const.UI_LAYER);
        this.game.scroller.add(this.spr, Const.PROPS_LAYER);
    }

    public function isBlockingHeroMoves()
        return false;

    public function initLife(value) {
        this.life = this.maxLife = value;
        this.updateLifeBar();
    }

    function updateLifeBar() {
        this.lifeBar.removeChildren();
        for (i in 0...this.maxLife) {
            var lifeDot = Assets.gameElements.h_get("dot", lifeBar);
            lifeDot.scaleY = 2;
            lifeDot.colorize(if (i + 1 <= life) 0xFFFFFF else 0xCC0000);
        }
    }

    public function isCoveredFrom(source: Entity) {
        return if (source == null) false else (
            this.cover != null &&
            this.cover.isAlive() &&
            this.dirTo(source) == this.dirTo(this.cover)
        );
    }

    public function hitCover(damage: Int, source: Entity) {
        this.cover.hit(damage, source);
    }

    public function hit(
        damage: Int, source: Entity, ?ignoreCover = false
    ): Bool {
        if (source != null)
            this.lastHitDir = source.dirTo(this);

        if (damage <= 0 || !this.isAlive() || this.cd.has("rolling"))
            return false;

        if (!ignoreCover && this.isCoveredFrom(source)) {
            this.hitCover(damage, source);
            return false;
        }

        damage = M.imin(this.life, damage);
        if (!this.isInvulnerable)
            this.life -= damage;
        this.updateLifeBar();
        this.onDamage(damage);
        this.blink();
        if (this.life <= 0) {
            this.interruptSkills(false);
            this.onDie();
        }
        return true;
    }

    public function violentBump(bdx: Float, bdy: Float, seconds: Float) {
        if (!this.isAlive())
            return;

        this.dx = bdx;
        this.dy = bdy;
        this.dir = if (bdx > 0) -1 else 1;
        this.stunS(seconds);
        this.interruptSkills(false);
    }

    function onDamage(value: Int) {
        // this.leaveCover();
    }

    function onDie() {
        this.destroy();
    }

    public inline function isAlive() {
        return this.life > 0 && !this.destroyed;
    }

    public function toString() {
        return Type.getClassName(Type.getClass(this)) + '#${this.uid}';
    }

    public function createSkill(id: String): Skill {
        var skill = new Skill(id, this);
        this.skills.push(skill);
        return skill;
    }

    public function interruptSkills(startCd: Bool) {
        for (skill in this.skills)
            skill.interrupt(startCd);
    }

    public function getSkill(id: String): Null<Skill> {
        for (skill in this.skills)
            if (skill.id == id)
                return skill;
        return null;
    }

    public function movementLocked() {
        return this.cd.has("moveLock") || this.isStunned();
    }

    public function lockMovementsS(t: Float) {
        if (this.isAlive())
            this.cd.setS("moveLock", t, false);
    }

    public function controlsLocked() {
        return
            this.cd.has("ctrlLock") ||
            this.isStunned() ||
            this.game.hasCinematic();
    }

    public function lockControlsS(t: Float) {
        if (this.isAlive())
            this.cd.setS("ctrlLock", t, false);
    }

    public function stunS(t: Float) {
        if (this.isAlive() && t > 0)
            this.cd.setS("stun", t, false);
    }

    public function isStunned() {
        return this.cd.has("stun");
    }

    // public function pop(str: String, ?c = 0x30D9E7) {
    //     var tf = new h2d.Text(Assets.font);
    //     game.scroller.add(tf, Const.DP_UI);
    //     tf.text = str;
    //     tf.textColor = c;
    //
    //     tf.x = Std.int(footX - tf.textWidth * 0.5);
    //     tf.y = Std.int(footY - 5);
    //     game.tw.createS(tf.y, tf.y - 20, 0.15);
    //     game.tw.createS(tf.scaleY, 0 > 1, 0.15);
    //     game.delayer.addS(function() {
    //         game.tw.createS(tf.y, tf.y - 15, 1);
    //     }, 0.15);
    //     game.delayer.addS(function() {
    //         game.tw.createS(tf.alpha, 1 > 0, 0.4).end(function() {
    //             tf.remove();
    //         });
    //     }, 2);
    // }

    inline function set_dir(value) {
        return this.dir = if (value > 0) 1 else if (value < 0) -1 else this.dir;
    }

    public function setPosCase(x: Int, y: Int) {
        this.cx = x;
        this.cy = y;
        this.xr = 0.5;
        this.yr = 1;
    }

    public function setPosPixel(x: Float, y: Float) {
        this.cx = Std.int(x / Const.GRID);
        this.cy = Std.int(y / Const.GRID);
        this.xr = (x - this.cx * Const.GRID) / Const.GRID;
        this.yr = (y - this.cy * Const.GRID) / Const.GRID;
    }

    public function say(str: String, ?color = 0xFFFFFF) {
        var i = 0;
        var tween = game.tw.createS(i, str.length, str.length * 0.03);
        tween.onUpdate = function() {
            this.setLabel(str.substr(0, i), color);
        }
        tween.onEnd = function() {
            var tf = this.label;
            this.game.cinematic.signal("say");
            this.game.tw.createS(tf.alpha, 0.5 | 0, 1)
                .end(function() this.setLabel());
        }
    }

    public function setLabel(?str: String, ?color = 0xFFFFFF) {
        if (str == null && this.label != null) {
            this.label.remove();
            this.label = null;
        }
        if (str != null) {
            if (this.label == null) {
                this.label = new h2d.Text(Assets.font);
                this.game.scroller.add(this.label, Const.UI_LAYER);
            }
            this.label.text = str;
            this.label.textColor = color;
        }
    }

    public function startCover(newCover: entity.Cover, side: Int) {
        if (!newCover.canHostSomeone(side))
            return false;

        this.dx = this.dy = 0;
        this.cover = newCover;
        this.setPosCase(newCover.cx + side, newCover.cy);
        this.xr = 0.5 - side * 0.25;
        this.yr = 1;
        this.lookAt(newCover);
        return true;
    }

    public function leaveCover() {
        this.cover = null;
    }

    public inline function rnd(min, max, ?sign)
        return Lib.rnd(min, max, sign);

    public inline function irnd(min, max, ?sign)
        return Lib.irnd(min, max, sign);

    public inline function pretty(value: Float, ?precision = 1)
        return M.pretty(value, precision);

    public inline function distCase(entity: Entity) {
        return M.dist(
            this.cx + this.xr, this.cy + this.yr, entity.cx + entity.xr,
            entity.cy + entity.yr
        );
    }

    public inline function distPx(entity: Entity) {
        return M.dist(this.footX, this.footY, entity.footX, entity.footY);
    }

    public inline function distPxFree(x: Float, y: Float) {
        return M.dist(this.footX, this.footY, x, y);
    }

    // function canSeeThrough(x, y)
    //     return !level.hasColl(x, y);
    //
    // public inline function sightCheck(e: Entity) {
    //     if (level.hasColl(cx, cy) || level.hasColl(e.cx, e.cy))
    //         return true;
    //     return dn.Bresenham.checkThinLine(cx, cy, e.cx, e.cy, canSeeThrough);
    // }
    //
    // public inline function sightCheckCase(x, y) {
    //     return dn.Bresenham.checkThinLine(cx, cy, x, y, canSeeThrough);
    // }

    public inline function getMoveAng() {
        return Math.atan2(this.dy, this.dx);
    }

    public inline function angTo(entity: Entity)
        return Math.atan2(entity.footY - this.footY, entity.footX - this.footX);

    public inline function dirTo(entity: Entity)
        return if (entity.footX <= this.footX) -1 else 1;

    public inline function lookAt(entity: Entity)
        this.dir = this.dirTo(entity);

    public inline function isLookingAt(entity: Entity)
        return this.dirTo(entity) == this.dir;

    public inline function destroy() {
        this.destroyed = true;
    }

    public function is<T: Entity>(cls: Class<T>)
        return Std.isOfType(this, cls);

    public function as<T: Entity>(cls: Class<T>): T
        return Std.downcast(this, cls);

    public function dispose() {
        ALL.remove(this);
        this.lifeBar.remove();
        this.cd.dispose();
        this.spr.remove();
        this.skills = null;
        if (this.label != null)
            this.label.remove();
        if (this.debug != null)
            this.debug.remove();
    }

    public function preUpdate() {
        this.cd.update(this.tmod);
    }

    public function postUpdate() {
        this.spr.x = (this.cx + this.xr) * Const.GRID;
        this.spr.y = (this.cy + this.yr) * Const.GRID;
        this.spr.scaleX = this.dir * this.sprScaleX;
        this.spr.scaleY = this.sprScaleY;
        this.spr.anim.setGlobalSpeed(
            if (isAffectBySlowMo) game.getSlowMoFactor() else 1
        );

        if (this.label != null) {
            this.label.setPosition(
                Std.int(this.footX - this.label.textWidth * 0.5),
                Std.int(this.headY - this.label.textHeight - 3),
            );
        }

        lifeBar.setPosition(
            Std.int(this.footX - this.lifeBar.outerWidth * 0.5),
            Std.int(this.footY + 2),
        );

        if (Console.ME.has("bounds")) {
            if (this.debug == null) {
                this.debug = new h2d.Graphics();
                this.game.scroller.add(this.debug, Const.UI_LAYER);
            }
            this.debug.setPosition(this.footX, this.footY);
            this.debug.clear();
            this.debug.beginFill(0xFFFFFF, 0.9);
            this.debug.drawRect(
                this.shootX - this.footX, this.shootY - this.footY, 2, 2
            );

            this.debug.beginFill(0xE8DDB3, 0.1);
            this.debug.lineStyle(1, 0xE8DDB3, 0.2);
            this.debug.drawCircle(0, -this.radius, this.radius);

            for (area in Area.ALL)
                if (area.owner == this) {
                    this.debug.beginFill(area.color, 0.2);
                    this.debug.lineStyle(1, area.color, 0.4);
                    this.debug.drawCircle(
                        area.centerX - this.footX,
                        area.centerY - this.footY,
                        area.radius
                    );
                }

            // var c = 0xFF0000; debug.beginFill(c,0.2); debug.lineStyle(1,c,0.7);
            // debug.drawCircle(head.centerX-footX, head.centerY-footY, head.radius);
            //
            // var c = 0x0080FF; debug.beginFill(c,0.2); debug.lineStyle(1,c,0.7);
            // debug.drawCircle(torso.centerX-footX, torso.centerY-footY, torso.radius);
            //
            // var c = 0x6D5BA4; debug.beginFill(c,0.2); debug.lineStyle(1,c,0.7);
            // debug.drawCircle(legs.centerX-footX, legs.centerY-footY, legs.radius);
        }
        if (!Console.ME.has("bounds") && this.debug != null) {
            this.debug.remove();
            this.debug = null;
        }

        this.cAdd.r *= Math.pow(0.93, this.tmod);
        this.cAdd.g *= Math.pow(0.8, this.tmod);
        this.cAdd.b *= Math.pow(0.8, this.tmod);
    }

    // function hasCircColl() {
    // return !destroyed && weight>=0 && !cd.has("rolling") && altitude<=5;
    // }
    //
    // function hasCircCollWith(e:Entity) {
    // return true;
    // }

    public function getDiminishingReturnFactor(
        id: String, fullUses: Int, maxUses: Int
    ): Float {
        if (!this.diminishingUses.exists(id))
            this.diminishingUses.set(id, 1);
        else
            this.diminishingUses.set(id, this.diminishingUses.get(id) + 1);

        var n = this.diminishingUses.get(id);
        if (n <= fullUses)
            return 1;
        else if (n > maxUses)
            return 0;
        else
            return 1 - (n - fullUses) / (maxUses - fullUses + 1);
    }

    public function onClick(x: Float, y: Float, bt: Int) {}

    function onTouch(entity: Entity) {}

    function onBounce(pow: Float) {}

    function onTouchWall(wallDir: Int) {
        this.dx *= 0.5;
    }

    function onTouchCeiling() {
        this.dy = 0;
    }

    function onLand() {
        this.dy = 0;
    }

    public function blink() {
        this.cAdd.r = 1;
        this.cAdd.g = 1;
        this.cAdd.b = 1;
    }

    public function setTmod(value: Float) {
        this.tmod = value * if (
            this.isAffectBySlowMo &&
            this.game.isSlowMo()
        ) Const.PAUSE_SLOWMO else 1;
    }

    public function hasSkillCharging() {
        for (skill in this.skills)
            if (skill.isCharging())
                return true;
        return false;
    }

    public function canInterruptSkill() {
        return true;
    }

    public function update() {
        for (skill in this.skills)
            skill.update(this.tmod);

        if (this.cover != null && !this.cover.isAlive())
            this.leaveCover();

        // // Circular collisions
        // if (hasCircColl())
        //     for (e in ALL)
        //         if (
        //             e != this &&
        //             e.hasCircColl() &&
        //             hasCircCollWith(e) &&
        //             e.hasCircCollWith(this)
        //         ) {
        //             var d = distPx(e);
        //             if (d <= radius + e.radius) {
        //                 var repel = 0.05;
        //                 var a = Math.atan2(e.footY - footY, e.footX - footX);
        //
        //                 var r = e.weight == weight ? 0.5 : e.weight / (weight
        //                     + e.weight);
        //                 if (r <= 0.1)
        //                     r = 0;
        //                 dx -= Math.cos(a) * repel * r;
        //                 dy -= Math.sin(a) * repel * r;
        //
        //                 var r = e.weight == weight ? 0.5 : weight / (weight
        //                     + e.weight);
        //                 if (r <= 0.1)
        //                     r = 0;
        //                 e.dx += Math.cos(a) * repel * r;
        //                 e.dy += Math.sin(a) * repel * r;
        //
        //                 onTouch(e);
        //                 e.onTouch(this);
        //             }
        //         }

        if (this.cover != null) {
            this.dx = this.dy = 0;
        }

        // X
        var steps = M.ceil(M.fabs(this.dx * this.tmod));
        var step = this.dx * this.tmod / steps;
        while (steps > 0) {
            this.xr += step;
            if (this.hasColl) {
                if (this.xr > 0.7 && this.level.hasColl(this.cx + 1, this.cy)) {
                    this.xr = 0.7;
                    this.onTouchWall(1);
                    steps = 0;
                }
                if (this.xr < 0.3 && this.level.hasColl(this.cx - 1, this.cy)) {
                    this.xr = 0.3;
                    this.onTouchWall(-1);
                    steps = 0;
                }
            }
            while (this.xr > 1) {
                this.xr--;
                this.cx++;
            }
            while (this.xr < 0) {
                this.xr++;
                this.cx--;
            }
            steps--;
        }
        this.dx *= Math.pow(this.frict, this.tmod);

        // Gravity
        if (!this.onGround && this.hasGravity)
            this.dy += this.gravity * this.tmod;

        // Y
        var steps = M.ceil(M.fabs(this.dy * this.tmod));
        var step = this.dy * this.tmod / steps;
        while (steps > 0) {
            this.yr += step;
            if (this.hasColl) {
                if (this.yr > 1 && this.level.hasColl(this.cx, this.cy + 1)) {
                    this.yr = 1;
                    this.onLand();
                    // steps = 0;
                }
                if (this.yr < 0.3 && this.level.hasColl(this.cx, this.cy - 1)) {
                    this.yr = 0.3;
                    this.onTouchCeiling();
                    steps = 0;
                }
            }
            while (this.yr > 1) {
                this.yr--;
                this.cy++;
            }
            while (this.yr < 0) {
                this.yr++;
                this.cy--;
            }
            steps--;
        }
        this.dy *= Math.pow(this.frict, this.tmod);
    }
}
