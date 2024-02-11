abstract class Action {
    var hero: entity.Hero;
    var helpText: Null<String> = null;
    var color: Null<dn.Col> = null;
    var displayEntity: Null<Entity> = null;

    function new(
        hero: entity.Hero, ?helpText: String, ?color: dn.Col,
        ?displayEntity: Entity
    ) {
        this.hero = hero;
        this.helpText = helpText;
        this.color = color;
        this.displayEntity = displayEntity;
    }

    public function execute() {
        if (!this.hero.game.isReplay)
            this.hero.game.heroHistory.push({t: this.hero.game.itime, a: this});
    }

    public function updateDisplay() {
        if (this.helpText == null)
            this.hero.icon.visible = false;
        else if (this.color != null)
            this.hero.icon.colorize(this.color);
        this.hero.setHelp(this.displayEntity, this.helpText, this.color);
    }
}
