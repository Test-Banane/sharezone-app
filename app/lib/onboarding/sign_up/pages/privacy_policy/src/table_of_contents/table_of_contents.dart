// Copyright (c) 2022 Sharezone UG (haftungsbeschränkt)
// Licensed under the EUPL-1.2-or-later.
//
// You may obtain a copy of the Licence at:
// https://joinup.ec.europa.eu/software/page/eupl
//
// SPDX-License-Identifier: EUPL-1.2

import 'package:common_domain_models/common_domain_models.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';

part './section_expansion.dart';

class DocumentSectionId extends Id {
  DocumentSectionId(String id) : super(id, 'DocumentSectionId');
}

class TableOfContents {
  final IList<TocSection> sections;

  TableOfContents(this.sections);

  TableOfContents manuallyToggleShowSubsectionsOf(DocumentSectionId sectionId) {
    return copyWith(
      sections: sections
          .replaceAllWhereMap((section) => section.id == sectionId,
              (section) => section.toggleExpansionManually())
          .toIList(),
    );
  }

  TableOfContents copyWith({
    IList<TocSection> sections,
  }) {
    return TableOfContents(
      sections ?? this.sections,
    );
  }

  TableOfContents changeCurrentlyReadSectionTo(
      DocumentSectionId currentlyReadSection) {
    return copyWith(
      sections: sections
          .map((section) =>
              section.notifyOfNewCurrentlyRead(currentlyReadSection))
          .toIList(),
    );
  }
}

extension ReplaceAllWhere<T> on IList<T> {
  Iterable<T> replaceAllWhereMap(
      Predicate<T> test, T Function(T element) toElement,
      {ConfigList config}) {
    return map((element) => test(element) ? toElement(element) : element,
        config: config);
  }
}

enum ExpansionMode { forced, automatic }

class ExpansionState {
  final bool isExpanded;
  final ExpansionMode expansionMode;

  ExpansionState({
    @required this.isExpanded,
    @required this.expansionMode,
  });

  ExpansionState copyWith({
    bool isExpanded,
    ExpansionMode expansionMode,
  }) {
    return ExpansionState(
      isExpanded: isExpanded ?? this.isExpanded,
      expansionMode: expansionMode ?? this.expansionMode,
    );
  }

  @override
  String toString() =>
      'ExpansionState(isExpanded: $isExpanded, expansionMode: $expansionMode)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExpansionState &&
        other.isExpanded == isExpanded &&
        other.expansionMode == expansionMode;
  }

  @override
  int get hashCode => isExpanded.hashCode ^ expansionMode.hashCode;
}

class TocSection {
  final DocumentSectionId id;
  final String title;
  final IList<TocSection> subsections;

  final ExpansionState expansionState;
  bool get isExpanded => expansionState.isExpanded;
  bool get isCollapsed => !isExpanded;
  bool get isExpandable => subsections.isNotEmpty;

  final bool isThisCurrentlyRead;
  bool get isThisOrASubsectionCurrentlyRead =>
      isThisCurrentlyRead ||
      subsections
          .where((subsection) => subsection.isThisOrASubsectionCurrentlyRead)
          .isNotEmpty;

  TocSection({
    @required this.id,
    @required this.title,
    @required this.subsections,
    @required this.expansionState,
    @required this.isThisCurrentlyRead,
  }) : assert(subsections
                .where((element) => element.isThisOrASubsectionCurrentlyRead)
                .length <=
            1) {
    if (subsections.isEmpty && isExpanded) {
      throw ArgumentError(
          '$TocSection cant be expanded if it has no subsections');
    }
  }

  TocSection toggleExpansionManually() {
    if (subsections.isEmpty) {
      throw ArgumentError();
    }
    return copyWith(
      expansionState: expansionState.copyWith(
        isExpanded: !isExpanded,
        expansionMode: ExpansionMode.forced,
      ),
    );
  }

  // TODO: Rename method (so its clear that it changes also its expansion
  // instead of only updating the currently read state)
  TocSection notifyOfNewCurrentlyRead(
      DocumentSectionId newCurrentlyReadSection) {
    final newSubsections = subsections
        .map((subsection) =>
            subsection.notifyOfNewCurrentlyRead(newCurrentlyReadSection))
        .toIList();

    TocSection updated = copyWith(
      isThisCurrentlyRead: id == newCurrentlyReadSection,
      subsections: newSubsections,
    );

    if (isExpandable) {
      updated = updated.copyWith(
        expansionState: _computeNewExpansionState(before: this, after: updated),
      );
    }

    return updated;
  }

  TocSection copyWith({
    DocumentSectionId id,
    String title,
    IList<TocSection> subsections,
    ExpansionState expansionState,
    bool isThisCurrentlyRead,
  }) {
    return TocSection(
      id: id ?? this.id,
      title: title ?? this.title,
      subsections: subsections ?? this.subsections,
      expansionState: expansionState ?? this.expansionState,
      isThisCurrentlyRead: isThisCurrentlyRead ?? this.isThisCurrentlyRead,
    );
  }

  @override
  String toString() {
    return 'TocSection(id: $id, title: $title, subsections: $subsections, expansionState: $expansionState, isThisCurrentlyRead: $isThisCurrentlyRead, isThisOrASubsectionCurrentlyRead: $isThisOrASubsectionCurrentlyRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TocSection &&
        other.id == id &&
        other.title == title &&
        other.subsections == subsections &&
        other.expansionState == expansionState &&
        other.isThisCurrentlyRead == isThisCurrentlyRead;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        subsections.hashCode ^
        expansionState.hashCode ^
        isThisCurrentlyRead.hashCode;
  }
}
