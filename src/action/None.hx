package action;

class None extends Action {
    function _execute() {}

    public function equals(action: Action): Bool {
        try {
            cast(action, None);
        } catch (e) {
            return false;
        }
        return true;
    }
}
