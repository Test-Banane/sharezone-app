import 'package:flutter/foundation.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharezone/onboarding/sign_up/pages/privacy_policy/new_privacy_policy_page.dart';
import 'package:sharezone/onboarding/sign_up/pages/privacy_policy/src/privacy_policy_src.dart';
import 'package:sharezone/onboarding/sign_up/pages/privacy_policy/src/table_of_contents_controller.dart';

DocumentSection _section(String id, {List<DocumentSection> subsections}) {
  return DocumentSection(id, id, subsections ?? []);
}

DocumentSectionHeadingPosition _headingPosition(
  String sectionId, {
  @required double itemLeadingEdge,
  @required double itemTrailingEdge,
}) {
  return DocumentSectionHeadingPosition(
    DocumentSection(sectionId, sectionId, []),
    itemLeadingEdge: itemLeadingEdge,
    itemTrailingEdge: itemTrailingEdge,
  );
}

void main() {
  group('the table of contents', () {
    TestCurrentlyReadingSectionController _createController(
      List<DocumentSection> sections,
      // TODO: Delete since its in the setup and can be used/accessed in the
      // method below?
      ValueNotifier<List<DocumentSectionHeadingPosition>> visibleSections, {
      double threshold = 0.1,
    }) {
      return TestCurrentlyReadingSectionController(
        sections,
        visibleSections,
        threshold: threshold,
      );
    }

    ValueNotifier<List<DocumentSectionHeadingPosition>> visibleSections;

    setUp(() {
      visibleSections = ValueNotifier<List<DocumentSectionHeadingPosition>>([]);
    });

    // TODO: Dont the first few tests more or less all test the same logic?
    test(
        'doesnt mark any section as active if none are or have been visible on the page',
        () {
      final sections = [
        _section('foo'),
      ];

      final controller = _createController(sections, visibleSections);

      expect(controller.currentlyReadSection, null);
    });

    test(
        'Doesnt mark a section as active when the top of the section is below the threshold',
        () {
      final sections = [
        _section('foo'),
      ];

      final controller =
          _createController(sections, visibleSections, threshold: 0.1);

      visibleSections.value = [
        _headingPosition(
          'foo',
          itemLeadingEdge: 0.11,
          itemTrailingEdge: 0.2,
        ),
      ];

      expect(controller.currentlyReadSection, null);
    });

    test(
        'Marks a section as active when the top of the section touches the threshold',
        () {
      final sections = [
        _section('foo'),
      ];

      final controller =
          _createController(sections, visibleSections, threshold: 0.1);

      visibleSections.value = [
        _headingPosition(
          'foo',
          itemLeadingEdge: 0.1,
          itemTrailingEdge: 0.15,
        ),
      ];

      expect(controller.currentlyReadSection, 'foo');
    });

    test(
        'Marks a section as active when the the section intersects the threshold',
        () {
      final sections = [
        _section('foo'),
      ];

      final controller =
          _createController(sections, visibleSections, threshold: 0.1);

      visibleSections.value = [
        _headingPosition(
          'foo',
          itemLeadingEdge: 0.05,
          itemTrailingEdge: 0.15,
        ),
      ];

      expect(controller.currentlyReadSection, 'foo');
    });
    test(
        'Marks a section as active when the the section is above the threshold',
        () {
      final sections = [
        _section('foo'),
      ];

      final controller =
          _createController(sections, visibleSections, threshold: 0.1);

      visibleSections.value = [
        _headingPosition(
          'foo',
          itemLeadingEdge: 0.05,
          itemTrailingEdge: 0.09,
        ),
      ];

      expect(controller.currentlyReadSection, 'foo');
    });

    test(
        'if currently visible sections go from some to none then it returns the section that comes before the current position inside the document',
        () {
      // TODO: Edge case: Scroll up from first section so that the first
      // section is not visible anymore
      // Scroll down from the last section so that the last section is not visible
      // anymore
      final sections = [
        _section('foo'),
        _section('bar'),
      ];

      final controller = _createController(sections, visibleSections);

      // At bottom of the screen
      visibleSections.value = [
        _headingPosition(
          'foo',
          itemLeadingEdge: 0.8,
          itemTrailingEdge: 0.85,
        ),
      ];

      // We scroll it to the top
      visibleSections.value = [
        _headingPosition(
          'foo',
          itemLeadingEdge: 0.0,
          itemTrailingEdge: 0.05,
        ),
      ];

      // We scroll it out of the view
      visibleSections.value = [];

      expect(controller.currentlyReadSection, 'foo');
    });
    test(
        'marks the one thats past/intersects with the threshold as active when several sections are on screen',
        () {
      final sections = [
        _section('foo'),
        _section('bar'),
        _section('baz'),
        _section('quz'),
      ];

      final controller = _createController(sections, visibleSections);

      // At bottom of the screen
      visibleSections.value = [
        _headingPosition(
          'foo',
          itemLeadingEdge: 0,
          itemTrailingEdge: 0.05,
        ),
        // intersects with thershold - should be active
        _headingPosition(
          'bar',
          itemLeadingEdge: 0.08,
          itemTrailingEdge: 0.12,
        ),
        _headingPosition(
          'baz',
          itemLeadingEdge: 0.2,
          itemTrailingEdge: 0.25,
        ),
        _headingPosition(
          'quz',
          itemLeadingEdge: 0.8,
          itemTrailingEdge: 1,
        ),
      ];

      expect(controller.currentlyReadSection, 'bar');
    });

    test(
        'when scrolling a section title out of viewport and another inside the viewport (at the bottom) it should mark the one scrolled out of the viewport as active',
        () {
      final sections = [
        _section('foo'),
        _section('bar'),
        _section('baz'),
      ];

      final controller = _createController(sections, visibleSections);

      // We scroll to the first section
      visibleSections.value = [
        _headingPosition(
          'foo',
          itemLeadingEdge: 0.8,
          itemTrailingEdge: 0.85,
        ),
      ];

      // We scroll down...
      visibleSections.value = [
        _headingPosition(
          'foo',
          itemLeadingEdge: 0,
          itemTrailingEdge: 0.05,
        ),
      ];

      // ... the first section out of view and the next one into the view at the
      // bottom
      visibleSections.value = [
        _headingPosition(
          'bar',
          itemLeadingEdge: 0.8,
          itemTrailingEdge: 0.85,
        ),
      ];

      expect(controller.currentlyReadSection, 'foo');
    });

    test(
        'marks the section "above" as active when scrolling back up from a previous section',
        () {
      final sections = [
        _section('foo'),
        _section('bar'),
      ];

      final controller = _createController(sections, visibleSections);

      // We scroll the second chapter to the bottom of the screen
      visibleSections.value = [
        _headingPosition(
          'bar',
          itemLeadingEdge: 0.8,
          itemTrailingEdge: 0.85,
        ),
      ];

      // We scroll it to the top post the threshold
      visibleSections.value = [
        _headingPosition(
          'bar',
          itemLeadingEdge: 0,
          itemTrailingEdge: 0.1,
        ),
      ];

      // We the section down to the bottom again (we scroll up the page)
      visibleSections.value = [
        _headingPosition(
          'bar',
          itemLeadingEdge: 0.95,
          itemTrailingEdge: 1,
        ),
      ];

      // We scroll it out of the view (we scroll up the page)
      // We're now in-between foo and bar (both not visible)
      visibleSections.value = [];

      expect(controller.currentlyReadSection, 'foo');
    });

    test('edge case: scrolling above first section', () {
      final sections = [
        _section('foo'),
      ];

      final controller = _createController(sections, visibleSections);

      // We scroll to the first section...
      visibleSections.value = [
        _headingPosition(
          'foo',
          itemLeadingEdge: 0.05,
          itemTrailingEdge: 0.15,
        ),
      ];

      // ... scroll up (section title is now at bottom of the viewport)
      visibleSections.value = [
        _headingPosition(
          'foo',
          itemLeadingEdge: 0.95,
          itemTrailingEdge: 1,
        ),
      ];

      // ...and scroll further up (the first section is now out of view)
      visibleSections.value = [];

      expect(controller.currentlyReadSection, null);
    });

    // TODO: Not sure if this test belongs here.
    // we need to test this since before there was no test for this behavior.
    // im not sure though if I originally didn't want to tie these tests to a
    // notion of a subsection i.e. make this more markdown document based (what
    // is the heading that we're in, doesnt matter what kind) instead of already
    // of already tying to to our model of section/subsection etc.
    // On the other hand it might still be best to do it like this.
    test('A subsection is marked as active correctly', () {
      final sections = [
        _section('foo', subsections: [
          _section('quz'),
          _section('baz'),
        ]),
      ];

      final controller = _createController(sections, visibleSections);

      // We scroll to the first section (its at the bottom)
      visibleSections.value = [
        _headingPosition(
          'foo',
          itemLeadingEdge: 0.9,
          itemTrailingEdge: 0.95,
        ),
      ];

      // We scroll down...
      visibleSections.value = [
        _headingPosition(
          'foo',
          itemLeadingEdge: 0,
          itemTrailingEdge: 0.05,
        ),
      ];

      // ... the first section out of view and the next one into the view at the
      // bottom
      visibleSections.value = [
        _headingPosition(
          'quz',
          itemLeadingEdge: 0.9,
          itemTrailingEdge: 0.95,
        ),
      ];

      // ... to the top
      visibleSections.value = [
        _headingPosition(
          'quz',
          itemLeadingEdge: 0,
          itemTrailingEdge: 0.05,
        ),
      ];

      // ... and out of the view
      visibleSections.value = [];

      expect(controller.currentlyReadSection, 'quz');
    });

    test(
        'regression test: When several sections scroll in and out of view (always at least one visible) then the right section is active',
        () {
      final sections = [
        _section('inhaltsverzeichnis'),
        _section('1-wichtige-begriffe'),
        _section('2-geltungsbereich'),
      ];

      final controller = _createController(sections, visibleSections);

      // We scroll to the first section
      visibleSections.value = [
        _headingPosition(
          'inhaltsverzeichnis',
          itemLeadingEdge: 0.95,
          itemTrailingEdge: 1,
        ),
      ];

      // We scroll down...
      visibleSections.value = [
        _headingPosition(
          'inhaltsverzeichnis',
          itemLeadingEdge: 0,
          itemTrailingEdge: 0.05,
        ),
        _headingPosition(
          '1-wichtige-begriffe',
          itemLeadingEdge: 0.9,
          itemTrailingEdge: 0.95,
        ),
      ];

      // ...and down
      visibleSections.value = [
        _headingPosition(
          '1-wichtige-begriffe',
          itemLeadingEdge: 0.15,
          itemTrailingEdge: 0.2,
        ),
        _headingPosition(
          '2-geltungsbereich',
          itemLeadingEdge: 0.9,
          itemTrailingEdge: 0.95,
        ),
      ];

      // ... now the first two sections are out of view
      // (but the text of the second section is still visible)
      visibleSections.value = [
        _headingPosition(
          '2-geltungsbereich',
          itemLeadingEdge: 0.6,
          itemTrailingEdge: 0.65,
        ),
      ];

      expect(controller.currentlyReadSection, '1-wichtige-begriffe');
    });

    test(
        'regression test: Being inbetween two sections (both headings not visible)',
        () {
      final sections = [
        _section('inhaltsverzeichnis'),
        _section('1-wichtige-begriffe'),
        _section('2-geltungsbereich'),
      ];

      final controller = _createController(sections, visibleSections);

      // We scroll to the first section
      visibleSections.value = [
        _headingPosition(
          'inhaltsverzeichnis',
          itemLeadingEdge: 0.95,
          itemTrailingEdge: 1,
        ),
      ];

      // We scroll down...
      visibleSections.value = [
        _headingPosition(
          'inhaltsverzeichnis',
          itemLeadingEdge: 0,
          itemTrailingEdge: 0.05,
        ),
        _headingPosition(
          '1-wichtige-begriffe',
          itemLeadingEdge: 0.9,
          itemTrailingEdge: 0.95,
        ),
      ];

      // ...down
      visibleSections.value = [
        _headingPosition(
          '1-wichtige-begriffe',
          itemLeadingEdge: 0,
          itemTrailingEdge: 0.05,
        ),
      ];

      // ... we're now between 1-wichtige-begriffe and 2-geltungsbereich
      visibleSections.value = [];

      expect(controller.currentlyReadSection, '1-wichtige-begriffe');
    });

    // TODO: We should make it an api contract that they will be always ordered
    // from the api that we consume (they should be ordererd already)
    test('regression test: Ordering of visible items inside ', () {
      final sections = [
        _section('foo'),
        _section('bar'),
        _section('baz'),
      ];

      final controller = _createController(sections, visibleSections);

      // We purposefully order the lower one first in this list to simulate
      // unordered values from the "visible sections" api we consume
      visibleSections.value = [
        _headingPosition(
          'baz',
          itemLeadingEdge: 0.95,
          itemTrailingEdge: 1,
        ),
        _headingPosition(
          'bar',
          itemLeadingEdge: 0.5,
          itemTrailingEdge: 0.6,
        ),
      ];

      expect(controller.currentlyReadSection, 'foo');
    });
  });
}

