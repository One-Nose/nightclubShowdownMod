package action;

class Wait extends Action {
    public var seconds: Float;

    public function new(seconds: Float) {
        super();

        this.seconds = seconds;
    }
}
