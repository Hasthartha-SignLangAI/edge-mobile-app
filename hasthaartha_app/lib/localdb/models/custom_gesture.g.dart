// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_gesture.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCustomGestureCollection on Isar {
  IsarCollection<CustomGesture> get customGestures => this.collection();
}

const CustomGestureSchema = CollectionSchema(
  name: r'CustomGesture',
  id: 7095443060850104453,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isTrained': PropertySchema(
      id: 1,
      name: r'isTrained',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    ),
    r'sampleCount': PropertySchema(
      id: 3,
      name: r'sampleCount',
      type: IsarType.long,
    ),
    r'samplesDir': PropertySchema(
      id: 4,
      name: r'samplesDir',
      type: IsarType.string,
    )
  },
  estimateSize: _customGestureEstimateSize,
  serialize: _customGestureSerialize,
  deserialize: _customGestureDeserialize,
  deserializeProp: _customGestureDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _customGestureGetId,
  getLinks: _customGestureGetLinks,
  attach: _customGestureAttach,
  version: '3.1.0+1',
);

int _customGestureEstimateSize(
  CustomGesture object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.samplesDir.length * 3;
  return bytesCount;
}

void _customGestureSerialize(
  CustomGesture object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeBool(offsets[1], object.isTrained);
  writer.writeString(offsets[2], object.name);
  writer.writeLong(offsets[3], object.sampleCount);
  writer.writeString(offsets[4], object.samplesDir);
}

CustomGesture _customGestureDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CustomGesture();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.isTrained = reader.readBool(offsets[1]);
  object.name = reader.readString(offsets[2]);
  object.sampleCount = reader.readLong(offsets[3]);
  object.samplesDir = reader.readString(offsets[4]);
  return object;
}

P _customGestureDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _customGestureGetId(CustomGesture object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _customGestureGetLinks(CustomGesture object) {
  return [];
}

void _customGestureAttach(
    IsarCollection<dynamic> col, Id id, CustomGesture object) {
  object.id = id;
}

extension CustomGestureQueryWhereSort
    on QueryBuilder<CustomGesture, CustomGesture, QWhere> {
  QueryBuilder<CustomGesture, CustomGesture, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CustomGestureQueryWhere
    on QueryBuilder<CustomGesture, CustomGesture, QWhereClause> {
  QueryBuilder<CustomGesture, CustomGesture, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CustomGestureQueryFilter
    on QueryBuilder<CustomGesture, CustomGesture, QFilterCondition> {
  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      isTrainedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isTrained',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      sampleCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sampleCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      sampleCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sampleCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      sampleCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sampleCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      sampleCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sampleCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      samplesDirEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'samplesDir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      samplesDirGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'samplesDir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      samplesDirLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'samplesDir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      samplesDirBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'samplesDir',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      samplesDirStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'samplesDir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      samplesDirEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'samplesDir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      samplesDirContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'samplesDir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      samplesDirMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'samplesDir',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      samplesDirIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'samplesDir',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      samplesDirIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'samplesDir',
        value: '',
      ));
    });
  }
}

extension CustomGestureQueryObject
    on QueryBuilder<CustomGesture, CustomGesture, QFilterCondition> {}

extension CustomGestureQueryLinks
    on QueryBuilder<CustomGesture, CustomGesture, QFilterCondition> {}

extension CustomGestureQuerySortBy
    on QueryBuilder<CustomGesture, CustomGesture, QSortBy> {
  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> sortByIsTrained() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrained', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy>
      sortByIsTrainedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrained', Sort.desc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> sortBySampleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleCount', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy>
      sortBySampleCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleCount', Sort.desc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> sortBySamplesDir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'samplesDir', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy>
      sortBySamplesDirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'samplesDir', Sort.desc);
    });
  }
}

extension CustomGestureQuerySortThenBy
    on QueryBuilder<CustomGesture, CustomGesture, QSortThenBy> {
  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> thenByIsTrained() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrained', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy>
      thenByIsTrainedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrained', Sort.desc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> thenBySampleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleCount', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy>
      thenBySampleCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleCount', Sort.desc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> thenBySamplesDir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'samplesDir', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy>
      thenBySamplesDirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'samplesDir', Sort.desc);
    });
  }
}

extension CustomGestureQueryWhereDistinct
    on QueryBuilder<CustomGesture, CustomGesture, QDistinct> {
  QueryBuilder<CustomGesture, CustomGesture, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QDistinct> distinctByIsTrained() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isTrained');
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QDistinct>
      distinctBySampleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sampleCount');
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QDistinct> distinctBySamplesDir(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'samplesDir', caseSensitive: caseSensitive);
    });
  }
}

extension CustomGestureQueryProperty
    on QueryBuilder<CustomGesture, CustomGesture, QQueryProperty> {
  QueryBuilder<CustomGesture, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CustomGesture, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CustomGesture, bool, QQueryOperations> isTrainedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isTrained');
    });
  }

  QueryBuilder<CustomGesture, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<CustomGesture, int, QQueryOperations> sampleCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sampleCount');
    });
  }

  QueryBuilder<CustomGesture, String, QQueryOperations> samplesDirProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'samplesDir');
    });
  }
}
