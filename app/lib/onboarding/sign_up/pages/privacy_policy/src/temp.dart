class Foo {
  final List<Foo> subsections;
  final bool aBoolWithSomeVeryLongName;

  Foo({
    this.subsections,
    this.aBoolWithSomeVeryLongName,
  }) : assert(subsections
                .where((element) => element.aBoolWithSomeVeryLongName)
                .length <=
            1);
}
