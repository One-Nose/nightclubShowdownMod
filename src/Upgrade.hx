class Upgrade {
    var game: Game;

    public var name(default, null): String;

    var onUnlock: () -> Void;
    var children: Array<Upgrade> = [];

    public function new(game: Game, name: String, onUnlock: () -> Void) {
        this.game = game;
        this.name = name;
        this.onUnlock = onUnlock;
    }

    public function claim() {
        this.onUnlock();

        this.game.unlockableUpgrades.remove(this);
        this.game.upgrades.push(this);
        for (upgrade in this.children)
            this.game.unlockableUpgrades.push(upgrade);
    }
}
