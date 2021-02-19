class Person {
  void work(Util util) {
    util.doIt();
  }
}

class Deveer extends Person {
  @override
  void work(covariant Keyboard util) {
    // TODO: implement work
    super.work(util);
  }
}

abstract class Util {
  void doIt();
}

class Keyboard extends Util {
  @override
  void doIt() {
    // TODO: implement doIt
    print('do it');
  }
}