class TestCurrentlyReadingSectionController {
  final List<DocumentSection> _tocSectionHeadings;
  final ValueListenable<List<DocumentSectionHeadingPosition>>
      _visibleSectionHeadings;

  final ValueNotifier<DocumentSectionId> _currentlyRead =
      ValueNotifier<DocumentSectionId>(null);

  TableOfContentsController _tableOfContentsController;

  String get currentlyReadSection =>
      currentlyReadDocumentSectionOrNull.value?.toString();

  ValueListenable<DocumentSectionId> get currentlyReadDocumentSectionOrNull =>
      _currentlyRead;

  DocumentSectionId _getCurrentlyHighlighted() {
    final highlightedRes = _tableOfContentsController.documentSections
        .where((element) => element.shouldHighlight);
    if (highlightedRes.isEmpty) {
      return null;
    }
    final highlighted = highlightedRes.single;
    final subHighlightedRes =
        highlighted.subsections.where((element) => element.shouldHighlight);
    if (subHighlightedRes.isEmpty) {
      return highlighted.id;
    }
    return subHighlightedRes.single.id;
  }

  TestCurrentlyReadingSectionController(
    this._tocSectionHeadings,
    this._visibleSectionHeadings, {
    @required double threshold,
  }) {
    _tableOfContentsController = TableOfContentsController.internal(
        CurrentlyReadingSectionController(
          _tocSectionHeadings,
          _visibleSectionHeadings,
          threshold: threshold,
        ),
        _tocSectionHeadings,
        (sectionId) => Future.value());
    _tableOfContentsController.addListener(() {
      _currentlyRead.value = _getCurrentlyHighlighted();
    });
  }
}

