package entity;

class UpgradeEntity extends Entity {
    public static var ALL: Array<UpgradeEntity> = [];

    var upgrade: Upgrade;
    var helpText: h2d.Text;
    var description: h2d.Text;

    var isHovered = false;

    public function new(x, y, upgrade: Upgrade) {
        super(x, y);

        this.upgrade = upgrade;

        this.spr.set("upgrade" + upgrade.iconName);

        this.helpText = new h2d.Text(Assets.font);
        this.helpText.text = upgrade.name;
        this.helpText.textColor = 0x44F1F7;

        this.description = new h2d.Text(Assets.font);
        this.description.text = upgrade.description;
        this.description.textColor = 0x44F1F7;

        this.floatHeight = 0.1;

        var distanceFromEdge = if (this.level.waveId < 2) 20 else 5;

        this.description.x = if (x >= 10) distanceFromEdge else
            this.level.wid * Const.GRID -
            this.description.textWidth -
            distanceFromEdge;

        this.description.y = if (this.level.waveId < 2) 60 else 130;
        this.description.visible = false;
    }

    @:access(Game)
    override function init() {
        super.init();

        ALL.push(this);

        this.game.scroller.add(this.helpText, Const.UI_LAYER);
        this.game.root.add(this.description, Const.TOP_LAYER);
    }

    public function hover() {
        this.isHovered = true;
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
        this.helpText.y = Const.GRID * if (this.level.waveId < 2) 7 else 5;

        this.description.visible = this.isHovered;
        this.isHovered = false;
    }

    override function dispose() {
        super.dispose();
        ALL.remove(this);

        this.helpText.remove();
        this.description.remove();
    }
}
