package action;

class TurnBack extends Action {
    public function execute() {
        this.hero.dir *= -1;
    }
}
