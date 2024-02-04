package action;

class TurnBack extends Action {
    public function execute(hero: en.Hero) {
        hero.dir *= -1;
    }
}
