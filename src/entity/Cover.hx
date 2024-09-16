package entity;

class Cover extends Entity {
    public static var ALL: Array<Cover> = [];

    public var left: Area;
    public var right: Area;

    var iconLeft: HSprite;
    var iconRight: HSprite;

    public function new(x, y, isMetal = false) {
        super(x, y);

        this.spr.set(if (isMetal) "crateMetal" else "crate");
        this.lifeBar.visible = true;
        initLife(if (isMetal) 6 else 3);

        var r = 11;
        left = new Area(
            this, r, function() return centerX - r, function() return centerY
        );
        left.color = 0x009500;
        right = new Area(
            this, r, function() return centerX + r, function() return centerY
        );
        right.color = 0x17FF17;

        iconLeft = Assets.gameElements.h_get("iconShield");
        iconLeft.setCenterRatio(0.5, 1);
        iconLeft.blendMode = Add;
        iconLeft.colorize(0x14BBEB);

        iconRight = Assets.gameElements.h_get("iconShield");
        iconRight.setCenterRatio(0.5, 1);
        iconRight.blendMode = Add;
        iconRight.colorize(0x14BBEB);
    }

    override function init() {
        super.init();

        ALL.push(this);

        game.scroller.add(this.iconLeft, Const.UI_LAYER);
        game.scroller.add(this.iconRight, Const.UI_LAYER);
    }

    override function onDamage(v) {
        super.onDamage(v);
        Assets.SFX.cover0(1);
    }

    override function onDie() {
        Assets.SFX.explode2(1);
        this.spr.set(this.spr.groupName + "Broken");
        cd.setS("decay", 15);
        fx.woodCover(centerX, centerY, lastHitDir);
        this.lifeBar.visible = false;
    }

    override public function isBlockingHeroMoves()
        return isAlive();

    public function canHostSomeone(side: Int) {
        if (!isAlive() || !onGround)
            return false;

        for (e in Entity.ALL)
            if (e.cover == this && dirTo(e) == side)
                return false;
        return true;
    }

    public function coversAnyone(?side = 0) {
        for (e in Entity.ALL)
            if (e.cover == this && (side == 0 || dirTo(e) == side))
                return true;
        return false;
    }

    override function onLand() {
        super.onLand();
        for (e in ALL)
            if (e != this && distCase(e) <= 1 && e.isAlive())
                e.hit(999, this);

        Assets.SFX.land0(0.5);
    }

    override public function dispose() {
        super.dispose();
        ALL.remove(this);
        iconLeft.remove();
        iconRight.remove();
    }

    override public function postUpdate() {
        super.postUpdate();
        if (!isAlive() && cd.has("decay"))
            spr.scaleY = cd.getRatio("decay");

        iconLeft.setPos(centerX - 6, footY);
        iconLeft.visible = coversAnyone(-1);

        iconRight.setPos(centerX + 6, footY);
        iconRight.visible = coversAnyone(1);

        if (!this.hero.hasTakenCover && this.isAlive() && this.onGround) {
            this.actionIcon.visible = true;
            new action.TakeCover(
                hero, this, this.dirTo(hero)).updateDisplay(this.actionIcon);
            this.actionIcon.colorize(0x888888);
        } else
            this.actionIcon.visible = false;
    }

    override public function update() {
        super.update();

        if (!isAlive() && !cd.has("decay"))
            destroy();
    }
}
