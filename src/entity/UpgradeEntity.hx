package entity;

class UpgradeEntity extends Entity {
    public static var ALL: Array<UpgradeEntity> = [];

    var upgrade: Upgrade;
    var helpText: h2d.Text;

    public function new(x, y, upgrade: Upgrade) {
        super(x, y);

        this.upgrade = upgrade;

        this.spr.set("crate");

        this.helpText = new h2d.Text(Assets.font);
        this.helpText.text = upgrade.name;
        this.helpText.textColor = 0x44F1F7;
    }

    @:access(Game)
    override function init() {
        super.init();

        ALL.push(this);

        this.game.scroller.add(this.helpText, Const.UI_LAYER);
    }

    public function claim() {
        this.upgrade.claim();

        Assets.SFX.reload2(1);

        this.game.tw
            .createMs(this.game.upgradeMessage.alpha, 0, 1500)
            .onEnd = this.game.upgradeMessage.remove;

        for (entity in ALL)
            entity.destroy();
    }

    override function postUpdate() {
        super.postUpdate();

        this.helpText.x = Std.int(this.footX - this.helpText.textWidth * 0.5);
        this.helpText.y = Std.int(this.footY);
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);

        this.helpText.remove();
    }
}
