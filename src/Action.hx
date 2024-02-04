abstract class Action {
    var helpText: Null<String> = null;
    var color: Null<dn.Col> = null;
    var displayEntity: Null<Entity> = null;

    function new(?helpText: String, ?color: dn.Col, ?displayEntity: Entity) {
        this.helpText = helpText;
        this.color = color;
        this.displayEntity = displayEntity;
    }

    public abstract function execute(hero: en.Hero): Void;

    public function updateDisplay(hero: en.Hero) {
        if (this.helpText == null)
            hero.icon.visible = false;
        else if (this.color != null)
            hero.icon.colorize(this.color);
        hero.setHelp(this.displayEntity, this.helpText, this.color);
    }
}