final tocDocumentSections = [
  DocumentSection('inhaltsverzeichnis', 'Inhaltsverzeichnis', []),
  DocumentSection('1-wichtige-begriffe', '1. Wichtige Begriffe', []),
  DocumentSection('2-geltungsbereich', '2. Geltungsbereich', []),
  DocumentSection('3-verantwortlichkeit-und-kontakt',
      '3. Verantwortlichkeit und Kontakt', []),
  DocumentSection(
      '4-hosting-backend-infrastruktur-und-speicherort-fr-eure-daten',
      '4. Hosting, Backend-Infrastruktur und Speicherort für eure Daten', []),
  DocumentSection('5-deine-rechte', '5. Deine Rechte', [
    DocumentSection('a-recht-auf-auskunft', 'a. Recht auf Auskunft', []),
    DocumentSection(
        'b-recht-auf-berichtigung', 'b. Recht auf Berichtigung', []),
    DocumentSection('c-recht-auf-lschung', 'c. Recht auf Löschung', []),
    DocumentSection('d-recht-auf-einschrnkung-der-verarbeitung',
        'd. Recht auf Einschränkung der Verarbeitung', []),
    DocumentSection('e-recht-auf-widerspruch', 'e. Recht auf Widerspruch', []),
    DocumentSection('f-recht-auf-widerruf', 'f. Recht auf Widerruf', []),
    DocumentSection('g-recht-auf-datenbertragbarkeit',
        'g. Recht auf Datenübertragbarkeit', []),
    DocumentSection('h-recht-auf-beschwerde', 'h. Recht auf Beschwerde', []),
  ]),
  DocumentSection('6-eure-kontaktaufnahme', '6. Eure Kontaktaufnahme', []),
  DocumentSection(
      '7-unser-umgang-mit-euren-daten', '7. Unser Umgang mit euren Daten', []),
  DocumentSection(
      '8-account-nickname-und-passwort', '8. Account, Nickname und Passwort', [
    DocumentSection('a-registrierung-mittels-anonymen-accounts',
        'a. Registrierung mittels anonymen Accounts', []),
    DocumentSection(
        'b-registrierung-mit-e-mail-adresse--passwort-oder-googleapple-sign-in-ab-einem-alter-von-16-jahren-und-lter',
        'b. Registrierung mit E-Mail-Adresse & Passwort oder Google/Apple Sign In ab einem Alter von 16 Jahren und älter',
        []),
  ]),
  DocumentSection(
      '9-verarbeitung-der-ip-adresse', '9. Verarbeitung der IP-Adresse', []),
  DocumentSection('10-speicherdauer-und-speicherfristen',
      '10. Speicherdauer und Speicherfristen', []),
  DocumentSection(
      '11-verarbeitung-des-gewhlten-account-typs-und-des-bundeslandes',
      '11. Verarbeitung des gewählten Account-Typs und des Bundeslandes', []),
  DocumentSection('12-anonyme-statistische-auswertung-der-app-nutzung',
      '12. Anonyme statistische Auswertung der App-Nutzung', []),
  DocumentSection('13-push-nachrichten', '13. Push-Nachrichten', []),
  DocumentSection('14-instance-id', '14. Instance ID', [
    DocumentSection('firebase-cloud-messaging', 'Firebase Cloud Messaging', []),
    DocumentSection('firebase-crashlytics', 'Firebase Crashlytics', []),
    DocumentSection('firebase-performance-monitoring',
        'Firebase Performance Monitoring', []),
    DocumentSection('firebase-predictions', 'Firebase Predictions', []),
    DocumentSection('firebase-remote-config', 'Firebase Remote Config', []),
    DocumentSection(
        'googlefirebase-analytics', 'Google/Firebase Analytics', []),
  ]),
  DocumentSection('15-empfnger-oder-kategorien-von-empfngern',
      '15. Empfänger oder Kategorien von Empfängern', []),
  DocumentSection(
      '16-ssltls-verschlsselung', '16. SSL/TLS-Verschlüsselung', []),
  DocumentSection('17-videokonferenzen', '17. Videokonferenzen', []),
  DocumentSection('18-datenbertragung-in-drittlnder-auerhalb-der-eu',
      '18. Datenübertragung in Drittländer außerhalb der EU', [
    DocumentSection(
        'a-firebase-authentication', 'a. Firebase Authentication', []),
    DocumentSection('b-firebase-hosting', 'b. Firebase Hosting', []),
  ]),
  DocumentSection(
      '19-datenschutzbeauftragter', '19. Datenschutzbeauftragter', []),
  DocumentSection('20-vorbehalt-der-nderung-dieser-informationen',
      '20. Vorbehalt der Änderung dieser Informationen', []),
];
