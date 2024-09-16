abstract class Action {
    var hero: entity.Hero;
    var color: Null<dn.Col> = null;
    var displayEntity: Null<Entity> = null;

    function new(hero: entity.Hero, ?color: dn.Col, ?displayEntity: Entity) {
        this.hero = hero;
        this.color = color;
        this.displayEntity = displayEntity;
    }

    /**
        Returns whether the action can be performed. 
        null means the action can only be performed after moving.
    **/
    function canBePerformed(): Null<Bool> {
        return null;
    }

    public function execute() {
        if (!this.hero.game.isReplay)
            this.hero.game.heroHistory.push({t: this.hero.game.itime, a: this});

        if (this.canBePerformed())
            this._execute();
    }

    private abstract function _execute(): Void;

    public function updateDisplay() {
        if (this.color == null)
            this.hero.icon.visible = false;
        else
            this.hero.icon.colorize(this.color);
    }

    public abstract function equals(action: Action): Bool;
}
