package action;

class TakeCover extends Action {
    public var entity: en.Cover;
    public var side: Int;

    public function new(entity: en.Cover, side: Int) {
        super();

        this.entity = entity;
        this.side = side;
    }
}
